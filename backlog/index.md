# Backlog index

One line per item, in priority order, highest first. The owner edits
the checkbox; the coordinator keeps the order and the changelog.

Legend for the checkbox:

- `[ ]` not reviewed by the owner yet
- `[a]` approved: an agent may take it, in its own worktree
- `[s]` soon: approved and wanted next
- `[l]` later: read, parked
- `[x]` done: the work landed on `master`, the file is deleted in the
  same commit, and the line moves to the Changelog below with the date

Rules: `CONVENTIONS.md` (backlog row) and `benchmarks/PLANNING.md`
("Three kinds of work, three places").

## Open

- [a] Project non-goals: sweep the history, write a README section; owner reviews before it lands (project-non-goals-in-readme.md)
- [ ] Runner alarms: count output-limit hits, optional per-turn stop, loop verdict at run close (runner-alarms-output-limit-and-loop-stop.md)
- [ ] Worker-profile table: which config is the best thinking-off sub-agent (worker-profile-table.md)
- [ ] Bench 10 candidates: the items deferred from bench 9 and the retries (bench-10-candidates.md)
- [ ] local-llm-eval-tools: extract the Mendel method into codebase-issue-simulator, room for slow-context-creep (local-llm-eval-tools-codebase-issue-simulator.md)
- [l] Qwen3.8 MLX output budget versus window; parked until bench 9 reports (qwen38-mlx-output-budget-and-window.md)

## Changelog

- 2026-09-04 Mendel peak_context: rule stated, 21 rows recomputed from per-turn usage, two post-compaction values corrected, caveat narrowed to one retired harness (Mendel `fe6da234`)
- 2026-09-04 Mendel telemetry: peak_context caveat on the reports, tool_calls counting rule on the method page, all 17 rows recounted and unchanged (Mendel `bec00354`)
- 2026-09-04 EvalPlus smoke: four fixed problems, same budget both sides, level/better/worse; validation on the Mac pending (`benchmarks/evalplus-smoke.py`)
- 2026-09-04 Method pages stop naming models; specifics moved to the setup pages (`a0c77df`)
- 2026-09-04 One creep apparatus, one monitor: the sweep runner samples memory and liveness itself (`f5b764a`, `6effada`)
- 2026-09-04 Mendel retry rule: points off when the model failed, no penalty when the harness did (`c089dc5`, Mendel `0b0e1a24`)
- 2026-09-04 Gemma-12B pages split: retired entry stripped, llama f16 config in front, evidence on the data page (`102a5b6`)
