# Ternary Bonsai-2-27B

Every config of this model, on every machine, best first.

<!-- gen:model-all:start -->
| Model / Config | Ctx | tok/s | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PQ2_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-pq2" hide="server" top /> | **208k** | <TokCell shallow="46.0" deep="14.5" cap="mem" top-shallow top-deep /> | <ScoreCell value="0.982/0.939" sub="100% completion" top /> | <ScoreCell value="59.5" pill="mendel-blind" top /> | <span title="EvalPlus 2h56 · Mendel 1h32">4h29</span> |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-ptq1" hide="server" top /> | **240k** | <TokCell shallow="41.7" deep="12.8" cap="mem" top-shallow top-deep /> | <ScoreCell value="pending" /> | <ScoreCell value="pending" /> | — |
<!-- gen:model-all:end -->

## Files

Every file of this model, on every machine that served it, with every run and a log.

<!-- gen:model-binaries:start -->
- [Ternary-Bonsai-2-27B PQ2_0 (prism-ml, prism fork)](../binaries/bonsai2-prism-pq2.md) — rtx-5060ti-16gb
- [Ternary-Bonsai-2-27B PTQ1_0 (prism-ml, prism fork)](../binaries/bonsai2-prism-ptq1.md) — rtx-5060ti-16gb
<!-- gen:model-binaries:end -->

## Quality — EvalPlus HumanEval+

<!-- gen:model-evalplus:start -->
| config | budget | Scores | empties | tok/s | wall |
|---|--:|--:|--:|--:|--:|
| [<ModelSpec base="Ternary-Bonsai-2-27B" quant="PQ2_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-pq2" />](../setups/arrietty/benchmarks/bonsai-2-27b.md) | 27257 | <ScoreCell value="0.982/0.939" sub="100% completion" top /> | none | <TokCell shallow="46.0" deep="14.5" /> | 2h56 |
<!-- gen:model-evalplus:end -->

Every run of this model on every machine, best base score first. The empties column carries the cause word ([what the words mean](../benchmarks/evalplus.md#limits-on-local-hardware)).

## Agent task — Mendel

<!-- gen:model-mendel:start -->
Blind test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PQ2_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-pq2" /> | blind-v1.1 | ?k | **59.5** | 8/8/done | NaN | — | — | 0 | 0 | 0 |  |

The window cell is the harness context window of that run. Rows before the KV pick of 2026-09-04 carry the type their runbook served, or `q8_0` where no record names one.
<!-- gen:model-mendel:end -->

The window cell is the harness context window of that run.

## What the numbers say

- **Ternary weights change what a 16 GB card holds.** The packings
  cost 6.71 and 5.54 GiB, so the KV cache becomes the large
  allocation, not the model. The card serves 208K tokens on the larger
  packing and 240K on the smaller one, where every 12 GiB 27B build on
  the same machine serves 64K.
- **The window is used, not offered.** The blind agent row peaked at
  192679 tokens of a 208896 window, 92.2%, with zero compactions. It is
  the first row in this project where the agent task itself went past
  64K.
- **It is also the fastest and the highest-scoring 27B build on that
  card**: 46.0 tok/s at 4K, and 0.982 / 0.939 on HumanEval+ with no
  empty answer under a 25209-token thinking budget.
- **The agent score does not follow the quality gate.** 59.5 blind,
  against 91 for a 3-bit build of another model on the same machine.
  The row completed with 16 commits, no repetition loop and no nudge,
  so the loss is judgment: a critical regression that deletes a debug
  file in an exit hook, a missed trap, no dependency pruning, and a
  formatter left failing. A short-prompt quality gate measures none of
  that.
- **The fork is the only backend.** Stock llama.cpp rejects both
  packings and makes garbage from the plain 2-bit file, because it has
  no Hadamard activation runtime. The fork release is part of each
  row's identity.
- **Pending**: a quality gate and an agent row on the smaller packing,
  a guided row on the larger one, a cheaper fixed thinking budget, and
  a mainline row when mainline learns these types.
