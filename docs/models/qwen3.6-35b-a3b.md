# Qwen3.6-35B-A3B

Every config of this model, on every machine, best first.

<!-- gen:model-all:start -->
| Model / Config | Ctx | tok/s | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" hardware="m1-max-32gb" page="/binaries/qwen36-unsloth-ud-q4kxl" hide="server" top /> | **82k** | <TokCell shallow="43.7" deep="13.0" cap="speed" /> | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="83" pill="mendel-guided" top /> | <span title="EvalPlus 2h27 · Mendel 1h32">3h59</span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="off" hardware="m1-max-32gb" page="/binaries/qwen36-unsloth-ud-q4kxl" hide="server" top /> | **82k** | <TokCell shallow="43.7" deep="13.0" cap="speed" /> | <ScoreCell value="0.951/0.915" sub="100% completion" /> | <ScoreCell value="62.5" pill="mendel-guided" top /> | <span title="EvalPlus 0h15 · Mendel 1h29"><b>1h44</b></span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/qwen36-unsloth-ud-q4kxl" hide="server" top /> | 66k | <TokCell shallow="50.5" deep="33.6" cap="mem" stale /> | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="50" pill="mendel-blind" /> | <span title="EvalPlus 2h27 · Mendel 0h33"><b>3h00</b></span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/2" offload="n-cpu-moe 21" kv="q8_0" effort="on" hardware="rtx-5060ti-16gb" page="/binaries/qwen36-unsloth-ud-q4kxl" hide="server" top /> | **97k** | <TokCell shallow="61.16" deep="45.42" cap="mem" top-shallow top-deep /> | <ScoreCell value="0.976/0.933" sub="100% completion" top /> | <ScoreCell value="48.5" note="75%" pill="mendel-guided" /> | <span title="EvalPlus 2h24 · Mendel 0h27"><b>2h51</b></span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.6-35B-A3B-4bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/qwen36-mlx-4bit" hide="server" /> | 37k | <TokCell shallow="54.5" deep="39.1" cap="mem" /> | <ScoreCell value="0.957/0.939" sub="99% completion" top /> | <ScoreCell value="37.5" note="38%" pill="mendel-blind" /> | <span title="EvalPlus 5h02 · Mendel 0h19">5h20</span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/qwen36-unsloth-ud-q4kxl" hide="server" /> | 41k | <TokCell shallow="69.1" deep="52.6" cap="mem" stale top-shallow top-deep /> | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 2h27 · Mendel —">2h27†</span> |

† from an earlier serving config or method; re-run pending.
<!-- gen:model-all:end -->

## Files

Every file of this model, on every machine that served it, with every run and a log.

<!-- gen:model-binaries:start -->
- [Qwen3.6-35B-A3B UD-Q4_K_XL (unsloth)](../binaries/qwen36-unsloth-ud-q4kxl.md) — m1-max-32gb, rtx-5060ti-16gb
- [Qwen3.6-35B-A3B MLX 4-bit (mlx-community)](../binaries/qwen36-mlx-4bit.md) — m1-max-32gb
- [Qwen3.6-35B-A3B NVFP4 (michaelw9999)](../binaries/qwen36-michaelw9999-nvfp4.md) — rtx-5060ti-16gb
<!-- gen:model-binaries:end -->

## Speed and context

