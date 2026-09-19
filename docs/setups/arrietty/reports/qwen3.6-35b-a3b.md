# Qwen3.6-35B-A3B on RTX 5060 Ti 16 GB

Backends: llama-server · [GGUF on Hugging Face](https://huggingface.co/unsloth/Qwen3.6-35B-A3B-MTP-GGUF)

<!-- gen:model-kpis:start -->
<div class="kpis">
  <div class="kpi"><b>21</b><span>expert layers in host RAM, MTP n-max 2</span></div>
  <div class="kpi"><b>0.945 / 0.902</b><span>EvalPlus base / plus, q8_0 KV, thinking on</span><small>96% completion</small></div>
  <div class="kpi"><b>48.5</b><span>Mendel guided, UD-Q4_K_XL, thinking on</span></div>
</div>
<!-- gen:model-kpis:end -->

Speed, context, drafter arms and the guided agent task measured 2026-09-13 to 2026-09-15; EvalPlus scored 2026-09-16 at thinking on.

## Highlights

- **A 23 GB file on a 16 GB card.** Part of the experts stay in host
  RAM; the row records how many layers, found by a ladder at
  `-c 98304`.
- **97K at 61.2 → 45.4 tok/s** with the MTP drafter at n-max 2.
- **EvalPlus 0.945 / 0.902 at thinking on, 6 of 164 empty**, in 192
  minutes on the drafter arm. The Mac reads 0.957 / 0.939 with 2 empty
  on the same file.

## All configs — this model

<!-- gen:model-table:start -->
| Model / Config | Ctx | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/2" offload="n-cpu-moe 21" kv="q8_0" effort="on" page="/binaries/qwen36-unsloth-ud-q4kxl" top /> | **97k** | <TokCell shallow="61.16" deep="45.42" cap="mem" top-shallow top-deep /> | **14.7 GB** | <ScoreCell value="0.945/0.902" sub="96% completion" top /> | <ScoreCell value="48.5" note="75%" pill="mendel-guided" top /> | <span title="EvalPlus 3h12 · Mendel 0h27"><b>3h39</b></span> |
<!-- gen:model-table:end -->

## Configs

Each table row above is one config; start it with its block below.

<!-- gen:model-configs:start -->
<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/2" offload="n-cpu-moe 21" kv="q8_0" effort="on" page="/binaries/qwen36-unsloth-ud-q4kxl" />

pi id `qwen3.6-35b-a3b-q4kxl`. The build the reference setup serves, with the MTP drafter embedded in the file. The file is larger than the card, so a measured count of expert layers stays in host RAM, and the drafter needs more of the card's memory than no drafter: no drafter serves `-c 98304` at `--n-cpu-moe 17` (55.8 tok/s at 4K, 37.8 at 97K), n-max 1 at 19 (60.6, 37.9), n-max 2 and 3 at 21 (61.2 and 45.4 for n-max 2; 57.9 and 46.8 for n-max 3). n-max 2 is the served arm: fastest at 4K and 65K, and within the spread of n-max 3 at 97K. A community NVFP4 repack was tried first and failed to load (a tensor-count defect); the owner chose the mainstream build over a niche one (2026-09-14). The guided task scored 48.5, 6 of 8 libraries, and ended on a loop at the seventh; three of its commits moved the pre-commit hook aside. EvalPlus at thinking on, scored 2026-09-16 on the drafter arm at `-c 32768`, budget 24154 from the standard formula: 0.945/0.902, 6 empty answers of 164 whose cause is unproven because the run saved no finish log, in 192.0 minutes of active time. The Mac's thinking-on row of the same model reads 0.939/0.921 with five empty answers, so this card scores higher on the base metric and lower on `plus`, with one empty answer more. Swap stayed flat, although the host held only 1.1 to 1.5 GB free with this configuration.

```bash
llama-server -m "$(hf download unsloth/Qwen3.6-35B-A3B-MTP-GGUF Qwen3.6-35B-A3B-UD-Q4_K_XL.gguf)" \
  --alias qwen3.6-35b-a3b-q4kxl --no-mmproj --parallel 1 \
  --spec-type draft-mtp --spec-draft-n-max 2 \
  -ngl 999 --fit off --n-cpu-moe 21 -fa on -c 98304 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --jinja --port 8081
```
<!-- gen:model-configs:end -->

## Model details and findings

- **The mainstream build, not a niche one.** The same unsloth
  UD-Q4_K_XL file the reference setup serves; a community NVFP4 repack
  was tried first and failed to load, and the owner's word is a popular
  stable release over a niche build. The MTP drafter is measured on
  real text, from no drafter up, before the row is served.

- **97K at 61 → 45 tok/s** with the drafter at n-max 2 and 21 expert
  layers in host RAM. Every drafter arm reads faster than no drafter;
  each step of draft depth needs two more layers in host RAM.
- **The guided task scored 48.5, 6 of 8**, and ended on a loop of five
  identical edits at the seventh library. Two critical bugs shipped:
  a `.then()` on `fs.promises.glob`, and test files that call
  `fs.globSync` with no `fs` import. It found and fixed the
  `mendel-requirify` rimraf references.
- **Three commits moved the pre-commit hook aside** and back, a bypass
  the scorer's automatic check does not see. The two bugs shipped in
  those commits.
- **EvalPlus at thinking on:** 0.945/0.902, 6 empty answers of 164,
  budget 24154 from the standard formula, 192.0 minutes, the drafter
  arm at q8_0 KV. The Mac's row of the same file and level reads
  0.957 / 0.939 with 2 empty, so this card scores lower on both metrics
  with one run each side. The cause of the 6 empties is unproven
  because the run saved no finish log. Thinking off is not scored on
  this card; on the Mac it takes 15 minutes at 0.951 / 0.915.

## Quality — EvalPlus HumanEval+

<!-- gen:model-evalplus:start -->
| config | budget | Scores | empties | tok/s | wall |
|---|--:|--:|--:|--:|--:|
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/2" offload="n-cpu-moe 21" kv="q8_0" effort="on" page="/binaries/qwen36-unsloth-ud-q4kxl" />](../benchmarks/qwen3.6-35b-a3b.md) | 24154 | <ScoreCell value="0.945/0.902" sub="96% completion" top /> | † unproven | <TokCell shallow="61.16" deep="45.42" /> | 3h12 |
<!-- gen:model-evalplus:end -->

Every run of this model on this machine, best base score first. The empties column carries the cause word ([what the words mean](../../../benchmarks/evalplus.md#limits-on-local-hardware)).

## Agentic quality — Mendel

<!-- gen:model-mendel:start -->
Guided test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/2" kv="q8_0" effort="on" page="/binaries/qwen36-unsloth-ud-q4kxl" /> | guided-v3.0 | 96k | **48.5** | 6/8/partial | 27.2 | 10,958k | 86k | 1 | 266 | 6 |  |

The window cell is the harness context window of that run. Rows before the KV pick of 2026-09-04 carry the type their runbook served, or `q8_0` where no record names one.
<!-- gen:model-mendel:end -->

Full data: [the benchmarks page](../benchmarks/qwen3.6-35b-a3b.md).
