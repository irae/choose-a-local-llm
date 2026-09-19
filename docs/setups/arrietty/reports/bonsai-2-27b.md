# Ternary Bonsai-2-27B on RTX 5060 Ti 16 GB

Backends: prism-llama · [GGUF on Hugging Face](https://huggingface.co/prism-ml/Ternary-Bonsai-2-27B-gguf)

<!-- gen:model-kpis:start -->
<div class="kpis">
  <div class="kpi"><b>208k</b><span>usable context, PQ2_0, q8_0 KV</span><small>240k on PTQ1_0</small></div>
  <div class="kpi"><b>46.0 tok/s</b><span>decode at 4K, PQ2_0, q8_0 KV</span></div>
  <div class="kpi"><b>0.982 / 0.939</b><span>EvalPlus base / plus, PQ2_0, effort xhigh</span><small>100% completion</small></div>
  <div class="kpi"><b>59.5</b><span>Mendel blind, PQ2_0, effort xhigh</span><small>peak 92.2% of a 208896 window</small></div>
</div>
<!-- gen:model-kpis:end -->

Published 2026-09-17 and measured the same day: both packings laddered
and swept, EvalPlus and the blind agent row on PQ2_0.

## Highlights

- **Ternary weights change what this card holds.** 6.71 GiB for PQ2_0
  and 5.54 GiB for PTQ1_0, against 12 GiB and more for every other 27B
  build here. The KV cache becomes the large allocation, and the card
  serves 208K and 240K tokens where the others serve 64K.
- **The window is used, not offered.** The blind agent row peaked at
  192679 tokens of a 208896 window, 92.2%, with zero compactions. It is
  the first row on this machine where the task itself went past 64K.
- **The fastest 27B build here**: 46.0 tok/s at 4K and 28.2 at 65K,
  against 29.43 and 21.13 for the 3-bit Qwen build.
- **The best quality gate here**: 0.982 / 0.939 with no empty answer,
  under a 25209-token thinking budget at effort xhigh.
- **The agent score does not follow.** 59.5 blind, against 91 for the
  3-bit Qwen build. The row completed with 16 commits, no repetition
  loop and no nudge, so the loss is judgment, not a harness failure.
- **Only the publisher's fork serves these files.** Stock llama.cpp
  rejects both packings and makes garbage from a plain 2-bit file,
  because it has no Hadamard activation runtime. The fork release is
  part of each row's identity.

## All configs — this model

<!-- gen:model-table:start -->
| Model / Config | Ctx | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" page="/binaries/bonsai2-prism-ptq1" top /> | **135k** | <TokCell shallow="42.1" deep="22.4" cap="mem" top-shallow top-deep /> | **15.0 GB** | <ScoreCell value="0.970/0.939" sub="100% completion" /> | <ScoreCell value="82" pill="mendel-blind" top /> | <span title="EvalPlus 3h16 · Mendel 1h28"><b>4h44</b></span> |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" adapter="refusal-ablation LoRA 1.0" kv="f16" effort="xhigh" page="/binaries/bonsai2-prism-ptq1" top /> | **135k** | <TokCell shallow="40.8" deep="22.0" cap="mem" top-deep /> | **15.0 GB** | <ScoreCell value="0.976/0.945" sub="100% completion" top /> | <ScoreCell value="75" pill="mendel-blind" top /> | <span title="EvalPlus 4h34 · Mendel 1h22">5h56</span> |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PQ2_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" page="/binaries/bonsai2-prism-pq2" /> | **208k** | <TokCell shallow="46.0" deep="14.5" cap="mem" top-shallow /> | **15.4 GB** | <ScoreCell value="0.982/0.939" sub="100% completion" top /> | <ScoreCell value="60.5" pill="mendel-blind" /> | <span title="EvalPlus 2h56 · Mendel 1h32"><b>4h29</b></span> |

Rows below 100 percent completeness. Completeness counts three measurements: tok/s, EvalPlus and Mendel.

| Model / Config | Ctx | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PQ2_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" page="/binaries/bonsai2-prism-pq2" top /> | **119k** | <TokCell shallow="46.3" deep="25.1" cap="mem" top-shallow top-deep /> | **15.1 GB** | <ScoreCell value="pending" /> | <ScoreCell value="77" pill="mendel-blind" top /> | <span title="EvalPlus — · Mendel 1h15">1h15†</span> |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" page="/binaries/bonsai2-prism-ptq1" top /> | **240k** | <TokCell shallow="41.7" deep="12.8" cap="mem" top-shallow top-deep /> | **15.5 GB** | <ScoreCell value="pending" /> | <ScoreCell value="73.5" pill="mendel-blind" top /> | <span title="EvalPlus — · Mendel 2h03">2h03†</span> |
<!-- gen:model-table:end -->

## Configs

Each table row above is one config; start it with its block below.

<!-- gen:model-configs:start -->
<ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" page="/binaries/bonsai2-prism-ptq1" />

pi id `bonsai2-27b-ptq1-f16`, the dense packing at f16. **The best blind agent row of this model on this card, 82**, against 77 for the larger packing at f16 and 73.5 and 60.5 for the two q8_0 arms. Its worst defect is a different class from its three siblings: trap A, a naive `.then()` on `fs.promises.glob()` that throws, where the others carried a trap-C exit hook or a chalk regression. All 17 of its commits are `chore`-typed, where the sibling rows used `fix(...)`, and it is the only row of the four with no repair commit and a real `pnpm install` after nearly every commit. `-c 139264`, window 135168, peak context 127141 with one compaction. 42.1 tok/s at 4K and 22.4 at 138240. Served by the PrismML llama.cpp fork, release `prism-b10685-7dffb15`; the stock binary makes garbage from this file. No smoke, and the row ran before any EvalPlus score of this file, so the 0.800 gate did not apply (owner, 2026-09-18). EvalPlus at effort xhigh, scored 2026-09-18 under a server thinking budget of 30000, the derive cap (the calibration's longest converged reasoning ran 23805 tokens, so the margin would have asked for 35707; answer budget 2048, `max_tokens` 32048): 0.970/0.939 with no empty answer in 195.5 minutes. Six problems hit the budget and were forced to answer. It is the first quality gate this file has on any cache type, and it lands 1.2 points of base under the larger packing at q8_0, which supports the publisher's claim that the two packings hold the same weights. Every agent row of this model was re-scored on the best tier on 2026-09-18, after the first scoring ran on a smaller model; the scores here are the re-scored ones. The two forced answers that failed their tests fail again without the budget, at the 30000-token cap, as genuine non-convergence, so the budget lost no answer and needed no correction.

```bash
llama-server -m "$(hf download prism-ml/Ternary-Bonsai-2-27B-gguf Ternary-Bonsai-2-27B-PTQ1_0.gguf)" \
  --alias bonsai2-27b-ptq1-f16 --no-mmproj --parallel 1 \
  -ngl 999 --fit off -fa on -c 139264 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```

<ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" adapter="refusal-ablation LoRA 1.0" kv="f16" effort="xhigh" page="/binaries/bonsai2-prism-ptq1" />

pi id `bonsai2-27b-ptq1-f16-orca`. The dense packing at f16 with a rank-1 LoRA adapter that ablates the refusal direction, applied by the server at scale 1.0 and not merged into the weights (`Continuum-AI-Corp/OrcaBonsai-27B-Uncensored`, `bonsai-abliterate-lora.gguf`, 9,682,464 bytes, sha256 `f1669534…67f42`). The adapter costs no window, `-c 139264` as without it, and about 3 percent of decode: 40.8 tok/s at 4K and 22.0 at 138240, against 42.1 and 22.4. Blind agent row 75, against 82 for the same file without the adapter. It hit no critical defect where the unablated row carried trap A; it lost its points on trap B (the legacy package declared out of scope), on no `pnpm install` in the whole session, and on 13 fix-typed commits. One run per cell, so the difference is indicated, not established. Scored on the best tier. Served by the PrismML llama.cpp fork, release `prism-b10685-7dffb15`. No smoke, and the row ran before any EvalPlus score of this config, so the 0.800 gate did not apply (owner, 2026-09-18). EvalPlus at effort xhigh under a server thinking budget of 30000, the derive cap (three of the ten calibration problems hit the 30000 cap unconverged; answer budget 2048, `max_tokens` 32048): 0.976/0.945 with no empty answer in about 274 minutes, against 0.970/0.939 in 195.5 minutes without the adapter. Ten problems hit the budget and were forced to answer; three of those failed. The adapter did not cost the quality gate.

```bash
llama-server -m "$(hf download prism-ml/Ternary-Bonsai-2-27B-gguf Ternary-Bonsai-2-27B-PTQ1_0.gguf)" \
  --lora "$(hf download Continuum-AI-Corp/OrcaBonsai-27B-Uncensored gguf/bonsai-abliterate-lora.gguf)" \
  --alias bonsai2-27b-ptq1-f16-orca --no-mmproj --parallel 1 \
  -ngl 999 --fit off -fa on -c 139264 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```

<ModelSpec base="Ternary-Bonsai-2-27B" quant="PQ2_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" page="/binaries/bonsai2-prism-pq2" />

pi id `bonsai2-27b-pq2`, revision `6ed5e12`, 6.71 GiB of weights. The ternary build that changes what this card holds: `-c 212992` at q8_0, against 65536 for every 12 GiB 27B build here, and f16 stops at 122880. The sweep found no speed ceiling: 46.0 tok/s at 4K, 38.2 at 24K, 28.2 at 65K and 14.5 at 211968, VRAM flat at 15735 MiB. EvalPlus at effort xhigh, scored 2026-09-18 under a server thinking budget of 25209 (answer budget 2048, `max_tokens` 27257, the calibration's longest converged reasoning 16806 tokens): 0.982/0.939 with no empty answer in 176.1 minutes. Seven problems hit the budget and were forced to answer; three passed. The four that failed hit the 30000-token cap unconverged in the natural re-run, so no forced answer was late and the budget stands. The blind agent row at a 208896 window scored 60.5 with a medium worst defect, complete in 1:32:27, 245 tool calls, 16 commits, no repetition loop, no nudge, and a peak context of 192679 tokens, 92.2% of the window and zero compactions: the first row in this project where the task itself went past 64K. The loss is judgment, not a harness failure: a trap-C regression that deletes the debug manifest in an exit hook, a missed trap B, no dependency pruning, and Prettier left failing. The stock llama.cpp binary does not serve this file: it rejects `PQ2_0` and `PTQ1_0` as unknown types and makes garbage from a `Q2_0` file, because it has no Hadamard activation runtime. Every number here is measured with fork `PrismML-Eng/llama.cpp` release `prism-b10685-7dffb15` (commit `7dffb158d`), one release behind `latest`, whose Linux CUDA asset was still building on 2026-09-17. A different fork release is a different serving stack. The model card publishes `min_p 0.0` in `general.sampling.*`; the server applies `min_p 0.05`, and the agent row samples, so the measured value is the one that counts. Vision is a separate `mmproj` file and this machine never fetched it; every command carries `--no-mmproj`. Every agent row of this model was re-scored on the best tier on 2026-09-18, after the first scoring ran on a smaller model; the scores here are the re-scored ones.

```bash
llama-server -m "$(hf download prism-ml/Ternary-Bonsai-2-27B-gguf Ternary-Bonsai-2-27B-PQ2_0.gguf)" \
  --alias bonsai2-27b-pq2 --no-mmproj --parallel 1 \
  -ngl 999 --fit off -fa on -c 212992 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --jinja --port 8081
```

<ModelSpec base="Ternary-Bonsai-2-27B" quant="PQ2_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" page="/binaries/bonsai2-prism-pq2" />

pi id `bonsai2-27b-pq2-f16`, the same file as the q8_0 row at the other cache type. It trades window for speed and, on one run each, for quality: `-c 122880` against 212992, 46.3 tok/s at 4K and 25.1 at 121856 against 46.0 and 14.5, and a blind agent row of 77 against 60.5. The f16 row paid one compaction at a 118784 window where the q8_0 row had none at 208896, and still scored higher; both rows carry a medium worst defect. Both peaked near 92 percent of their window, so the task grows to fill what it is given. That is one run per arm, so the direction is indicated and not established. Served by the PrismML llama.cpp fork, release `prism-b10685-7dffb15`, commit `7dffb158d`; the stock binary makes garbage from this file. The server applies `min_p 0.05` where the model card publishes `0.0`. EvalPlus at this cache type is scheduled and not yet run. Every agent row of this model was re-scored on the best tier on 2026-09-18, after the first scoring ran on a smaller model; the scores here are the re-scored ones.

```bash
llama-server -m "$(hf download prism-ml/Ternary-Bonsai-2-27B-gguf Ternary-Bonsai-2-27B-PQ2_0.gguf)" \
  --alias bonsai2-27b-pq2-f16 --no-mmproj --parallel 1 \
  -ngl 999 --fit off -fa on -c 122880 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```

<ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" page="/binaries/bonsai2-prism-ptq1" />

pi id `bonsai2-27b-ptq1`, revision `6ed5e12`, 5.54 GiB of weights. The smaller packing and the larger window: `-c 245760` at q8_0, 94% of the trained 262144, where f16 aborts on a live CUDA out-of-memory at 147456 and tops out at 139264. The sweep found no speed ceiling: 41.7 tok/s at 4K, 34.9 at 24K, 26.5 at 65K and 12.8 at 244736, VRAM flat at 15837 MiB. No EvalPlus row and no agent row yet, so nothing is known about what the smaller packing costs in quality. The stock llama.cpp binary does not serve this file: it rejects `PQ2_0` and `PTQ1_0` as unknown types and makes garbage from a `Q2_0` file, because it has no Hadamard activation runtime. Every number here is measured with fork `PrismML-Eng/llama.cpp` release `prism-b10685-7dffb15` (commit `7dffb158d`), one release behind `latest`, whose Linux CUDA asset was still building on 2026-09-17. A different fork release is a different serving stack. The model card publishes `min_p 0.0` in `general.sampling.*`; the server applies `min_p 0.05`, and the agent row samples, so the measured value is the one that counts. Vision is a separate `mmproj` file and this machine never fetched it; every command carries `--no-mmproj`.

```bash
llama-server -m "$(hf download prism-ml/Ternary-Bonsai-2-27B-gguf Ternary-Bonsai-2-27B-PTQ1_0.gguf)" \
  --alias bonsai2-27b-ptq1 --no-mmproj --parallel 1 \
  -ngl 999 --fit off -fa on -c 245760 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --jinja --port 8081
```
<!-- gen:model-configs:end -->

## Quality — EvalPlus HumanEval+

<!-- gen:model-evalplus:start -->
| config | budget | Scores | empties | tok/s | wall |
|---|--:|--:|--:|--:|--:|
| [<ModelSpec base="Ternary-Bonsai-2-27B" quant="PQ2_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" page="/binaries/bonsai2-prism-pq2" />](../benchmarks/bonsai-2-27b.md) | 27257 | <ScoreCell value="0.982/0.939" sub="100% completion" top /> | none | <TokCell shallow="46.0" deep="14.5" /> | 2h56 |
| [<ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" adapter="refusal-ablation LoRA 1.0" kv="f16" effort="xhigh" page="/binaries/bonsai2-prism-ptq1" />](../benchmarks/bonsai-2-27b.md) | 32048 | <ScoreCell value="0.976/0.945" sub="100% completion" top /> | none | <TokCell shallow="40.8" deep="22.0" /> | 4h34 |
| [<ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" page="/binaries/bonsai2-prism-ptq1" />](../benchmarks/bonsai-2-27b.md) | 32048 | <ScoreCell value="0.970/0.939" sub="100% completion" /> | none | <TokCell shallow="42.1" deep="22.4" /> | 3h16 |
<!-- gen:model-evalplus:end -->

Every run of this model on this machine, best base score first. The empties column carries the cause word ([what the words mean](../../../benchmarks/evalplus.md#limits-on-local-hardware)).

The scored run carries a server thinking budget of 25209 tokens, from a
calibration whose longest converged reasoning ran 16806 tokens. Seven
problems hit the budget and were forced to answer; three passed, and
the four that failed hit the 30000-token cap unconverged in the natural
re-run, so no forced answer was late and the budget needed no
correction. The owner's word on how a budgeted score is shown is
pending.

## Agentic quality — Mendel

<!-- gen:model-mendel:start -->
Blind test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" page="/binaries/bonsai2-prism-ptq1" /> | blind-v1.1 | 128k | **82** | 8/8/done | 88.4 | 15,676k | 127k | 1 | 258 | 17 |  |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PQ2_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" page="/binaries/bonsai2-prism-pq2" /> | blind-v1.1 | 112k | **77** | 8/8/done | 74.7 | 14,833k | 110k | 1 | 230 | 13 |  |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" adapter="refusal-ablation LoRA 1.0" kv="f16" effort="xhigh" page="/binaries/bonsai2-prism-ptq1" /> | blind-v1.1 | 128k | **75** | 8/8/done | 82.0 | 17,259k | 127k | 1 | 269 | 15 |  |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" page="/binaries/bonsai2-prism-ptq1" /> | blind-v1.1 | 256k | **73.5** | 8/8/done | 123.1 | 25,992k | 225k | 0 | 254 | 17 |  |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PQ2_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" page="/binaries/bonsai2-prism-pq2" /> | blind-v1.1 | 208k | **60.5** | 8/8/done | 92.4 | 19,572k | 193k | 0 | 245 | 16 |  |

The window cell is the harness context window of that run. Rows before the KV pick of 2026-09-04 carry the type their runbook served, or `q8_0` where no record names one.
<!-- gen:model-mendel:end -->

The window cell is the harness context window of that run.

The blind row lost its points to judgment, not to the harness: a
CRITICAL trap-C regression that deletes the debug manifest in an exit
hook, a missed trap B, no dependency pruning at all, and Prettier left
failing. Test discipline and commit craft scored near full.

Full data: [the benchmarks page](../benchmarks/bonsai-2-27b.md).
