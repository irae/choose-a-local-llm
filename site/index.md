# Choosing a Local Coding LLM

Measured decode speed at depth, real-memory context limits, HumanEval+ coding quality, and end-to-end agent scores on real consumer hardware. **325h+** of non-overlapping local compute (**110** scored runs, **8** models, **2** machines, **9,444** tool calls, **427** commits; **339.5h** with documented diagnostic runs — see [Benchmarks](/benchmarks/)).

## Winners by Machine

- **[Apple M1 Max 32 GB](/setups/m1-max-32gb/):** [Qwen3.8-27B](/models/qwen3.8-27b) Q4_K_M (`f16` KV, no drafter, `xhigh`) leads at **93/100 blind** (8/8 libraries, 0 critical defects, `72k` ctx, `12.4 → 9.7 tok/s`), matching frontier cloud models. For deeper context, 3-bit [Qwen3.8-27B](/models/qwen3.8-27b) reaches `147k` (`80.5/100` blind); [Qwen3.6-35B-A3B](/models/qwen3.6-35b-a3b) holds `43.7 → 13.0 tok/s` at `82k` (`83/100` guided).
- **[RTX 5060 Ti 16 GB](/setups/rtx-5060ti-16gb/):** [Qwen3.8-27B](/models/qwen3.8-27b) IQ3_S-mtp (`q8_0` KV, no drafter, `xhigh`) leads at **91/100 blind** / **85/100 guided** (`65k` ctx, `29.4 → 21.1 tok/s`) and is the author's sole daily-driver local config (~6–12 h/month for personal finance automation). For 120k–240k windows, [Ternary-Bonsai-2-27B](/models/bonsai-2-27b) hits **82/100 blind** (`135k`, `PTQ1_0` `f16`) and `240k` on `q8_0` KV (`73.5/100`, 0 compactions).

## Best Configuration per Model

<!-- gen:home-best-per-model:start -->
| Model / Config | Ctx | tok/s | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/files/qwen38-bartowski-q4km" model-page="/models/qwen3.8-27b" hide="server" top /> | 72k | <TokCell shallow="12.4" deep="9.7" cap="mem" /> | <ScoreCell value="0.982/0.951" sub="100% completion" top /> | <ScoreCell value="93" pill="mendel-blind" top /> | <span title="EvalPlus 5h04 · Mendel 3h33">8h38</span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" hardware="m1-max-32gb" page="/files/qwen36-unsloth-ud-q4kxl" model-page="/models/qwen3.6-35b-a3b" hide="server" top /> | 82k | <TokCell shallow="43.7" deep="13.0" cap="speed" top-shallow /> | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="83" pill="mendel-guided" top /> | <span title="EvalPlus 2h27 · Mendel 1h32"><b>3h59</b></span> |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" hardware="rtx-5060ti-16gb" page="/files/bonsai2-prism-ptq1" model-page="/models/bonsai-2-27b" hide="server" top /> | 135k | <TokCell shallow="42.1" deep="22.4" cap="mem" top-shallow top-deep /> | <ScoreCell value="0.976/0.945" sub="100% completion" top /> | <ScoreCell value="82" pill="mendel-blind" top /> | <span title="EvalPlus 2h05 · Mendel 1h28"><b>3h33</b></span> |
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" hardware="m1-max-32gb" page="/files/gemma26-unsloth-ud-q4kxl" model-page="/models/gemma-4-26b-a4b" hide="server" /> | **197k** | <TokCell shallow="60.1" deep="19.1" cap="mem" top-shallow /> | <ScoreCell value="0.988/0.957" sub="100% completion" top /> | <ScoreCell value="47.5" pill="mendel-blind" /> | <span title="EvalPlus 1h57 · Mendel 1h21"><b>3h18</b></span> |
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" hardware="m1-max-32gb" page="/files/gemma12-unsloth-ud-q4kxl" model-page="/models/gemma-4-12b-it" hide="server" /> | **245k** | <TokCell shallow="25.0" deep="9.2" cap="mem" /> | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="37.5" note="38%" pill="mendel-guided" /> | <span title="EvalPlus 0h43 · Mendel 1h38"><b>2h21</b></span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/files/bonsai-mlx-2bit" model-page="/models/bonsai-27b" hide="server" /> | 40k | <TokCell shallow="24.5" deep="17.3" cap="mem" stale /> | <ScoreCell value="0.933/0.902" sub="99% completion" /> | <ScoreCell value="37.5†" note="38%" pill="mendel-blind" /> | <span title="EvalPlus 19h24 · Mendel 5h00">24h24</span> |
| <ModelSpec base="Arete-27B" quant="Q3_K_M" server="llama-server" publisher="bartowski" repo="bartowski/NousResearch_Arete-27B-GGUF" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/files/arete-bartowski-q3km" model-page="/models/arete-27b" hide="server" /> | 64k | <TokCell shallow="27.60" deep="20.07" cap="mem" top-deep /> | <ScoreCell value="0.976/0.951" sub="100% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 3h24 · Mendel —">3h24†</span> |
| <ModelSpec base="S5-nano" quant="BF16" server="llama-server" publisher="maritaca-ai" repo="maritaca-ai/S5-nano-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/files/s5-nano-maritaca-bf16" model-page="/models/s5-nano" hide="server" /> | **204k** | <TokCell shallow="45.68" deep="26.41" cap="mem" top-shallow top-deep /> | <ScoreCell value="0.841/0.774" sub="100% completion" /> | <ScoreCell value="0" note="0%" pill="failed-smoke" /> | <span title="EvalPlus 3h42 · Mendel —">3h42†</span> |

† from an earlier serving config or method; re-run pending.
<!-- gen:home-best-per-model:end -->

## Four Empirical Laws

1. **An 8192 thinking budget fixes single-turn benchmarks without hurting agents.** Under fast mode (`8192` think / `16384` output), thinking-on beats thinking-off on every pair with zero empties. Across 12 re-runs of forced failures, zero passed with more thinking; normal Mendel turns peak near ~1,400 thinking tokens.
2. **HumanEval+ is a gate, not an agent predictor.** [Gemma-4-12B](/models/gemma-4-12b-it) UD-Q4_K_XL leads HumanEval+ (**0.988 / 0.963**) yet scores **0/100** on Mendel (zero commits).
3. **Hardware flips optimal configs — never copy flags across machines.** On Metal, `f16` KV beats `q8_0`, MTP hurts dense 27Bs, and `PTQ1_0` beats `PQ2_0` by 4× context. On CUDA, `q8_0` KV doubles 27B context cleanly, MTP accelerates decode where VRAM fits, and `PQ2_0` decodes faster.
4. **Shallow speed hides deep collapse.** Dense layer offload (`-ngl 45/64`) collapses to `5.1 → 2.3 tok/s`; MoE expert offload (`--n-cpu-moe`) holds `45+ tok/s` at `97k`.

## Run This on Your Hardware

Read the [scientific method](/method/), browse [all 25 model files](/files/), or follow the [operator guide on GitHub](https://github.com/irae/choose-a-local-llm/blob/master/docs/repo/README.md).
