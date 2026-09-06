# The shared-score rule needs a quant exception in the owner's words

Status: pending owner decision. Filed 2026-09-05.
Needs hardware: no.

`docs/methodology.md`, "Score the quant, once per model", says runtimes
serving the same model at a standard quant share the EvalPlus score.
Run 9 scored Gemma-4-12B's GGUF Q4_K_XL at 0.976/0.939 thinking off,
0.067 above its LM Studio MLX 4-bit at 0.909/0.872, so two standard
quants of one model can carry their own scores.

The comparison page footnote already says "until a measurement says
otherwise" and names the pair. The method page needs one sentence from
the owner: when two quants of one model both get scored, and what
difference makes them separate rows (the 0.012 threshold bench 9 used,
or another).
