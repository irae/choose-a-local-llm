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
<!-- gen:mendel-local:end -->

The columns are the ones of the reference setup's
[Mendel page](../../m1-max-32gb/benchmarks/mendel.md#legend). On this
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
| [<ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="off" />](../reports/gemma-4-12b-it.md) | <ScoreCell value="0" note="0%" top /> | **1 min** | <span class="ctxuse">**256k**<br><TokCell shallow="49.55" deep="33.11" top-shallow top-deep /></span> | 2k | **5%** | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">1 critical</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">model-failed</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 30/6</span> <span class="ms-pill cs-pill cs-pill-gray">commits 0</span> <span class="ms-pill cs-pill cs-pill-gray">turns 31</span></span> |
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
