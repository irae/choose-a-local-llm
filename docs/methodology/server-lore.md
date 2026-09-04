# Server lore — verified failure modes and quirks

Read this before touching a server and before blaming a model for a
stall. Everything here was hit at least once.

## mlx_lm.server

- **Dead-thread trap**: the generation thread can die (Metal OOM) while
  the process lives and `/health` returns 200; the client hangs forever.
  Any script talking to an mlx server watches the server log for the
  death signature ("Insufficient Memory", "Command buffer execution
  failed", a Traceback) and exits with code 42 immediately. Exit 42
  means: the last printed row is the ceiling.
- **Prompt-cache pool**: by default the server pools several distinct KV
  caches (multi-GB each at depth) and acts like a memory leak across
  differently-shaped requests. Always serve with
  `--prompt-cache-size 2`.
- A single request can crash on a Metal resource limit
  (`[metal::malloc] Resource limit ... exceeded`) while the server stays
  "healthy"; that request then hangs forever under a retry loop.
  Restart the server and resume.
- **Check the server log before blaming the model** when a run stalls
  far longer than its budget allows.
- For short runs, depth sweeps, or runs expected to end in OOM, run the
  memory probe (`benchmarks/mem-watch.sh` or
  `tools/sweeps/mem-watch-fast.sh`) at a 20-30 s interval so the final
  pre-OOM samples exist; it separates swap/compression events from
  compute slowdowns. Thermal vs memory-pressure for long-run slowdowns
  is an OPEN question — evidence exists for both.

## LM Studio (verified 2026-08-29/30, LM Studio 0.4.23 / mlx-engine 1.10.1)

Use `tools/sweeps/creep_lmstudio.py` for LM Studio depth sweeps; set
`N_CONTEXTS` for N alternating contexts. Full forensic record:
`benchmarks/bench4/lmstudio-forensics.md`.

- **Some MLX architectures refuse a pinned context window, and auto-fit
  wins.** Every path is ignored — CLI `-c`/`--context-length`, the REST
  load body, the per-model config file, the app default. Auto-fit
  computes the window from `iogpu.wired_limit_mb` instead. `--parallel`
  IS honored. `lms ps` shows the live values — check it, never guess.
  Consequence: LM Studio ceilings use the compression-onset criterion
  ([context creep](./context-creep.md)). For the architecture and the
  window measured on the reference setup, see its
  [runtime lore for that model](../setups/m1-max-32gb/benchmarks/gemma-4-12b-it.md#runtime-lore-for-this-model).
- **`lms load --estimate-only` is untrustworthy**: it prices weights
  only ("Confidence: LOW") and ignores KV. Do not use it as a fit
  check. MLX allocates KV lazily, so a load that succeeds proves
  nothing about deep-context safety.
- **JIT traps**: with JIT loading on, any request naming an unloaded
  model silently loads it with fresh auto-fit; a JIT-loaded model
  auto-unloads after the TTL (1200 s here). For runs, always load
  explicitly with `lms load` and verify with `lms ps` before starting.
  Loading while another instance is resident creates a duplicate
  (`:2`) instance — unload first.
- **A lost run may be a kernel panic, not an OOM.** This Mac panicked
  in `IOGPUFamily` on 2026-09-03: `"completeMemory() prepare count
  underflow" @IOGPUMemory.cpp:492`, panicking task `node`. The panic
  log's own accounting showed memory was FINE (compressor at 3%, swap
  OK), so it was not memory exhaustion — it is a reference-counting
  fault in Apple's GPU memory manager, reachable from ordinary GPU
  work. A panic takes the whole machine, so it leaves the same evidence
  as a silent death: no server log, no session log, no row. Before
  calling any lost run an OOM, check
  `ls -t /Library/Logs/DiagnosticReports/*.panic | head`. Suspected
  trigger, unproven: repeated load/unload churn in LM Studio with a
  client connecting between cycles. Mitigation is already the rule —
  load once per session, quit the app rather than cycling it.
- **LM Studio cannot serve without Electron, and any `lms` command
  revives it.** `LM Studio --run-as-service` is the headless mode: no
  menubar, but it still runs the Electron Framework, an Electron GPU
  helper, and `~/.cache/lm-studio/.internal/utils/node`. The engine is
  Electron-hosted and `lms server start` only toggles the HTTP listener
  inside it. So quitting the app does NOT keep it gone — a later
  `lms ps` prints "Waking up LM Studio service..." and brings the whole
  stack back, GPU helper included. After quitting, verify with
  `pgrep -fl "LM Studio"`, never with `lms`. This matters because the
  2026-09-03 kernel panic named `node` with 40 threads, which fits that
  internal node helper.
- **`lms load` does not start the HTTP server, and `lms ps` will not
  tell you.** A loaded model shows `IDLE` with its context and parallel
  slots in `lms ps` whether or not anything can reach it. Every client
  request then fails with a bare `Connection error.` — no hint that the
  server is the problem. Check `lms server status` and start it with
  `lms server start`. Verify the endpoint itself before a run:
  `curl -s http://127.0.0.1:1234/v1/models`. Two commands, because the
  two states are independent: the model is loaded, and the server is
  listening.
- **`/v1/completions` (raw prompt, no chat) is broken on this build.**
  It returns garbage text and streams in one sub-5 ms burst; any tok/s
  computed from it is nonsense. Use `/v1/chat/completions`, growing a
  single user message append-only — that streams correctly and reuses
  the prompt cache (confirmed via `cached_tokens` climbing step to
  step).
- **Read the server log, not client-side HTTP timing, for ground
  truth**: `~/.cache/lm-studio/server-logs/<YYYY-MM>/<date>.N.log`
  (latest file in the glob) has per-request `Prompt cache restore:
  cached_tokens=... uncached_tokens=...`, `Prompt processing progress`
  ticks, and on load a `context_fit` line with the full memory-budget
  math. The sweep scripts tail it for a crash-signature watchdog
  (`[ERROR]`, `OutOfMemory`, `crashed`, `Traceback` — widen the list
  the first time a real crash shows a different string).
- **The disk-backed prompt cache** (separate from GPU memory) caps at
  ~25% of free disk and evicts constantly once full (`VLM prompt cache
  disk usage: ... lifetime_evicted_mib=...`). Within a sweep, restores
  keep working — but at extreme depth an eviction forces a silent full
  recompute (`cached_tokens=0` with a huge uncached count) that
  inflates the step's wall time; the decode tok/s stays valid (measured
  from post-prefill streaming). Freeing disk raises the cap.
