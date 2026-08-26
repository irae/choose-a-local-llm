# Night 1 EvalPlus results

Timing is clean-run only where meaningful: wall-clock from the final,
successful attempt's server start to its evaluate finish. Restarts/bugfixing
time is excluded so configs compare fairly on speed; incident counts are
noted separately. Timing is secondary to scoring per the user — treat it as
approximate, not exact.

**Known limitation, all three blocks**: `max_tokens=3072` was too low for
these thinking/reasoning models — the model's reasoning sometimes consumes
the whole token budget before it writes an answer, leaving `content` empty
(scored as a hard failure). This was discovered mid-run on block 3, verified
as a real, generic problem (not EvalPlus-specific — see state.md's research
notes), and deliberately NOT fixed for tonight so all three blocks stay
apples-to-apples under the same flawed setting. Every score below is a
lower bound on the model's real capability, worst for block 2. See state.md
for the full incident history and a real calibration method for next time.

| block | model | config | pass@1 base | pass@1 plus | samples | empty rate | clean start | clean finish | clean duration | incidents |
|---|---|---|---|---|---|---|---|---|---|---|
| qwen38-mlx-medium | mlx-community/Qwen3.8-27B-4bit | mlx_lm.server, reasoning_effort=medium | 0.970 | 0.939 | 164/164 | 3/164 (~2%) | 01:47 | 04:34 | ~2h47m | 2 failed attempts before this one (dataset-download hang from a firewall block, None-content codegen crash) + a post-hoc scoring bug (wrong samples file graded first, fixed and rescored, ~1 min re-run cost folded into clean finish); see state.md for root causes and fixes |
| qwen36-think | qwen3.6-35b-a3b | llama-server+MTP, thinking on | 0.610 | 0.610 | 164/164 | 62/164 (~38%) | 04:38 | 06:35 | ~1h57m | none — clean run on the first attempt, fixes from block 1 held. Worst-affected by the max_tokens finding; real score likely notably higher |
| bonsai-think | prism-ml/Ternary-Bonsai-27B-mlx-2bit | mlx_lm.server, thinking on | 0.640 | 0.634 | 164/164 | 49/164 (~30%) | 13:47 (final resume) | 18:44 | not clean — see state.md | Most complex block: dataset-download hang, None-content crash, RLIMIT_AS macOS bug, wrong-file-graded bug (all shared/fixed early), then a dedicated max_tokens investigation mid-run — briefly fixed (raised to 16000, verified 0 empty) then deliberately reverted to 3072 for apples-to-apples consistency with blocks 1/2, per the user's decision. Full history in state.md |

## Not run tonight

Blocks 4 (gemma26-think) and 5 (gemma12-think) were not started — the user
paused the run after block 3 to review the max_tokens finding. Available to
run on a future night, ideally with a properly calibrated `max_tokens` per
model rather than reusing 3072.
