# Gemma-4-12B-it on RTX 5060 Ti 16 GB

Backends: llama-server · [NVFP4 GGUF on Hugging Face](https://huggingface.co/FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF) · [UD-Q4_K_XL GGUF](https://huggingface.co/unsloth/gemma-4-12b-it-GGUF)

<!-- gen:model-kpis:start -->
<div class="kpis">
  <div class="kpi"><b>261k</b><span>usable context, NVFP4, f16 KV</span></div>
  <div class="kpi"><b>pending</b><span>Mendel guided, NVFP4, thinking off</span></div>
</div>
<!-- gen:model-kpis:end -->

First run started 2026-09-13. Speed and context are measured; the agent cells are pending.

## Highlights

- **The NVFP4 build is the run's headline row.** A 7 GB file leaves
  room for the trained 262,144 window at f16 KV on 16 GB, and the
  card runs NVFP4 natively.
- **The k-quant build is the control.** The same file the reference
  setup serves, read on this card at the same depths, so the NVFP4
  row has a pair.

## All configs — this model

<!-- gen:model-table:start -->
| Model / Config | Ctx | Cap | tok/s | Memory<br>(at max ctx) | EvalPlus | Coding |
|---|--:|:--:|--:|--:|--:|--:|
| <ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="off" /> | **261k** | mem | <TokCell shallow="49.55" deep="33.11" top-shallow top-deep /> | **12.3 GB** | <ScoreCell value="pending" /> | <ScoreCell value="0" note="0%" pill="model-failed" /> |
| <ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" /> | **261k** | mem | <TokCell shallow="47.39" deep="32.18" top-shallow top-deep /> | **12.7 GB** | <ScoreCell value="pending" /> | <ScoreCell value="pending" /> |
<!-- gen:model-table:end -->

## Configs

Each table row above is one config; start it with its block below.

<!-- gen:model-configs:start -->
<ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="off" />

pi id `gemma-4-12b-nvfp4`. A community NVFP4 repack of the model, the run's headline NVFP4 row: the weights leave room for the trained 262,144 window at f16 KV. `-c 262144` loads at once and serves the deep cell at 261,120; the window is the model's own limit, not the card's. The agent cells are pending.

```bash
llama-server -m ~/.cache/llama.cpp/hf/FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF/gemma-4-12b-it-nvfp4.gguf \
  --alias gemma-4-12b-nvfp4 --no-mmproj --parallel 1 \
  -ngl 999 --fit off -fa on -c 262144 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```

<ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" />

pi id `gemma-4-12b-q4kxl`. The k-quant build the Mac serves, the control for the NVFP4 row on this card. `-c 262144` loads at once and serves the deep cell at 261,120. The agent cells are pending.

```bash
llama-server -m ~/.cache/llama.cpp/hf/unsloth/gemma-4-12b-it-GGUF/gemma-4-12b-it-UD-Q4_K_XL.gguf \
  --alias gemma-4-12b-q4kxl --no-mmproj --parallel 1 \
  -ngl 999 --fit off -fa on -c 262144 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```
<!-- gen:model-configs:end -->

## Model details and findings

Pending. The findings land here when the first run closes.

## Agentic quality — Mendel

<!-- gen:model-mendel:start -->
Guided test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="off" /> | guided-v3.0 | 256k | **0** (raw 34) | 0/8/model-failed | 1.0 | 296k | 13k | 0 | 30 | 0 |  |

The window cell is the harness context window of that run. Rows before the KV pick of 2026-09-04 carry the type their runbook served, or `q8_0` where no record names one.
<!-- gen:model-mendel:end -->

Full data: [the benchmarks page](../benchmarks/gemma-4-12b-it.md).
