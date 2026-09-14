# Qwen3.6-35B-A3B on RTX 5060 Ti 16 GB

Backends: llama-server · [NVFP4 GGUF on Hugging Face](https://huggingface.co/michaelw9999/Qwen3.6-35B-A3B-NVFP4-MTP-GGUF)

<!-- gen:model-kpis:start -->
<div class="kpis">
  <div class="kpi"><b>pending</b><span>expert layers in host RAM at -c 98304</span></div>
  <div class="kpi"><b>pending</b><span>Mendel guided, NVFP4, thinking on</span></div>
</div>
<!-- gen:model-kpis:end -->

First run started 2026-09-13; every number is pending until it closes.

## Highlights

- **A 20 GB file on a 16 GB card.** Part of the experts stay in host
  RAM; the row records how many layers, found by a ladder at
  `-c 98304`.
- **The MTP drafter is embedded and measured on real text**, from no
  drafter up, before the row is served.

## All configs — this model

<!-- gen:model-table:start -->
| Model / Config | Ctx | Cap | tok/s | Memory<br>(at max ctx) | EvalPlus | Coding |
|---|--:|:--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.6-35B-A3B" quant="NVFP4-MTP-HQ" server="llama-server" publisher="michaelw9999" repo="michaelw9999/Qwen3.6-35B-A3B-NVFP4-MTP-GGUF" kv="q8_0" effort="on" /> | **pending** | mem | <TokCell shallow="pending" deep="pending" /> | pending | <ScoreCell value="pending" /> | <ScoreCell value="pending" /> |
<!-- gen:model-table:end -->

## Configs

Each table row above is one config; start it with its block below.

<!-- gen:model-configs:start -->
<ModelSpec base="Qwen3.6-35B-A3B" quant="NVFP4-MTP-HQ" server="llama-server" publisher="michaelw9999" repo="michaelw9999/Qwen3.6-35B-A3B-NVFP4-MTP-GGUF" kv="q8_0" effort="on" />

pi id `qwen3.6-35b-a3b-nvfp4`. A community NVFP4 repack with the MTP drafter embedded. The file is larger than the card, so a measured count of expert layers stays in host RAM (`--n-cpu-moe`); the drafter arm is measured on real text before the row is served. Every cell is pending until the first run closes.

```bash
llama-server -m ~/.cache/llama.cpp/hf/michaelw9999/Qwen3.6-35B-A3B-NVFP4-MTP-GGUF/Qwen3.6-35B-A3B-NVFP4-MTP-HQ.gguf \
  --alias qwen3.6-35b-a3b-nvfp4 --no-mmproj --parallel 1 \
  -ngl 999 --fit off --n-cpu-moe <measured> -fa on -c 98304 \
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

Full data: [the benchmarks page](../benchmarks/qwen3.6-35b-a3b.md).
