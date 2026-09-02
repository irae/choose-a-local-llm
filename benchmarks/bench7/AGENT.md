# Run 7 — Mendel re-runs, local models (Mac)

You are the runner. Read this file, then the pages it links, and nothing
else. Write all prose in ASD-STE100 Simplified Technical English.

## Read first

1. `docs/methodology/checklist.md` — the run loop.
2. `docs/methodology/mendel.md` — house rules for Mendel runs.
3. `docs/methodology/server-lore.md` — open it FIRST when a run stalls.
4. `../mendel/benchmark/PLAN.md` — how to run and how to score. It is
   the law for everything inside the Mendel repo.
5. `../mendel/benchmark/RUBRIC.md` — the scoring rubric.

## Ground rules

- Work sits in two repos. Benchmark artifacts, scores, reports, run
  branches: `../mendel`, branch `benchmark` — commit there with type
  `chore(benchmark)` and PUSH there after each scored run (branch
  `benchmark`, the run branch, tags stay put). This repo: create a
  LOCAL branch `run7`, log progress in `benchmarks/bench7/state.md`,
  commit as you go, merge back to `master` when the run closes, NEVER
  push this repo.
- One model on the GPU at a time. Port 8081. No parallel workers.
- Before the first run: `git -C ../mendel pull` (branch `benchmark`,
  expect `79526d6` or later), confirm the GPU is idle, confirm
  `sysctl iogpu.wired_limit_mb` is 24000.
- Scoped mem-watch around every run
  (`tools/sweeps/mem-watch-fast.sh`, `MEMWATCH_INTERVAL=20`), stopped
  right after. Read logs with `tail`, never `cat`.
- Heartbeat in chat about every 20 minutes. No approval gates: when a
  block ends, start the next at once.
- After EVERY run: stop the server, then `pkill -f "Mendel Daemon"`
  (never mid-run). Clean the worktree per PLAN.md "Cleanup"; keep the
  branch.
- Never run Gemma-4-26B-A4B. It is parked.
- Never trust the model under test. Score only from the verification
  battery (`node ../mendel/benchmark/score.mjs` plus the rubric).

## The worker command

All runs go through the worker; never `pi -p`, never the TUI:

```bash
cd /Users/irae/code/mendel/benchmark
./run-worker.sh <model> pi <blind|guided> <thinking>
```

Watch `runs/<slug>-runner.log` during the run. Exit 3 means bad model
config: fix `~/.pi/agent/models.json`, never pass `--allow-bad-config`.
No human input goes into a run; the runner's nudge policy is the only
voice.

## After each run — score and record

Follow `../mendel/benchmark/PLAN.md` "How to score a run" exactly:
evidence pack with `score.mjs`, your judgement only where the rubric
says so, one new row in `results.json` (blind, `prompt_version` v1.1)
or `results-guided.json` (guided, v3.0), regenerate with
`node generate-report.mjs` (blind) or `node generate-report.mjs
--guided`, commit, push. Then update `state.md` here and start the next
run. Mirror refresh into `benchmarks/mendel/` is NOT your job; the
coordinator does it.

## The queue — priority order, do not reorder

A fully scored-and-pushed prefix is the goal; the tail can wait for
another night.

### Block 1 — Qwen3.8-27B-4bit, effort low (mlx)

Serve: `mlx_lm.server --model mlx-community/Qwen3.8-27B-4bit
--prompt-cache-size 2 --port 8081`

1. `./run-worker.sh mlx-community/Qwen3.8-27B-4bit pi blind low`
2. `./run-worker.sh mlx-community/Qwen3.8-27B-4bit pi guided low`

### Block 2 — Ternary Bonsai-27B 2-bit (mlx), four runs

Serve: `mlx_lm.server --model prism-ml/Ternary-Bonsai-27B-mlx-2bit
--prompt-cache-size 2 --port 8081`

1. `./run-worker.sh prism-ml/Ternary-Bonsai-27B-mlx-2bit pi blind low`
2. `./run-worker.sh prism-ml/Ternary-Bonsai-27B-mlx-2bit pi guided low`
3. `./run-worker.sh prism-ml/Ternary-Bonsai-27B-mlx-2bit pi blind high`
4. `./run-worker.sh prism-ml/Ternary-Bonsai-27B-mlx-2bit pi guided high`

Budget one retry per run (PLAN.md retry rules).

### Block 3 — Gemma-12B (LM Studio), three runs

Serve: `~/.cache/lm-studio/bin/lms load google/gemma-4-12b --parallel 4
--gpu max -y`, then verify with `lms ps`. Never trust JIT loading. Use
the pi model id for this server from `~/.pi/agent/models.json`; if it
is missing, add it per PLAN.md model-config rules before the run.

1. blind `high`
2. guided `high`
3. guided `low`

### Block 4 — Qwen3.6-35B-A3B (llama-server)

Serve with the exact config from its report page
(`docs/setups/m1-max-32gb/`). Do NOT pass any MTP drafter flags; they
break this brew build. Use the pi model id `qwen3.6-35b-a3b`.

1. `./run-worker.sh qwen3.6-35b-a3b pi blind high`
2. `./run-worker.sh qwen3.6-35b-a3b pi guided high`

### Block 5 — only if time remains

`./run-worker.sh mlx-community/Qwen3.8-27B-4bit pi guided xhigh`
(guided only, no blind pair).

## Closing

When the queue ends (or morning comes): stop everything, confirm no
server, no watcher, no Mendel Daemon (`ps aux`). Write the handing-over
section in `state.md`, merge `run7` into `master` locally, do not push
this repo. The mendel repo must already be pushed run by run.
