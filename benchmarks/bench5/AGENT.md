# Night 5 — prepared 2026-08-30

Read first: `HANDOFF.md`, `benchmarks/bench4/state.md` (what night 4 finished),
`benchmarks/bench4/lmstudio-forensics.md` (LM Studio rules that still apply),
`docs/methodology.md`. Execution rules are night 4's, unchanged: STE
prose, one model on the GPU at a time, port 8081, heartbeats ≤20 min,
scoped memory watcher on every run, own branch, never push, never
publish.

## Blocks, in order

The focus of this run: clear the dagger (†) cells we expect to improve,
and fill the pending cells. Do NOT re-run the GGUF MTP depth floors
(Qwen3.6 90K window, Qwen3.8 ~19K, Gemma-12B ~11K) — those decays are
compute-bound and a re-run is not expected to move them. Gemma-4-26B is
PARKED (owner's decision, 2026-08-30): no benchmarks for it, in any
block, including Mendel and polyglot.

1. **Bonsai fork, single agent, the scored config — TOP PRIORITY.**
   Slow-creep depth sweep of the exact scored command (the
   `bonsai-fork-single` row's `command` in
   `docs/setups/m1-max-32gb/models.json`: rotation flag + q4 KV +
   `--kv-mean-center` bias). This fills the row's pending maxCtx and
   tokDeep and clears its stale shallow/memory daggers. Watcher scoped,
   ~25 s pauses, run to the floor.
2. **Bonsai fork 2×48K, serial slow creep** with the same flags (one
   slot decoding, the other loaded and idle). Clears that row's
   daggers; check whether the bias flags move the ~32K slot floor.
3. **Gemma-12B LM Studio shallow probe.** One short watched sweep from
   4K through ~33K on `google/gemma-4-12b` to confirm or replace the
   37† shallow figure, and record memory at depth to clear the 8.8 GB†
   cell on both LM Studio rows.
4. **Resume Gemma-12B thinking-on EvalPlus** from 54/164
   (`RESULTS_BASE=benchmarks/bench3/results`, budget 12000, identical
   command). Fills the pending score.
5. **Qwen3.8-27B thinking low** — as before (download, verify the
   low-effort control, 10 worst problems, then creep + full EvalPlus if
   promising).
6. **bonsai-off** — thinking-off EvalPlus on the mlx-f16 config,
   recalibrated budget.
7. **Mendel** (one at a time, per the Mendel block below): Bonsai MLX
   single agent first, then Qwen3.8-27B effort medium, then Gemma-12B
   LM Studio. NOT Gemma-26B (parked).
8. **Aider polyglot** — only after Mendel, only if the table is
   complete. Gemma-26B is excluded.

After every block: update the value in `models.json` AND remove the
field from that row's `stale` array, then `npm run docs:tables` — the
dagger clears on every page at once. Commit.

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
  benchmarked, and never mid-run) check for and kill stray
  "Mendel Daemon" processes before starting the next model. The name is
  exact — capital D, it sets `process.name`:
  `pkill -f "Mendel Daemon"` (check first with
  `pgrep -fl "Mendel Daemon"`). Do not commit a fix for this in the
  Mendel repo.

## Report format for heartbeat checks

Same as night 4: "Block N (model): done X/Y, [num]h[num]min left."
