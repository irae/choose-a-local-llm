# Qwen3.6-35B-A3B MLX 4-bit (mlx-community)

File: [`mlx-community/Qwen3.6-35B-A3B-4bit`](https://huggingface.co/mlx-community/Qwen3.6-35B-A3B-4bit),
4-bit MLX repack. Server: mlx_lm.server, unquantized (f16) KV. Every run
of this file on every machine is on this page, retired and superseded
rows included; a run a harness or serving defect voided is not.

- **Why it is here.** The MLX build of the 35B-A3B MoE, run beside the
  unsloth UD-Q4_K_XL GGUF build as the runtime comparison on this
  machine.
- **What it settled.** The MTP drafter has no API on mlx_lm.server, so
  this build never runs with one. On `mlx_lm.server` the harness window
  is 5 percent under the measured ceiling, rounded down (owner rule,
  2026-09-12), because the runtime often triggers macOS memory
  compression near its ceiling and dies.
- **Where it stands.** Blind 37.5 on the agent task (raw 51.5, 3 of 8
  libraries) on a 36864 window, far under the same model's GGUF build,
  which scored blind 50.5 complete on an 81920 window. No EvalPlus run
  has been scheduled on this file; the configuration row carries the
  GGUF sibling's score under the shared-score rule.

## Configurations

<!-- gen:binary-rows:start -->
| Model / Config | Ctx | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.6-35B-A3B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.6-35B-A3B-4bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/qwen36-mlx-4bit" top /> | **37k** | <TokCell shallow="54.5" deep="39.1" cap="mem" top-shallow top-deep /> | **24.6 GB** | <ScoreCell value="0.957/0.939" sub="99% completion" top /> | <ScoreCell value="37.5" note="38%" pill="mendel-blind" top /> | <span title="EvalPlus 5h02 · Mendel 0h19"><b>5h20</b></span> |
<!-- gen:binary-rows:end -->

## Quality — EvalPlus HumanEval+

<!-- gen:binary-evalplus:start -->
No EvalPlus run yet.
<!-- gen:binary-evalplus:end -->

No EvalPlus run exists for this file. Only the depth creep, the smoke,
and the agent task have run on it.

## Agent task — Mendel, every prompt version

<!-- gen:binary-mendel:start -->
Blind test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Qwen3.6-35B-A3B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.6-35B-A3B-4bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/qwen36-mlx-4bit" /> | blind-v1.1 | 32k | **37.5** | 3/8/partial | 18.5 | 1,318k | 31k | 1 | 63 | 3 |  |

The window cell is the harness context window of that run. Rows before the KV pick of 2026-09-04 carry the type their runbook served, or `q8_0` where no record names one.
<!-- gen:binary-mendel:end -->

The first blind row scored 25/100: a `git stash pop` pulled an older
run's stash from the shared stack, a benchmark fault, not a model
score. The re-run, without penalty, scored 37.5 (raw 51.5), capped at
3 of 8 libraries; the model spent its nudge budget. A `git commit
--amend` on the accepted row rewrote the branch's base commit, taking
HEAD after two rejected commit attempts.

## Speed and context

Measured on the M1 Max 32 GB, the only machine that served this file.

<ModelSpec base="Qwen3.6-35B-A3B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.6-35B-A3B-4bit" kv="f16" hide="drafter,effort" />

| measurement | date | config | result |
|---|---|---|---|
| slow creep, retired 24000 limit | 2026-08-29 | no MTP | 53.3 tok/s at 4K, 42.2 at 32-33K, Metal OOM near 37-41K; ceiling 37-41K |
| creep at wired limit 25000 | 2026-09-06 | no MTP, `--prompt-cache-size 2` | 37.4 tok/s at 40982, wired memory 24.6 GB; the generation thread died on a Metal OOM at the next step while `/health` kept answering |
| real text, llama-benchy | 2026-09-12 | at the 36864 window | 54.5 tok/s at 4K, 39.1 at 35840, within four percent of the creep |

The full curves are on [the benchmarks page](../setups/kamaji/benchmarks/qwen3.6-35b-a3b.md).

## Log

- 2026-08-28 to 2026-08-29 — First creep at the retired 24000 wired
  limit: 53.3 tok/s at 4K down to 42.2 at 32-33K, Metal OOM near
  37-41K, ceiling read as 37-41K. `hardware/kamaji/benchmarks/bench2/`,
  `hardware/kamaji/benchmarks/bench3/`.
- 2026-09-06 to 2026-09-07 — Creep at wired limit 25000: last stable
  depth 40982 at 37.4 tok/s, then the generation thread died on a
  Metal OOM at the next step while the models endpoint kept answering;
  wired memory peaked at 24.6 GB. No harness pi entry existed yet for
  this build, so the two Mendel blocks planned for it did not run.
  `hardware/kamaji/benchmarks/bench11/`.
- 2026-09-12 — The MLX 5 percent window rule set: on `mlx_lm.server`
  the harness window is 5 percent under the measured ceiling, rounded
  down to a multiple of 4096, because the runtime often triggers
  macOS memory compression near its ceiling and dies (owner rule).
- 2026-09-12 to 2026-09-13 — Smoke passed at the 36864 window. First
  Mendel blind row scored 25/100: a `git stash pop` took an older
  run's stash from the shared stack, ruled a benchmark fault and
  re-run without penalty; `git stash clear` before every agent run is
  now a rule. The re-run scored 37.5 (raw 51.5), 3 of 8 libraries, the
  model's nudge budget spent; a `git commit --amend` on this branch
  rewrote the base commit. Real-text speed at the same window: 54.5
  tok/s at 4K, 39.1 at 35840, within four percent of the creep.
  `hardware/kamaji/benchmarks/bench16/`.
