# Qwen3.8-27B

Every config of this model, on every machine, best first.

<!-- gen:model-all:start -->
| Model / Config | Ctx | Cap | tok/s | HumanEval+ | Coding | Wall |
|---|--:|:--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" hardware="m1-max-32gb" hide="server" top /> | 72k | mem | <TokCell shallow="12.4" deep="9.7" /> | <ScoreCell value="0.957/0.939" sub="96% completion" /> | <ScoreCell value="93" pill="mendel-blind" top /> | <span title="EvalPlus 8h30 · Mendel 3h33">12h04</span> |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" hide="server" top /> | 65k | mem | <TokCell shallow="29.43" deep="21.13" top-shallow top-deep /> | <ScoreCell value="0.945/0.909" sub="96% completion" /> | <ScoreCell value="91" pill="mendel-blind" top /> | <span title="EvalPlus 3h38 · Mendel 1h15">4h53</span> |
| <ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" kv="f16" effort="medium" hardware="m1-max-32gb" hide="server" top /> | 72k | mem | <TokCell shallow="12.4" deep="9.7" /> | <ScoreCell value="0.982/0.939" sub="100% completion" top /> | <ScoreCell value="87" pill="mendel-blind" top /> | <span title="EvalPlus 3h32 · Mendel 2h09">5h42</span> |
| <ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" hardware="m1-max-32gb" hide="server" top /> | **147k** | speed | <TokCell shallow="13.60" deep="7.97" /> | <ScoreCell value="0.945/0.927" sub="100% completion" /> | <ScoreCell value="90.5" pill="mendel-blind" top /> | <span title="EvalPlus 10h16 · Mendel 3h05">13h21</span> |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="xhigh" hardware="m1-max-32gb" hide="server" top /> | **147k** | speed | <TokCell shallow="14.1" deep="8.1" /> | <ScoreCell value="0.945/0.921" sub="97% completion" /> | <ScoreCell value="80.5" pill="mendel-blind" top /> | <span title="EvalPlus 9h43 · Mendel 1h49">11h33</span> |
| <ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" hide="server" top /> | 65k | mem | <TokCell shallow="29.36" deep="20.92" top-shallow top-deep /> | <ScoreCell value="0.957/0.921" sub="98% completion" /> | <ScoreCell value="79" note="88%" pill="mendel-guided" top /> | <span title="EvalPlus 4h50 · Mendel 4h46">9h36</span> |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" drafter="mtp/3" kv="f16" effort="medium" hardware="m1-max-32gb" hide="server" top /> | **128k** | mem | <TokCell shallow="15.1" deep="9.7" stale /> | <ScoreCell value="0.976/0.945" sub="99% completion" top /> | <ScoreCell value="76.5" pill="mendel-blind" /> | <span title="EvalPlus 3h12 · Mendel 2h15">5h27</span> |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="low" hardware="m1-max-32gb" hide="server" /> | **147k** | speed | <TokCell shallow="14.1" deep="8.1" /> | <ScoreCell value="0.976/0.933" sub="99% completion" top /> | <ScoreCell value="66" note="88%" pill="mendel-blind" /> | <span title="EvalPlus 2h27 · Mendel 2h43">5h10</span> |
| <ModelSpec base="Qwen3.8-27B" quant="AD-IQ3_S" server="llama-server" publisher="AtomicChat" repo="AtomicChat/Qwen3.8-27B-GGUF" kv="f16" effort="medium" hardware="m1-max-32gb" hide="server" /> | 104k | mem | <TokCell shallow="14.3" deep="9.6" /> | <ScoreCell value="0.988/0.927" sub="100% completion" top /> | <ScoreCell value="37.5" note="38%" pill="mendel-blind" /> | <span title="EvalPlus 3h11 · Mendel 1h00">4h10</span> |
| <ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" effort="low" hardware="m1-max-32gb" hide="server" /> | 25k | mem | <TokCell shallow="17.3" deep="14.8" /> | <ScoreCell value="0.976/0.927" sub="100% completion" top /> | <ScoreCell value="12.5†" note="13%" pill="mendel-blind" /> | <span title="EvalPlus 2h09 · Mendel 1h25">3h34</span> |
| <ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" effort="medium" hardware="m1-max-32gb" hide="server" /> | 25k | mem | <TokCell shallow="17.3" deep="14.8" /> | <ScoreCell value="0.982/0.939" sub="100% completion" top /> | <ScoreCell value="not run" /> | <span title="EvalPlus 3h32 · Mendel —">3h32†</span> |

† from an earlier serving config or method; re-run pending.
<!-- gen:model-all:end -->

## What the numbers say

- **The agent pick on both machines.** On the M1 Max the 4-bit GGUF
  scores 93 blind at effort xhigh on a 65K window. On the RTX 5060 Ti
  the ISTA 3-bit scores 85 guided and 91 blind on a 61K window, at
  about twice the Mac's speed.
- **Effort xhigh is the level.** It is the model's published default.
  Medium is not run again on this model: it thinks long and does not
  conclude on agent work, and every medium row on this site is a
  record, not a target. Low is the other level worth a try.
- **Two 3-bit builds for one 12 GB budget.** unsloth UD-IQ3_S and ISTA
  IQ3_S-mtp are two providers' trade-offs of one model. On the
  single-turn test they sit within one point of each other on both
  machines. On the agent task the ISTA build leads on the card and the
  unsloth build on the Mac, one run each.
- **The drafter is a speed decision, never a quality one.** On the Mac
  the dense builds serve without it, because on real text it loses at
  every depth. On the card every drafter arm reads faster, but it costs
  VRAM the desktop also needs, and the agent rows serve without it.
- **The slowest model here, and its empties are its thinking.** At
  xhigh a few problems never converge inside the output budget on both
  machines. A thinking budget on the server is under test on this model
  ([method](../methodology/evalplus.md#unproven-yet-a-thinking-budget-instead-of-a-larger-output-budget)).
