# Bonsai on the fork at f16 KV: the EvalPlus gate

Unscheduled. Needs hardware: yes, one EvalPlus run of a few hours.

The scheduled work serves this model on the PrismML fork at f16 KV and
measures its depth, then runs the agent task there. This item is the
quality half of the same change.

The published score, 0.927 base with 98 percent completion, was
measured at q4_0 KV with the vendor's calibration file. The project's
own rule says an aggressive or calibrated quant never shares a score
and passes the gate separately, so the reverse also holds: a config
that drops that calibration is not covered by the score the
calibration earned. f16 KV is lossless where q4 was corrected, so the
score should hold or improve, and that is an assumption until it is
measured.

What it needs when it runs: the fork's serving command at f16 KV with
the `-c` the scheduled creep found, the calibrated budget of 10240,
thinking on, and the standard EvalPlus procedure.

It is not urgent. The agent run decides whether the f16 arm is worth
keeping at all; the gate only matters if it is.
