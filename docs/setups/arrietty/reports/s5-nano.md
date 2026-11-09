# S5-nano on RTX 5060 Ti 16 GB

Backends: llama-server · [Publisher GGUF](https://huggingface.co/maritaca-ai/S5-nano-GGUF)

<!-- gen:model-kpis:start -->
<div class="kpis">
  <div class="kpi"><b>pending</b><span>Full EvalPlus quality gate</span></div>
  <div class="kpi"><b>pending</b><span>Agent task</span></div>
</div>
<!-- gen:model-kpis:end -->

Benchmark run 33 uses official llama.cpp stable v0.9.0. Full quality and agent results are pending.

## Highlights

- The publisher provides a Q8_0 file for llama.cpp.
- Think is the publisher's default mode. Instruct is also available.

## All configs

<!-- gen:model-table:start -->
| Model / Config | Ctx | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="S5-nano" quant="Q8_0" server="llama-server" publisher="maritaca-ai" repo="maritaca-ai/S5-nano-GGUF" kv="q8_0" effort="on" page="/binaries/s5-nano-maritaca-q8" top /> | **pending** | <TokCell shallow="pending" deep="pending" cap="pending" /> | pending | <ScoreCell value="pending" /> | <ScoreCell value="pending" /> | — |
<!-- gen:model-table:end -->

## Configs

<!-- gen:model-configs:start -->
<ModelSpec base="S5-nano" quant="Q8_0" server="llama-server" publisher="maritaca-ai" repo="maritaca-ai/S5-nano-GGUF" kv="q8_0" effort="on" page="/binaries/s5-nano-maritaca-q8" />

Quality gate pending. Official llama.cpp stable v0.9.0, b12110. q8_0 KV selected in benchmark run 33. The short test served -c 34816; the depth test must set the final serving context and harness window. No MTP or vision. The four-problem smoke is unscored and is not a quality result.

```bash
llama-server -m "$(hf download maritaca-ai/S5-nano-GGUF S5-nano-Q8_0.gguf --revision 5fd041274829d60aeeba1e2edc4aabb621a432e4)" \
  --alias s5-nano-q8 --no-mmproj --parallel 1 \
  -ngl 999 --fit off -fa on -c 34816 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --jinja --port 8081
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

[Full measurement record](../benchmarks/s5-nano.md).
