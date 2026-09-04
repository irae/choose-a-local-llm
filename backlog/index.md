# Backlog index

One line per item, in priority order, highest first. The owner edits
the checkbox; the coordinator keeps the order and the changelog.

Legend for the checkbox:

- `[ ]` not reviewed by the owner yet
- `[a]` approved: an agent may take it, in its own worktree
- `[s]` soon: approved and wanted next
- `[l]` later: read, parked
- `[p]` pull request: the work is done on a branch and waits for the
  owner's review before it merges; the line names the branch
- `[x]` done: the work landed on `master`, the file is deleted in the
  same commit, and the line moves to the Changelog below with the date

Rules: `CONVENTIONS.md` (backlog row) and `benchmarks/PLANNING.md`
("Three kinds of work, three places").

## Open

- [a] peak_context is verifiable after all: recompute every pi row from per-turn usage, fix two compaction rows, narrow the caveat that landed today (peak-context-recompute-from-usage.md)
- [p] Project non-goals: README section and findings file, branch `backlog/non-goals`, worktree `../choose-a-local-llm-backlog-nongoals` (project-non-goals-in-readme.md)
- [p] Unslop of the internal docs: AI-tell cleanup of AGENTS, CONVENTIONS, EDITOR, PLANNING, INDEX, runbooks; branch `unslop-internal-docs`, worktree `../choose-a-local-llm-unslop`; conflicts with master on EDITOR.md (no backlog file)
- [ ] Runner alarms: count output-limit hits, optional per-turn stop, loop verdict at run close (runner-alarms-output-limit-and-loop-stop.md)
- [ ] Worker-profile table: which config is the best thinking-off sub-agent (worker-profile-table.md)
- [ ] Bench 10 candidates: the items deferred from bench 9 and the retries (bench-10-candidates.md)
- [ ] local-llm-eval-tools: extract the Mendel method into codebase-issue-simulator, room for slow-context-creep (local-llm-eval-tools-codebase-issue-simulator.md)
- [l] Qwen3.8 MLX output budget versus window; parked until bench 9 reports (qwen38-mlx-output-budget-and-window.md)

## Changelog

- 2026-09-04 Mendel telemetry: peak_context caveat on the reports, tool_calls counting rule on the method page, all 17 rows recounted and unchanged (Mendel `bec00354`)
- 2026-09-04 EvalPlus smoke: four fixed problems, same budget both sides, level/better/worse; validation on the Mac pending (`benchmarks/evalplus-smoke.py`)
- 2026-09-04 Method pages stop naming models; specifics moved to the setup pages (`a0c77df`)
- 2026-09-04 One creep apparatus, one monitor: the sweep runner samples memory and liveness itself (`f5b764a`, `6effada`)
- 2026-09-04 Mendel retry rule: points off when the model failed, no penalty when the harness did (`c089dc5`, Mendel `0b0e1a24`)
- 2026-09-04 Gemma-12B pages split: retired entry stripped, llama f16 config in front, evidence on the data page (`102a5b6`)
