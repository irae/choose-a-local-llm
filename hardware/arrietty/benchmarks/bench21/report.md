# Run 21 — report

The large form of the run's status line
(`docs/methodology/status-lines.md`, "The site comparison, in full").
The thinking-budget test on the RTX 5060 Ti 16 GB
(`docs/methodology/evalplus.md`, "Unproven yet",
`../../research/thinking-budget.md`): two run 19 configs scored again
under a server thinking budget, then a natural re-run of each forced
answer that failed. Ten blocks, 2026-09-16 to 2026-09-17, no block
waited on a human. The coordinator re-derived every empty count from
the samples file and every forced count from `finish.jsonl`; all match
the runner's `results.md`.

| old/new | # | Config | Level | Think budget | Base | Plus | Empty | Forced | Wall |
|---|--:|---|---|--:|--:|--:|--:|--:|--:|
| old | — | Gemma-4-12B NVFP4, f16 KV, natural at 8192 | on | none | 0.659 | 0.640 | 53/164 | — | 203.9 |
| new | — | Gemma-4-12B NVFP4, f16 KV | on | 7350 | **0.976** | **0.951** | 0/164 | 45 | 194.8 |
| old | — | Qwen3.8-27B ISTA IQ3_S-mtp, q8_0 KV, natural at 20500 | xhigh | none | 0.945 | 0.909 | 7/164 | — | 217.6 |
| new | — | Qwen3.8-27B ISTA IQ3_S-mtp, q8_0 KV | xhigh | 30000 (cap) | 0.976 | 0.933 | 0/164 | 6 | 273.4 |
| new | — | Qwen3.8-27B ISTA IQ3_S-mtp, q8_0 KV | xhigh | 8192 (fixed) | 0.976 | 0.933 | 0/164 | 11 | 175.0 |

The natural re-runs (no flag, `max_tokens` 30000) of the forced answers
that failed a test:

| Config | Think budget | Forced | Pass | Late | Loop | Wrong | Re-run wall |
|---|--:|--:|--:|--:|--:|--:|--:|
| Gemma-4-12B NVFP4, on | 7350 | 45 | 39 | 0 | 6 | 0 | 62.3 |
| Qwen3.8-27B ISTA, xhigh | 30000 | 6 | 4 | 0 | 2 | 0 | 37.2 |
| Qwen3.8-27B ISTA, xhigh | 8192 | 11 | 5 | 0 | 2 | 4 | 69.5 |

Findings:

- **A thinking budget turns every empty answer into an answer.** No
  budgeted block has an empty answer, and none ends on `length`. The
  forced answers are the former empties, and most pass.
- **No forced answer was late.** Not one forced failure passes with
  more thinking: each either hits 30000 without the flag (a loop) or
  converges and is still wrong. No budget needed a correction.
- **The fixed 8192 budget loses nothing on the ISTA config against the
  30000 cap.** The two runs fail the same four base problems and the
  same seven plus-only problems. The four "wrong" problems
  (HumanEval/32, 47, 91, 132) fail the same tests at 30000, where they
  converge between 10379 and 22947 reasoning tokens. 8192 costs 175.0
  minutes against 273.4; with the re-runs, 244.5 against 310.6.
- **HumanEval/99 and HumanEval/145 loop on both models** at every
  budget. A forced answer on HumanEval/99 passes the base tests on the
  ISTA config; the natural run never answers.
- **Gemma-12B NVFP4 with thinking on now beats thinking off** (0.927 /
  0.896 in run 19), at four times the wall.
- The calibration set the Gemma budget from four converged problems of
  ten; six were cut at 30000. The budget held: all six forced failures
  are loops.

Gates: none. Items: the Claude Code harness killed the run task and the
watcher on its low-memory guard during the Gemma budgeted block; the
server stayed up and the runner resumed with `setsid nohup` outside
the harness's task list. `pkill -f` on the server command line kills
the runner's own shell; use `pkill -x llama-server`. The site shows
each budgeted result as a note on the natural row until the owner
decides how a budgeted row reads.
