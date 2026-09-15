# Gemma-4-26B-A4B on RTX 5060 Ti 16 GB

Backends: llama-server · [NVFP4 GGUF on Hugging Face](https://huggingface.co/catlilface/Gemma-4-26B-A4B-NVFP4-GGUF)

<!-- gen:model-kpis:start -->
<div class="kpis">
  <div class="kpi"><b>7</b><span>expert layers in host RAM at -c 98304</span></div>
  <div class="kpi"><b>37.5</b><span>Mendel guided, NVFP4, thinking on</span></div>
</div>
<!-- gen:model-kpis:end -->

First run 2026-09-13 to 2026-09-15: speed, context and the guided agent task. No EvalPlus on this machine yet.

## Highlights

- **A 15 GB file on a 16 GB card.** Part of the experts stay in host
  RAM; the row records how many layers, found by a ladder at
  `-c 98304`.
- **Attention stays at Q8 in this build**, the shape NVIDIA's own
  NVFP4 checkpoints use; the experts are NVFP4.

## All configs — this model

<!-- gen:model-table:start -->
| Model / Config | Ctx | Cap | tok/s | Memory<br>(at max ctx) | EvalPlus | Coding |
|---|--:|:--:|--:|--:|--:|--:|
| <ModelSpec base="Gemma-4-26B-A4B" quant="NVFP4Q8" server="llama-server" publisher="catlilface" repo="catlilface/Gemma-4-26B-A4B-NVFP4-GGUF" kv="f16" effort="on" /> | **97k** | mem | <TokCell shallow="58.77" deep="45.59" top-shallow top-deep /> | **15.2 GB** | <ScoreCell value="pending" /> | <ScoreCell value="37.5" note="38%" pill="mendel-guided" top /> |
<!-- gen:model-table:end -->

## Configs

Each table row above is one config; start it with its block below.

<!-- gen:model-configs:start -->
<ModelSpec base="Gemma-4-26B-A4B" quant="NVFP4Q8" server="llama-server" publisher="catlilface" repo="catlilface/Gemma-4-26B-A4B-NVFP4-GGUF" kv="f16" effort="on" />

pi id `gemma-4-26b-a4b-nvfp4`. A community NVFP4 repack that keeps attention at Q8. The file is larger than the card, so a measured count of expert layers stays in host RAM: 7 is the lowest `--n-cpu-moe` that loads at `-c 98304` and serves a real request at the deep cell (6 runs out of memory at load). The file has no MTP layers, so no drafter arm exists. The guided task scored 37.5, 3 of 8 libraries, and ended on a loop in its text.

```bash
llama-server -m ~/.cache/llama.cpp/hf/catlilface/Gemma-4-26B-A4B-NVFP4-GGUF/Gemma4-26b-NVFP4Q8.gguf \
  --alias gemma-4-26b-a4b-nvfp4 --no-mmproj --parallel 1 \
  -ngl 999 --fit off --n-cpu-moe 7 -fa on -c 98304 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```
<!-- gen:model-configs:end -->

## Model details and findings

- **97K at 59 → 46 tok/s** with 7 expert layers in host RAM, the
  fastest deep cell on this card. The file has no MTP layers.
- **The guided task scored 37.5, 3 of 8**, and ended on a text loop
  of 475 repeats. Two of its three libraries carry medium defects,
  and only one of six commits ran the full test suite first.

## Agentic quality — Mendel

<!-- gen:model-mendel:start -->
Guided test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Gemma-4-26B-A4B" quant="NVFP4Q8" server="llama-server" publisher="catlilface" repo="catlilface/Gemma-4-26B-A4B-NVFP4-GGUF" kv="f16" effort="on" /> | guided-v3.0 | 96k | **37.5** | 3/8/partial | 22.5 | 6,687k | 90k | 1 | 137 | 6 | thinking |

The window cell is the harness context window of that run. Rows before the KV pick of 2026-09-04 carry the type their runbook served, or `q8_0` where no record names one.
<!-- gen:model-mendel:end -->

Full data: [the benchmarks page](../benchmarks/gemma-4-26b-a4b.md).
