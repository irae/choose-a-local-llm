# Night 4 — revised 2026-08-29 late, after the LM Studio forensics

Read first: `benchmarks/bench4/lmstudio-forensics.md` (tonight's findings — it
changes block 2 and 3 below), `benchmarks/bench3/state.md` (history),
`docs/methodology.md` (the flow is the law). Everything below was
approved by the owner tonight, in this order.

## Execution rules (all mandatory)

Same as night 3's — see `benchmarks/bench3/AGENT.md`'s "Execution rules":
STE prose, one model on the GPU at a time, port 8081, heartbeat every
≤20 min, mlx dead-thread watchdog, prompt-cache-reuse rule, "commit
deviations, suspect the harness before the model."

- Run the memory watcher for EVERY sweep or benchmark, scoped to that
  run only (start right before, stop right after). A run without the
  watcher is not valid and cannot be written to the site.
- Branch before block 1 (`AGENTS.md` rule: benchmark runs get their own
  branch, never master). The owner pushes; never push.
- Update the comparison tables (tok/s, max context, memory) after every
  sweep and every EvalPlus — not batched at the end.
- LM Studio specifics (from the forensics — these override older lore):
  - Context length CANNOT be pinned for `google/gemma-4-12b`. Do not
    pass `-c`; do not try 262,144; auto-fit always gives 158,464 at
    wired limit 24000. `--parallel` DOES work. Always load explicitly
    with `lms load` and verify with `lms ps` (JIT can silently load or
    TTL-unload otherwise).
  - Thinking is always ON for `google/gemma-4-12b`; no toggle works.
  - LM Studio ceiling criterion (owner's decision): the ceiling is the
    onset of memory compression/swap in the watcher log, the tok/s
    figure comes from before that onset, and the context-window column
    keeps the auto-fit estimate with a loader-estimate flag.

## Blocks, in order

1. **bonsai-prism** (PrismML fork A/B, resume from 72/164; partial
   results in `benchmarks/bench3/results/bonsai-prism/`). Top priority per the
   owner ("Bonsai with its fork and q4 is super important"). Serve with
   `LLAMA_ATTN_ROT_DISABLE=1 ~/prism-llama/llama-server -m <HF cache
   path> --alias bonsai-prism -ngl 999 -fa on -c 65536 --parallel 1
   --cache-type-k q4_0 --cache-type-v q4_0 --kv-mean-center
   /tmp/Ternary-Bonsai-27B-kv-bias.gguf --jinja --port 8081`
   (regenerate the bias file per `benchmarks/bench3/state.md` if `/tmp` was wiped;
   stop the LM Studio server first — it holds port 8081). Run
   `EVALPLUS_MAX_NEW_TOKENS=10240 benchmarks/run-humaneval.sh bonsai-prism
   bonsai-prism` with `benchmarks/mem-watch.sh` running throughout
   (interval 20-30 s). When done: record in `benchmarks/bench4/state.md` and
   `benchmarks/bench4/results.md`, compare against Bonsai MLX (0.915/0.884),
   update the site table if it passes the gate, commit.
2. **gemma-12b LM Studio table entry, new ceiling criterion.** No pin
   attempts, no 262,144 — see the forensics. The onset data already
   exists: compression starts inside the 74,108-token step (single
   context; clean figure 30.53 tok/s at 49,087) and at ~49.9k per
   context for 2 alternating contexts. Run ONE short confirmation sweep
   to bracket the single-context onset tighter: load
   `lms load google/gemma-4-12b --parallel 4 --gpu max -y`, watcher
   `MEMWATCH_INTERVAL=20 tools/sweeps/mem-watch-fast.sh`, then
   `DEPTH_LIST="41000 49000 57000 65000 74000"
   tools/sweeps/lmstudio_sweep.py`. The onset step = first watcher line
   with d_compress or d_swapout materially above zero (hundreds of
   pages, not single digits). Record: ceiling = onset depth, tok/s =
   last clean step, context window = 158,464 flagged as loader
   auto-fit estimate (trained max 262,144 in the footnote). Update
   `benchmarks/bench4/results.md` and the site comparison table row, commit.
3. **Gemma-12B thinking-on EvalPlus** (LM Studio, always-on thinking —
   no special request body needed). Calibrate the budget first
   (`benchmarks/calibrate.py` method: 10 fixed problems, cap 30000). Expect
   a real empty-completion rate from budget-exhausted reasoning
   (Gemma-26B got 28%; a 16-problem smoke at 16384 got 25%). Score the
   full 164 with `benchmarks/run-humaneval.sh`, watcher running. Record
   honestly including the empty count; do not chase zero empties with
   ever-larger budgets. Update tables, commit.
4. **Qwen3.8-27B, thinking low.** Not downloaded yet — fetch via
   `lms get qwen/qwen3.8-27b` (curated alias; a GUI config stub already
   exists with `reasoningEffort: medium` — see the forensics). Steps:
   1. Load, verify with `lms ps`. Confirm "low" reasoning effort
      actually works: send the same prompt at default and with
      `reasoning_effort: "low"` (and, if that fails, the
      `ext.virtualModel.customField.qwen.qwen3.827b.reasoningEffort`
      per-model config file path) and compare `reasoning_content`
      lengths. If no path changes the reasoning length, record that and
      stop this block — do not score a config we cannot set.
   2. Compute the 10 worst-scoring HumanEval problems across our
      finished runs (aggregate per-problem pass/fail from the
      `*eval_results.json` files in `benchmarks/bench2/results/` and
      `benchmarks/bench3/results/`; the 10 with the most failures). Run just those
      10 at thinking low (calibrated budget, standard method).
   3. If promising (clearly better than our weakest passing models on
      those 10 — judgment call, record the reasoning), run the
      slow-creep context sweep (`tools/sweeps/lmstudio_sweep.py`,
      watcher on, compression-onset criterion from block 2), then the
      full 164-problem EvalPlus at thinking low. Update tables after
      each part, commit.
5. **bonsai-off** (thinking-off pass on the existing mlx-f16 config).
   Recalibrate the budget first (10 fixed problems, cap 30000) — never
   reuse the thinking-on budget. Update tables, commit.
6. **Polyglot, only if everything above is done** and the comparison
   table is 100% complete including Qwen3.8-27B low: run the Aider
   polyglot benchmark (see `docs/methodology.md`, "Aider polyglot
   benchmark") for the top EvalPlus survivors, as many as the night
   allows. Update tables, commit.

## Report format for heartbeat checks

Same as night 3: "Block N (model): done X/Y, [num]h[num]min left."

## First moves if this session dies

1. `ps aux | grep -E "run_codegen_wrapper|run-humaneval|mlx_sweep|lmstudio_sweep|mem-watch|llama-server|mlx_lm"`
   and check `benchmarks/bench4/results/` plus sweep logs in `/tmp` for what was
   in flight.
2. `git status`; commit anything uncommitted (never push).
3. Re-read this file, `benchmarks/bench4/lmstudio-forensics.md`, and
   `benchmarks/bench3/state.md` closing sections.