<!-- gen:model-curve:start -->
| arm | 4K | 8K | 16K | 24K | 32K | 40K | 48K | 64K | 80K | 96K |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|
| m1-max-32gb, UD-Q4_K_XL, MTP n-max 3, f16 KV, -c 40K, wired 25000 † | <CurveCell value="69.12" /> | <CurveCell value="71.34" /> | <CurveCell value="65.66" /> | <CurveCell value="61.03" /> | <CurveCell value="56.52" depth="32.0K" /> | <CurveCell value="52.6" depth="40.0K" /> |  |  |  |  |
| rtx-5060ti-16gb, UD-Q4_K_XL, MTP n-max 2, q8_0 KV, `--n-cpu-moe 21`, -c 96K | <CurveCell value="61.16" served /> |  |  |  |  |  |  | <CurveCell value="50.04" served /> |  | <CurveCell value="45.42" depth="95.0K" served /> |
| rtx-5060ti-16gb, UD-Q4_K_XL, MTP n-max 1, q8_0 KV, `--n-cpu-moe 19`, -c 96K | <CurveCell value="60.6" /> |  |  |  |  |  |  | <CurveCell value="44.12" /> |  | <CurveCell value="37.92" depth="95.0K" /> |
| rtx-5060ti-16gb, UD-Q4_K_XL, MTP n-max 3, q8_0 KV, `--n-cpu-moe 21`, -c 96K | <CurveCell value="57.85" /> |  |  |  |  |  |  | <CurveCell value="47.25" /> |  | <CurveCell value="46.76" depth="95.0K" /> |
| rtx-5060ti-16gb, UD-Q4_K_XL, q8_0 KV, no drafter, `--n-cpu-moe 17`, -c 96K | <CurveCell value="55.81" /> |  |  |  |  |  |  | <CurveCell value="42.52" /> |  | <CurveCell value="37.8" depth="95.0K" /> |
| m1-max-32gb, 4-bit, f16 KV, no drafter, -c 36K, wired 24000 † | <CurveCell value="53.3" served /> |  | <CurveCell value="49.6" served /> |  | <CurveCell value="42.2" depth="33.0K" served /> | <CurveCell value="42.0" depth="37.0K" served /> |  |  |  |  |
| m1-max-32gb, UD-Q4_K_XL, f16 KV, no drafter, -c 64K, wired 25000 † | <CurveCell value="50.49" /> | <CurveCell value="48.41" /> | <CurveCell value="46.17" /> | <CurveCell value="43.71" /> | <CurveCell value="41.5" depth="32.0K" /> | <CurveCell value="39.32" depth="40.0K" /> | <CurveCell value="37.2" /> | <CurveCell value="33.64" /> |  |  |
| m1-max-32gb, UD-Q4_K_XL, MTP n-max 3, q8_0 KV, -c 96K, wired 25000 † |  | <CurveCell value="44.1" /> | <CurveCell value="31.15" /> | <CurveCell value="24.16" /> | <CurveCell value="19.64" depth="32.0K" /> | <CurveCell value="16.55" depth="40.0K" /> |  | <CurveCell value="11.23" /> |  | <CurveCell value="7.86" depth="96.0K" /> |
| m1-max-32gb, UD-Q4_K_XL, MTP n-max 3, q8_0 KV, -c 96K | <CurveCell value="43.68" served /> |  |  |  |  |  | <CurveCell value="19.23" served /> |  | <CurveCell value="13.01" served /> |  |

The served arm of each config is in bold. A pill under a reading is the depth it was read at, where the arms of that column did not share one.

† read with the context-creep tool of an earlier version of this project, not with `llama-benchy` on real text. The two methods do not give the same number. A reading stays until a re-run replaces it.
<!-- gen:model-curve:end -->

## Quality — EvalPlus HumanEval+

<!-- gen:model-evalplus:start -->
| config | think | budget | Scores | empties | forced | tok/s | wall |
|---|--:|--:|--:|--:|--:|--:|--:|
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" hardware="m1-max-32gb" page="/binaries/qwen36-unsloth-ud-q4kxl" />](../setups/kamaji/benchmarks/qwen3.6-35b-a3b.md) | 8192 | 16384 | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | none | 17/164 | <TokCell shallow="43.7" deep="13.0" /> | 2h27 |
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/2" offload="n-cpu-moe 21" kv="q8_0" effort="on" hardware="rtx-5060ti-16gb" page="/binaries/qwen36-unsloth-ud-q4kxl" />](../setups/arrietty/benchmarks/qwen3.6-35b-a3b.md) | 8192 | 16384 | <ScoreCell value="0.976/0.933" sub="100% completion" top /> | none | 12/164 | <TokCell shallow="61.16" deep="45.42" /> | 2h24 |
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="off" hardware="m1-max-32gb" page="/binaries/qwen36-unsloth-ud-q4kxl" />](../setups/kamaji/benchmarks/qwen3.6-35b-a3b.md) | none | 8192 | <ScoreCell value="0.951/0.915" sub="100% completion" top /> | none | — | <TokCell shallow="43.7" deep="13.0" /> | 0h15 |
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" hardware="m1-max-32gb" page="/binaries/qwen36-unsloth-ud-q4kxl" />](../setups/kamaji/benchmarks/qwen3.6-35b-a3b.md) | —† | 26624 | <ScoreCell value="0.957/0.939" sub="99% completion" /> | 2 budget | — | <TokCell shallow="43.7" deep="13.0" /> | 5h02 |
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/2" offload="n-cpu-moe 21" kv="q8_0" effort="on" hardware="rtx-5060ti-16gb" page="/binaries/qwen36-unsloth-ud-q4kxl" />](../setups/arrietty/benchmarks/qwen3.6-35b-a3b.md) | —† | 24154 | <ScoreCell value="0.945/0.902" sub="96% completion" /> | † unproven | — | <TokCell shallow="61.16" deep="45.42" /> | 3h12 |

