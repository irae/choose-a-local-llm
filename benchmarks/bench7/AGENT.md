# Run 7 — Mendel re-runs, local models (Mac)

You are the runner. Read this file, then the pages it links, and nothing
else. Write all prose in ASD-STE100 Simplified Technical English.

## Read first

1. `benchmarks/bench7/state.md` — what earlier sessions of this run
   already did. Resume where its handing-over section says; never
   redo a scored run (the worker aborts on an existing branch).
2. `docs/methodology/checklist.md` — the run loop.
3. `docs/methodology/mendel.md` — house rules for Mendel runs.
4. `docs/methodology/server-lore.md` — open it FIRST when a run stalls.
5. `../mendel-benchmark/benchmark/PLAN.md` — how to run and how to
   score. It is the law for everything inside the Mendel repo.
6. `../mendel-benchmark/benchmark/RUBRIC.md` — the scoring rubric.

## Step 1 — one-time cleanup of this machine (2026-09-02)

Do this FIRST, before any run. Background: mendel `master` was rebased
and force-pushed, the bench bases are now the MOVING tags
`benchmark-blind-base` and `benchmark-guided-base`, and each repo's
main worktree stays on `master` for the coordinator. Earlier runs may
not have cleaned up. Bring the machine to the desired state below on
your own; do not report problems from the expected list — fix them.
Stop and ask the owner ONLY if you find a commit that exists on no
origin branch.

Desired state:

- `~/code/choose-a-local-llm`: main worktree on `master`, equal to
  `origin/master`. No `run*` branch, no extra worktree (your own
  `../choose-a-local-llm-run7` comes later, when you create it).
- `~/code/mendel`: main worktree on `master`, equal to
  `origin/master`, tags equal to origin. No `benchmark/` directory in
  it. Keep the pushed `*-issue-13` run branches.
- `~/code/mendel-benchmark`: worktree of `../mendel` on branch
  `benchmark`, equal to `origin/benchmark`. Transient run files live
  only under its gitignored `scratchpad/`.
- No `mendel-bench-*` worktree. No stray process: no `Mendel Daemon`,
  no `mlx_lm.server`, no `llama-server`, no leftover `pi`.

Expected problems and their fixes:

- Stale or missing tags: `git -C ../mendel fetch --force --tags
  origin` (the base tags move; a plain fetch does not update them).
- Mendel main worktree still on `benchmark`: commit nothing, confirm
  `git status` clean, `git switch master`.
- Mendel `master` diverged from origin: the divergence is the
  pre-rebase commits (origin has them all, rewritten as `chore:`);
  `git reset --hard origin/master`. If choose-a-local-llm `master`
  diverged instead, stop and ask the owner.
- `../mendel-benchmark` missing:
  `git -C ../mendel worktree add ../mendel-benchmark benchmark`, then
  pull it.
- Leftover untracked `benchmark/` files in `../mendel` (from before
  the worktree split): move the `runs/` content into
  `../mendel-benchmark/scratchpad/benchmark/runs/`, delete the rest of
  `../mendel/benchmark`.
- Stale `scratchpad/benchmark/.pi-agent/` (the old shared config dir)
  in the benchmark worktree: delete it; workers now build per-run
  dirs. Keep `scratchpad/benchmark/runs/` content — it includes the
  only copies of the claude-era `*-result.json` telemetry.
- Stale `mendel-bench-*` worktrees or prunable entries:
  `pkill -f <worktree path>`, `git -C ../mendel worktree remove
  --force <path>`, `git -C ../mendel worktree prune`. The run data is
  the branch, which is pushed; the worktree holds nothing to keep.
- Merged leftover `run7` branch here: `git branch -d run7` (if `-d`
  refuses, it is unmerged — stop and ask the owner).

End of step 1: run `git -C ../mendel worktree list`, `git worktree
list`, and `ps aux | grep -iE 'mendel|mlx|llama'`, and record in
`state.md` that the machine matches the desired state.

## Ground rules

- **FIRST ACTION, before you read further or touch any file:**
  `git worktree add ../choose-a-local-llm-run7 -b run7` (or `cd` into
  it if it exists), then `cd ../choose-a-local-llm-run7`. Verify with
  `pwd` and `git worktree list`. Every command of this run happens
  there — never in `~/code/choose-a-local-llm`.
- Never run a bare `git stash` in any worktree of either repo — the
  stash list is shared and parallel agents clobber each other. Prefer
  a WIP commit on your run branch. If a stash is unavoidable: `git
  stash push -m "run7: <what>"` and pop by name only.
- Work sits in two repos, and the main worktree of each stays with the
  coordinator — never work in it. Benchmark artifacts, scores,
  reports, run branches: the `../mendel-benchmark` worktree (branch
  `benchmark` of `../mendel`) — commit there with type
  `chore(benchmark)` and PUSH there after each scored run (branch
  `benchmark`, the run branch; never push mendel `master` or tags).
  This repo: create the LOCAL branch `run7` in a fresh sibling
  worktree (`git worktree add ../choose-a-local-llm-run7 -b run7`) and
  work there; log progress in `benchmarks/bench7/state.md`, commit as
  you go. Never push a run branch. When the owner asks to stop, follow
  the stop-and-sync steps in `AGENTS.md` (merge to `master`, push
  `master`, delete the branch, remove the worktree — that one push is
  required).
- Never download a model. Every model is already in the cache, in the
  exact tested revision and quant. If one is missing, STOP and ask the
  owner.
