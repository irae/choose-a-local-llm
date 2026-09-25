# Agent rows hit by the compaction summary cap: retry and replace

Unscheduled. Needs hardware: yes, three simulator(mendel) rows. The
next Mac run takes them (owner, 2026-09-25).

From 2026-09-06 to 2026-09-24 the simulator pinned pi
`reserveTokens` 8192. pi caps a compaction summary at
`0.8 x reserveTokens` (6553) and a split-turn prefix summary at
`0.5 x reserveTokens` (4096), thinking included. A thinking model at
high or xhigh can spend that whole cap on thinking. pi 0.84.3 on the
Mac then keeps an empty or cut summary with no error. The evidence:
`/history/compaction-summary-cap.html`.

The harness caused these failures, so a re-run replaces the row with
no retry penalty (`docs/methodology/mendel.md`).

| row | score / end | what happened | impact |
| --- | --- | --- | --- |
| `bonsai-prism-high-guided-v3-issue-13` | 31.5 / `wall_clock` | one summary empty at exactly 6553; the model then lost its task | certain |
| `qwen3.8-27b-iq3s-m1-xhigh-guided-v3-issue-13` | 62.5 / `wall_clock` | a prefix summary of 9482 tokens against a 4096 cap; cause unknown | possible |
| `qwen3.8-27b-xhigh-issue-13` (blind) | 93 / complete | a prefix summary stopped at exactly 4096; it may be cut | possible |

What each row needs when it runs: the current method. That is pi at
the newest version (preflight), the run config written by
`tools/gen-pi-models.mjs --run-dir`, no `maxTokens` and no
`reserveTokens` override, `keepRecentTokens` from the window curve,
and the fast-mode thinking budget on the server. The row's note says
that the re-run also changed the thinking budget, so a score change
does not come from compaction alone.
