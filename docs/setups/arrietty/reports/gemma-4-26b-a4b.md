# Gemma-4-26B-A4B on RTX 5060 Ti 16 GB

Backends: llama-server · [NVFP4 GGUF on Hugging Face](https://huggingface.co/catlilface/Gemma-4-26B-A4B-NVFP4-GGUF)

<!-- gen:model-kpis:start -->
<div class="kpis">
  <div class="kpi"><b>7</b><span>expert layers in host RAM at -c 98304</span></div>
  <div class="kpi"><b>0.909 / 0.878</b><span>EvalPlus base / plus, NVFP4Q8, thinking on</span><small>91% completion</small></div>
  <div class="kpi"><b>37.5</b><span>Mendel guided, NVFP4, thinking on</span></div>
</div>
<!-- gen:model-kpis:end -->

Speed, context and the guided agent task measured 2026-09-13 to 2026-09-15; EvalPlus scored 2026-09-16 at thinking on.

## Highlights

- **A 15 GB file on a 16 GB card.** Part of the experts stay in host
  RAM; the row records how many layers, found by a ladder at
  `-c 98304`.
- **EvalPlus 0.909 / 0.878 at thinking on, 14 of 164 empty**, at a
  12500 budget in 215 minutes. The Mac's k-quant of the same model
  reads 0.896 / 0.872 with 16 empty at a 30000 budget.

## All configs — this model

<!-- gen:model-table:start -->
| Model / Config | Ctx | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Gemma-4-26B-A4B" quant="NVFP4Q8" server="llama-server" publisher="catlilface" repo="catlilface/Gemma-4-26B-A4B-NVFP4-GGUF" offload="n-cpu-moe 7" kv="f16" effort="on" page="/binaries/gemma26-catlilface-nvfp4q8" top /> | **97k** | <TokCell shallow="58.77" deep="45.59" cap="mem" top-shallow top-deep /> | **15.2 GB** | <ScoreCell value="0.988/0.951" sub="100% completion" top /> | <ScoreCell value="37.5" note="38%" pill="mendel-guided" top /> | <span title="EvalPlus 2h34 · Mendel 0h23"><b>2h57</b></span> |
<!-- gen:model-table:end -->

## Configs

Each table row above is one config; start it with its block below.

<!-- gen:model-configs:start -->
<ModelSpec base="Gemma-4-26B-A4B" quant="NVFP4Q8" server="llama-server" publisher="catlilface" repo="catlilface/Gemma-4-26B-A4B-NVFP4-GGUF" offload="n-cpu-moe 7" kv="f16" effort="on" page="/binaries/gemma26-catlilface-nvfp4q8" />

pi id `gemma-4-26b-a4b-nvfp4`. A community NVFP4 repack that keeps attention at Q8. The file is larger than the card, so a measured count of expert layers stays in host RAM: 7 is the lowest `--n-cpu-moe` that loads at `-c 98304` and serves a real request at the deep cell (6 runs out of memory at load). The file has no MTP layers, so no drafter arm exists. The guided task scored 37.5, 3 of 8 libraries, and ended on a loop in its text. EvalPlus at thinking on, scored 2026-09-16 at `-c 32768`, budget 12500: 0.909/0.878, 14 empty answers of 164 whose cause is unproven because the run saved no finish log, in 215.3 minutes of active time. Two of ten calibration problems never converged, so the budget sits just above the longest successful answer, and the full run left 14 answers empty. The Mac's nearest row is a different build, the unsloth k-quant at thinking on: 0.884/0.860 with eighteen empty answers at a 30000 budget. The published score is the fast-mode run of 2026-09-20: thinking closed at 8192 tokens, output budget 16384, all 164 problems generated. It reads 0.988/0.951 with no empty answer and 19 forced answers of 164, in 154 minutes of active time. The earlier run left 15 answers empty and scored 0.909/0.878 on the same file; closing the thinking recovered every one of them. The coordinator recomputed this score from the per-problem results because the block ran the evaluator by hand.

```bash
llama-server -m "$(hf download catlilface/Gemma-4-26B-A4B-NVFP4-GGUF Gemma4-26b-NVFP4Q8.gguf)" \
  --alias gemma-4-26b-a4b-nvfp4 --no-mmproj --parallel 1 \
  -ngl 999 --fit off --n-cpu-moe 7 -fa on -c 98304 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```
<!-- gen:model-configs:end -->

## Model details and findings

- **Attention stays at Q8 in this build**, the shape NVIDIA's own
  NVFP4 checkpoints use; the experts are NVFP4. NVFP4 is on this card's
  list because the card runs it natively.

- **97K at 59 → 46 tok/s** with 7 expert layers in host RAM, the
  fastest deep cell on this card. The file has no MTP layers.
- **The guided task scored 37.5, 3 of 8**, and ended on a text loop
  of 475 repeats. Two of its three libraries carry medium defects,
  and only one of six commits ran the full test suite first.
- **EvalPlus at thinking on:** 0.909/0.878, 14 empty answers of 164,
  budget 12500, 215.3 minutes. Two of ten calibration answers never
  converged, so the budget sits just above the longest successful one.
  The cause of each empty is unproven because the run saved no finish
  log; on the Mac the same model's empties were proven as the budget,
  and this model loops in the agent task on both machines. Thinking off
  is not scored on this card yet; on the Mac it reads 0.976 / 0.945 in
  20 minutes.

## Quality — EvalPlus HumanEval+

<!-- gen:model-evalplus:start -->
| config | think | budget | Scores | empties | forced | tok/s | wall |
|---|--:|--:|--:|--:|--:|--:|--:|
| [<ModelSpec base="Gemma-4-26B-A4B" quant="NVFP4Q8" server="llama-server" publisher="catlilface" repo="catlilface/Gemma-4-26B-A4B-NVFP4-GGUF" offload="n-cpu-moe 7" kv="f16" effort="on" page="/binaries/gemma26-catlilface-nvfp4q8" />](../benchmarks/gemma-4-26b-a4b.md) | 8192 | 16384 | <ScoreCell value="0.988/0.951" sub="100% completion" top /> | none | 19/164 | <TokCell shallow="58.77" deep="45.59" /> | 2h34 |
| [<ModelSpec base="Gemma-4-26B-A4B" quant="NVFP4Q8" server="llama-server" publisher="catlilface" repo="catlilface/Gemma-4-26B-A4B-NVFP4-GGUF" offload="n-cpu-moe 7" kv="f16" effort="on" page="/binaries/gemma26-catlilface-nvfp4q8" />](../benchmarks/gemma-4-26b-a4b.md) | —† | 12500 | <ScoreCell value="0.909/0.878" sub="91% completion" /> | † unproven | — | <TokCell shallow="58.77" deep="45.59" /> | 3h35 |

† not fast mode: a thinking budget other than 8192, or none. Kept for the record; only fast-mode rows compare across models.
<!-- gen:model-evalplus:end -->

Every run of this model on this machine, best base score first. The empties column carries the cause word ([what the words mean](../../../benchmarks/evalplus.md#limits-on-local-hardware)).

## Agentic quality — Mendel

<!-- gen:model-mendel:start -->
Guided test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Gemma-4-26B-A4B" quant="NVFP4Q8" server="llama-server" publisher="catlilface" repo="catlilface/Gemma-4-26B-A4B-NVFP4-GGUF" kv="f16" effort="on" page="/binaries/gemma26-catlilface-nvfp4q8" /> | guided-v3.0 | 96k | **37.5** | 3/8/partial | 22.5 | 6,687k | 90k | 1 | 137 | 6 | thinking |

The window cell is the harness context window of that run. Rows before the KV pick of 2026-09-04 carry the type their runbook served, or `q8_0` where no record names one.
<!-- gen:model-mendel:end -->

Full data: [the benchmarks page](../benchmarks/gemma-4-26b-a4b.md).
