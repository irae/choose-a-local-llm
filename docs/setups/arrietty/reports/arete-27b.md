# Arete-27B on RTX 5060 Ti 16 GB

Backends: llama-server · [GGUF](https://huggingface.co/bartowski/NousResearch_Arete-27B-GGUF)

<!-- gen:model-kpis:start -->
<div class="kpis">
  <div class="kpi"><b>64,512</b><span>Deepest clean used context</span><small>61,440-token harness window</small></div>
  <div class="kpi"><b>27.60 / 20.07</b><span>Decode tok/s, shallow / deep</span></div>
  <div class="kpi"><b>pending</b><span>Full EvalPlus quality gate</span></div>
  <div class="kpi"><b>pending</b><span>Agent task</span></div>
</div>
<!-- gen:model-kpis:end -->

Benchmark run 33 uses official llama.cpp stable v0.9.0. Full quality and agent results are pending.

## Highlights

- The Q3_K_M build serves the planned 64K allocation on this card.
- Decode reaches 20.07 tok/s at 64,512 used tokens with q8_0 KV.

## All configs

<!-- gen:model-table:start -->
| Model / Config | Ctx | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Arete-27B" quant="Q3_K_M" server="llama-server" publisher="bartowski" repo="bartowski/NousResearch_Arete-27B-GGUF" kv="q8_0" effort="xhigh" page="/binaries/arete-bartowski-q3km" top /> | **64k** | <TokCell shallow="27.60" deep="20.07" cap="mem" top-shallow top-deep /> | **15.4 GiB** | <ScoreCell value="pending" /> | <ScoreCell value="pending" /> | — |
<!-- gen:model-table:end -->

## Configs

<!-- gen:model-configs:start -->
<ModelSpec base="Arete-27B" quant="Q3_K_M" server="llama-server" publisher="bartowski" repo="bartowski/NousResearch_Arete-27B-GGUF" kv="q8_0" effort="xhigh" page="/binaries/arete-bartowski-q3km" />

Quality and agent tasks pending. Official llama.cpp stable v0.9.0, b12110. q8_0 KV, xhigh, no drafter or vision. Benchmark run 33 served -c 65536 and measured a deepest clean cell of 64512 tokens at 20.07 tok/s. The run stopped at its planned 64K cap, not an observed OOM or speed floor. The harness window is 61440, rounded down to 4096 from the clean depth. Compaction keep is 8192; maxTokens and reserveTokens use pi defaults. Peak total GPU use was 15771 MiB. Timed cells showed no swap growth; setup had a recorded premeasurement swap increase.

```bash
llama-server -m "$(hf download bartowski/NousResearch_Arete-27B-GGUF NousResearch_Arete-27B-Q3_K_M.gguf --revision 9762c8502a79bd2b8634735d75f426b9febe092c)"   --alias arete-27b-q3km --no-mmproj --parallel 1   -ngl 999 --fit off -fa on -c 65536   --cache-type-k q8_0 --cache-type-v q8_0   --jinja --port 8081
```
<!-- gen:model-configs:end -->

## Model details and findings

The baseline uses q8_0 KV at effort xhigh, with MTP and vision disabled. It serves `-c 65536`. The deepest clean cell is 64,512 tokens; the harness window is 61,440. The run stopped at its planned cap, without an OOM or speed-floor failure. Peak total GPU use was 15,771 MiB. Swap did not grow during the timed cells. Full quality and agent results are pending.

## Quality

<!-- gen:model-evalplus:start -->
No EvalPlus run yet.
<!-- gen:model-evalplus:end -->

## Agent task

<!-- gen:model-mendel:start -->
No Mendel run yet.
<!-- gen:model-mendel:end -->

[Full measurement record](../benchmarks/arete-27b.md).
