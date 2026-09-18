# Ternary Bonsai-27B

Every config of this model, on every machine, best first.

<!-- gen:model-all:start -->
| Model / Config | Ctx | tok/s | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-mlx-2bit" hide="server" top /> | **40k** | <TokCell shallow="24.5" deep="17.3" cap="mem" stale top-shallow top-deep /> | <ScoreCell value="0.933/0.902" sub="99% completion" top /> | <ScoreCell value="37.5†" note="38%" pill="mendel-blind" top /> | <span title="EvalPlus 19h24 · Mendel 5h00">24h24</span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-prism-q2g64" hide="server" top /> | 33k | <TokCell shallow="14.7" deep="7.8" cap="speed" top-shallow /> | <ScoreCell value="0.927/0.890" sub="98% completion" top /> | <ScoreCell value="31.5" note="38%" pill="mendel-guided" top /> | <span title="EvalPlus 9h55 · Mendel 5h00">14h55</span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-prism-q2g64" hide="server" /> | **2x48k** | <TokCell shallow="14.9" deep="7.8" cap="speed" stale top-shallow /> | <ScoreCell value="0.927/0.890" sub="98% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 9h55 · Mendel —">9h55†</span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="off" hardware="m1-max-32gb" page="/binaries/bonsai-mlx-2bit" hide="server" /> | **40k** | <TokCell shallow="24.5" deep="17.3" cap="mem" stale top-shallow top-deep /> | <ScoreCell value="0.927/0.902" sub="100% completion" top /> | <ScoreCell value="0" note="0%" pill="model-failed" /> | <span title="EvalPlus 0h46 · Mendel 3h07">3h53</span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-prism-q2g64" hide="server" /> | **131k** | <TokCell shallow="15.0" deep="9.7" cap="mem" stale top-shallow top-deep /> | <ScoreCell value="pending" /> | <ScoreCell value="12.5" note="13%" pill="mendel-guided" /> | <span title="EvalPlus — · Mendel 3h15">3h15†</span> |

† from an earlier serving config or method; re-run pending.
<!-- gen:model-all:end -->

## Files

Every file of this model, on every machine that served it, with every run and a log.

<!-- gen:model-binaries:start -->
- [Ternary-Bonsai-27B MLX 2-bit (prism-ml)](../binaries/bonsai-mlx-2bit.md) — m1-max-32gb
- [Ternary-Bonsai-27B Q2_g64 (prism-ml, prism fork)](../binaries/bonsai-prism-q2g64.md) — m1-max-32gb
<!-- gen:model-binaries:end -->

## Quality — EvalPlus HumanEval+

<!-- gen:model-evalplus:start -->
| config | budget | Scores | empties | tok/s | wall |
|---|--:|--:|--:|--:|--:|
| [<ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-mlx-2bit" />](../setups/kamaji/benchmarks/bonsai-27b.md) | 10240 | <ScoreCell value="0.933/0.902" sub="99% completion" top /> | 2 budget | <TokCell shallow="24.5" deep="17.3" /> | 19h24 |
| [<ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-prism-q2g64" />](../setups/kamaji/benchmarks/bonsai-27b.md) | 10240 | <ScoreCell value="0.927/0.890" sub="98% completion" top /> | 4 budget | <TokCell shallow="14.7" deep="7.8" /> | 9h55 |
<!-- gen:model-evalplus:end -->

Every run of this model on every machine, best base score first. The empties column carries the cause word ([what the words mean](../benchmarks/evalplus.md#limits-on-local-hardware)).

## Agent task — Mendel

<!-- gen:model-mendel:start -->
Blind test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-mlx-2bit" /> | blind-v1.0 | ?k | **37.5** (raw 58) | 3/8/done | NaN | — | — | 0 | 0 | 0 |  |
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-mlx-2bit" /> | blind-v1.1 | ?k | **37.5** (raw 55) | 3/8/done | NaN | — | — | 0 | 0 | 0 |  |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-prism-q2g64" /> | blind-v1.1 | ?k | **12.5** (raw 60.5) | 1/8/done | NaN | — | — | 0 | 0 | 0 |  |

Guided test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-mlx-2bit" /> | guided-v2.1 | ?k | **37.5** (raw 69) | 3/8/done | NaN | — | — | 0 | 0 | 0 |  |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-prism-q2g64" /> | guided-v3.0 | ?k | **31.5** | 3/8/done | NaN | — | — | 0 | 0 | 0 |  |
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-mlx-2bit" /> | guided-v3.0 | ?k | **12.5** (raw 59) | 1/8/done | NaN | — | — | 0 | 0 | 0 |  |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-prism-q2g64" /> | guided-v3.0 | ?k | **12.5** | 1/8/done | NaN | — | — | 0 | 0 | 0 |  |
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="off" hardware="m1-max-32gb" page="/binaries/bonsai-mlx-2bit" /> | guided-v3.0 | ?k | **0** (raw 25) | 0/8/done | NaN | — | — | 0 | 0 | 0 |  |

The window cell is the harness context window of that run. Rows before the KV pick of 2026-09-04 carry the type their runbook served, or `q8_0` where no record names one.
<!-- gen:model-mendel:end -->

The window cell is the harness context window of that run.

## What the numbers say

- **The ternary claim holds up.** 0.933 / 0.902 on MLX 2-bit and
  0.927 / 0.890 on the fork with the vendor's q4 KV bias, from 8 GB of
  weights. Every empty that remains is the output budget, proven.
- **No complete agent row.** MLX dies near 47K under the agent task;
  the fork at q4_0 KV floors at 33K used tokens; at f16 KV it holds
  131K and scored 12.5 guided on 1 of 8. Thinking off looped on
  identical commands and is not run again.
- **The fork is the path.** It is the only backend for the ternary
  GGUF, its q4 KV calibration and the DSpark drafter, and two 48K
  slots leave the Mac usable while an agent runs.
- **The retry rule was born here.** A model that does not finish the
  task cannot score as if it had; a retry after a model failure loses
  points for each earlier valid attempt.
- **Pending**: the fork's EvalPlus at f16 KV, and a guided agent row
  under a thinking budget if the fork build takes the flag.
