# Methodology — the flow

This is the law for every test cycle. Do not skip steps.

## Measurement rules

1. **One model on the GPU at a time.** Fresh server start per configuration.
   Long runs go in background tasks.
2. **Warmup first.** Send a discarded warmup request; measure only after it.
3. **Fixed prompts**, temperature 0, fixed token count (we use 256), identical
   across every model and config:
   - py: `Write a Python function that parses ISO dates.`
   - js: `Write a JavaScript function that deep clones an object.`
   Two languages matter: speculative-decoding acceptance differs by language,
   so a single-prompt benchmark can mislead.
4. **Read the server's own timings, not wall clocks**, where available.
   llama-server: `.timings` from `/completion` (`prompt_per_second`,
   `predicted_per_second`, `draft_n`, `draft_n_accepted`). mlx_lm.server has
   no per-request timings — measure decode by streaming and timing the
   token chunks.
5. **Find context maxima by probing, not by spec sheet.** Raise the allocated
   context in fixed steps (we use 8K) until the GPU OOMs
   (`kIOGPUCommandBufferCallbackErrorOutOfMemory` on Metal); record RSS per
   step. A config that loads but decodes degraded counts as failed.
   Speculative decoding: sweep the draft depth per model AND per mode — the
   optimum shifts with output style (thinking on/off) and with depth.
