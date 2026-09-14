# EvalPlus (HumanEval+) — RTX 5060 Ti 16 GB

The quality gate: pass@1 at temperature 0, output budget calibrated
per model; see [the method](../../../methodology/evalplus). Scores
are shared across serving configs when thinking mode, effort, and
quant match.

No EvalPlus score exists on this machine yet. The first run skips the
gate on the owner's word (2026-09-13), so its agent rows carry that
note. A NVFP4 build is a new quant, so it gets its own score when one
is measured; it does not share the k-quant's.

<!-- gen:evalplus-table:start -->
| config | budget | pass@1 base | pass@1 plus | empty | completion |
|---|--:|--:|--:|--:|--:|
<!-- gen:evalplus-table:end -->
