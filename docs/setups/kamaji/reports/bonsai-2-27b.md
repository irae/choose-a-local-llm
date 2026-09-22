# Ternary Bonsai-2-27B on M1 Max 32 GB

Backends: prism-llama · [GGUF on Hugging Face](https://huggingface.co/prism-ml/Ternary-Bonsai-2-27B-gguf)

<!-- gen:model-kpis:start -->
<div class="kpis">
  <div class="kpi"><b>160k</b><span>usable context, PTQ1_0, f16 KV</span><small>41k on PQ2_0</small></div>
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
- **0.988 / 0.939 on EvalPlus with no empty answer** at effort xhigh,
  under a 16056-token thinking budget. The card scores the same file
  0.970 / 0.939.

## All configs — this model

<!-- gen:model-table:start -->
| Model / Config | Ctx | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" page="/binaries/bonsai2-prism-ptq1" top /> | **160k** | <TokCell shallow="17.9" deep="9.1" cap="mem" top-shallow top-deep /> | **25.5 GB** | <ScoreCell value="0.988/0.939" sub="100% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 4h49 · Mendel —">4h49†</span> |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="MLX 2-bit" server="mlx" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-mlx-2bit" adapter="bonsai2-mlx-server.py" kv="f16" effort="on" top /> | **28k** | <TokCell shallow="21.47" deep="10.45" cap="mem" top-shallow top-deep /> | **15.7 GB** | <ScoreCell value="not run" /> | <ScoreCell value="not run" /> | — |
<!-- gen:model-table:end -->

## Configs

<!-- gen:model-configs:start -->
<ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" page="/binaries/bonsai2-prism-ptq1" />

pi id `bonsai2-27b-ptq1-mac`, the dense packing at f16, the served pack on this machine. `-c 262144`, the trained context, loads and serves, with a harness window of 159744; the deepest clean depth is 163858 at 9.07 tok/s, and the next step, 196618 at 8.18, grew swap by 130 MB, so memory ends the window before the 8 tok/s floor does. The slot packing, PQ2_0, is the faster file on the card and the slower one here: 17.05 tok/s at 4K and under the floor between 41K and 66K, where PTQ1_0 reads 17.86 and 13.05. Read with the context-creep tool at wired limit 25000. Served by the PrismML llama.cpp fork, release `prism-b10685-7dffb15`, Metal build; the stock binary does not serve this file. f16 KV only on this machine. EvalPlus at effort xhigh under a server thinking budget of 16056 (the calibration longest converged reasoning, 10704, times 1.5; answer budget 2048, `max_tokens` 18104): 0.988/0.939 with no empty answer in 337 minutes. Seven problems hit the budget and were forced to answer. The card scored the same file at 0.970/0.939 under a budget of 30000. The four forced answers that failed their tests fail again without the budget, at the 30000-token cap, as loops, so the budget lost no answer. The blind agent row is pending. The published score is the fast-mode run of 2026-09-22: thinking closed at 8192 tokens, output budget 16384, 154 answers kept from the run 26 budget of 16056 and 10 regenerated. It reads 0.988/0.939, the same pair as that run, with no empty answer and 10 forced answers of 164, in 289 minutes of which 72 are its own.

```bash
llama-server -m "$(hf download prism-ml/Ternary-Bonsai-2-27B-gguf Ternary-Bonsai-2-27B-PTQ1_0.gguf)" \
  --alias bonsai2-27b-ptq1-mac --no-mmproj --parallel 1 \
  -ngl 999 -fa on -c 262144 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```

<ModelSpec base="Ternary-Bonsai-2-27B" quant="MLX 2-bit" server="mlx" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-mlx-2bit" adapter="bonsai2-mlx-server.py" kv="f16" effort="on" />

The MLX pack of the ternary 27B, revision `3f926b4`, measured 2026-09-21. **No stock server runs this pack.** `mlx_lm.server` refuses the model type `prism_hadamard_qwen35`; the pack's own `artifact.py` refuses its schema version; Apple's newest `mlx-lm` has no module for it; LM Studio 0.4.24+1 stops with "Unrecognized video processor", because the pack carries no `video_preprocessor_config.json`. The publisher ships a one-shot demo script and no server. The row is therefore served by `tools/sweeps/bonsai2-mlx-server.py`, a thin server in this repository around the publisher's own loader and `mlx_vlm.stream_generate`, with `mlx` 0.32.0 and `mlx-vlm` 0.6.3, the publisher's pins. It keeps no prompt cache, so every step of a depth sweep pays the full prefill. Speed with the context-creep tool at wired limit 25000: 21.47 tok/s at 4K, 12.13 at 24K and 10.45 at 32818, the deepest clean depth; 40982 reads 8.12 and 65578 reads 6.18, and both grew swap, so they are not clean. The window is 28672. The same file's GGUF packings go deeper on this machine: PQ2_0 is clean to 40982 and PTQ1_0 to 163858, where it still reads 9.07 tok/s. MLX is the fastest of the three at 4K and the first to run out of memory. No EvalPlus and no agent row: this run measured speed only.

```bash
BONSAI2_PACK=<pack dir> \
  BONSAI2_MANIFEST=<pack dir>/bonsai2-runtime.sha256 \
  <venv>/bin/python tools/sweeps/bonsai2-mlx-server.py
```
<!-- gen:model-configs:end -->

## Model details and findings

- **Memory ends the window, not speed.** The next PTQ1_0 step, 197K at
  8.18 tok/s, grew swap by 130 MB.
- **About 2.4 times slower than the card at 4K**: 17.9 tok/s against
  42.1 for the same file at the same cache type.

## Quality — EvalPlus HumanEval+

<!-- gen:model-evalplus:start -->
| config | think | budget | Scores | empties | forced | tok/s | wall |
|---|--:|--:|--:|--:|--:|--:|--:|
| [<ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" page="/binaries/bonsai2-prism-ptq1" />](../benchmarks/bonsai-2-27b.md) | 8192 | 16384 | <ScoreCell value="0.988/0.939" sub="100% completion" top /> | none | 10/164 | <TokCell shallow="17.9" deep="9.1" /> | 4h49 |
| [<ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" page="/binaries/bonsai2-prism-ptq1" />](../benchmarks/bonsai-2-27b.md) | 16056† | 18104 | <ScoreCell value="0.988/0.939" sub="100% completion" /> | none | 7/164 | <TokCell shallow="17.9" deep="9.1" /> | 5h37 |

† not fast mode: a thinking budget other than 8192, or none. Kept for the record; only fast-mode rows compare across models.
<!-- gen:model-evalplus:end -->

## Agentic quality — Mendel

<!-- gen:model-mendel:start -->
No Mendel run yet.
<!-- gen:model-mendel:end -->
