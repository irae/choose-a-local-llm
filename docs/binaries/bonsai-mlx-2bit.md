# Ternary-Bonsai-27B MLX 2-bit (prism-ml)

File: [`prism-ml/Ternary-Bonsai-27B-mlx-2bit`](https://huggingface.co/prism-ml/Ternary-Bonsai-27B-mlx-2bit),
MLX 2-bit, about 7.2 GB. Ternary (2-bit) weights on the Qwen3.6-27B
base; no MTP head (removed from the checkpoint). Server: `mlx_lm.server`,
unquantized (f16) KV. Every run of this file on every machine is on this
page, retired and superseded rows included; a run a harness or serving
defect voided is not.

- **Why it is here.** The MLX build of Ternary-Bonsai-27B on its own
  server, `mlx_lm.server`, against the same model's GGUF fork on
  `prism-llama` (the `bonsai-prism-q2g64.md` page).
- **What it settled.** A fixed 3072-token output budget deflated the
  quality score by the largest margin of any model on this machine;
  calibrated budgets fixed it. The depth curve is the flattest
  measured on this machine, but the memory ceiling moved down from
  58K to near 47K between the first creep and a later real-text read,
  so the served window is 40960. The model has not finished the agent
  task at either thinking level in any attempt.
- **Where it stands.** EvalPlus 0.933/0.902 at thinking on, budget
  10240; 0.927/0.902 at thinking off, budget 8192. No Mendel row is
  complete: the current blind row is capped to 37.5 on a 3-of-8
  partial, the current guided row to 12.5 on a 1-of-8 partial, and
  every guided attempt at thinking off is invalid.

## Configurations

<!-- gen:binary-rows:start -->
| Model / Config | Ctx | Cap | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|:--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-mlx-2bit" top /> | **40k** | mem | <TokCell shallow="24.5" deep="17.3" stale top-shallow top-deep /> | **22.5 GB** | <ScoreCell value="0.933/0.902" sub="99% completion" top /> | <ScoreCell value="37.5†" note="38%" pill="mendel-blind" top /> | <span title="EvalPlus 19h24 · Mendel 5h00">24h24</span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="off" hardware="m1-max-32gb" page="/binaries/bonsai-mlx-2bit" /> | **40k** | mem | <TokCell shallow="24.5" deep="17.3" stale top-shallow top-deep /> | **22.5 GB** | <ScoreCell value="0.927/0.902" sub="100% completion" top /> | <ScoreCell value="0" note="0%" pill="model-failed" /> | <span title="EvalPlus 0h46 · Mendel 3h07">3h53</span> |

† from an earlier serving config or method; re-run pending.
<!-- gen:binary-rows:end -->

## Quality — EvalPlus HumanEval+

<!-- gen:binary-evalplus:start -->
| config | budget | Scores | empties | tok/s | wall |
|---|--:|--:|--:|--:|--:|
| [<ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-mlx-2bit" />](../setups/kamaji/benchmarks/bonsai-27b.md) | 10240 | <ScoreCell value="0.933/0.902" sub="99% completion" top /> | 2 budget | <TokCell shallow="24.5" deep="17.3" /> | 19h24 |
<!-- gen:binary-evalplus:end -->

Every empty on this file is the output budget. The 2026-09-16 re-run
took the five thinking-on empties at budget 10240: three completed and
passed, and the two that remain hit the cap again with
`finish_reason: length`.

## Agent task — Mendel, every prompt version

<!-- gen:binary-mendel:start -->
Blind test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-mlx-2bit" /> | blind-v1.0 | 56k | **37.5** (raw 58) | 3/8/partial | 101.8 | 887k | 28k | 0 | 53 | 3 |  |
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-mlx-2bit" /> | blind-v1.1 | 56k | **37.5** (raw 55) | 3/8/partial | 300.0 | 3,555k | 52k | 0 | 135 | 4 | thinking |

Guided test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-mlx-2bit" /> | guided-v2.1 | 56k | **37.5** (raw 69) | 3/8/partial | 230.3 | 2,142k | 51k | 0 | 94 | 3 |  |
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-mlx-2bit" /> | guided-v3.0 | 56k | **12.5** (raw 59) | 1/8/partial | 300.0 | 3,619k | 46k | 0 | 122 | 1 |  |
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="off" hardware="m1-max-32gb" page="/binaries/bonsai-mlx-2bit" /> | guided-v3.0 | 56k | **0** (raw 25) | 0/8/model-failed | 186.9 | 1,969k | 27k | 0 | 105 | 0 | tool call |

The window cell is the harness context window of that run. Rows before the KV pick of 2026-09-04 carry the type their runbook served, or `q8_0` where no record names one.
<!-- gen:binary-mendel:end -->

The current blind row (v1.1, thinking on) stopped at 3 of 8 libraries,
raw 55, capped to 37.5 by the completion-fraction rule. The current
guided row (v3.0, thinking on) stopped at 1 of 8, raw 59, capped to
12.5; its branch is labeled "low" in the run kit but ran at thinking
on, a known mislabel. No guided row stands for thinking off: both
attempts are invalid, one on a harness-level `gh` auth fault, the
other on an unterminated identical-command loop the harness had no
stop condition for.

## Speed and context

Measured on the M1 Max 32 GB, the only machine that served this file.

<ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" hide="drafter,effort" />

| measurement | date | config | result |
|---|---|---|---|
| fast-sweep ceiling | 2026-08-27/28 | no pause between depth steps | 57-61K, last stable 57K at 18.2 tok/s; superseded by the slow-creep rule |
| slow-creep re-test | 2026-08-29 | `--prompt-cache-size 2`, wired limit 24000, 25 s pause per step | flat curve to 58K (18.60-17.27 tok/s from 40K); Metal OOM near 60K; ceiling 58-60K |
| multi-session, two server instances | 2026-08-28 | two `mlx_lm.server` processes, ports 8081/8082 | solo 24.6 tok/s; concurrent 14.0 / 13.9 tok/s each, 14.9 GB RSS combined; ruled out, not worth the per-agent weight copy and port wiring |
| real text, llama-benchy | 2026-09-12/13 | `--prompt-cache-size 2`, old 53248 window | generation thread died on a Metal OOM twice, at 56320 and 52224, with the prompt fill stalled near 47K; no benchy cell survived because it writes its result only at the end of a run |

The real-text ceiling of 2026-09-12/13 sits well under the 2026-08-29
creep's 58K, so the served window is now 40960 (the MLX 5-percent
window rule, owner, 2026-09-12) and the speed and memory cells on this
page carry the 2026-08-29 creep's numbers marked stale. The full
curves are on [the benchmarks page](../setups/kamaji/benchmarks/bonsai-27b.md).

## Log

- 2026-08-27 — First quality pass under a flawed fixed 3072-token
  output budget: 0.640 base / 0.634 plus, 49 of 164 completions empty
  (~30%) — reasoning exhausted the cap. Blind Mendel v1.0: 58/100,
  partial, on a `mlx_lm.server` tool-call parser crash on embedded
  quotes. `hardware/kamaji/benchmarks/bench1/`.
- 2026-08-28 — Corrected with the budget-calibration method (10 fixed
  problems, 30K cap, budget = observed max × 1.5): 0.640 → 0.915/0.884,
  5 of 164 empty, a true model ceiling at the corrected budget. The
  largest correction of any model on this machine. Fast-sweep depth
  ceiling read 57-61K, last stable 57K at 18.2 tok/s.
  `hardware/kamaji/benchmarks/bench2/`.
- 2026-08-28 — Two-server multi-session measured (solo 24.6 tok/s,
  concurrent 14.0/13.9 tok/s each) and ruled out: MLX has no slots, so
  concurrency means one weight copy and one port per agent.
- 2026-08-29 — Slow-creep re-test at wired limit 24000, bounded prompt
  cache: flat curve to 58K, last stable 58K at 17.27 tok/s, Metal OOM
  near 60K. Confirmed a false 44K OOM was the unbounded default cache
  pool, not the model.
- 2026-08-30 to 2026-08-31 — Blind v1.1: 55/100 raw, capped to 37.5 on
  a 3-of-8 partial. Guided v2.1: 69/100 raw, partial, closed at 3 of 8
  after 45-plus minutes stuck on a self-made bug; superseded by v3.0
  and kept only as a record. `hardware/kamaji/benchmarks/bench5/`.
- 2026-09-01 — EvalPlus at thinking off scored for the first time,
  0.927/0.902, no empty; the expected non-zero empty rate did not
  materialize because the one calibration problem that failed to
  converge at the 30000-token calibration cap converged inside the
  real 8192-token budget. The speed and memory cells were
  copied from the thinking-on config rather than swept fresh, a
  planning miss the owner noted; the sweep did not happen in a later
  run either. `hardware/kamaji/benchmarks/bench6/`.
- 2026-09-02 to 2026-09-04 — Guided v3.0 "low" branch (mislabeled: ran
  at thinking on): 59/100 raw, capped to 12.5, partial 1 of 8, most of
  the run spent looping on a self-authored typo'd worktree path.
  `hardware/kamaji/benchmarks/bench7/`.
- 2026-09-04 — Guided v3.0 at thinking off, first attempt: invalid, a
  harness-level fault (this machine's `gh` token was invalid, HTTP
  401, and the model looped on the interactive `gh auth login` the
  prompt forbids until the tooling budget ran out). Retry after the
  owner fixed `gh` auth: invalid again, an unterminated
  identical-command loop the harness had no stop condition for,
  operator-killed after 186.9 minutes with zero commits. Both rows are
  `invalid: true`; no guided row stands for thinking off.
  `hardware/kamaji/benchmarks/bench10/`.
- 2026-09-06 — Agent smoke at thinking off: 14 tool calls, 1 commit,
  no loop, 115 seconds, pass.
- 2026-09-12 to 2026-09-13 — Real-text speed read on
  `llama-benchy` under the old 53248 window: the generation thread died
  twice on a Metal OOM, at 56320 and 52224, prompt fill stalled near
  47K. Served window revised to 40960 by the MLX 5-percent window
  rule; no benchy cell survived to replace the 2026-08-29 creep
  numbers, which stay on the page marked stale.
  `hardware/kamaji/benchmarks/bench16/`.
- 2026-09-15 to 2026-09-16 — Re-run of the empty EvalPlus problems at
  thinking on: 0.915/0.884 → 0.933/0.902, empties 5 → 2 of 164, cause
  `budget` for both. The server died three times on long generations
  during this run with no OOM signature, most likely unbounded
  prompt-cache growth; the standing serve command already carries
  `--prompt-cache-size 2`, and future Bonsai MLX commands must keep
  it. `hardware/kamaji/benchmarks/bench20/`.
