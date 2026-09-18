# Qwen3.6-35B-A3B

Every config of this model, on every machine, best first.

<!-- gen:model-all:start -->
| Model / Config | Ctx | tok/s | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" hardware="m1-max-32gb" page="/binaries/qwen36-unsloth-ud-q4kxl" hide="server" top /> | **82k** | <TokCell shallow="43.7" deep="13.0" cap="speed" /> | <ScoreCell value="0.957/0.939" sub="99% completion" top /> | <ScoreCell value="83" pill="mendel-guided" top /> | <span title="EvalPlus 5h02 · Mendel 1h32">6h33</span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="off" hardware="m1-max-32gb" page="/binaries/qwen36-unsloth-ud-q4kxl" hide="server" top /> | **82k** | <TokCell shallow="43.7" deep="13.0" cap="speed" /> | <ScoreCell value="0.951/0.915" sub="100% completion" top /> | <ScoreCell value="62.5" pill="mendel-guided" top /> | <span title="EvalPlus 0h15 · Mendel 1h29">1h44</span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/qwen36-unsloth-ud-q4kxl" hide="server" top /> | 66k | <TokCell shallow="50.5" deep="33.6" cap="mem" stale /> | <ScoreCell value="0.957/0.939" sub="99% completion" top /> | <ScoreCell value="50" pill="mendel-blind" /> | <span title="EvalPlus 5h02 · Mendel 0h33">5h35</span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/2" kv="q8_0" effort="on" hardware="rtx-5060ti-16gb" page="/binaries/qwen36-unsloth-ud-q4kxl" hide="server" /> | **97k** | <TokCell shallow="61.16" deep="45.42" cap="mem" top-shallow top-deep /> | <ScoreCell value="0.945/0.902" sub="96% completion" /> | <ScoreCell value="48.5" note="75%" pill="mendel-guided" /> | <span title="EvalPlus 3h12 · Mendel 0h27">3h39</span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.6-35B-A3B-4bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/qwen36-mlx-4bit" hide="server" /> | 37k | <TokCell shallow="54.5" deep="39.1" cap="mem" /> | <ScoreCell value="0.957/0.939" sub="99% completion" top /> | <ScoreCell value="37.5" note="38%" pill="mendel-blind" /> | <span title="EvalPlus 5h02 · Mendel 0h19">5h20</span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/qwen36-unsloth-ud-q4kxl" hide="server" /> | 41k | <TokCell shallow="69.1" deep="52.6" cap="mem" stale top-shallow top-deep /> | <ScoreCell value="0.957/0.939" sub="99% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 5h02 · Mendel —">5h02†</span> |

† from an earlier serving config or method; re-run pending.
<!-- gen:model-all:end -->

## Files

Every file of this model, on every machine that served it, with every run and a log.

<!-- gen:model-binaries:start -->
- [Qwen3.6-35B-A3B UD-Q4_K_XL (unsloth)](../binaries/qwen36-unsloth-ud-q4kxl.md) — m1-max-32gb, rtx-5060ti-16gb
- [Qwen3.6-35B-A3B MLX 4-bit (mlx-community)](../binaries/qwen36-mlx-4bit.md) — m1-max-32gb
- [Qwen3.6-35B-A3B NVFP4 (michaelw9999)](../binaries/qwen36-michaelw9999-nvfp4.md) — rtx-5060ti-16gb
<!-- gen:model-binaries:end -->

## Quality — EvalPlus HumanEval+

<!-- gen:model-evalplus:start -->
| config | budget | Scores | empties | tok/s | wall |
|---|--:|--:|--:|--:|--:|
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" hardware="m1-max-32gb" page="/binaries/qwen36-unsloth-ud-q4kxl" />](../setups/kamaji/benchmarks/qwen3.6-35b-a3b.md) | 26624 | <ScoreCell value="0.957/0.939" sub="99% completion" top /> | 2 budget | <TokCell shallow="43.7" deep="13.0" /> | 5h02 |
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="off" hardware="m1-max-32gb" page="/binaries/qwen36-unsloth-ud-q4kxl" />](../setups/kamaji/benchmarks/qwen3.6-35b-a3b.md) | 8192 | <ScoreCell value="0.951/0.915" sub="100% completion" top /> | none | <TokCell shallow="43.7" deep="13.0" /> | 0h15 |
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/2" kv="q8_0" effort="on" hardware="rtx-5060ti-16gb" page="/binaries/qwen36-unsloth-ud-q4kxl" />](../setups/arrietty/benchmarks/qwen3.6-35b-a3b.md) | 24154 | <ScoreCell value="0.945/0.902" sub="96% completion" /> | † unproven | <TokCell shallow="61.16" deep="45.42" /> | 3h12 |
<!-- gen:model-evalplus:end -->

Every run of this model on every machine, best base score first. The empties column carries the cause word ([what the words mean](../benchmarks/evalplus.md#limits-on-local-hardware)).

## Agent task — Mendel

<!-- gen:model-mendel:start -->
Blind test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" hardware="m1-max-32gb" page="/binaries/qwen36-unsloth-ud-q4kxl" /> | blind-v1.1 | ?k | **63** | 8/8/done | NaN | — | — | 0 | 0 | 0 |  |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="off" hardware="m1-max-32gb" page="/binaries/qwen36-unsloth-ud-q4kxl" /> | blind-v1.1 | ?k | **50.5** | 8/8/done | NaN | — | — | 0 | 0 | 0 |  |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/qwen36-unsloth-ud-q4kxl" /> | blind-v1.1 | ?k | **50** | 8/8/done | NaN | — | — | 0 | 0 | 0 |  |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" hardware="m1-max-32gb" page="/binaries/qwen36-unsloth-ud-q4kxl" /> | blind-v1.0 | ?k | **41.5** | 8/8/done | NaN | — | — | 0 | 0 | 0 |  |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.6-35B-A3B-4bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/qwen36-mlx-4bit" /> | blind-v1.1 | ?k | **37.5** | 3/8/done | NaN | — | — | 0 | 0 | 0 |  |

Guided test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" hardware="m1-max-32gb" page="/binaries/qwen36-unsloth-ud-q4kxl" /> | guided-v3.0 | ?k | **83** | 8/8/done | NaN | — | — | 0 | 0 | 0 |  |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" hardware="m1-max-32gb" page="/binaries/qwen36-unsloth-ud-q4kxl" /> | guided-v2.1 | ?k | **65.5** | 8/8/done | NaN | — | — | 0 | 0 | 0 |  |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="off" hardware="m1-max-32gb" page="/binaries/qwen36-unsloth-ud-q4kxl" /> | guided-v3.0 | ?k | **62.5** | 8/8/done | NaN | — | — | 0 | 0 | 0 |  |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/2" kv="q8_0" effort="on" hardware="rtx-5060ti-16gb" page="/binaries/qwen36-unsloth-ud-q4kxl" /> | guided-v3.0 | ?k | **48.5** | 6/8/done | NaN | — | — | 0 | 0 | 0 |  |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="off" hardware="m1-max-32gb" page="/binaries/qwen36-unsloth-ud-q4kxl" /> | guided-v3.0 | ?k | **46.5** | 8/8/done | NaN | — | — | 0 | 0 | 0 |  |

The window cell is the harness context window of that run. Rows before the KV pick of 2026-09-04 carry the type their runbook served, or `q8_0` where no record names one.
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
