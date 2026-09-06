# Pushing a run branch: rewrite the rule or return to one merge

Status: pending owner decision. Filed 2026-09-05.
Needs hardware: no.

The rule in `AGENTS.md` (standing rules) and `docs/methodology/checklist.md`
step 1 says a run branch is never pushed. Run 10 pushes `run10` after
every block, on the owner's instruction, and the coordinator merges it
into master at each block report, so the site updates while the run
continues.

Options:

1. Keep the new practice and rewrite the rule: a run branch is pushed
   after every block commit; the coordinator merges at each report;
   the runner never merges master itself except when the coordinator
   says so.
2. Return to one merge at run close, and delete `origin/run10` after
   run 10 merges.

The coordinator recommends 1.
