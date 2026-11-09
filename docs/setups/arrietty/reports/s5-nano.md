# S5-nano on RTX 5060 Ti 16 GB

Backends: llama-server · [Publisher GGUF](https://huggingface.co/maritaca-ai/S5-nano-GGUF)

<!-- gen:model-kpis:start -->
<div class="kpis">
  <div class="kpi"><b>261,120</b><span>Deepest clean used context</span><small>258,048-token harness window</small></div>
  <div class="kpi"><b>77.37 / 30.59</b><span>Decode tok/s, shallow / deep</span></div>
  <div class="kpi"><b>pending</b><span>Full EvalPlus quality gate</span></div>
  <div class="kpi"><b>not run</b><span>Agent task</span></div>
</div>
<!-- gen:model-kpis:end -->

Benchmark run 33 uses official llama.cpp stable v0.9.0. Full quality results are pending. The agent task was not run.

## Highlights

- The Q8_0 build serves the full 262,144-token allocation on this card.
- Decode reaches 30.59 tok/s at 261,120 used tokens with q8_0 KV.
- Think is the publisher's default mode. Instruct is also available.

## All configs

<!-- gen:model-table:start -->
| Model / Config | Ctx | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="S5-nano" quant="Q8_0" server="llama-server" publisher="maritaca-ai" repo="maritaca-ai/S5-nano-GGUF" kv="q8_0" effort="on" page="/binaries/s5-nano-maritaca-q8" top /> | **261k** | <TokCell shallow="77.37" deep="30.59" cap="mem" top-shallow top-deep /> | **10.9 GiB** | <ScoreCell value="pending" /> | <ScoreCell value="not run" /> | — |
<!-- gen:model-table:end -->

## Configs

<!-- gen:model-configs:start -->
<ModelSpec base="S5-nano" quant="Q8_0" server="llama-server" publisher="maritaca-ai" repo="maritaca-ai/S5-nano-GGUF" kv="q8_0" effort="on" page="/binaries/s5-nano-maritaca-q8" />

Full quality gate pending. Agent task not run. Official llama.cpp stable v0.9.0, b12110. q8_0 KV, high Think, no drafter or vision. Benchmark run 33 served -c 262144 and measured a deepest clean cell of 261120 tokens at 30.59 tok/s. The run reached its planned model context cap, not an observed OOM or speed floor. The harness window is 258048, rounded down to 4096 from the clean depth. Compaction keep uses pi default 20000; maxTokens and reserveTokens also use pi defaults. Peak total GPU use was 11117 MiB. Timed cells showed no swap growth; setup had recorded premeasurement swap use.

```bash
llama-server -m "$(hf download maritaca-ai/S5-nano-GGUF S5-nano-Q8_0.gguf --revision 5fd041274829d60aeeba1e2edc4aabb621a432e4)" \
  --alias s5-nano-q8 --no-mmproj --parallel 1 \
  -ngl 999 --fit off -fa on -c 262144 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --jinja --port 8081
```
<!-- gen:model-configs:end -->

## Model details and findings

The baseline uses q8_0 KV in high Think mode, with MTP and vision disabled. It serves `-c 262144`. The deepest clean cell is 261,120 tokens; the harness window is 258,048. The run reached its planned cap, without an OOM or speed-floor failure. Peak total GPU use was 11,117 MiB. Swap did not grow during the timed cells. Full quality results are pending. The agent task was not run.

## Quality

<!-- gen:model-evalplus:start -->
No EvalPlus run yet.
<!-- gen:model-evalplus:end -->

## Agent task

<!-- gen:model-mendel:start -->
No Mendel run yet.
<!-- gen:model-mendel:end -->

[Full measurement record](../benchmarks/s5-nano.md).
