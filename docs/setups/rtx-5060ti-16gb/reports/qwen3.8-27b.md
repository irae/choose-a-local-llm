# Qwen3.8-27B on RTX 5060 Ti 16 GB

Backends: llama-server · [GGUF on Hugging Face](https://huggingface.co/unsloth/Qwen3.8-27B-GGUF)

<!-- gen:model-kpis:start -->
<div class="kpis">
  <div class="kpi"><b>65k</b><span>usable context, UD-IQ3_S, q8_0 KV</span></div>
  <div class="kpi"><b>pending</b><span>Mendel guided, UD-IQ3_S, effort xhigh</span></div>
</div>
<!-- gen:model-kpis:end -->

First run started 2026-09-13. Speed and context are measured; the agent cells are pending.

## Highlights

- **The 3-bit build is the one that leaves room for a KV cache.** The
  dense 27B model at 4 bits or at NVFP4 is 16 GB and up, the card's
  whole memory; the UD-IQ3_S file is 12 GB.
- **The KV type is measured here, f16 against q8_0.** On this card
  the type decides the window, and the reference setup's pick does
  not carry over.
- **Effort xhigh, the model's published default.** Medium is never
  run on this model.

## All configs — this model

<!-- gen:model-table:start -->
| Model / Config | Ctx | Cap | tok/s | Memory<br>(at max ctx) | EvalPlus | Coding |
|---|--:|:--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="q8_0" effort="xhigh" /> | **65k** | mem | <TokCell shallow="29.36" deep="20.92" top-shallow top-deep /> | **14.2 GB** | <ScoreCell value="pending" /> | <ScoreCell value="pending" /> |
<!-- gen:model-table:end -->

## Configs

Each table row above is one config; start it with its block below.

<!-- gen:model-configs:start -->
<ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="q8_0" effort="xhigh" />

pi id `qwen3.8-27b-iq3s`. The 3-bit build that leaves room for a KV cache on 16 GB. The KV type was measured on this card: q8_0 serves `-c 65536`, and f16 serves only `-c 53248` (24.3 tok/s at its deep cell), because a larger f16 window loads but runs out of memory on the first real request. q8_0 is the served type. The agent cells are pending.

```bash
llama-server -m ~/.cache/llama.cpp/hf/unsloth/Qwen3.8-27B-GGUF/Qwen3.8-27B-UD-IQ3_S.gguf \
  --alias qwen3.8-27b-iq3s --no-mmproj --parallel 1 \
  -ngl 999 --fit off -fa on -c 65536 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --jinja --port 8081
```
<!-- gen:model-configs:end -->

## Model details and findings

Pending. The findings land here when the first run closes.

## Agentic quality — Mendel

<!-- gen:model-mendel:start -->
No Mendel run yet.
<!-- gen:model-mendel:end -->

Full data: [the benchmarks page](../benchmarks/qwen3.8-27b.md).
