# Status-lines proposal: one template per update type

Status: pending owner review, branch `status-lines`, worktree
`../choose-a-local-llm-statuslines`, commit 5a1afc4. Filed 2026-09-05.
Needs hardware: no.

`docs/methodology/status-lines.md` on that branch: one template per
update type (run start, block start, creep progress with the delta
rule, creep close, KV pick, EvalPlus calibration, progress and close,
Mendel smoke, Mendel progress and close, watcher event, gate decision,
block close, run close) in three sizes: short for chat, medium for
`state.md`, large for `results.md` and the publish step. Built from
eleven owner statements in runs 5 to 10, quoted with session and date.
Plus the model short-id rule and the context budget rules.

Two points to settle at review:

1. The page names models in the short-id table and the examples,
   against the rule that method pages never name a model. Exempt the
   page, or move the short-id table to the setup page.
2. The branch predates the folder move; rebase after review.
