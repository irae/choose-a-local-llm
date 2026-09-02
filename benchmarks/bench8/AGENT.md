# Run 8 — Mendel re-runs, API models (Linux)

You are the runner, on the Linux box. Read this file, then the pages it
links, and nothing else. Write all prose in ASD-STE100 Simplified
Technical English.

## Read first

1. `docs/methodology/mendel.md` — house rules for Mendel runs.
2. `../mendel/benchmark/PLAN.md` — how to run and how to score. It is
   the law for everything inside the Mendel repo. Read "Plan
   accounting" with care: two providers here run on subscription plans.
3. `../mendel/benchmark/RUBRIC.md` — the scoring rubric.

There is no GPU work on this box: no server to start, no mem-watch, no
wired limit. The models are remote APIs that pi is already logged into
(fireworks, openai-codex, xai).

## Ground rules

- Work sits in two repos. Benchmark artifacts, scores, reports, run
  branches: `../mendel`, branch `benchmark` — commit there with type
  `chore(benchmark)` and PUSH there after each scored run. This repo:
  create a LOCAL branch `run8`, log progress in
  `benchmarks/bench8/state.md`, commit as you go, merge back to
  `master` when the run closes, NEVER push this repo.
- Before the first run: `git -C ../mendel pull` (branch `benchmark`,
  expect `79526d6` or later).
- One run at a time, strictly serial. The plan probes in the worker
  need a quiet account: during the openai-codex runs nobody may use
  ChatGPT or Codex. Run those last, in the deepest night hours.
- Heartbeat in chat about every 20 minutes. No approval gates: when a
  run is scored and pushed, start the next at once.
- After EVERY run: `pkill -f "Mendel Daemon"` (never mid-run), clean
  the worktree per PLAN.md "Cleanup"; keep the branch.
- Never run any Anthropic model. There is no budget and no login.
- Never trust the model under test. Score only from the verification
  battery (`node ../mendel/benchmark/score.mjs` plus the rubric).

## The worker command

All runs go through the worker; never `pi -p`, never the TUI:

```bash
cd /home/irae/code/mendel/benchmark
./run-worker.sh <model> pi <blind|guided> high
```

Every run on this box uses thinking `high`. Watch
`runs/<slug>-runner.log` during the run. Exit 3 means bad model config;
fix the config, never pass `--allow-bad-config`. If the worker aborts
because a plan probe fails, record it in `state.md` and move to the
next model on a different provider; do not skip the probe. No human
input goes into a run; the runner's nudge policy is the only voice.

## After each run — score and record

Follow `../mendel/benchmark/PLAN.md` "How to score a run" exactly:
evidence pack with `score.mjs`, your judgement only where the rubric
says so, one new row in `results.json` (blind, `prompt_version` v1.1)
or `results-guided.json` (guided, v3.0), regenerate with
`node generate-report.mjs` (blind) or `node generate-report.mjs
--guided`, commit, push. Then update `state.md` here and start the
next run. Mirror refresh into `benchmarks/mendel/` is NOT your job;
the coordinator does it.

## The queue — in order, do not reorder

Track policy (now in PLAN.md "Which models run which test"): strong API
models get blind only; guided rows are for the cheap probe and the one
strong reference, and each guided model also gets a blind row.

Fireworks first (metered, no isolation need), xai next, openai-codex
last (quiet-account window).

1. `./run-worker.sh accounts/fireworks/models/deepseek-v4-flash-0731 pi guided high`
2. `./run-worker.sh accounts/fireworks/models/deepseek-v4-flash-0731 pi blind high`
3. `./run-worker.sh accounts/fireworks/models/kimi-k3 pi blind high`
4. `./run-worker.sh accounts/fireworks/models/deepseek-v4-pro-0813 pi blind high`
5. `./run-worker.sh grok-4.6 pi blind high`
6. `./run-worker.sh gpt-5.6-luna pi guided high`
7. `./run-worker.sh gpt-5.6-luna pi blind high`
8. `./run-worker.sh gpt-5.6-sol pi blind high`
9. **SKIP — claude-haiku-4.5, blind + guided, thinking high.** Stays on
   the list so a later run picks it up. Reason: no Anthropic login and
   no budget on this box today. Do not attempt it.

If a fireworks model id is rejected, list the store
(`~/.pi/agent/models-store.json`) and use the exact id from there;
record the correction in `state.md`.

## Closing

When the queue ends: confirm no Mendel Daemon and no leftover worktrees
(`ps aux`, `git -C ../mendel worktree list`). Write the handing-over
section in `state.md`, merge `run8` into `master` locally, do not push
this repo. The mendel repo must already be pushed run by run.
