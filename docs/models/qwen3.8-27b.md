# Qwen3.8-27B

Every config of this model, on every machine, best first.

<!-- gen:model-all:start -->
| Model / Config | Ctx | tok/s | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/binaries/qwen38-bartowski-q4km" hide="server" top /> | 72k | <TokCell shallow="12.4" deep="9.7" cap="mem" /> | <ScoreCell value="0.957/0.939" sub="96% completion" /> | <ScoreCell value="93" pill="mendel-blind" top /> | <span title="EvalPlus 8h30 · Mendel 3h33">12h04</span> |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/qwen38-ista-iq3s-mtp" hide="server" top /> | 65k | <TokCell shallow="29.43" deep="21.13" cap="mem" top-shallow top-deep /> | <ScoreCell value="0.945/0.909" sub="96% completion" /> | <ScoreCell value="91" pill="mendel-blind" top /> | <span title="EvalPlus 3h38 · Mendel 1h15"><b>4h53</b></span> |
| <ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" kv="f16" effort="medium" hardware="m1-max-32gb" page="/binaries/qwen38-bartowski-q4km" hide="server" top /> | 72k | <TokCell shallow="12.4" deep="9.7" cap="mem" /> | <ScoreCell value="0.982/0.939" sub="100% completion" top /> | <ScoreCell value="87" pill="mendel-blind" top /> | <span title="EvalPlus 3h32 · Mendel 2h09"><b>5h42</b></span> |
| <ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/binaries/qwen38-unsloth-ud-iq3s" hide="server" top /> | **147k** | <TokCell shallow="13.60" deep="7.97" cap="speed" /> | <ScoreCell value="0.945/0.927" sub="100% completion" /> | <ScoreCell value="90.5" pill="mendel-blind" top /> | <span title="EvalPlus 13h36 · Mendel 3h05">16h41</span> |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/binaries/qwen38-ista-iq3s-mtp" hide="server" top /> | **147k** | <TokCell shallow="14.1" deep="8.1" cap="speed" /> | <ScoreCell value="0.945/0.921" sub="97% completion" /> | <ScoreCell value="80.5" pill="mendel-blind" top /> | <span title="EvalPlus 9h43 · Mendel 1h49">11h33</span> |
| <ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/qwen38-unsloth-ud-iq3s" hide="server" top /> | 65k | <TokCell shallow="29.36" deep="20.92" cap="mem" top-shallow top-deep /> | <ScoreCell value="0.957/0.921" sub="98% completion" /> | <ScoreCell value="79" note="88%" pill="mendel-guided" top /> | <span title="EvalPlus 4h50 · Mendel 4h46">9h36</span> |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" drafter="mtp/3" kv="f16" effort="medium" hardware="m1-max-32gb" page="/binaries/qwen38-ista-iq3s-mtp" hide="server" top /> | **128k** | <TokCell shallow="15.1" deep="9.7" cap="mem" stale /> | <ScoreCell value="0.976/0.945" sub="99% completion" top /> | <ScoreCell value="76.5" pill="mendel-blind" /> | <span title="EvalPlus 3h12 · Mendel 2h15"><b>5h27</b></span> |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="low" hardware="m1-max-32gb" page="/binaries/qwen38-ista-iq3s-mtp" hide="server" /> | **147k** | <TokCell shallow="14.1" deep="8.1" cap="speed" /> | <ScoreCell value="0.976/0.933" sub="99% completion" top /> | <ScoreCell value="66" note="88%" pill="mendel-blind" /> | <span title="EvalPlus 2h27 · Mendel 2h43"><b>5h10</b></span> |
| <ModelSpec base="Qwen3.8-27B" quant="AD-IQ3_S" server="llama-server" publisher="AtomicChat" repo="AtomicChat/Qwen3.8-27B-GGUF" kv="f16" effort="medium" hardware="m1-max-32gb" page="/binaries/qwen38-atomicchat-ad-iq3s" hide="server" /> | 104k | <TokCell shallow="14.3" deep="9.6" cap="mem" /> | <ScoreCell value="0.988/0.927" sub="100% completion" top /> | <ScoreCell value="37.5" note="38%" pill="mendel-blind" /> | <span title="EvalPlus 3h11 · Mendel 1h00"><b>4h10</b></span> |
| <ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" effort="low" hardware="m1-max-32gb" page="/binaries/qwen38-mlx-4bit" hide="server" /> | 25k | <TokCell shallow="17.3" deep="14.8" cap="mem" /> | <ScoreCell value="0.976/0.927" sub="100% completion" top /> | <ScoreCell value="12.5†" note="13%" pill="mendel-blind" /> | <span title="EvalPlus 2h09 · Mendel 1h25"><b>3h34</b></span> |
| <ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" effort="medium" hardware="m1-max-32gb" page="/binaries/qwen38-mlx-4bit" hide="server" /> | 25k | <TokCell shallow="17.3" deep="14.8" cap="mem" /> | <ScoreCell value="0.982/0.939" sub="100% completion" top /> | <ScoreCell value="not run" /> | <span title="EvalPlus 3h32 · Mendel —">3h32†</span> |
| <ModelSpec base="Qwen3.8-27B" quant="Q3_K_M" server="llama-server" publisher="OBLITERATUS" repo="OBLITERATUS/Qwen3.8-27B-OBLITERATED" kv="q8_0" effort="medium" hardware="rtx-5060ti-16gb" page="/binaries/qwen38-obliteratus-q3km" hide="server" /> | 65k | <TokCell shallow="22.67" deep="16.74" cap="mem" /> | <ScoreCell value="0.854/0.787" sub="100% completion" /> | <ScoreCell value="0" note="0%" pill="failed-smoke" /> | <span title="EvalPlus 1h29 · Mendel —">1h29†</span> |