- One model on the GPU at a time. Port 8081. No parallel workers.
- Before the first run: step 1 above, confirm the GPU is
  idle, confirm `sysctl iogpu.wired_limit_mb` is 24000.
- Scoped mem-watch around every run
  (`tools/sweeps/mem-watch-fast.sh`, `MEMWATCH_INTERVAL=20`), stopped
  right after. Read logs with `tail`, never `cat`.
- Heartbeat in chat about every 20 minutes. No approval gates: when a
  block ends, start the next at once.
- After EVERY run: stop the server, then `pkill -f "Mendel Daemon"`
  (never mid-run). Clean the worktree per PLAN.md "Cleanup"; keep the
  branch.
- Never run Gemma-4-26B-A4B. It is parked.
- Score in a subagent on the Fable model (`claude-fable-5`) — scoring
  is LLM judgment; a smaller model misjudges rubric calls and cost
  bases.
- Never trust the model under test. Score only from the verification
  battery (`node ../mendel-benchmark/benchmark/score.mjs` plus the
  rubric).

## The worker command

All runs go through the worker; never `pi -p`, never the TUI:

```bash
cd /Users/irae/code/mendel-benchmark/benchmark
./run-worker.sh <model> pi <blind|guided> <thinking>
```

Watch `scratchpad/benchmark/runs/<slug>-<bench>-runner.log` during
the run (transient outputs live under `scratchpad/`, gitignored;
only scored artifacts get committed into `benchmark/runs/`). Exit 3 means bad model
config: fix `~/.pi/agent/models.json`, never pass `--allow-bad-config`.
No human input goes into a run; the runner's nudge policy is the only
voice.

## After each run — score and record

Follow `../mendel-benchmark/benchmark/PLAN.md` "How to score a run"
exactly:
evidence pack with `score.mjs`, your judgement only where the rubric
says so, one new row in `results.json` (blind, `prompt_version` v1.1)
or `results-guided.json` (guided, v3.0), regenerate with
`node generate-report.mjs` (blind) or `node generate-report.mjs
--guided`, commit, push. Then update `state.md` here and start the next
run. Mirror refresh into `benchmarks/mendel/` is NOT your job; the
coordinator does it.

## The queue — priority order, do not reorder

Consolidated 2026-09-03 after the owner's newer decisions. Done so
far: Block 1 (both Qwen3.8 low runs, partial), the Bonsai mlx runs
(kept as high — the low flag was not honored), Qwen3.6-35B-A3B blind
high (re-scored on Fable; the row in `results.json` is the truth). A
fully scored-and-pushed prefix is
the goal; the tail can wait for another night.

Scoring reminder: score in a Fable subagent (`claude-fable-5`), never
on a smaller model.

### Block 1 — Qwen3.6-35B-A3B guided high (llama-server) — NEXT

The server for this model is already proven; finish its pair first.
Serve with the exact config from its report page
(`docs/setups/m1-max-32gb/`). No MTP drafter flags. Model id
`qwen3.6-35b-a3b`.

1. `./run-worker.sh qwen3.6-35b-a3b pi guided high`

### Block 2 — Ternary Bonsai-27B on the PrismML fork, low first

The mlx runs of this block are DONE and stay in the data: both ran at
high because mlx did not honor the low flag (see the rows'
`config_note`). The remaining Bonsai runs use the PrismML llama.cpp
fork — the owner wants the fork scored, and wants LOW first.

Serve with the exact `bonsai-prism` config from the report page
(`docs/setups/m1-max-32gb/reports/bonsai-27b.md`):
`~/prism-llama/llama-server`, ternary Q2_g64 GGUF. Add a pi model
entry per PLAN.md model-config rules if one is missing. These are NEW
rows (new serving stack), not replacements of the mlx rows.

1. `./run-worker.sh bonsai-prism pi blind low`
2. `./run-worker.sh bonsai-prism pi guided low`
3. `./run-worker.sh bonsai-prism pi blind high`
4. `./run-worker.sh bonsai-prism pi guided high`

**Verify the thinking level right after each run starts:** the session
log's `thinking_level_change` event must say the requested level. Both
mlx runs silently ran at high. If the level is wrong, stop the run at
once, note it in `state.md`, and continue with the next item — do not
burn wall clock on a wrong config.

Budget one retry per run (PLAN.md retry rules).

### Block 3 — Gemma-12B (LM Studio), three runs

Serve: `~/.cache/lm-studio/bin/lms load google/gemma-4-12b --parallel 4
--gpu max -y`, then verify with `lms ps`. Never trust JIT loading. Use
the pi model id for this server from `~/.pi/agent/models.json`; if it
is missing, add it per PLAN.md model-config rules before the run.

1. blind `high`
2. guided `high`
3. guided `low`

### Block 4 — only if time remains

`./run-worker.sh mlx-community/Qwen3.8-27B-4bit pi guided xhigh`
(guided only, no blind pair).

## Closing

When the queue ends (or morning comes): stop everything, confirm no
server, no watcher, no Mendel Daemon (`ps aux`), no leftover run
worktrees (`git -C ../mendel worktree list` — the `mendel-benchmark`
worktree itself stays). Write the handing-over section in `state.md`,
then follow the stop-and-sync steps in `AGENTS.md` for `run7` (merge,
push `master`, delete the branch, remove the worktree). The mendel
repo must already be pushed run by run.
