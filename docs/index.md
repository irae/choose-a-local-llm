# Local coding models, measured

Which local model, runtime and config to code with, per machine. Every
number comes from an OpenAI-compatible server that a coding harness
uses.

## Best config per model

The label under each name is the machine.

<!-- gen:models-evaluated:all:start -->
| Model / Config | Ctx | tok/s | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/binaries/qwen38-bartowski-q4km" hide="server" top /> | 72k | <TokCell shallow="12.4" deep="9.7" cap="mem" /> | <ScoreCell value="0.957/0.939" sub="96% completion" /> | <ScoreCell value="93" pill="mendel-blind" top /> | <span title="EvalPlus 8h30 · Mendel 3h33">12h04</span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" hardware="m1-max-32gb" page="/binaries/qwen36-unsloth-ud-q4kxl" hide="server" top /> | 82k | <TokCell shallow="43.7" deep="13.0" cap="speed" top-shallow /> | <ScoreCell value="0.957/0.939" sub="99% completion" /> | <ScoreCell value="83" pill="mendel-guided" top /> | <span title="EvalPlus 5h02 · Mendel 1h32">6h33</span> |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PQ2_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-pq2" hide="server" /> | **208k** | <TokCell shallow="46.0" deep="14.5" cap="mem" top-shallow /> | <ScoreCell value="0.982/0.939" sub="100% completion" top /> | <ScoreCell value="59.5" pill="mendel-blind" /> | <span title="EvalPlus 2h56 · Mendel 1h32">4h29</span> |
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/gemma26-unsloth-ud-q4kxl" hide="server" /> | **197k** | <TokCell shallow="60.1" deep="19.1" cap="mem" top-shallow top-deep /> | <ScoreCell value="0.896/0.872" sub="90% completion" /> | <ScoreCell value="47.5" pill="mendel-blind" /> | <span title="EvalPlus 5h47 · Mendel 1h21">7h08</span> |
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" hardware="m1-max-32gb" page="/binaries/gemma12-unsloth-ud-q4kxl" hide="server" /> | **245k** | <TokCell shallow="25.0" deep="9.2" cap="mem" /> | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="37.5" note="38%" pill="mendel-guided" /> | <span title="EvalPlus 0h43 · Mendel 1h38">2h21</span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-mlx-2bit" hide="server" /> | 40k | <TokCell shallow="24.5" deep="17.3" cap="mem" stale top-deep /> | <ScoreCell value="0.933/0.902" sub="99% completion" /> | <ScoreCell value="37.5†" note="38%" pill="mendel-blind" /> | <span title="EvalPlus 19h24 · Mendel 5h00">24h24</span> |

† from an earlier serving config or method; re-run pending.
<!-- gen:models-evaluated:all:end -->

¹ LM Studio's MLX engine, retired ([why](./setups/kamaji/lmstudio-retired.md)).
² PrismML's llama.cpp fork, an approved exception to the no-forks rule.

#### Legend

- **Ctx**: the deepest context served at 8 tok/s or more. The harness
  window is Ctx rounded down to a multiple of 4096; on MLX, 5 percent
  under the measured ceiling.
- **Cap**: `mem`, memory ran out first; `speed`, decode fell under
  8 tok/s first.
- **tok/s**: decode on real code text, near an empty context → at
  Ctx.
- **HumanEval+**: EvalPlus pass@1, base over plus, and the share of
  problems that finished inside the output budget (cap 30000 tokens).
- **Coding**: the Mendel score out of 100, a multi-turn agent task on
  a real repository with known traps. The pill names the test, blind
  or guided. A muted percentage is the share of libraries done when
  the run did not finish. `model-failed`: zero commits.
- **Wall**: active time of the scored EvalPlus run plus the scored
  Mendel run, pauses removed. Hover for each part. † one part has no
  time yet. Not part of the sort.
- **Sort**: the average of EvalPlus base × 100 and Coding; a missing
  score counts as 0. EvalPlus, then Ctx, break ties.

## Machines

| machine | runtimes | pages |
|---|---|---|
| M1 Max 32 GB, `m1-max-32gb` | llama-server, mlx_lm.server, PrismML fork | [comparison](./setups/kamaji/comparison.md) · [setup](./setups/kamaji/index.md) · [historical](./setups/kamaji/historical.md) |
| RTX 5060 Ti 16 GB, `rtx-5060ti-16gb` | llama-server, CUDA | [comparison](./setups/arrietty/comparison.md) · [setup](./setups/arrietty/index.md) |

Every config of one model on every machine: [Models](./models/).

## Method

Read [the methodology](./methodology.md) before you run anything.
Speed is read at depth: one real session read 1.7 tok/s at 135K used
tokens, on a config that read 62 tok/s near an empty context.