† not fast mode: a thinking budget other than 8192, or none. Kept for the record; only fast-mode rows compare across models.
<!-- gen:model-evalplus:end -->

Every run of this model on every machine, best base score first. The empties column carries the cause word ([what the words mean](../benchmarks/evalplus.md#limits-on-local-hardware)).

## Agent task — Mendel

<!-- gen:model-mendel:start -->
Blind test:

| Model / Config | Score | Wall | Ctx / speed | Out/Total | Ctx use | Bugs | Stats |
|---|--:|--:|--:|--:|--:|---|---|
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" hardware="m1-max-32gb" page="/binaries/qwen36-unsloth-ud-q4kxl" />](../setups/kamaji/reports/qwen3.6-35b-a3b.md) | <ScoreCell value="63" top /> | 79 min | **96k** | <span class="ctxuse">40k<br><span class="ms-pill cs-pill cs-pill-gray">7.9M</span></span> | **96%** | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">1 critical</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">3 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 203/13</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">commits 13</span> <span class="ms-pill cs-pill cs-pill-gray">turns 155</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 60%</span></span> |
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="off" hardware="m1-max-32gb" page="/binaries/qwen36-unsloth-ud-q4kxl" />](../setups/kamaji/reports/qwen3.6-35b-a3b.md) | <ScoreCell value="50.5" top /> | **40 min** | **80k** | <span class="ctxuse">35k<br><span class="ms-pill cs-pill cs-pill-gray">7.0M</span></span> | <span class="ctxuse">319%<br><span class="ms-pill cs-pill cs-pill-yellow">2 compactions</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">2 critical</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">3 medium</span> <span class="ms-pill cs-pill cs-pill-gray">2 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 190/26</span> <span class="ms-pill cs-pill cs-pill-gray">commits 10</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-red">failed commits 1</span> <span class="ms-pill cs-pill cs-pill-gray">turns 162</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 34%</span></span> |
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/qwen36-unsloth-ud-q4kxl" />](../setups/kamaji/reports/qwen3.6-35b-a3b.md) | <ScoreCell value="50" top /> | **33 min** | 64k | <span class="ctxuse">42k<br><span class="ms-pill cs-pill cs-pill-gray">7.3M</span></span> | <span class="ctxuse">294%<br><span class="ms-pill cs-pill cs-pill-yellow">2 compactions</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">2 critical</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">1 medium</span> <span class="ms-pill cs-pill cs-pill-gray">3 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 211/29</span> <span class="ms-pill cs-pill cs-pill-gray">commits 13</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-red">failed commits 2</span> <span class="ms-pill cs-pill cs-pill-gray">turns 188</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 71%</span></span> |
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.6-35B-A3B-4bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/qwen36-mlx-4bit" />](../setups/kamaji/reports/qwen3.6-35b-a3b.md) | <ScoreCell value="37.5" note="38%" /> | **19 min** | 36k | <span class="ctxuse">17k<br><span class="ms-pill cs-pill cs-pill-gray">1.3M</span></span> | <span class="ctxuse">**184%**<br><span class="ms-pill cs-pill cs-pill-yellow">1 compaction</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">1 medium</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">2 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 63/9</span> <span class="ms-pill cs-pill cs-pill-gray">commits 3</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-red">failed commits 2</span> <span class="ms-pill cs-pill cs-pill-gray">turns 67</span> <span class="ms-pill cs-pill cs-pill-yellow">nudges 3m</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 58%</span></span> |

Guided test:

| Model / Config | Score | Wall | Ctx / speed | Out/Total | Ctx use | Bugs | Stats |
|---|--:|--:|--:|--:|--:|---|---|
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" hardware="m1-max-32gb" page="/binaries/qwen36-unsloth-ud-q4kxl" />](../setups/kamaji/reports/qwen3.6-35b-a3b.md) | <ScoreCell value="83" top /> | **92 min** | **120k** | <span class="ctxuse">43k<br><span class="ms-pill cs-pill cs-pill-gray">12.7M</span></span> | <span class="ctxuse">**179%**<br><span class="ms-pill cs-pill cs-pill-yellow">1 compaction</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">1 critical</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">2 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 285/25</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">commits 16</span> <span class="ms-pill cs-pill cs-pill-gray">turns 230</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 65%</span></span> |
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="off" hardware="m1-max-32gb" page="/binaries/qwen36-unsloth-ud-q4kxl" />](../setups/kamaji/reports/qwen3.6-35b-a3b.md) | <ScoreCell value="62.5" top /> | **89 min** | 80k | <span class="ctxuse">35k<br><span class="ms-pill cs-pill cs-pill-gray">13.0M</span></span> | <span class="ctxuse">**195%**<br><span class="ms-pill cs-pill cs-pill-yellow">1 compaction</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">1 critical</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">1 medium</span> <span class="ms-pill cs-pill cs-pill-gray">3 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 264/24</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">commits 16</span> <span class="ms-pill cs-pill cs-pill-gray">turns 267</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 63%</span></span> |
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/2" kv="q8_0" effort="on" hardware="rtx-5060ti-16gb" page="/binaries/qwen36-unsloth-ud-q4kxl" />](../setups/arrietty/reports/qwen3.6-35b-a3b.md) | <ScoreCell value="48.5" note="75%" /> | **27 min** | <span class="ctxuse">**92k**<br><TokCell shallow="61.16" deep="45.42" top-shallow top-deep /></span> | <span class="ctxuse">47k<br><span class="ms-pill cs-pill cs-pill-gray">11.0M</span></span> | <span class="ctxuse">**191%**<br><span class="ms-pill cs-pill cs-pill-yellow">1 compaction</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">2 critical</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">1 medium</span> <span class="ms-pill cs-pill cs-pill-gray">4 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 266/25</span> <span class="ms-pill cs-pill cs-pill-gray">commits 6</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-red">failed commits 1</span> <span class="ms-pill cs-pill cs-pill-gray">turns 213</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 59%</span></span> |
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="off" hardware="m1-max-32gb" page="/binaries/qwen36-unsloth-ud-q4kxl" />](../setups/kamaji/reports/qwen3.6-35b-a3b.md) | <ScoreCell value="46.5" /> | **96 min** | 48k | <span class="ctxuse">50k<br><span class="ms-pill cs-pill cs-pill-gray">9.5M</span></span> | <span class="ctxuse">1305%<br><span class="ms-pill cs-pill cs-pill-yellow">12 compactions</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">1 critical</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">4 medium</span> <span class="ms-pill cs-pill cs-pill-gray">5 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 299/37</span> <span class="ms-pill cs-pill cs-pill-gray">commits 7</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">turns 275</span> <span class="ms-pill cs-pill cs-pill-yellow">nudges 2m</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 58%</span></span> |

