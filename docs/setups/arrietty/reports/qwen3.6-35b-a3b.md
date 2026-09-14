# Qwen3.6-35B-A3B on RTX 5060 Ti 16 GB

Backends: llama-server · [GGUF on Hugging Face](https://huggingface.co/unsloth/Qwen3.6-35B-A3B-MTP-GGUF)

<!-- gen:model-kpis:start -->
<div class="kpis">
  <div class="kpi"><b>21</b><span>expert layers in host RAM, MTP n-max 2</span></div>
  <div class="kpi"><b>pending</b><span>Mendel guided, UD-Q4_K_XL, thinking on</span></div>
</div>
<!-- gen:model-kpis:end -->

First run started 2026-09-13; every number is pending until it closes.

## Highlights

- **A 23 GB file on a 16 GB card.** Part of the experts stay in host
  RAM; the row records how many layers, found by a ladder at
  `-c 98304`.
- **The mainstream build, not a niche one.** The same unsloth
  UD-Q4_K_XL file the reference setup serves; a community NVFP4 repack
  was tried first and failed to load. The MTP drafter is measured on
  real text, from no drafter up, before the row is served.

## All configs — this model

<!-- gen:model-table:start -->
| Model / Config | Ctx | Cap | tok/s | Memory<br>(at max ctx) | EvalPlus | Coding |
|---|--:|:--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/2" kv="q8_0" effort="on" /> | **97k** | mem | <TokCell shallow="61.16" deep="45.42" top-shallow top-deep /> | **14.7 GB** | <ScoreCell value="pending" /> | <ScoreCell value="pending" /> |
<!-- gen:model-table:end -->

## Configs

Each table row above is one config; start it with its block below.

<!-- gen:model-configs:start -->
<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/2" kv="q8_0" effort="on" />

pi id `qwen3.6-35b-a3b-q4kxl`. The build the reference setup serves, with the MTP drafter embedded in the file. The file is larger than the card, so a measured count of expert layers stays in host RAM, and the drafter needs more of the card's memory than no drafter: no drafter serves `-c 98304` at `--n-cpu-moe 17` (55.8 tok/s at 4K, 37.8 at 97K), n-max 1 at 19 (60.6, 37.9), n-max 2 and 3 at 21 (61.2 and 45.4 for n-max 2; 57.9 and 46.8 for n-max 3). n-max 2 is the served arm: fastest at 4K and 65K, and within the spread of n-max 3 at 97K. A community NVFP4 repack was tried first and failed to load (a tensor-count defect); the owner chose the mainstream build over a niche one (2026-09-14). The agent cells are pending.

```bash
llama-server -m ~/.cache/llama.cpp/hf/unsloth/Qwen3.6-35B-A3B-MTP-GGUF/Qwen3.6-35B-A3B-UD-Q4_K_XL.gguf \
  --alias qwen3.6-35b-a3b-q4kxl --no-mmproj --parallel 1 \
  --spec-type draft-mtp --spec-draft-n-max 2 \
  -ngl 999 --fit off --n-cpu-moe 21 -fa on -c 98304 \
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
