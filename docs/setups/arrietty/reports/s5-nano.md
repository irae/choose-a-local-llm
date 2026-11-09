# S5-nano on RTX 5060 Ti 16 GB

Backends: llama-server · [Publisher GGUF](https://huggingface.co/maritaca-ai/S5-nano-GGUF)

<!-- gen:model-kpis:start -->
<div class="kpis">
  <div class="kpi"><b>261,120</b><span>Deepest clean used context</span><small>258,048-token harness window</small></div>
  <div class="kpi"><b>77.37 / 30.59</b><span>Decode tok/s, shallow / deep</span></div>
  <div class="kpi"><b>0.811 / 0.726</b><span>EvalPlus base / plus, thinking on</span><small>0 empty, 26 forced of 164</small></div>
  <div class="kpi"><b>not run</b><span>Agent task</span></div>
</div>
<!-- gen:model-kpis:end -->

Benchmark run 33 uses official llama.cpp stable v0.9.0. The thinking quality gate passed. Instruct quality is also measured. The agent task was not run.

## Highlights

- The Q8_0 build serves the full 262,144-token allocation on this card.
- Decode reaches 30.59 tok/s at 261,120 used tokens with q8_0 KV.
- Think mode delivered code for all 164 quality problems.

## All configs

<!-- gen:model-table:start -->
| Model / Config | Ctx | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="S5-nano" quant="Q8_0" server="llama-server" publisher="maritaca-ai" repo="maritaca-ai/S5-nano-GGUF" kv="q8_0" effort="on" page="/binaries/s5-nano-maritaca-q8" top /> | **261k** | <TokCell shallow="77.37" deep="30.59" cap="mem" top-shallow top-deep /> | **10.9 GiB** | <ScoreCell value="0.811/0.726" sub="100% completion" top /> | <ScoreCell value="not run" /> | <span title="EvalPlus 1h56 · Mendel —">1h56†</span> |
<!-- gen:model-table:end -->

## Configs

<!-- gen:model-configs:start -->
<ModelSpec base="S5-nano" quant="Q8_0" server="llama-server" publisher="maritaca-ai" repo="maritaca-ai/S5-nano-GGUF" kv="q8_0" effort="on" page="/binaries/s5-nano-maritaca-q8" />

EvalPlus fast mode scored 0.811 base and 0.726 plus, with 0 empty and 26 forced answers of 164 in 116.3 active minutes. Thinking budget 8192, output budget 16384, no calibration. The base quality gate passed. Agent task not run. Official llama.cpp stable v0.9.0, b12110. q8_0 KV, high Think, no drafter or vision. Benchmark run 33 served -c 262144 and measured a deepest clean cell of 261120 tokens at 30.59 tok/s. The run reached its planned model context cap, not an observed OOM or speed floor. The harness window is 258048, rounded down to 4096 from the clean depth. Compaction keep uses pi default 20000; maxTokens and reserveTokens also use pi defaults. Peak total GPU use was 11117 MiB. Timed cells showed no swap growth; setup had recorded premeasurement swap use. A separate Instruct run, with thinking disabled and no server reasoning budget, scored 0.720 base and 0.634 plus, with no empty or forced answer in 25.5 active minutes. Output budget was 16384. This thinking-off score does not qualify the thinking-on agent row.

```bash
llama-server -m "$(hf download maritaca-ai/S5-nano-GGUF S5-nano-Q8_0.gguf --revision 5fd041274829d60aeeba1e2edc4aabb621a432e4)" \
  --alias s5-nano-q8 --no-mmproj --parallel 1 \
  -ngl 999 --fit off -fa on -c 262144 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --jinja --port 8081
```
<!-- gen:model-configs:end -->

## Model details and findings

The baseline uses q8_0 KV in high Think mode, with MTP and vision disabled. It serves `-c 262144`. The deepest clean cell is 261,120 tokens; the harness window is 258,048. The run reached its planned cap, without an OOM or speed-floor failure. Peak total GPU use was 11,117 MiB. Swap did not grow during the timed cells. The thinking quality gate passed. Instruct quality is also measured. The agent task was not run.

## Quality

Fast mode scored 133 base passes and 119 plus passes out of 164, or 0.811 / 0.726. No answer was empty. The server forced 26 answers at the 8,192-token thinking budget. The active wall was 116.3 minutes, with an output budget of 16,384 and no calibration.

Instruct mode, with thinking disabled, scored 118 base passes and 104 plus passes out of 164, or 0.720 / 0.634. No answer was empty or forced. Active wall was 25.5 minutes at the same 16,384-token output budget, without a server reasoning budget. This is a separate quality result. The agent task was not run.

<!-- gen:model-evalplus:start -->
| config | think | budget | Scores | empties | forced | tok/s | wall |
|---|--:|--:|--:|--:|--:|--:|--:|
| [<ModelSpec base="S5-nano" quant="Q8_0" server="llama-server" publisher="maritaca-ai" repo="maritaca-ai/S5-nano-GGUF" kv="q8_0" effort="on" page="/binaries/s5-nano-maritaca-q8" />](../benchmarks/s5-nano.md) | 8192 | 16384 | <ScoreCell value="0.811/0.726" sub="100% completion" top /> | none | 26/164 | <TokCell shallow="77.37" deep="30.59" /> | 1h56 |
| [<ModelSpec base="S5-nano" quant="Q8_0" server="llama-server" publisher="maritaca-ai" repo="maritaca-ai/S5-nano-GGUF" kv="q8_0" effort="off" page="/binaries/s5-nano-maritaca-q8" />](../benchmarks/s5-nano.md) | none | 16384 | <ScoreCell value="0.720/0.634" sub="100% completion" top /> | none | 0/164 | <TokCell shallow="77.37" deep="30.59" /> | 0h26 |
<!-- gen:model-evalplus:end -->

## Agent task

<!-- gen:model-mendel:start -->
No Mendel run yet.
<!-- gen:model-mendel:end -->

[Full measurement record](../benchmarks/s5-nano.md).
