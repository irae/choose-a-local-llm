# Arete-27B

Dense 27B reasoning model (`NousResearch_Arete-27B`, `bartowski Q3_K_M`) measured on RTX 5060 Ti 16 GB under `llama.cpp` v0.9.0 (`b12110`). Full Mendel agent evaluation is pending.

## Verdict

- **Strong quality gate and lowest forced-answer rate among 27Bs:** Fast-mode EvalPlus (`xhigh`, `8192` think / `16384` output) scored **0.976 / 0.951** (`0` empty) with only **7/164 forced answers** — the lowest forced rate of any 27B reasoning model tested.
- **Clean 64k window on 16 GB VRAM:** At `q8_0` KV with no drafter (`-c 65536`, harness window `61,440`), decode holds **27.60 → 20.07 tok/s** across `64,512` tokens at `15.4 GiB` peak VRAM (`15,771 MiB`), slightly slower than 3-bit [Qwen3.8-27B](/models/qwen3.8-27b) (`29.4 → 21.1 tok/s`) at the same window.
- **Agent status (pending):** Passed the Mendel tool-calling smoke cleanly (`14` tool calls, `1` commit, `122s`, clean tree). Full blind and guided Mendel runs are deferred to a future benchmark run, so Arete-27B is not yet ranked against finished coding agents.

## Configurations

<!-- gen:model-configs:start -->
| Model / Config | Ctx | tok/s | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|
| <ModelSpec base="Arete-27B" quant="Q3_K_M" server="llama-server" publisher="bartowski" repo="bartowski/NousResearch_Arete-27B-GGUF" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/files/arete-bartowski-q3km" hide="server" top /> | **64k** | <TokCell shallow="27.60" deep="20.07" cap="mem" top-shallow top-deep /> | <ScoreCell value="0.976/0.951" sub="100% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 3h24 · Mendel —">3h24†</span> |
<!-- gen:model-configs:end -->

## Decode Speed vs Context Depth

<!-- gen:model-curves:start -->
| arm | 4K | 24K | 32K | 64K |
|---|--:|--:|--:|--:|
| rtx-5060ti-16gb, Q3_K_M, q8_0 KV, no drafter, -c 64K | <CurveCell value="27.6" served /> | <CurveCell value="24.49" served /> | <CurveCell value="23.4" served /> | <CurveCell value="20.07" served /> |

The served arm of each config is in bold. A pill under a reading shows its exact depth when arms in that column differed.
<!-- gen:model-curves:end -->

## HumanEval+

<!-- gen:model-evalplus:start -->
| config | think | budget | Scores | empties | forced | tok/s | wall |
|---|--:|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Arete-27B" quant="Q3_K_M" server="llama-server" publisher="bartowski" repo="bartowski/NousResearch_Arete-27B-GGUF" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/files/arete-bartowski-q3km" /> | 8192 | 16384 | <ScoreCell value="0.976/0.951" sub="100% completion" top /> | none | 7/164 | <TokCell shallow="27.60" deep="20.07" /> | 3h24 |
<!-- gen:model-evalplus:end -->

## Mendel Agent Runs

<!-- gen:model-mendel:start -->
No agent run yet.
<!-- gen:model-mendel:end -->

## Model Files

<!-- gen:model-files:start -->
- [Arete-27B Q3_K_M (bartowski)](/files/arete-bartowski-q3km) — RTX 5060 Ti 16 GB
<!-- gen:model-files:end -->
