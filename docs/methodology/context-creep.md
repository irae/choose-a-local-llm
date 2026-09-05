# Context creep — decode speed against USED context

Allocation is storage; used tokens are what decode pays for. This test
finds the depth curve, the floor, and the "capped by" verdict for a
config. Common rules and the run loop apply
([common rules](./common-rules.md), [checklist](./checklist.md)).

## Requirements

- The server for ONE config, warmed up, with its log in a file.
- One command per sweep, and one output file. The runner samples memory
  itself and watches liveness itself, so a sweep needs no second process
  beside it — see [The monitor](#the-monitor) below.
- Append-only prompt growth (prompt-cache rule) — the sweep scripts in
  `tools/sweeps/` already do this.
- The pause rule: **creep slowly, ~25 s between depth steps.** The pause
  simulates real use — an agent's model waits on the user and on tool
  runs between requests — and it gives macOS time to compress other
  memory, which raises the measured ceiling (verified on the reference
  setup: about 2K extra tokens on a 35B MoE MLX config). A no-pause sweep
  understates the ceiling a real harness reaches.

## Speed measurement rules

These rules belong to the speed test only. The common rules still
apply on top of them.

- **Fixed prompts**, temperature 0, fixed token count (we use 256),
  identical across every model and config:
  - py: `Write a Python function that parses ISO dates.`
  - js: `Write a JavaScript function that deep clones an object.`
  Two languages matter: speculative-decoding acceptance differs by
  language, so a single-prompt benchmark can mislead.
- **Read the server's own timings, not wall clocks**, where available.
  llama-server: `.timings` from `/completion` (`prompt_per_second`,
  `predicted_per_second`, `draft_n`, `draft_n_accepted`).
  mlx_lm.server has no per-request timings — measure decode by
  streaming and timing the token chunks. LM Studio: the server log is
  ground truth ([server lore](./server-lore.md)).
- **Reuse the server's prompt cache perfectly.** Grow prompts
  append-only: each request's prompt = the previous prompt + the
  server's own reply + the new text. Never insert before an existing
  prefix, and never use a fixed suffix that later steps insert before.
  llama-server reuses any longest common prefix; mlx_lm.server only
  reuses strict extensions. Verify reuse via llama's
  `.timings.prompt_n` (must be the delta, not the total).
- **With a drafter, record draft acceptance beside every tok/s.** A
  speculative-decoding number without its acceptance rate cannot be
  compared with a later run (research run 2 could not reproduce a
  published 45.0 py tok/s for that reason alone). Sweep the draft
  depth per model AND per mode: the optimum shifts with output style
  (thinking on/off) and with depth.

## The KV cache type decision

Decided per model, by research, then by a short creep, before any full
sweep. The policy (which types are candidates) is
[common rules](./common-rules.md), rule 4. The procedure, in order:

1. **Research the cache quality first.** Look for measured evidence
   that q8_0 KV is near-identical to f16 for THIS model: the quant
   publisher's own grading (unsloth grades its weight quants with
   KL-divergence graphs; cache-type graphs come from community
   benchmarks such as the localbench KL study), or a KL or
   benchmark comparison with the method shown. Trust it when the
   proof is there. Record the source beside the config. Some model
   families stay near-identical at q8_0 (KL under 0.04 in community
   measurements); others lose far more, and their MoE variants lose
   the most. Do not assume which group a model is in.
2. **Short creep, both types, to 32K.** Below 32K a config is not
   useful, so 32K is the smallest depth that decides anything.
   Same command, only the cache types change. Record decode tok/s
   and wired memory at 4K and 32K for each type. The short creep is
   the steps below with `DEPTH_LIST="4096,8192,16384,24576,32768"`.
3. **Predict the fit.** KV cost per token is linear:
   `kv_per_token = (wired_32k - wired_4k) / 28672`. A type fits at
   a target context when
   `wired_4k + kv_per_token × (target - 4096) + 1500 MB ≤ iogpu.wired_limit_mb`.
   The target is the model's trained window or the depth the
   short creep already shows is the speed floor, whichever is
   smaller.
4. **Pick.** f16 when it fits at a useful context AND is faster at
   32K, or when step 1 says q8_0 costs this model quality. q8_0
   when f16 does not fit at a useful context; a slower cache that
   holds the context beats a faster one that does not. When the
   two curves are within 10% at 32K and both fit, q8_0.
5. **Full creep on the pick.** When the prediction is not decisive
   (the fit is within the margin, or the curves cross), run the
   full creep on both; a creep is cheap next to a wrong published
   row. Publish the pick, and note the other type's 32K numbers.

The type can dominate everything else: on one dense 12B model on the
reference setup, q8_0 fell under the floor by 16K while f16 was 3.2x
faster there, still usable at 131K, and fit at the model's full
window. q8_0 can also lower MTP draft acceptance (one MoE model: 81% →
68%). The evidence is in that setup's report.

## How a sweep runs

Read this once and the rest of the page is detail.

1. Prepare the machine: [checklist](./checklist.md), "Before the run".
2. Start the server for ONE config, and send its log to a file.
3. Warm it up with one small request.
4. Run the one command, and keep its whole output:

