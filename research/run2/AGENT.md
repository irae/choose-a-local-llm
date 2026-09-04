# Research run 2 — runtime improvements (Mac, in-depth)

You are a research-and-experiment agent on the Mac. Read this file,
`state.md`, `../run1/` (its diagnoses feed this run), then
`results/*.md` — three web-research reports gathered by the
coordinator (2026-09-03) and `results/web-upstream-status.md`, the
version and issue-status check of 2026-09-04. All with sources. Write all prose in ASD-STE100
Simplified Technical English. `AGENTS.md` ground rules apply, plus:
NO model downloads and NO destructive config changes until the owner
approves a filtered experiment list. Your first deliverable is that
list.

## Why

Run 7 showed serving-stack failures masquerading as model quality:
the Gemma-12B newline flood (three ~30 rows, zero commits), the mlx
dead-thread Metal OOM, the Qwen3.8 26624-token window, the llama.cpp
MTP drafter breaking the backend, and the dagger-sweep OOM. The goal
is what the first commits of this repo did for serving configs: make
every model complete its runs, so a real user hitting a fluke can
restart and keep working.

## How to work

1. Verify locally what the web reports claim (versions, templates,
   configs) — the reports are leads, not truth. Add your own research.
2. Merge with `../run1/results/` diagnoses (session-log evidence).
   Read `../run1/state.md` to its end: its session close reverses two
   earlier conclusions, and the later text wins.
3. Propose a ranked experiment list to the owner. Iterate: agree,
   test, evaluate, record. Only then change published configs.
4. Prepare the machine with the cold-start sequence in
   `docs/methodology/checklist.md` step 4. Wired memory is the meter;
   free memory drops by the model's size on first load and stays
   there. Load each model ONCE per session and quit the LM Studio app
   between models: repeated load/unload churn kernel-panicked the Mac
   in run 1. After any lost run, check
   `/Library/Logs/DiagnosticReports/*.panic` before calling it an OOM.
5. Archive every session log with `tools/archive-evidence.sh` before
   a session closes. Nine of seventeen Mendel rows have no log left;
   do not add to that number.

## Threads and starting alternatives (err wild; filter later)

### A. Model containers — get the download right

- Verify every local GGUF's embedded template (`gguf_dump.py` →
  `tokenizer.chat_template`) and every MLX repo's
  `tokenizer_config.json` against the base model's template. Wrong
  templates break tool calls and leak thinking tags.
- llama-server: test `--jinja` on/off per model; try
  `--chat-template-file` with community-fixed templates (Qwen 3.x
  think-tags; Gemma has no official tool role — see
  `results/web-quant-and-models.md`).
- *Template date check.* Two of the three Gemma-12B newline floods
  contain only newlines and `<|channel>`. That token is correct: it
  opens Gemma 4's thought channel and should be followed by `thought`.
  So the flood is a thought channel that opens and never proceeds,
  which is the upstream Gemma-4-12B thought-loop (HF discussion 41,
  closed by Google with a chat-template fix merged 2026-07-15, and
  llama.cpp PR 21343 of 2026-04-03 fixing Gemma 4 newline
  tokenization). Check the template and conversion dates of every
  local Gemma-4 container against those two dates. Detail in
  `research/run1/results/backend-diagnosis.md` and
  `results/web-upstream-status.md`.
- Check whether our Gemma-4 MLX quants have the confirmed
  quantized-PLE defect (all HF mlx-community Gemma-4 quants reported
  broken; a fix repo exists). Compare `config.json` quantization
  blocks against a known-good reference.
- M1 Max instruction sets: `dotprod` yes, `i8mm` NO (M2+). Check
  `sysctl -a | grep hw.optional` and whether any of our GGUFs or
  build flags assume i8mm. Q4_0 online repacking targets the CPU
  path — measure whether it matters at all for our GPU-only runs.
- KV cache: never Q4 (large silent output drift); Q8 or f16 only.
  Audit our published configs for this.
- Pin exact HF revisions for every model file — quant makers replace
  files silently.

### B. Bonsai configs — thinking OFF, and q8 KV on the fork

