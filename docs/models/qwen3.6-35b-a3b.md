# Qwen3.6-35B-A3B

Every config of this model, on every machine, best first.

<!-- gen:model-all:start -->
| Model / Config | Ctx | Cap | tok/s | HumanEval+ | Coding | Wall |
|---|--:|:--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" hardware="m1-max-32gb" page="/setups/kamaji/binaries/qwen36-unsloth-ud-q4kxl" hide="server" top /> | **82k** | speed | <TokCell shallow="43.7" deep="13.0" /> | <ScoreCell value="0.957/0.939" sub="99% completion" top /> | <ScoreCell value="83" pill="mendel-guided" top /> | <span title="EvalPlus 5h02 · Mendel 1h32">6h33</span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="off" hardware="m1-max-32gb" page="/setups/kamaji/binaries/qwen36-unsloth-ud-q4kxl" hide="server" top /> | **82k** | speed | <TokCell shallow="43.7" deep="13.0" /> | <ScoreCell value="0.951/0.915" sub="100% completion" top /> | <ScoreCell value="62.5" pill="mendel-guided" top /> | <span title="EvalPlus 0h15 · Mendel 1h29">1h44</span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" kv="f16" effort="on" hardware="m1-max-32gb" page="/setups/kamaji/binaries/qwen36-unsloth-ud-q4kxl" hide="server" top /> | 66k | mem | <TokCell shallow="50.5" deep="33.6" stale /> | <ScoreCell value="0.957/0.939" sub="99% completion" top /> | <ScoreCell value="50" pill="mendel-blind" /> | <span title="EvalPlus 5h02 · Mendel 0h33">5h35</span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/2" kv="q8_0" effort="on" hardware="rtx-5060ti-16gb" page="/setups/arrietty/binaries/qwen36-unsloth-ud-q4kxl" hide="server" /> | **97k** | mem | <TokCell shallow="61.16" deep="45.42" top-shallow top-deep /> | <ScoreCell value="0.945/0.902" sub="96% completion" /> | <ScoreCell value="48.5" note="75%" pill="mendel-guided" /> | <span title="EvalPlus 3h12 · Mendel 0h27">3h39</span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.6-35B-A3B-4bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/setups/kamaji/binaries/qwen36-mlx-4bit" hide="server" /> | 37k | mem | <TokCell shallow="54.5" deep="39.1" /> | <ScoreCell value="0.957/0.939" sub="99% completion" top /> | <ScoreCell value="37.5" note="38%" pill="mendel-blind" /> | <span title="EvalPlus 5h02 · Mendel 0h19">5h20</span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="f16" effort="on" hardware="m1-max-32gb" page="/setups/kamaji/binaries/qwen36-unsloth-ud-q4kxl" hide="server" /> | 41k | mem | <TokCell shallow="69.1" deep="52.6" stale top-shallow top-deep /> | <ScoreCell value="0.957/0.939" sub="99% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 5h02 · Mendel —">5h02†</span> |

† from an earlier serving config or method; re-run pending.
<!-- gen:model-all:end -->

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
