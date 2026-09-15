# Mendel — RTX 5060 Ti 16 GB

One real repository task with known traps, scored on a 100-point
rubric by the open-source
[Mendel](https://github.com/irae/mendel/tree/benchmark) project;
method and house rules in
[the methodology](../../../methodology/mendel). The **blind** test
gives a terse prompt and asks whether the model finds the traps by
itself; the **guided** test hands every model the same plan with the
traps disclosed. Scores never compare across the two tests. The
tables show only the runs made on this machine; the cloud anchors are
the same for every setup.

## Local models — blind test

<!-- gen:mendel-local:start -->
| Model / Config | Score | Wall | Ctx / speed | Tokens | Ctx use | Bugs | Stats |
|---|--:|--:|--:|--:|--:|---|---|
| [<ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="q8_0" effort="xhigh" />](../reports/qwen3.8-27b.md) | <ScoreCell value="91" top /> | **75 min** | <span class="ctxuse">**64k**<br><TokCell shallow="29.43" deep="21.13" top-shallow top-deep /></span> | 93k | <span class="ctxuse">**405%**<br><span class="ms-pill cs-pill cs-pill-yellow">3 compactions</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">1 medium</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">2 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 257/25</span> <span class="ms-pill cs-pill cs-pill-gray">commits 17</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-red">failed commits 1</span> <span class="ms-pill cs-pill cs-pill-gray">turns 239</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 73%</span></span> |
<!-- gen:mendel-local:end -->

The columns are the ones of the reference setup's
[Mendel page](../../kamaji/benchmarks/mendel.md#legend). On this
machine the blind test runs only for a build whose guided row
finished all eight libraries.

## Cloud reference — blind test

<!-- gen:mendel-cloud:start -->
| model | harness | score |
|---|---|--:|
| kimi-k3 | pi | **93.5/100** |
| grok-4.6 | pi | **92.5/100** |
| gpt-5.6-sol | pi | **92/100** |
| claude-opus-5 | pi | **90.5/100** |
| deepseek-v4-flash-0731 | pi | **84.5/100** |
| gpt-5.6-luna | pi | **83.5/100** |
| deepseek-v4-pro-0813 | pi | **79/100** |
| glm-5p3-flash | pi | **75/100** |
| Claude Sonnet 4.5 | pi | **43.5/100** |
| claude-haiku-4.5 | pi | **34/100** |
<!-- gen:mendel-cloud:end -->

## Guided test

Local rows on the current guided prompt; the cloud anchors on the
same prompt follow.

<!-- gen:mendel-guided:start -->
| Model / Config | Score | Wall | Ctx / speed | Tokens | Ctx use | Bugs | Stats |
|---|--:|--:|--:|--:|--:|---|---|
| [<ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="q8_0" effort="xhigh" />](../reports/qwen3.8-27b.md) | <ScoreCell value="85" top /> | 215 min | <span class="ctxuse">64k<br><TokCell shallow="29.43" deep="21.13" /></span> | 161k | <span class="ctxuse">2394%<br><span class="ms-pill cs-pill cs-pill-yellow">23 compactions</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">1 critical</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">1 medium</span> <span class="ms-pill cs-pill cs-pill-gray">1 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 320/9</span> <span class="ms-pill cs-pill cs-pill-gray">commits 8</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">turns 290</span> <span class="ms-pill cs-pill cs-pill-yellow">nudges 5t</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 62%</span></span> |
| [<ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="q8_0" effort="xhigh" />](../reports/qwen3.8-27b.md) | <ScoreCell value="79" note="88%" top /> | 286 min | <span class="ctxuse">64k<br><TokCell shallow="29.36" deep="20.92" /></span> | 188k | <span class="ctxuse">3594%<br><span class="ms-pill cs-pill cs-pill-yellow">35 compactions</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">2 medium</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">3 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 332/16</span> <span class="ms-pill cs-pill cs-pill-gray">commits 7</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-red">failed commits 1</span> <span class="ms-pill cs-pill cs-pill-gray">turns 315</span> <span class="ms-pill cs-pill cs-pill-yellow">nudges 10t</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 70%</span></span> |
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/2" kv="q8_0" effort="on" />](../reports/qwen3.6-35b-a3b.md) | <ScoreCell value="48.5" note="75%" /> | **27 min** | <span class="ctxuse">**96k**<br><TokCell shallow="61.16" deep="45.42" top-shallow top-deep /></span> | 47k | <span class="ctxuse">**191%**<br><span class="ms-pill cs-pill cs-pill-yellow">1 compaction</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">2 critical</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">1 medium</span> <span class="ms-pill cs-pill cs-pill-gray">4 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 266/25</span> <span class="ms-pill cs-pill cs-pill-gray">commits 6</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-red">failed commits 1</span> <span class="ms-pill cs-pill cs-pill-gray">turns 213</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 59%</span></span> |
| [<ModelSpec base="Gemma-4-26B-A4B" quant="NVFP4Q8" server="llama-server" publisher="catlilface" repo="catlilface/Gemma-4-26B-A4B-NVFP4-GGUF" kv="f16" effort="on" />](../reports/gemma-4-26b-a4b.md) | <ScoreCell value="37.5" note="38%" /> | **23 min** | <span class="ctxuse">**96k**<br><TokCell shallow="58.77" deep="45.59" top-shallow top-deep /></span> | 45k | <span class="ctxuse">**196%**<br><span class="ms-pill cs-pill cs-pill-yellow">1 compaction</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">2 medium</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">4 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 137/13</span> <span class="ms-pill cs-pill cs-pill-gray">commits 6</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-red">failed commits 1</span> <span class="ms-pill cs-pill cs-pill-gray">turns 139</span> <span class="ms-pill cs-pill cs-pill-red">loop thinking</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 91%</span></span> |
| [<ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="off" />](../reports/gemma-4-12b-it.md) | <ScoreCell value="0" note="0%" /> | **1 min** | <span class="ctxuse">**256k**<br><TokCell shallow="49.55" deep="33.11" /></span> | 2k | **5%** | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">1 critical</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">model-failed</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 30/6</span> <span class="ms-pill cs-pill cs-pill-gray">commits 0</span> <span class="ms-pill cs-pill cs-pill-gray">turns 31</span></span> |
| [<ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="on" />](../reports/gemma-4-12b-it.md) | <ScoreCell value="0" note="0%" /> | **5 min** | <span class="ctxuse">**256k**<br><TokCell shallow="47.39" deep="32.18" /></span> | 13k | **10%** | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">1 critical</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">model-failed</span> <span class="ms-pill cs-pill cs-pill-gray">calls 17/2</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">commits 0</span> <span class="ms-pill cs-pill cs-pill-gray">turns 19</span> <span class="ms-pill cs-pill cs-pill-red">loop thinking</span></span> |
| [<ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="on" />](../reports/gemma-4-12b-it.md) | <ScoreCell value="0" note="0%" /> | **6 min** | <span class="ctxuse">**256k**<br><TokCell shallow="49.55" deep="33.11" /></span> | 14k | **15%** | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">1 critical</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">model-failed</span> <span class="ms-pill cs-pill cs-pill-gray">calls 24/0</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">commits 0</span> <span class="ms-pill cs-pill cs-pill-gray">turns 25</span> <span class="ms-pill cs-pill cs-pill-red">loop thinking</span></span> |
<!-- gen:mendel-guided:end -->

Cloud anchors on the same guided prompt:

<!-- gen:mendel-guided-cloud:start -->
| model | harness | score |
|---|---|--:|
| glm-5p3-flash | pi | **98/100** |
| deepseek-v4-flash-0731 | pi | **97/100** |
| gpt-5.6-luna | pi | **88.5/100** |
| claude-sonnet-4.5 | pi | **88/100** |
| Claude Haiku 4.5 | pi | **76/100** |
<!-- gen:mendel-guided-cloud:end -->

## Stale rows

Valid local rows on an older prompt version of either test.

<!-- gen:mendel-stale:start -->
No stale row.
<!-- gen:mendel-stale:end -->

## Full reports

The hosted reports, generated from the Mendel data, for the curious:
the <a href="../../../mendel/report.html" target="_blank" rel="noreferrer">blind report</a>
and the <a href="../../../mendel/report-guided.html" target="_blank" rel="noreferrer">guided report</a>,
with the criteria matrix, cost tables and defect ledger. The tables
on this page come from the mirrored result files in
`benchmarks/mendel/` (`npm run docs:tables`).
