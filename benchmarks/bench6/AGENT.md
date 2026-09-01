# Benchmark run 6 — prepared 2026-08-31

Read first: `benchmarks/bench5/state.md` (what run 5 finished and where
block 5 paused), `benchmarks/bench4/lmstudio-forensics.md` (LM Studio
rules that still apply), `docs/methodology.md`, then
`docs/methodology/checklist.md` and `docs/methodology/evalplus.md`.
Execution rules are unchanged: STE prose, one model on the GPU at a
time, port 8081, heartbeats at most 20 min apart, scoped memory watcher
on every run, local run branch (`run6`, merged back into `master` when the run ends),
never push, never publish.

This run holds only EvalPlus and site-table work. **No Mendel runs in
this run.** The Mendel guided queue and Aider polyglot move to run 7.
Gemma-4-26B-A4B is PARKED (owner's decision): no benchmarks for it, in
any block.

## Before block 1: consolidate local branches

The Mac may still hold local branches from earlier runs (for example
`run5`). Before you create `run6`, run `git branch` and `git fetch
--prune`. For every local branch other than `master`: if it has commits
that `master` lacks (`git log master..<branch>`), rebase it onto
`master`, fast-forward `master`, and verify (`npm run verify`); then
delete the branch. If it has no such commits, delete it. Also check
`git worktree list` and remove stray worktrees. Then create `run6` from
the updated `master`.

## Blocks, in order

1. **Resume Gemma-12B thinking-on EvalPlus from 98/164.** The jsonl in
   `benchmarks/bench3/results/gemma12-lmstudio-thinking-on/` resumes
   automatically. Thinking is always on for this model in LM Studio; do
   not pass an extra body.
   ```bash
   ~/.cache/lm-studio/bin/lms server start --port 8081
   ~/.cache/lm-studio/bin/lms load google/gemma-4-12b --parallel 4 --gpu max -y
   ~/.cache/lm-studio/bin/lms ps
   RESULTS_BASE=benchmarks/bench3/results EVALPLUS_MAX_NEW_TOKENS=12000 \
     benchmarks/run-humaneval.sh gemma12-lmstudio-thinking-on google/gemma-4-12b
   ```
   Watcher: `benchmarks/mem-watch.sh`. Done = 164/164 evaluated. Record
   pass@1 base/plus and the empty count. Then set `evalplus` on the
   `gemma12-lmstudio-think` row in `docs/setups/m1-max-32gb/models.json`,
   run `npm run docs:tables`, update `results.md`, `state.md`, commit.
   Unload: `~/.cache/lm-studio/bin/lms unload --all`.

2. **Qwen3.8-27B, effort low, EvalPlus.** New config; it has a Mendel
   guided score (84/100) but no EvalPlus score. Serve on `mlx_lm.server`
   (not LM Studio):
   ```bash
   mlx_lm.server --model mlx-community/Qwen3.8-27B-4bit \
     --reasoning-effort low --prompt-cache-size 2 --port 8081
   ```
   1. Verify low is real. Send `HumanEval/0` twice with
      `benchmarks/calibrate.py`-style requests: one with extra body
      `{"chat_template_kwargs":{"reasoning_effort":"low"}}`, one with
      `"medium"`. Compare `reasoning_content` length (or
      `completion_tokens`). Low must be clearly shorter. If it is not,
      record that in `state.md` and stop this block; do not score a
      config you cannot set.
   2. Calibrate: `benchmarks/calibrate.py qwen38-mlx-low
      mlx-community/Qwen3.8-27B-4bit '{"chat_template_kwargs":{"reasoning_effort":"low"}}'`.
      Budget = max completion × 1.5, floor 8192. Save
      `benchmarks/calibration-qwen38-mlx-low.json`.
   3. Full run:
      ```bash
      RESULTS_BASE=benchmarks/bench6/results EVALPLUS_MAX_NEW_TOKENS=<budget> \
        benchmarks/run-humaneval.sh qwen38-mlx-low mlx-community/Qwen3.8-27B-4bit \
        '{"chat_template_kwargs":{"reasoning_effort":"low"}}'
      ```
   Done = 164/164 evaluated. Add a new row `qwen38-mlx-low` to
   `models.json` next to `qwen38-mlx-medium` (config "Qwen3.8-27B, MLX,
   effort low"; copy the medium row's `maxCtx`, `tokShallow`, `tokDeep`,
   `memory`, and list those four fields in `stale` — the depth sweep is
   not part of this run). Run `npm run docs:tables`, update
   `results.md`, `state.md`, commit.

3. **bonsai-off: Ternary Bonsai-27B MLX, thinking off, EvalPlus.**
   ```bash
   mlx_lm.server --model prism-ml/Ternary-Bonsai-27B-mlx-2bit \
     --prompt-cache-size 2 --port 8081
   ```
   Extra body for every request: `{"chat_template_kwargs":{"enable_thinking":false}}`.
   1. Verify the toggle: one request with and one without the extra
      body; the off request must return no `reasoning_content` and no
      `<think>` block. If the toggle does not work, record it and stop
      this block.
   2. Calibrate with the extra body: `benchmarks/calibrate.py bonsai-off
      prism-ml/Ternary-Bonsai-27B-mlx-2bit '{"chat_template_kwargs":{"enable_thinking":false}}'`.
      Never reuse the thinking-on budget (10240). Save
      `benchmarks/calibration-bonsai-off.json`.
   3. Full run:
      ```bash
      RESULTS_BASE=benchmarks/bench6/results EVALPLUS_MAX_NEW_TOKENS=<budget> \
        benchmarks/run-humaneval.sh bonsai-off prism-ml/Ternary-Bonsai-27B-mlx-2bit \
        '{"chat_template_kwargs":{"enable_thinking":false}}'
      ```
   Done = 164/164 evaluated. Add a row `bonsai-mlx-off` to `models.json`
   (config "Ternary-Bonsai-27B, MLX, bounded cache, thinking off"; copy
   the `bonsai-mlx` row's speed and memory cells and list them in
   `stale`). Run `npm run docs:tables`, update `results.md`, `state.md`,
   commit.

4. **Qwen3.6-35B-A3B GGUF MTP drafter re-check — deferred to run 7**
   (owner's decision, 2026-09-01, after block 3 finished). Run 6 closes
   after block 3. See `benchmarks/INDEX.md` and `state.md` for the
   carry-over note. Run 5 found that
   `--spec-type draft-mtp --spec-draft-n-max 3` fails to allocate on the
   current brew llama.cpp build and leaves the backend returning HTTP
   500 (see `benchmarks/bench5/state.md`). The site row
   `qwen36-gguf-think` still shows 44/8.1 tok/s from an older build.
   1. Record `brew list --versions llama.cpp` in `state.md`.
   2. Start the row's exact `command` from `models.json` (with the
      drafter flags) with the GPU idle. Send one warmup request.
   3. If it generates: run a short shallow probe (one 4K step with
      `tools/sweeps/`, watcher on) and record the shallow tok/s; leave
      the depth floor as is. Note in `state.md` that the drafter works
      again on this build.
   4. If it fails (allocation error or HTTP 500 after `/health` ready):
      stop the server, note the failure and the build version in
      `state.md`, and add `"note"` text to the `qwen36-gguf-think` row
      that the drafter fails on this brew build and the row's speed
      figures are unverified. Do not change the numbers. Run `npm run
      docs:tables`, commit.

After every block: update `models.json` AND remove the field from that
row's `stale` array when the value is fresh, then `npm run docs:tables`.
Commit on `run6`.

## Not in this run

- Mendel (guided runs for Gemma-12B LM Studio and Qwen3.8-27B medium,
  and all Mendel harness work) — run 7.
- Aider polyglot — run 7, after the Mendel rows.
- GGUF MTP depth-floor re-runs (Qwen3.6 90K, Qwen3.8 ~19K, Gemma-12B
  ~11K) — compute-bound decays; a re-run is not expected to move them.
- Gemma-4-26B-A4B — parked.
- **Block 4 (Qwen3.6-35B-A3B GGUF MTP drafter re-check)** — deferred to
  run 7 (owner's decision, 2026-09-01). Run 6 closes with blocks 1-3
  done; the `qwen36-gguf-think` row's speed figures stay unverified
  against the current brew build until run 7 checks the drafter.

## Report format for heartbeat checks

"Block N (model): done X/Y, [num]h[num]min left."

## First moves if this session dies

1. `ps aux | grep -E "run_codegen_wrapper|run-humaneval|mem-watch|llama-server|mlx_lm"`
   and `~/.cache/lm-studio/bin/lms ps` — see what was in flight.
2. Check the jsonl line counts under `benchmarks/bench3/results/gemma12-lmstudio-thinking-on/`
   and `benchmarks/bench6/results/*/` — `run-humaneval.sh` resumes from
   them with the identical command.
3. Read `state.md` in this folder, then continue with the next block.