The published choose-a-local-llm tables benchmark Bonsai mlx with
thinking OFF (its best EvalPlus row, 0.927/0.902); the Mendel runs
were scheduled at "low", which the stack cannot even reach. Owner
decision (2026-09-03): try thinking OFF for Bonsai Mendel runs — it
matches the published config and sidesteps the unreachable-low
problem. On the prism fork, also try q8_0 KV instead of the
calibrated q4 KV (q4 KV silently drifts output — see the research),
at reduced context if memory demands. Fix the MLX serving config too,
not only the fork.

### C. Re-quantization — make better local builds

- Re-quantize one model from original weights with
  `mlx_lm.convert -q --q-bits 4 --q-group-size 32
  --quant-predicate mixed_4_6` and A/B against the mlx-community
  download (EvalPlus smoke + a short Mendel-style task).
- Wilder: `mlx_lm.dwq` (distilled quantization, biggest reported
  quality gain) on Bonsai or Qwen3.8.
- A/B K-quant vs IQ-quant decode speed on the M1 Max GPU (IQ reported
  3.5x slower on Apple GPUs).

### D. Gemma-12B newline flood (LM Studio MLX)

Upstream facts: Gemma-4 has a confirmed model-level repetition
collapse (44-60% repro on long agent prompts, present in F16 —
repeat_penalty does not help); LM Studio's bundled Gemma-4 template
crashes on tool calls (fix macro in their tracker #2012); the MLX
engine ignores `enable_thinking:false`, the set context length, and
mishandles stop sequences. Alternatives, re-ranked by the
coordinator on 2026-09-04 after run 1 closed:

1. **A/B the same replay on llama-server (GGUF).** Run 1 proved the
   vetted llama-server Gemma-12B command serves with the MTP drafter
   at 8192, and its replay kit (`../run1/results/replay-probe.sh`,
   `count-replay.py`, the archived 3909-character prompt) reproduces
   the loop on LM Studio by call 11-40. One replay per backend
   separates model from MLX path. Do this first; everything else in
   this section depends on the answer.
2. **Date-check the containers.** Google closed the 12B thought-loop
   discussion with a chat-template fix merged 2026-07-15, and llama.cpp
   PR 21343 (2026-04-03) fixed Gemma 4 newline tokenization. Compare
   the local GGUF conversion date and both templates (GGUF embedded,
   LM Studio bundled) against those dates. See section A.
3. Disable thinking in the LM Studio UI (not the API) and re-test.
   `docs/methodology/server-lore.md` says thinking is always on for
   `gemma4_unified`; this tests whether the UI switch reaches it.
4. Apply the template fix macro; watch server logs for the Jinja
   error right after a failed-edit turn.
5. Harness-side stop on repeated calls — section I owns this.
6. Trim tool-schema verbosity; sanitize failed-edit error text before
   feeding it back (its repeated structure may seed the loop).
7. Compare LM Studio's MLX engine against upstream `mlx_lm.server`.
   They are not the same build: LM Studio pins mlx 0.32.0 and an
   unreleased mlx-lm commit 13 ahead of v0.31.3, so a difference can
   be the engine version, not the wrapper.
If nothing works, propose marking the Gemma-12B x LM Studio x agent
combination unsupported (feeds run 1 goal 2).

**Settled by run 1 (2026-09-04).** The loop is NOT machine state. A
full-length replay on a freshly rebooted, quiet, zero-swap machine
looped: 71 calls, 30 distinct, 37 identical in a row, against the
original 130 / 30 / 72. The repeated call was `bash {"command": 4}`,
an integer where a string belongs; the original looped on `ls -F_r`.
Both are malformed calls the model re-emits after pi rejects them.
The floods are the thought channel opening (`<|channel>` is the
correct token) and never proceeding. Detail in
`../run1/results/invalid-runs.md` and `backend-diagnosis.md`.

**Run 1 findings that bear on this section (all committed to master).**
Run 1 hit LM Studio hard while setting up its goal-3 trial and stopped,
handing the parameter question here. What it established:

- **The Mac kernel-panicked, and it was not an OOM.**
  `"completeMemory() prepare count underflow" @IOGPUMemory.cpp:492`,
  kext `com.apple.iokit.IOGPUFamily`, panicking task `node`. The panic
  log's own accounting shows memory was fine: compressor at 3%, swap
  OK. Context was repeated LM Studio load/unload of
  `google/gemma-4-12b` with a client connecting between cycles. Not
  reproduced on purpose. See `research/run1/results/backend-diagnosis.md`
  and `docs/methodology/server-lore.md`.
- **LM Studio cannot serve without Electron.** `--run-as-service` is
  the headless mode and still runs the Electron Framework, an Electron
  GPU helper, and `~/.cache/lm-studio/.internal/utils/node`. The
  panicking task was `node` with 40 threads, which fits that internal
  helper. This matters for alternative 6, comparing LM Studio's MLX
  wrapper against upstream `mlx_lm.server`: the wrapper is not a thin
  layer, it is a separate process tree.
- **Any `lms` command revives the whole stack.** Quitting the app is
  not enough; a later `lms ps` prints a waking-up message and restarts
  Electron and the GPU helper. Verify with `pgrep -fl "LM Studio"`,
  never with `lms`. A status check during a run can put a second
  process on the GPU.
- **`lms load` does not start the HTTP server, and `lms ps` does not
  reveal it.** A loaded model reads `IDLE` with context and slots while
  nothing can reach it; clients get a bare `Connection error.` Check
  `lms server status` and curl `/v1/models`.
- **Gemma-12B's tool-call record, from the session logs.** 117 errors
  in 166 calls across three runs, 70.5%, the worst of any local model.
  Its low-guided run made 130 calls with only 30 distinct, including
  one invalid command (`ls -F_r`) repeated 72 times consecutively and
  88 times in total. That is the same failure family as the newline
  flood: the model emits a broken thing and then repeats it. See
  `research/run1/results/tool-call-trial.md`.
- **The MLX Bonsai on upstream `mlx_lm.server` was clean** on the same
  short probes run minutes later: 4/4 correct, one tool call each, no
  swap growth, no crash. That is a data point for alternative 6 —
  upstream MLX behaved where the LM Studio path did not.

Run 1 owns none of this section. It is blocked here and will not retry
the Gemma-12B x LM Studio combination.

### E. mlx_lm.server dead thread and OOM

Upstream: confirmed open bug — /health never checks the generation
thread (issues 1505/1390/854; unmerged PRs 1513/1514/1791).
Alternatives: `--prompt-cache-bytes` cap (4-6 GB); a watchdog that
probes a REAL completion, not /health (our monitors already check
output growth — unify); cherry-pick the unmerged PRs locally; a
`threading.excepthook` → `os._exit()` wrapper so the process dies
honestly; periodic `mx.clear_cache()`; `--max-kv-size` is in the
library but not exposed by the server (could patch).

**Status 2026-09-04.** mlx-lm 0.31.3 is still the latest release;
issues 1505/1390/854 are open and PRs 1513/1514/1791 are unmerged, so
no upgrade fixes the green-health dead thread. The 26624 window is
OURS: it is `contextWindow` in pi's model entry, not a server limit
(`../run1/results/backend-diagnosis.md`, item 3). Two experiments
follow. First, re-probe the Qwen3.8 ceiling at the current
`iogpu.wired_limit_mb=24000`; the ~29K figure was measured at 25000.
Second, fix the arithmetic: `maxTokens` 16384 plus `contextWindow`
26624 cannot fit once a prompt passes ~10K, which caused three
premature length stops in run 7. Propose the values as a diff; it
alters a published measurement, so the owner applies it.

### F. llama.cpp memory fit and the MTP drafter

**The build is not the problem (run 1, 2026-09-03).** The drafter
allocates and accepts 51% of drafts on the SAME brew build at context
8192 on a quiet machine. PRs 23485 and 20817 are both merged and both
sit inside homebrew `llama.cpp` 0.3.0 (tag v0.3.0, 2026-08-25);
confirm with `brew info llama.cpp`. The failure is conditional: at
262144 with `-ngl 999`, llama.cpp's automatic fitting is disabled
(bench7 H2) and the drafter init hits a real Metal allocation
failure. There is nothing to file upstream.

The experiment is a context ramp with the drafter enabled: 8K, 32K,
64K, 128K, 262K, recording at each step whether the drafter
allocates, and wired memory before and after. Then the same ramp with
`-ngl 999` replaced by `--fit on`, to see whether fitting degrades
instead of failing. Also sample `vmmap --summary` IOAccelerator on
llama-server once: run 1 found it reads ~0 for `mlx_lm.server`, and
the same test on llama-server says whether that meter is useless in
general. Other options stay: a measured `-ngl` minus 15-20% margin;
skip MTP on 32 GB (spec-decode gives ~zero gain on Apple Silicon per
the video research); harness-side relaunch-without-drafter fallback;
match drafter and main context sizes.

### G. Prompt-cache hit monitoring (config health, not scoring)

A config that never hits the prompt cache re-reads the whole context
every turn, runs far slower, and can die on the 300-min budget — our
config's fault, not the model's. Telemetry already records
`cache_read`; the cost table shows the cache share for API runs.
Extend it to local backends: find what llama-server, mlx_lm.server,
and LM Studio expose (llama-server slots/metrics, `cached_tokens` in
responses — the LM Studio sweep already reads it), log the hit rate
per run, and propose an alert threshold (for example: cache share
near zero after turn 3 = misconfigured serving; fix the config before
blaming the model). Wilder: make the worker log it live so a
zero-cache run gets flagged in the first 10 minutes, not after 300.

### H. LM Studio trials, and new model candidates


LM Studio trials for existing models: Qwen3.8-27B first (its mlx
26624-window failure is the motivation; LM Studio auto-fit would give
it a far larger window), then other models where the mlx path is the
blocker — with the known LM Studio MLX-engine bugs (stop sequences,
thinking flag, templates) watched in the session logs.

Cautions from 2026-09-04. LM Studio 0.4.23 is current and every bug
above is still open. Its MLX engine is a different build from
homebrew mlx-lm, so a result on one does not transfer to the other.
Auto-fit is a cost as well as a gift: pi compacts against
`contextWindow`, so an auto-fit window the harness does not know about
buys nothing, and the 158464 window it chose for Gemma-12B ate memory.
An "MLX context AutoFit load toggle" landed on mlx-engine main on
2026-07-31; check whether 0.4.23 exposes it, because that would make
the context settable again. The 26624 window itself is a harness
number, see section E, so fix that before crediting LM Studio.

New model candidates — CODING-FOCUSED only (owner cut Muse Glimmer:
weak coding scores; re-filter every candidate for coding/agentic
benchmarks before shortlisting): GLM-4.7-Flash (30B-A3B MoE, MIT —
same active class as Qwen3.6), Poolside Laguna XS 2.1 (33.4B/3B MoE —
check llama.cpp support), Mistral Devstral Small 2 (24B dense, leaves
context headroom). Downloads only after the owner approves the
shortlist.

### I. Stopping loops without touching the prompt

New item, filed by run 1 on 2026-09-03. Research only, not for this
run's execution unless it turns out cheap.

**Why it is here.** Run 1 measured what a prompt rule could do about
tool-call loops and the answer is: we cannot use one. `agents-global.md`
is frozen at v1.0 because changing it invalidates every scored row, and
the owner has decided it stays frozen. So the prompt layer is closed.
The failures are real and unaddressed:

- `google/gemma-4-12b` repeated one invalid command (`ls -F_r`) 72 times
  in a row, 88 times in total, out of 130 tool calls with only 30
  distinct.
- `prism-ml/Ternary-Bonsai-27B-mlx-2bit` repeated the same `ls` 30 times
  in a row on a path it had typed wrong itself.
- Gemma-4's model-level repetition collapse (see section D) is the same
  shape one layer down.

Measurements in `research/run1/results/tool-call-trial.md`.

**The question.** If the prompt cannot be changed, what else stops a
loop? Two layers are open: the sampler, and the harness.

**Sampler side, starting points.** Note that section D already records
`repeat_penalty` failing against Gemma-4's collapse, so treat that as a
known negative and look wider:

- `repeat_penalty` and `repeat_last_n` — llama.cpp only, and already
  reported not to help the Gemma case.
- **ANSWERED 2026-09-03 by run 1: `mlx_lm.server` has the penalties
  too, and they are per-request.** Reading `server.py` in mlx-lm
  0.31.3, the request body accepts `repetition_penalty`,
  `presence_penalty`, `frequency_penalty`, each with its own
  `*_context_size` window, plus `logit_bias`. **All three penalties
  default to 0.0, which is off**, and `repetition_context_size`
  defaults to 20 tokens.
  Three things follow. MLX-served models are not defenceless, so that
  gap does not exist. Nothing is currently defending them either, since
  the defaults are off. And because the values are read from the
  request body rather than server flags, a harness can set them per
  request without restarting a server mid-run — which was the practical
  blocker this item worried about.
  What is still unknown: whether they work. `repeat_penalty` is already
  a known negative against Gemma-4's collapse on llama.cpp, and a flat
  token penalty is a poor match for a repeated multi-token tool call.
  `repetition_context_size` of 20 tokens is far shorter than one
  `bash` call, so the default window could not see a repeat even if the
  penalty were on. Test with a window sized to several calls.
- `frequency_penalty` and `presence_penalty` — these ride the
  OpenAI-compatible API, so they may reach BOTH backends. Check whether
  llama-server and `mlx_lm.server` honour them or silently drop them.
  Silently dropped parameters are this project's recurring trap.
- DRY and XTC samplers in llama.cpp — DRY targets repeated sequences
  specifically, which is closer to the failure than a flat penalty.
- Whether any of these can be set per-request by the harness rather
  than at server start, since a benchmark cannot restart a server
  mid-run.

**Harness side, starting points.** pi supports extensions
(`docs/extensions.md`) with `tool_call` and `tool_result` events, so a
loop detector is implementable without touching any prompt:

- Count identical consecutive tool calls; after N, inject a tool result
  that says so rather than the same error again.
- The existing telemetry already computes the signal — distinct calls
  as a fraction of total calls — so the detection rule is known to work
  offline. The question is only whether it can act in time.
- Decide whether a harness that intervenes is still measuring the model.
  This is the important one: a detector that rescues a looping model
  changes what the benchmark reports. It may belong in the runner as a
  safety stop that ENDS the run, rather than a fix that continues it.

**What would make this shippable.** A defence that needs no prompt
change, works on both backends or is honestly documented as
backend-specific, and either does not alter what is measured or is
declared loudly where it does.

**Coordinator position, 2026-09-04.** Both reproduced loops began with
a malformed call that pi rejected, and the model re-emitted the
rejected call unchanged. So the detection rule is "N identical
consecutive tool calls", and it is known to fire early (call 11-40).
Build it as a STOP that ends the run with its own `end_reason`, not
as a rescue that continues it; a rescue changes what the benchmark
measures. Measure the stop unscored on the replay kit first.
Sampler facts verified upstream: llama-server exposes DRY
(`dry_multiplier`, `dry_base`, `dry_allowed_length`,
`dry_penalty_last_n`, `dry_sequence_breakers`) and XTC per request;
both servers honour `frequency_penalty` and `presence_penalty` per
request; `mlx_lm.server` has no DRY. Sources in
`results/web-upstream-status.md`.

## Parked for research run 3 — owner decisions, do not act

- Whether existing rows carry a `peak_context` caveat or drop the
  claim (no per-cycle context in the logs).
- The `tool_calls` gap in two rows (qwen3.6 guided high: 251 in the
  row, 285 in the log); needs the harness counting rule first.
- Whether the three Gemma-12B rows stay invalid once section D
  separates model from backend.
- Whether the Qwen3.8 harness arithmetic fix (section E) is applied
  before or after the next scored run.
- Anthropic budget for sonnet-5/opus-5 re-runs; Aider polyglot models.

## Deliverables

- `state.md`: running log, handing-over sections.
- `results/experiments.md`: the ranked, owner-filterable experiment
  list with expected cost (GPU-hours, downloads) per item.
- After owner approval: per-experiment findings appended to
  `results/`, and config changes proposed as diffs, not applied
  silently.
