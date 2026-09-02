# Run 8 — Mendel re-runs, API models (Linux)

You are the runner, on the Linux box. Read this file, then the pages it
links, and nothing else. Write all prose in ASD-STE100 Simplified
Technical English.

## Read first

1. `benchmarks/bench8/state.md` — what earlier sessions of this run
   already did. Resume where its last section says; never redo a
   scored run (the worker aborts on an existing branch).
2. `docs/methodology/mendel.md` — house rules for Mendel runs.
3. `../mendel-benchmark/benchmark/PLAN.md` — how to run and how to
   score. It is the law for everything inside the Mendel repo. Read
   "Plan accounting" with care: two providers here run on subscription
   plans.
4. `../mendel-benchmark/benchmark/RUBRIC.md` — the scoring rubric.

There is no GPU work on this box: no server to start, no mem-watch, no
wired limit. The models are remote APIs that pi is already logged into
(fireworks, openai-codex, xai).

## Ground rules

- Work sits in two repos, and the main worktree of each stays with the
  coordinator — never work in it. Benchmark artifacts, scores,
  reports, run branches: the `../mendel-benchmark` worktree (branch
  `benchmark` of `../mendel`) — commit there with type
  `chore(benchmark)` and PUSH there after each scored run. This repo:
  create the LOCAL branch `run8` in a fresh sibling worktree
  (`git worktree add ../choose-a-local-llm-run8 -b run8`) and work
  there; log progress in `benchmarks/bench8/state.md`, commit as you
  go. Never push a run branch. When the owner asks to stop, follow
  the stop-and-sync steps in `AGENTS.md` (merge to `master`, push
  `master`, delete the branch, remove the worktree — that one push is
  required).
- Before the first run: `git -C ../mendel-benchmark pull` and
  `git -C ../mendel fetch --force --tags origin`. The bench bases are
  the MOVING tags `benchmark-blind-base` and `benchmark-guided-base`;
  the worker resolves them, but they must exist locally and match
  origin.
- One run at a time by default. The owner may direct parallel runs
  from separate shells, different models. Keep at most TWO runs in
  flight at once, and never two on the same account (plan provider,
  or the same metered API account). At most ONE openai-codex run and
  at most ONE xai run in flight at any moment — two runs on the same
  plan contaminate each other's plan-window deltas. Cross-account
  pairs are fine (grok + openai, either + fireworks, either +
  anthropic); metered fireworks and metered anthropic (pi) runs may
  each overlap with any other account, but not with another run on
  their own account. The plan probes also need a quiet account:
  during an openai-codex run nobody may use ChatGPT or Codex. Run the
  openai-codex items in the deepest night hours.
- Heartbeat in chat about every 20 minutes. No approval gates: when a
  run is scored and pushed, start the next at once.
- After EVERY run: `pkill -f "Mendel Daemon"` (never mid-run), clean
  the worktree per PLAN.md "Cleanup"; keep the branch.
- Anthropic models are allowed now: login and budget exist on this
  box. pi+anthropic runs are metered, not plan-share, so no isolation
  window applies to them.
- Never trust the model under test. Score only from the verification
  battery (`node ../mendel-benchmark/benchmark/score.mjs` plus the
  rubric).

## The worker command

All runs go through the worker; never `pi -p`, never the TUI:

```bash
cd /home/irae/code/mendel-benchmark/benchmark
./run-worker.sh <model> pi <blind|guided> high
```

Every run on this box uses thinking `high`. Watch `scratchpad/benchmark/runs/<slug>-<bench>-runner.log` during
the run (transient outputs live under `scratchpad/`, gitignored;
only scored artifacts get committed into `benchmark/runs/`). Exit 3 means bad model config;
fix the config, never pass `--allow-bad-config`. If the worker aborts
because a plan probe fails, record it in `state.md` and move to the
next model on a different provider; do not skip the probe. No human
input goes into a run; the runner's nudge policy is the only voice.

## After each run — score and record

Follow `../mendel-benchmark/benchmark/PLAN.md` "How to score a run"
exactly:
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
9. `./run-worker.sh anthropic/claude-haiku-4-5 pi guided high`
10. `./run-worker.sh anthropic/claude-haiku-4-5 pi blind high`
11. `./run-worker.sh anthropic/claude-sonnet-4-5 pi blind high`
12. `./run-worker.sh accounts/fireworks/models/glm-5p3-flash pi blind high`
13. `./run-worker.sh accounts/fireworks/models/glm-5p3-flash pi guided high`
14. `./run-worker.sh anthropic/claude-sonnet-4-5 pi guided high`

If a fireworks model id is rejected, list the store
(`~/.pi/agent/models-store.json`) and use the exact id from there;
record the correction in `state.md`. A bare Anthropic model name is
ambiguous across providers (cloudflare-ai-gateway, github-copilot);
always use the `anthropic/<id>` form, with dashes not dots (e.g.
`anthropic/claude-haiku-4-5`).

## Closing

When the queue ends: confirm no Mendel Daemon and no leftover run
worktrees (`ps aux`, `git -C ../mendel worktree list` — the
`mendel-benchmark` worktree itself stays). Write the handing-over
section in `state.md`, then follow the stop-and-sync steps in
`AGENTS.md` for `run8` (merge, push `master`, delete the branch,
remove the worktree). The mendel repo must already be pushed run by
run.
