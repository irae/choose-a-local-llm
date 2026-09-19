# Ternary Bonsai-2-27B on M1 Max 32 GB

Backends: prism-llama · [GGUF on Hugging Face](https://huggingface.co/prism-ml/Ternary-Bonsai-2-27B-gguf)

<!-- gen:model-kpis:start -->
<div class="kpis">
  <div class="kpi"><b>164k</b><span>deepest clean depth, PTQ1_0, f16 KV</span><small>41k on PQ2_0</small></div>
  <div class="kpi"><b>17.9 tok/s</b><span>decode at 4K, PTQ1_0, f16 KV</span><small>17.05 on PQ2_0</small></div>
</div>
<!-- gen:model-kpis:end -->

Published 2026-09-19: both packings laddered and swept at f16 KV.
EvalPlus and the blind agent row run on PTQ1_0.

## Highlights

- **The dense packing is the one to serve here.** PTQ1_0 holds a clean
  164K at 9.07 tok/s. PQ2_0 falls under the 8 tok/s floor between 41K
  and 66K. On the card the order is the other way round: PQ2_0 decodes
  faster there.
- **Memory ends the window, not speed.** The next PTQ1_0 step, 197K at
  8.18 tok/s, grew swap by 130 MB.
- **About 2.4 times slower than the card at 4K**: 17.9 tok/s against
  42.1 for the same file at the same cache type.

## All configs — this model

<!-- gen:model-table:start -->
| Model / Config | Ctx | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" page="/binaries/bonsai2-prism-ptq1" top /> | **164k** | <TokCell shallow="17.9" deep="9.1" cap="mem" top-shallow top-deep /> | **25.5 GB** | <ScoreCell value="0.988/0.939" sub="100% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 5h37 · Mendel —">5h37†</span> |
<!-- gen:model-table:end -->

## Configs

<!-- gen:model-configs:start -->
<ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" page="/binaries/bonsai2-prism-ptq1" />

pi id `bonsai2-27b-ptq1-mac`, the dense packing at f16, the served pack on this machine. `-c 262144`, the trained context, loads; the deepest clean depth is 163858 at 9.07 tok/s, and the next step, 196618 at 8.18, grew swap by 130 MB, so memory ends the window before the 8 tok/s floor does. The slot packing, PQ2_0, is the faster file on the card and the slower one here: 17.05 tok/s at 4K and under the floor between 41K and 66K, where PTQ1_0 reads 17.86 and 13.05. Read with the context-creep tool at wired limit 25000. Served by the PrismML llama.cpp fork, release `prism-b10685-7dffb15`, Metal build; the stock binary does not serve this file. f16 KV only on this machine. EvalPlus at effort xhigh under a server thinking budget of 16056 (the calibration longest converged reasoning, 10704, times 1.5; answer budget 2048, `max_tokens` 18104): 0.988/0.939 with no empty answer in 337 minutes. Seven problems hit the budget and were forced to answer. The card scored the same file at 0.970/0.939 under a budget of 30000. The blind agent row is running.

```bash
llama-server -m "$(hf download prism-ml/Ternary-Bonsai-2-27B-gguf Ternary-Bonsai-2-27B-PTQ1_0.gguf)" \
  --alias bonsai2-27b-ptq1-mac --no-mmproj --parallel 1 \
  -ngl 999 -fa on -c 167936 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```
<!-- gen:model-configs:end -->

## Quality — EvalPlus HumanEval+

<!-- gen:model-evalplus:start -->
| config | budget | Scores | empties | tok/s | wall |
|---|--:|--:|--:|--:|--:|
| [<ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" page="/binaries/bonsai2-prism-ptq1" />](../benchmarks/bonsai-2-27b.md) | 18104 | <ScoreCell value="0.988/0.939" sub="100% completion" top /> | none | <TokCell shallow="17.9" deep="9.1" /> | 5h37 |
<!-- gen:model-evalplus:end -->

## Agentic quality — Mendel

<!-- gen:model-mendel:start -->
No Mendel run yet.
<!-- gen:model-mendel:end -->
