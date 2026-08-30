# Night 5 — prepared 2026-08-30

Read first: `HANDOFF.md`, `night4/state.md` (what night 4 finished),
`night4/lmstudio-forensics.md` (LM Studio rules that still apply),
`docs/methodology.md`. Execution rules are night 4's, unchanged: STE
prose, one model on the GPU at a time, port 8081, heartbeats ≤20 min,
scoped memory watcher on every run, own branch, never push, never
publish.

## Blocks, in order

1. **Finish Gemma-12B thinking-on EvalPlus** (night 4 left it
   mid-codegen; results under
   `night3/results/gemma12-lmstudio-thinking-on/`, budget 12000,
   calibration said expect a high empty rate). Resume with the identical
   command — evalplus's codegen resume skips existing task_ids. Evaluate,
   record the score with the honest empty count, update the tables,
   commit.
2. **Qwen3.8-27B thinking low** — as written in `night4/NIGHT-AGENT.md`
   block 4 (download, verify the low-effort control changes
   `reasoning_content` length, 10 worst-scoring problems, then context
   creep and full EvalPlus if promising).
3. **bonsai-off** — as written in `night4/NIGHT-AGENT.md` block 5.
4. **Mendel benchmark for our models.** See "Mendel benchmark" below.
   Runs one at a time, never in parallel — one GPU.
5. **Aider polyglot** — only after Mendel, and only if the comparison
   table is 100% complete.

## Mendel benchmark (before polyglot, owner's order)

Mendel is the owner's open-source repo at `../mendel`
(`/Users/irae/code/mendel`). Its `benchmark` branch holds a model
bake-off of the owner's own design: one identical repo task (issue 13),
one identical prompt, a 100-point rubric.

- **The instructions live there, not here.** Read
  `../mendel/benchmark/PLAN.md` (how to run, how to score, harness
  attribution, versioned outputs) and `../mendel/benchmark/RUBRIC.md`
  (scoring). Follow them exactly. If they prove insufficient, improve
  and commit them there — without mentioning this repo there.
- **Artifacts live there** (`benchmark/results.json`, `results.csv`,
  `report.html`, branch `benchmark`). Import result rows into this
  repo's tables afterward; mentioning Mendel on the site is allowed
  (it is open source).
- **Which models**: every config on our comparison table that passed
  the EvalPlus gate and has no row in
  `../mendel/benchmark/results.csv`. Already scored, do NOT re-run:
  `qwen3.6-35b-a3b` (llama-server) and `gemma-4-26b-a4b` (partial).
- **One at a time.** The worktree tooling there supports parallel
  workers; our single GPU does not. Run one model, score it, commit
  there, then start the next. Start the model's server here with the
  exact serving config from its report page, then run the harness per
  `PLAN.md` (local models go through the pi harness; provider `llama`
  is llama-server, `lmstudio` is LM Studio).
- Scoring rules from `PLAN.md` apply unchanged: same base commit, real
  `pnpm install`, no mid-run help, never trust the model's own claims,
  rubric unchanged.
- **Known methodology bug, not fixed in that repo yet: "Mendel Daemon"
  processes stay behind after a run finishes.** After each run ends, YOU
  (the agent running the benchmark, never the coder model being
  benchmarked, and never mid-run) check for and kill stray Mendel
  daemon processes (`ps aux | grep -i "mendel" | grep -vi grep`, then
  kill the leftovers) before starting the next model. Do not commit a
  fix for this in the Mendel repo.

## Report format for heartbeat checks

Same as night 4: "Block N (model): done X/Y, [num]h[num]min left."