6. **Sweep decode speed against USED context — the depth sweep.** Allocation
   is storage; used tokens are what decode pays for. Grow a prompt in steps
   (4K, 8K, 16K, 24K, 32K, then 16K steps), measure decode at each depth, and
   stop at the first reading under the usability floor (ours: 8 tok/s) or at
   OOM. Every config gets a floor and a "capped by" verdict: **speed** (drops
   under the floor), **OOM** (dies while still fast), or **window** (the
   model's own limit arrives first). The floor — not the window — is where
   the harness compaction threshold belongs. Measured law so far: MLX
   runtimes barely creep but hit hard memory ceilings; llama runtimes creep
   faster but never OOM inside their window.
7. **Record each result on every surface in the same pass** — a result is not
   recorded until all agree: the model's
   `docs/setups/<setup>/benchmarks/*.md` (full data), its
   `docs/setups/<setup>/reports/*.md` page **including the summary line**
   (it goes stale easily), the setup's `comparison.md`, and the harness config
   (`~/.pi/agent/models.json`). Every server config gets a copy-paste command
   block in its report whose alias equals the harness model id. The report
   and comparison pages show only numbers measured under the CURRENT wired
   limit; superseded measurements move to the setup's `historical.html`
   (markdowns keep the full archive).
8. **After tests, check for leftovers and clean up**: `pgrep -fl
   "llama-server|mlx_lm"`, kill strays, verify no background task holds the
   GPU. End every session with the machine idle. Do not delete model files
   or tools early — keep variants for debugging until many successes.
9. **KV cache policy: 8-bit (q8_0) is the default.** Near-lossless (verified
   byte-identical outputs vs f16 at temperature 0); the context it unlocks
   overrules f16's ~1% speed edge. Every published config uses q8 — no
   exceptions, even trained-window-limited configs. Caveat to measure per
   model: q8 can lower MTP draft acceptance and decode speed (Gemma-26B js:
   81% → 68%). q4_0 is banned for quality — with one exception: a vendor
   ships a per-model calibration for it (PrismML's Bonsai bias); such a
   config must pass the EvalPlus gate before serving.
10. **API-or-nothing.** A config qualifies only if it serves an HTTP API a
    harness can use. CLI-only inference paths are disqualified.
11. **Keep thinking-on AND thinking-off data, both labeled — never replace
    one with the other.** The target setup is mixed: main agent thinks,
    sub-agents run thinking-off. Report tables show thinking-on; thinking-off
    goes in note text.
12. **Benchmark scripts must reuse the server's prompt cache perfectly.**
    Grow prompts append-only: each request's prompt = the previous prompt +
    the server's own reply + the new text. Never insert before an existing
    prefix, and never use a fixed suffix that later steps insert before.
    llama-server reuses any longest common prefix; mlx_lm.server only reuses
    strict extensions. Verify reuse via llama's `.timings.prompt_n` (must be
    the delta, not the total). Binds every benchmark run.
13. **Downloads: sequential, one at a time** on slow connections,
    needed-first order, never during meetings (parallel only when the user
    says so). Download only the exact files needed (`--hf-file` /
    `hf_hub_download`) — repos bundle huge F16 siblings and trap-named
    variants; verify file lists and `model_type`/layout compatibility before
    pulling.

## Server-failure lore (verified, will recur)

- **mlx dead-thread trap**: mlx_lm.server's generation thread can die (Metal
  OOM) while the process lives and `/health` returns 200; the client hangs
  forever. Any script talking to an mlx server watches the server log for
  the death signature ("Insufficient Memory", "Command buffer execution
  failed", a Traceback) and exits with code 42 immediately. Exit 42 means:
  the last printed row is the ceiling.
- **mlx prompt-cache pool**: by default the server pools several distinct KV
  caches (multi-GB each at depth) and acts like a memory leak across
  differently-shaped requests. Always serve with `--prompt-cache-size 2`.
- **Check the server log before blaming the model** when a run stalls far
  longer than its budget allows.
- For short runs, depth sweeps, or runs expected to end in OOM, run the
  memory probe (`night2/mem-watch.sh`) at a 20-30 s interval so the final
  pre-OOM samples exist; it separates swap/compression events from compute
  slowdowns. Thermal vs memory-pressure for long-run slowdowns is an OPEN
  question — evidence exists for both.

## Runtimes

- **llama-server** (llama.cpp, brew stable). The concurrency backbone: slots
  share one weight copy; MTP speculative decoding.
- **mlx_lm.server** (mlx-lm, brew). Often faster decode and flatter depth
  curves, but no slots, f16 KV only, and hard memory ceilings.
- **LM Studio via the `lms` CLI** (approved exception to the no-GUI rule:
  everything runs CLI-only — `lms get/load/server`; the model store is
  shared with the app). Its engine supports model types mlx-lm lacks
  (`gemma4_unified`) and implements their attention properly.
- **PrismML llama.cpp fork** (approved exception to the no-forks rule,
  vendor's own): the only backend for ternary GGUFs (Q2_g64), q4-KV with
  calibration, and the DSpark drafter. Side-by-side install in
  `~/prism-llama/` (`prism-llama` alias; `install-latest.sh` overwrites with
  the newest build — one version only). Results labeled with the fork build.
- Default remains: no other forks, no `--HEAD` builds.

## How we picked models (reasoning to reuse)

- **Prefer MoE on bandwidth-limited hardware.** Decode scales with *active*
  parameters — and on MLX the MoE advantage extends to depth (the two
  fastest depth curves measured are MoE-on-MLX).
- **Prefer models with MTP support** — output-lossless free speed on llama.
  Note: speculative decoding (MTP or draft-model) costs depth — the floor
  arrives shallower with a drafter; measure both.
- **Take the newest strong models even if slow**; let the quality gate decide.
- **One compressed-frontier experiment at a time** (ours: ternary Bonsai) —
  and read the vendor's serving docs before concluding anything; we missed
  their 4-bit-KV path and their layout migrations for a while.
- **Use the most popular mainstream quant repos** (HF download counts);
  verify exact file lists first.
- **Per-quantization scoring**: what you run is a quant; quality must be
  measured per quant AND per runtime (mlx vs GGUF weights are different
  artifacts of the same model).

## Code-quality gate (EvalPlus, then Aider)

Tier 1, **EvalPlus (HumanEval+)**: cheap, execution-verified, sensitive to
quantization damage. A gate, not a ranking. Tier 2, for gate survivors: the
**Aider polyglot benchmark** (225 Exercism problems, 6 languages, 2 attempts
with test feedback, docker against your servers) — hours per model. On this
machine docker does not fit beside a loaded model; Aider runs driven from
another computer against the Mac's server.

Gate mechanics: temperature 0, pass@1, small prompt context (problems are
tiny — prompt context does not affect scores). Serve through the config you
will actually run. Score thinking-on for comparability with published
numbers; add thinking-off passes where sub-agent use is planned.

**`max_tokens` (output budget) is a separate axis and it DOES affect
scores.** Calibrate per model: sample ~10 fixed problems at a 30K cap,
record real `completion_tokens`, set budget = observed max × 1.5 (floor
8192). An undersized budget lets reasoning exhaust the cap and empty
completions score as failures — run 1's flaw (up to 38% of scores lost).
For models whose thinking sometimes never converges (finish_reason length at
any budget), the budget is a waste-limiter: set it just above the longest
SUCCESSFUL completion. Speculative decoding never changes outputs at
temperature 0, so score without a drafter and serve with one freely.

Timing of runs is a secondary signal; never chase precision. pass@1 is what
matters.

## Benchmark runs

- **Heartbeat, mandatory**: schedule a wakeup ≤20 minutes after starting any
  block; verify real output growth (not process liveness); restart dead
  blocks; every wakeup ends with a new wakeup or the shutdown checklist.
  Verified necessary on run 2: a block sat 52 minutes in a silent retry loop.
- Close background apps before the run; start the memory probe.
- The prompt-cache rule, the mlx watchdog, and the server-failure lore above
  all bind run scripts.
- The runbook lives in `night<N>/NIGHT-AGENT.md`; state discipline in
  `state.md` per run; results in `results.md`. Executors are explicitly
  allowed to invent fixes for unforeseen problems — fairness first, smallest
  fix, document every deviation, suspect the harness before the model.
- EvalPlus 0.3.1 needs local patches (token budget, extra_body, None-content,
  no signal.alarm + 7200 s client timeout, macOS rlimit in the venv). All
  live in `night1/run_codegen_wrapper.py` + one venv file; history in
  `night1/state.md` and `night2/state.md`.