† from an earlier serving config or method; re-run pending.
<!-- gen:model-all:end -->

## Files

Every file of this model, on every machine that served it, with every run and a log.

<!-- gen:model-binaries:start -->
- [Qwen3.8-27B Q4_K_M (bartowski)](../binaries/qwen38-bartowski-q4km.md) — m1-max-32gb
- [Qwen3.8-27B IQ3_S-mtp (ISTA-DASLab)](../binaries/qwen38-ista-iq3s-mtp.md) — m1-max-32gb, rtx-5060ti-16gb
- [Qwen3.8-27B UD-IQ3_S (unsloth)](../binaries/qwen38-unsloth-ud-iq3s.md) — m1-max-32gb, rtx-5060ti-16gb
- [Qwen3.8-27B AD-IQ3_S (AtomicChat)](../binaries/qwen38-atomicchat-ad-iq3s.md) — m1-max-32gb
- [Qwen3.8-27B UD-Q3_K_XL (unsloth)](../binaries/qwen38-unsloth-ud-q3kxl.md) — m1-max-32gb
- [Qwen3.8-27B MLX 4-bit (mlx-community)](../binaries/qwen38-mlx-4bit.md) — m1-max-32gb
- [Qwen3.8-27B Q3_K_M (OBLITERATUS)](../binaries/qwen38-obliteratus-q3km.md) — rtx-5060ti-16gb
<!-- gen:model-binaries:end -->

## Quality — EvalPlus HumanEval+