```bash
DEPTH_LIST=4096,8192,16384,24576,32768,49152,65536 \
MODEL=<the id the server answers to> \
SWEEP_BASE=http://127.0.0.1:8081 \
python3 tools/sweeps/creep_llama.py > /tmp/<config>-creep.tsv 2>&1
```

   On `mlx_lm.server` add `SERVER_LOG=<the server log>`, so the runner
   sees the death signature.
5. Watch the file grow. Every line is one step row or one event.
6. Read the verdict from the last line and the exit code.

The columns, in order:

| Column | What it says |
| --- | --- |
| `context` | Which round-robin context: A, B, ... |
| `depth_tokens` | Used context at this step |
| `decode_toks` | Decode speed. This is the published number |
| `wired_mb` | Wired memory. The meter that cannot lie |
| `free_mb` | Free memory. Read its shape, never its level |
| `swap_delta_mb` | Swap used now, minus swap used at the start |
| `compress_pages` | Pages compressed since the step before |
| `decompress_pages` | Pages decompressed since the step before |
| `step_seconds` | Wall time of the step |

The verdict, from the last line:

| Last line | Exit | Verdict |
| --- | --- | --- |
| `STOP: below N tok/s at depth D` | 0 | **speed**. The ceiling is the deepest row at or above the floor |
| `STOP: request failed ...` | 42 | **OOM**, when the server was still fast. The ceiling is the last good row |
| `STOP: silent halt, no tokens ...` | 42 | **OOM**. The server answered with nothing |
| `STOP: swap grew N MB ...` | 42 | **mem**. Every number past the last good row times the swap file |
| `STOP: N or more pages compressed ...` | 42 | **mem**. Compaction onset; the last clean row carries the tok/s |
| `STOP: generation thread died in <log>` | 42 | Dead server, not a ceiling. Restart and run it again |
| `STOP: server dead. The step gave nothing ...` | 42 | The same, found by the probes instead of the log |
| `no ceiling found up to D` | 0 | **window**, or no ceiling in the swept range |

The site publishes the stable value only: the deepest depth that still
served correctly, with its tok/s. The death point stays in the run log.

## The monitor

**A sweep needs no external memory watcher. A scoring run does.**

The runner reads `vm_stat` and `vm.swapusage` after every step and
writes what it read into the row. So the memory evidence sits beside the
tok/s it explains, at the same instant, in one file. An external watcher
samples on its own timer and writes a second file that somebody must
line up by wall clock — which is the manual step this method used to
ask for, and the step agents skipped.

The runner also owns the stop conditions that watcher was there to
serve: swap growth, sustained material compaction, the floor, a silent
halt, a failed request, and a dead server.

Keep the external watcher for **scoring runs** — EvalPlus, Mendel,
polyglot. Those harnesses sample no memory at all and run for hours, so
`benchmarks/mem-watch.sh` is the only memory record they get. Start it
as [the checklist](./checklist.md) step 6 says.

Liveness is one signal, not three. `/health` stays 200 after an
`mlx_lm.server` generation thread dies, so no sweep tool reads it. The
runner watches the server log for the backend's death signature, and it
probes ONE real completion when a step goes SILENT for `STALL_S`
(default 600 s).

**Silence, not slowness, starts a probe.** The streaming backends
(`mlx_lm.server` and LM Studio) beat a heartbeat into the runner for
every chunk they send, so a step that still produces tokens never
stalls. Only a silent phase can — a prefill, a full recompute, or a dead
generation thread. The raw llama-server completion path does not stream,
so there the whole step is silent and the clock runs from the start of
the request.

**One failed probe is a suspicion, not a verdict.** All three servers
hold one slot, so a probe sent while a step is in flight queues behind
it and times out exactly like a probe to a dead server. The runner
therefore polls the step and the probe together, and it drops the probe
the moment the step answers or sends a chunk again. It calls the server
dead only after two probes fail, each after its own silent `STALL_S`. A
silent step gets about `2 * (STALL_S + PROBE_TIMEOUT_S)` to prove it
lives — 30 minutes on the defaults — and then the sweep exits 42.

A probe that finds the server alive still takes a cache slot, so the
runner warns that the next step can re-read its prompt and read slow.

**The one case the probe cannot tell apart:** a prefill that sends
nothing for longer than that whole window. The runner would call a live
server dead. If a config prefills that slowly, raise `STALL_S` for it,
and record the value you used beside the sweep — a ceiling measured with
a changed `STALL_S` must say so.

## Steps