Older prompt versions of these runs are on [the agent-task page](../benchmarks/mendel.md).
<!-- gen:model-mendel:end -->

The window cell is the harness context window of that run.

## What the numbers say

- **The fast one with a real window.** On the M1 Max the q8_0 KV arm
  with its drafter serves 82K at 43.7 → 13.0 tok/s. On the RTX 5060 Ti
  the same file serves 97K at 61 → 45 tok/s with 21 expert layers in
  host RAM.
- **Thinking on is the level for agent work**: 83 guided against 62.5
  at thinking off on the Mac, on the same window. Thinking off is the
  single-turn pick: the whole gate runs in 15 minutes at 0.951 / 0.915
  against 0.957 / 0.939 in five hours.
- **The mainstream build, not a niche one.** unsloth UD-Q4_K_XL with
  the embedded MTP drafter on both machines. A community NVFP4 repack
  failed to load on the card, and the owner's word is a popular stable
  release over a niche build.
- **The card scores under the Mac on the same file, one run each
  side**: 0.945 / 0.902 with 6 empty against 0.957 / 0.939 with 2, and
  48.5 guided against 83. The card's empties are unproven; a blind
  agent row on the card is pending.
- **One context at a time.** The harness almost never runs parallel
  contexts, so no multi-slot row is scored.
