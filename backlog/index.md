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

- [ ] Runner alarms: decided 2026-09-05 (maxTokens rule, 25-minute turn cap, at-budget pair stop, loop flag); runner code, PLAN.md sentences and the Mac config edits pending (runner-alarms-output-limit-and-loop-stop.md, summary.html beside it, report in `benchmarks/history/`)
- [ ] Worker-profile table: which config is the best thinking-off sub-agent (worker-profile-table.md)
- [ ] Bench 10 candidates: the items deferred from bench 9 and the retries (bench-10-candidates.md)
- [ ] local-llm-eval-tools: extract the Mendel method into codebase-issue-simulator, room for slow-context-creep (local-llm-eval-tools-codebase-issue-simulator.md)
- [l] Qwen3.8 MLX output budget versus window; superseded by the runner-alarms maxTokens rule, dynamic cap stays a framework candidate (qwen38-mlx-output-budget-and-window.md)

## Changelog

- 2026-09-05 README says what the project does not measure, five items with the owner's reasons; agent rules moved to AGENTS.md, "collapse" term out of CONVENTIONS.md (`backlog/non-goals` merge)
- 2026-09-05 Unslop of the internal docs: em dashes, "the law", daggers and capitals replaced across AGENTS, CONVENTIONS, EDITOR, PLANNING, INDEX, READMEs and the research runbooks (`128858c`)
- 2026-09-04 Mendel peak_context: rule stated, 21 rows recomputed from per-turn usage, two post-compaction values corrected, caveat narrowed to one retired harness (Mendel `fe6da234`)
- 2026-09-04 Mendel telemetry: peak_context caveat on the reports, tool_calls counting rule on the method page, all 17 rows recounted and unchanged (Mendel `bec00354`)
- 2026-09-04 EvalPlus smoke: four fixed problems, same budget both sides, level/better/worse; validation on the Mac pending (`benchmarks/evalplus-smoke.py`)
- 2026-09-04 Method pages stop naming models; specifics moved to the setup pages (`a0c77df`)
- 2026-09-04 One creep apparatus, one monitor: the sweep runner samples memory and liveness itself (`f5b764a`, `6effada`)
- 2026-09-04 Mendel retry rule: points off when the model failed, no penalty when the harness did (`c089dc5`, Mendel `0b0e1a24`)
- 2026-09-04 Gemma-12B pages split: retired entry stripped, llama f16 config in front, evidence on the data page (`102a5b6`)