0. On llama-server, decide the KV cache type first
   ([the decision](#the-kv-cache-type-decision)).
1. Grow a prompt in steps: 4K, 8K, 16K, 24K, 32K, then 16K steps.
2. Measure decode tok/s at each depth (server timings, or streamed
   chunks where the server has none). The runner writes one row per
   step, with the memory counters of that same step beside the speed.
   With a drafter, record draft acceptance beside every tok/s.
3. Stop at the first reading under the usability floor (ours: 8 tok/s),
   at OOM, or at the model's trained/max context — never earlier. **A
   sweep that stops at an arbitrary depth has not found a ceiling — it
   has just stopped.** Record "no ceiling found up to `<max>`" only
   after the sweep actually reached that number.
4. Read the memory columns of the same row before you trust a slow
   step: `wired_mb` first, then `swap_delta_mb`, `compress_pages` and
   `decompress_pages`. Free memory is the wrong meter (see the pitfalls
   below). The runner stops by itself on swap growth and on material
   compaction that speed does not recover from; a step that shows either
   and keeps going is still a step to distrust.
5. Verdict, one of: **speed** (drops under the floor), **OOM** (dies
   while still fast), **window** (the model's own limit arrives first),
   or **mem** (the machine compacts or swaps before any of those
   arrives; on LM Studio it is the criterion, below).
6. Record on every surface; the floor — not the window — is where the
   harness compaction threshold belongs.

## LM Studio: the compression-onset criterion

Context length cannot be pinned on LM Studio for some MLX models
(auto-fit always wins — [server lore](./server-lore.md)), so the raw
window is a loader estimate, not a measurement. For LM Studio configs:

- **The ceiling is the FIRST depth step whose row shows material
  compression or swap**: `compress_pages` plus `decompress_pages` at or
  above `COMPACT_PAGES` (default 200 — hundreds of pages, not single
  digits), or any growth in `swap_delta_mb`.
- The reported tok/s comes from the last clean step before onset.
- The context-window column keeps the auto-fit estimate, flagged as a
  loader estimate; the trained max goes in a footnote.
- The engine stays functional well past onset — that functional range is
  worth a note for harness use, but it is not the ceiling.

## Multi-context (multi-agent) configs

Reported tok/s comes from ONE slot decoding alone, not all slots
decoding at once. Slots are parallel *contexts*, not parallel *use*: a
sub-agent's slot holds its place while idle, but a main agent and a
sub-agent rarely generate at the same instant. Depth-sweep the single
slot exactly as any other config; the other slots stay loaded but idle.
For N alternating contexts use `N_CONTEXTS` on the backend's creep
script. Round-robin works on all three backends: `mlx_lm.server` holds
several distinct KV caches when started with `--prompt-cache-size` at
least as large as `N_CONTEXTS`.

## The scripts

One command per backend, all sharing `tools/sweeps/creep.py`, which owns
the method: the 25-second pause as a DEFAULT, append-only growth,
round-robin contexts, memory sampling, liveness, and the stop
conditions. Each backend file holds only its endpoint, its request
shape, how it reads speed, and its two liveness parts. Every script
prints its own header with `--help`, and every environment variable it
reads is documented there.

- `tools/sweeps/creep_llama.py` — llama-server. `ENDPOINT=completion`
  (default) is raw and comparable with every published number here;
  `ENDPOINT=chat` is the path a harness uses. llama-server defaults
  `enable_thinking` to TRUE on the chat path, so set `THINKING=off`
  when that is what you mean.
- `tools/sweeps/creep_lmstudio.py` — LM Studio. Chat endpoint only.
- `tools/sweeps/creep_mlx.py` — `mlx_lm.server`. Set `SERVER_LOG`; this
  backend's generation thread can die while `/health` stays green.

Stop conditions and their defaults, all overridable by environment
variable: the floor (`FLOOR_TOKS`, 8 tok/s), swap growth above 1 MB,
material compaction (`COMPACT_PAGES`, 200 pages) on three steps in a row
without speed recovering against the previous step, a silent halt, a
failed request, and a dead server (silence for `STALL_S`, 600 s, then a
probe with `PROBE_TIMEOUT_S`, 300 s; two failed probes end the sweep).
Compaction under `COMPACT_PAGES` in one step is noise on a busy machine
and does not count.

## Do not try these — see git history

- **Parallel slot sweeps.** `llama_sweep_slot.py` used llama.cpp's
  `id_slot` to sweep one slot of a parallel server. The project measures
  round-robin instead: separate sessions keeping their own cache is the
  real shape, and parallel slots do not fit sub-agent use. Deleted
  2026-09-04.
- **A "slow" script beside a fast one.** `mlx_sweep_slow.py` differed
  from `mlx_sweep.py` by three lines and defaulted its pause to ZERO, so
  its name asserted behaviour its code did not have. Slow creep is now
  the default and cannot be lost by picking the wrong file. Deleted
  2026-09-04.
- **`sweep-one.sh` and `ceilings.sh`.** Both hardcoded a scratchpad path
  from a long-dead session and could not run. Deleted 2026-09-04.
- **LM Studio's `/v1/completions`.** Returns garbage on this build and
  streams the whole reply in one burst with no per-token pacing —
  verified 2026-08-29. Use chat completions there.

## Known pitfalls

- **Allocation is not depth.** Serving `-c 262144` proves the KV fits;
  it says nothing about decode speed at 262144 USED tokens. Reading one
  as the other produced a wrong "this row is stale" claim in run 2.
- **Allocating far more context than the sweep will reach** costs memory
  for nothing and can push the machine into compaction.
- **Free memory is the wrong meter.** Read `wired_mb`
  ([memory ceiling](./memory-ceiling.md) says why).