<!-- gen:model-evalplus:start -->
| config | budget | Scores | empties | tok/s | wall |
|---|--:|--:|--:|--:|--:|
| [<ModelSpec base="Qwen3.8-27B" quant="AD-IQ3_S" server="llama-server" publisher="AtomicChat" repo="AtomicChat/Qwen3.8-27B-GGUF" drafter="mtp/3" kv="f16" effort="medium" hardware="m1-max-32gb" page="/binaries/qwen38-atomicchat-ad-iq3s" />](../setups/kamaji/benchmarks/qwen3.8-27b.md) | 8886 | <ScoreCell value="0.988/0.927" sub="100% completion" top /> | none | <TokCell shallow="14.3" deep="9.6" /> | 3h11 |
| [<ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" effort="medium" hardware="m1-max-32gb" page="/binaries/qwen38-mlx-4bit" />](../setups/kamaji/benchmarks/qwen3.8-27b.md) | 8192 | <ScoreCell value="0.982/0.939" sub="100% completion" top /> | none | <TokCell shallow="17.3" deep="14.8" /> | 3h32 |
| [<ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" drafter="mtp/3" kv="f16" effort="medium" hardware="m1-max-32gb" page="/binaries/qwen38-ista-iq3s-mtp" />](../setups/kamaji/benchmarks/qwen3.8-27b.md) | 8192 | <ScoreCell value="0.976/0.945" sub="99% completion" top /> | 1 budget | <TokCell shallow="15.1" deep="9.7" /> | 3h12 |
| [<ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="low" hardware="m1-max-32gb" page="/binaries/qwen38-ista-iq3s-mtp" />](../setups/kamaji/benchmarks/qwen3.8-27b.md) | 8192 | <ScoreCell value="0.976/0.933" sub="99% completion" top /> | 1 budget | <TokCell shallow="14.1" deep="8.1" /> | 2h27 |
| [<ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" drafter="mtp/3" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/binaries/qwen38-bartowski-q4km" />](../setups/kamaji/benchmarks/qwen3.8-27b.md) | 30000 | <ScoreCell value="0.957/0.939" sub="96% completion" /> | 6 budget | <TokCell shallow="12.4" deep="9.7" /> | 8h30 |
| [<ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/qwen38-unsloth-ud-iq3s" />](../setups/arrietty/benchmarks/qwen3.8-27b.md) | 19000 | <ScoreCell value="0.957/0.921" sub="98% completion" /> | † unproven | <TokCell shallow="29.36" deep="20.92" /> | 4h50 |
| [<ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/binaries/qwen38-unsloth-ud-iq3s" />](../setups/kamaji/benchmarks/qwen3.8-27b.md) | 20000 | <ScoreCell value="0.945/0.927" sub="95% completion" /> | 8 budget | <TokCell shallow="13.60" deep="7.97" /> | 13h36 |
| [<ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/binaries/qwen38-ista-iq3s-mtp" />](../setups/kamaji/benchmarks/qwen3.8-27b.md) | 30000 | <ScoreCell value="0.945/0.921" sub="97% completion" /> | 5 budget | <TokCell shallow="14.1" deep="8.1" /> | 9h43 |
| [<ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/qwen38-ista-iq3s-mtp" />](../setups/arrietty/benchmarks/qwen3.8-27b.md) | 20500 | <ScoreCell value="0.945/0.909" sub="96% completion" /> | † unproven | <TokCell shallow="29.43" deep="21.13" /> | 3h38 |
| [<ModelSpec base="Qwen3.8-27B" quant="Q3_K_M" server="llama-server" publisher="OBLITERATUS" repo="OBLITERATUS/Qwen3.8-27B-OBLITERATED" kv="q8_0" effort="medium" hardware="rtx-5060ti-16gb" page="/binaries/qwen38-obliteratus-q3km" />](../setups/arrietty/benchmarks/qwen3.8-27b.md) | 6034 | <ScoreCell value="0.854/0.787" sub="98% completion" /> | model | <TokCell shallow="22.67" deep="16.74" /> | 1h29 |
<!-- gen:model-evalplus:end -->

Every run of this model on every machine, best base score first. The empties column carries the cause word ([what the words mean](../benchmarks/evalplus.md#limits-on-local-hardware)).

## Agent task — Mendel

<!-- gen:model-mendel:start -->
Blind test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" drafter="mtp/3" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/binaries/qwen38-bartowski-q4km" /> | blind-v1.1 | ?k | **93** | 8/8/done | NaN | — | — | 0 | 0 | 0 |  |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/qwen38-ista-iq3s-mtp" /> | blind-v1.1 | ?k | **91** | 8/8/done | NaN | — | — | 0 | 0 | 0 |  |
| <ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/binaries/qwen38-unsloth-ud-iq3s" /> | blind-v1.1 | ?k | **90.5** | 8/8/done | NaN | — | — | 0 | 0 | 0 |  |
| <ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" drafter="mtp/3" kv="f16" effort="medium" hardware="m1-max-32gb" page="/binaries/qwen38-bartowski-q4km" /> | blind-v1.1 | ?k | **87** | 8/8/done | NaN | — | — | 0 | 0 | 0 |  |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/binaries/qwen38-ista-iq3s-mtp" /> | blind-v1.1 | ?k | **80.5** | 8/8/done | NaN | — | — | 0 | 0 | 0 |  |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" drafter="mtp/3" kv="f16" effort="medium" hardware="m1-max-32gb" page="/binaries/qwen38-ista-iq3s-mtp" /> | blind-v1.1 | ?k | **76.5** | 8/8/done | NaN | — | — | 0 | 0 | 0 |  |
| <ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" drafter="mtp/3" kv="f16" effort="medium" hardware="m1-max-32gb" page="/binaries/qwen38-bartowski-q4km" /> | blind-v1.1 | ?k | **76** | 8/8/done | NaN | — | — | 0 | 0 | 0 |  |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="low" hardware="m1-max-32gb" page="/binaries/qwen38-ista-iq3s-mtp" /> | blind-v1.1 | ?k | **66** | 7/8/done | NaN | — | — | 0 | 0 | 0 |  |
| <ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" effort="medium" hardware="m1-max-32gb" page="/binaries/qwen38-mlx-4bit" /> | blind-v1.0 | ?k | **37.5** (raw 80) | 3/8/done | NaN | — | — | 0 | 0 | 0 |  |
| <ModelSpec base="Qwen3.8-27B" quant="AD-IQ3_S" server="llama-server" publisher="AtomicChat" repo="AtomicChat/Qwen3.8-27B-GGUF" drafter="mtp/3" kv="f16" effort="medium" hardware="m1-max-32gb" page="/binaries/qwen38-atomicchat-ad-iq3s" /> | blind-v1.1 | ?k | **37.5** | 3/8/done | NaN | — | — | 0 | 0 | 0 |  |
| <ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" effort="low" hardware="m1-max-32gb" page="/binaries/qwen38-mlx-4bit" /> | blind-v1.1 | ?k | **12.5** (raw 67.5) | 1/8/done | NaN | — | — | 0 | 0 | 0 |  |

Guided test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/qwen38-ista-iq3s-mtp" /> | guided-v3.0 | ?k | **85** | 8/8/done | NaN | — | — | 0 | 0 | 0 |  |
| <ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/qwen38-unsloth-ud-iq3s" /> | guided-v3.0 | ?k | **79** | 7/8/done | NaN | — | — | 0 | 0 | 0 |  |
| <ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" effort="low" hardware="m1-max-32gb" page="/binaries/qwen38-mlx-4bit" /> | guided-v2.1 | ?k | **75** (raw 84) | 6/8/done | NaN | — | — | 0 | 0 | 0 |  |
| <ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/binaries/qwen38-unsloth-ud-iq3s" /> | guided-v3.0 | ?k | **62.5** | 5/8/done | NaN | — | — | 0 | 0 | 0 |  |

The window cell is the harness context window of that run. Rows before the KV pick of 2026-09-04 carry the type their runbook served, or `q8_0` where no record names one.
<!-- gen:model-mendel:end -->

The window cell is the harness context window of that run.

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
  ([method](../methodology/evalplus.md#unproven-yet-a-thinking-budget-instead-of-a-larger-output-budget)):
  the 4-bit build on the Mac, forced to answer at 30000 thinking
  tokens, scored 0.982 / 0.951 with no empty answer, against
  0.957 / 0.939 with six empties without the flag.