- **Test the real response for thinking; never trust the capabilities
  list.** `/api/v0/models`' `capabilities` list does not tell you what a
  model store entry does. One entry can return populated
  `reasoning_content` for a plain chat request with no toggle that works
  (`chat_template_kwargs: {enable_thinking: false}` and every other shape
  change nothing), while another entry for the same weights answers with
  thinking off and cannot turn it on. Probe each entry, and record the
  entry name with the result. For the entries measured on the reference
  setup, see its [runtime lore for that model](../setups/m1-max-32gb/benchmarks/gemma-4-12b-it.md#runtime-lore-for-this-model).
- **MLX multi-slot only works through LM Studio**, not plain
  `mlx_lm.server` (which needs a second full weight copy for concurrent
  decode). LM Studio's engine added continuous batching for text models
  in 0.4.2.
- **A curated Hub identifier is not necessarily different weights.** A
  curated id can resolve to another repository's container. Check
  `hub/models/<id>/manifest.json` before assuming. For the example
  measured on the reference setup, see its [runtime lore for that model](../setups/m1-max-32gb/benchmarks/gemma-4-12b-it.md#runtime-lore-for-this-model).

## The machine

- The owner's per-process firewall silently blocks new binaries'
  network access — suspect it first for any fresh-process hang
  (Node.js usually passes; Python often does not).
- `lms` lives at `~/.cache/lm-studio/bin/lms`, not on `PATH`.
- Server port for everything: 8081 (the harness scripts hardcode it).
