# S5-nano

Compact 4B-class reasoning model (`maritaca-ai/S5-nano-GGUF`) measured on RTX 5060 Ti 16 GB under `llama.cpp` v0.9.0 (`b12110`). Fast with huge context, but not viable as a coding agent.

## Verdict

- **Failed the coding-agent gate on both quants:** Both `Q8_0` (`q8_0` KV) and `BF16` (`f16` KV) failed the Mendel tool-calling smoke — deleting the fixture's `.git` directory and committing against the outer repository — so full Mendel runs were skipped.
- **High speed and deep context:** `Q8_0` / `q8_0` KV reaches the full `261k` context cap (`-c 262144`, harness window `258,048`) at **77.37 → 30.59 tok/s** in `10.9 GiB` VRAM. `BF16` / `f16` KV reaches `203,776` clean tokens (`-c 204800`, window `200,704`) at **45.68 → 26.41 tok/s** in `15.5 GiB` VRAM (`37%` slower at 32K than `Q8_0`/`q8_0`).
- **Single-turn coding quality:** Passes the `0.800` base gate with thinking on — **0.811 / 0.726** on `Q8_0` (`26/164` forced) and **0.841 / 0.774** on `BF16` / `f16` KV (`31/164` forced, measured at `-c 65536`). Thinking-off (`Q8_0` Instruct) drops to **0.720 / 0.634** (`0` forced), confirming thinking helps even at 4B scale.

## Configurations

<!-- gen:model-configs:start -->
| Model / Config | Ctx | tok/s | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|
| <ModelSpec base="S5-nano" quant="BF16" server="llama-server" publisher="maritaca-ai" repo="maritaca-ai/S5-nano-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/files/s5-nano-maritaca-bf16" hide="server" /> | **204k** | <TokCell shallow="45.68" deep="26.41" cap="mem" top-shallow top-deep /> | <ScoreCell value="0.841/0.774" sub="100% completion" top /> | <ScoreCell value="0" note="0%" pill="failed-smoke" /> | <span title="EvalPlus 3h42 · Mendel —">3h42†</span> |
| <ModelSpec base="S5-nano" quant="Q8_0" server="llama-server" publisher="maritaca-ai" repo="maritaca-ai/S5-nano-GGUF" kv="q8_0" effort="on" hardware="rtx-5060ti-16gb" page="/files/s5-nano-maritaca-q8" hide="server" /> | **261k** | <TokCell shallow="77.37" deep="30.59" cap="mem" top-shallow top-deep /> | <ScoreCell value="0.811/0.726" sub="100% completion" top /> | <ScoreCell value="0" note="0%" pill="failed-smoke" /> | <span title="EvalPlus 1h56 · Mendel —">1h56†</span> |
<!-- gen:model-configs:end -->

## Decode Speed vs Context Depth

<!-- gen:model-curves:start -->
<DecodePlot :series='[{"name":"rtx-5060ti-16gb, Q8_0, q8_0 KV, no drafter, -c 256K","served":true,"points":[[4096,77.37],[24576,69],[32768,66.01],[65536,56.76],[131072,44.29],[196608,36.16],[245760,31.76],[261120,30.59]]},{"name":"rtx-5060ti-16gb, BF16, f16 KV, no drafter, -c 200K","served":false,"points":[[4096,45.68],[24576,42.46],[32768,41.35],[65536,37.31],[131072,31.23],[203776,26.41]]}]' />

| arm | 4K | 24K | 32K | 64K | 128K | 192K | 240K | 256K |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| rtx-5060ti-16gb, Q8_0, q8_0 KV, no drafter, -c 256K | <CurveCell value="77.37" served /> | <CurveCell value="69.0" served /> | <CurveCell value="66.01" served /> | <CurveCell value="56.76" served /> | <CurveCell value="44.29" served /> | <CurveCell value="36.16" depth="192.0K" served /> | <CurveCell value="31.76" served /> | <CurveCell value="30.59" served /> |
| rtx-5060ti-16gb, BF16, f16 KV, no drafter, -c 200K | <CurveCell value="45.68" /> | <CurveCell value="42.46" /> | <CurveCell value="41.35" /> | <CurveCell value="37.31" /> | <CurveCell value="31.23" /> | <CurveCell value="26.41" depth="199.0K" /> |  |  |

The served arm of each config is in bold. A pill under a reading shows its exact depth when arms in that column differed.
<!-- gen:model-curves:end -->

## HumanEval+

<!-- gen:model-evalplus:start -->
| config | think | budget | Scores | empties | forced | tok/s | wall |
|---|--:|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="S5-nano" quant="BF16" server="llama-server" publisher="maritaca-ai" repo="maritaca-ai/S5-nano-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/files/s5-nano-maritaca-bf16" /> | 8192 | 16384 | <ScoreCell value="0.841/0.774" sub="100% completion" top /> | none | 31/164 | <TokCell shallow="45.68" deep="26.41" /> | 3h42 |
| <ModelSpec base="S5-nano" quant="Q8_0" server="llama-server" publisher="maritaca-ai" repo="maritaca-ai/S5-nano-GGUF" kv="q8_0" effort="on" hardware="rtx-5060ti-16gb" page="/files/s5-nano-maritaca-q8" /> | 8192 | 16384 | <ScoreCell value="0.811/0.726" sub="100% completion" top /> | none | 26/164 | <TokCell shallow="77.37" deep="30.59" /> | 1h56 |
| <ModelSpec base="S5-nano" quant="Q8_0" server="llama-server" publisher="maritaca-ai" repo="maritaca-ai/S5-nano-GGUF" kv="q8_0" effort="off" hardware="rtx-5060ti-16gb" page="/files/s5-nano-maritaca-q8" /> | none | 16384 | <ScoreCell value="0.720/0.634" sub="100% completion" /> | none | 0/164 | <TokCell shallow="77.37" deep="30.59" /> | 0h26 |
<!-- gen:model-evalplus:end -->

## Mendel Agent Runs

<!-- gen:model-mendel:start -->
No agent run yet.
<!-- gen:model-mendel:end -->

## Model Files

<!-- gen:model-files:start -->
- [S5-nano Q8_0 (Maritaca AI)](/files/s5-nano-maritaca-q8) — RTX 5060 Ti 16 GB
- [S5-nano BF16 (Maritaca AI)](/files/s5-nano-maritaca-bf16) — RTX 5060 Ti 16 GB
<!-- gen:model-files:end -->
