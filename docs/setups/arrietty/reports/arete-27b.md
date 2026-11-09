# Arete-27B on RTX 5060 Ti 16 GB

Backends: llama-server · [GGUF](https://huggingface.co/bartowski/NousResearch_Arete-27B-GGUF)

<!-- gen:model-kpis:start -->
<div class="kpis">
  <div class="kpi"><b>pending</b><span>Full EvalPlus quality gate</span></div>
  <div class="kpi"><b>pending</b><span>Agent task</span></div>
</div>
<!-- gen:model-kpis:end -->

Benchmark run 33 uses official llama.cpp stable v0.9.0. Full quality and agent results are pending.

## Highlights

- The community Q3_K_M file fits the initial CUDA test.
- The baseline uses effort xhigh.

## All configs

<!-- gen:model-table:start -->
| Model / Config | Ctx | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Arete-27B" quant="Q3_K_M" server="llama-server" publisher="bartowski" repo="bartowski/NousResearch_Arete-27B-GGUF" kv="q8_0" effort="xhigh" page="/binaries/arete-bartowski-q3km" top /> | **pending** | <TokCell shallow="pending" deep="pending" cap="pending" /> | pending | <ScoreCell value="pending" /> | <ScoreCell value="pending" /> | — |
<!-- gen:model-table:end -->

## Configs

<!-- gen:model-configs:start -->
<ModelSpec base="Arete-27B" quant="Q3_K_M" server="llama-server" publisher="bartowski" repo="bartowski/NousResearch_Arete-27B-GGUF" kv="q8_0" effort="xhigh" page="/binaries/arete-bartowski-q3km" />

Quality gate pending. Official llama.cpp stable v0.9.0, b12110. q8_0 KV selected in benchmark run 33. The short test served -c 34816. The depth test must set the final serving context and harness window. Use effort xhigh, without a drafter or vision. The fixed smoke is unscored and is not a full quality result.

```bash
llama-server -m "$(hf download bartowski/NousResearch_Arete-27B-GGUF NousResearch_Arete-27B-Q3_K_M.gguf --revision 9762c8502a79bd2b8634735d75f426b9febe092c)"   --alias arete-27b-q3km --no-mmproj --parallel 1   -ngl 999 --fit off -fa on -c 34816   --cache-type-k q8_0 --cache-type-v q8_0   --jinja --port 8081
```
<!-- gen:model-configs:end -->

## Model details and findings

The baseline uses q8_0 KV with MTP and vision disabled. Depth testing must set the final serving context.

## Quality

<!-- gen:model-evalplus:start -->
No EvalPlus run yet.
<!-- gen:model-evalplus:end -->

## Agent task

<!-- gen:model-mendel:start -->
No Mendel run yet.
<!-- gen:model-mendel:end -->

[Full measurement record](../benchmarks/arete-27b.md).
