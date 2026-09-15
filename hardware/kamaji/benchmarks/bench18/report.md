# Run 18 — report

The large form of the run's status line. See
`docs/methodology/status-lines.md`, "The site comparison, in full", for
the table rules. The run measures one new build on the Mac: the unsloth
`UD-IQ3_S` file of Qwen3.8-27B, the same file the Linux setup serves,
beside the ISTA 3-bit build this machine already published. The runbook
list ran to its end.

Quality, EvalPlus at effort xhigh:

| old/new | # | Config | Budget | Base | Plus | Empty | Wall |
|---|--:|---|--:|--:|--:|--:|--:|
| old | — | Qwen3.8-27B ISTA IQ3_S-mtp, f16 KV, no drafter | 30000 | 0.945 | 0.921 | 5/164 | 583.2 |
| new | — | Qwen3.8-27B **unsloth UD-IQ3_S**, f16 KV, no drafter | **20000** | 0.945 | **0.927** | 8/164 | 615.6 |

Same base score, a higher `plus` score, at a smaller budget. The eight
empty answers have no proven cause: this run saved no finish reason.
Run 20 re-runs those eight problems.

Speed and context, real text with llama-benchy, no drafter:

| old/new | Config | Ctx | Cap | tok/s (shallow → deep) | Wired at load |
|---|---|--:|:--:|--:|--:|
| old | Qwen3.8-27B ISTA IQ3_S-mtp, f16 KV | 147k | speed | 14.1 → 8.3 | 25000 |
| new | Qwen3.8-27B **unsloth UD-IQ3_S**, f16 KV | **188k** | speed | 13.70 → 8.17 | **25911** |

The new build serves a deeper window and reads slightly slower. The
ladder found `-c 188416` as the largest value that loads; 196608 hits a
Metal out-of-memory at load. The creep stops on the 8 tok/s floor at
depth 163858, with no swap growth.

Mendel, effort xhigh:

| old/new | test | model | score | libraries | end |
|---|---|---|--:|---|---|
| old | blind | Qwen3.8-27B ISTA IQ3_S-mtp | 80.5 | 8/8 | complete |
| new | blind | Qwen3.8-27B **unsloth UD-IQ3_S** | **90.5** | 8/8 | complete |
| new | guided | Qwen3.8-27B unsloth UD-IQ3_S | 62.5 (76 raw) | 5/8 | wall_clock |

The blind row carries an anomaly: the model merged `master` into its own
branch mid-run, on its own reasoning, and imported infrastructure the
blind base hides. The coordinator kept the score and marked the row not
base-comparable. The guided row is a valid partial at the 300-minute
cap, not a failure.

Gates:

| gate | result | verdict |
|---|---|---|
| mendel smoke | 13 calls, 1 commit, no loop, 206s | pass |
| evalplus smoke | 4/4 passed both builds, 0 empty both builds | level |
| blind-row anomaly | keep the row as published, mark it not base-comparable | keep |

Items:

- The drafter `-c` search never found a fail inside its four-load
  budget, so 139264 is the deepest load tried, not a true ceiling. The
  drafter arms stay pending.
- Wired memory at the two largest passing rungs (25344 and 25911 MB)
  reads above the 25000 sysctl limit. The sysctl gates the process's
  accelerator view, not total wired memory, so the ladder rule still
  applied. Flagged for the owner.
- The EvalPlus watcher exited 42 twice during the Mendel guided block.
  Both times the server answered `/health`, so the run continued.
- `git stash clear` in `~/code/mendel-benchmark` is blocked by the Mac
  session's sandbox. The stash list read empty first, so nothing was
  lost.
- The Mendel repository has no CSV generator; the guided CSV row was
  appended from the JSON by hand.
- Origin carries a branch
  `qwen3.8-27b-iq3s-xhigh-guided-v3-issue-13-interrupted1` from an
  earlier attempt at this row. Not investigated.
