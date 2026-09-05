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

- [ ] One folder per machine: move bench and research runs under hardware/<id>/{benchmarks,research}; method pages already read the machine file (hardware-folders-per-machine.md)
- [ ] Bench 10 candidates: the items deferred from bench 9 and the retries (bench-10-candidates.md)
- [ ] local-llm-eval-tools: extract the Mendel method into codebase-issue-simulator, room for slow-context-creep (local-llm-eval-tools-codebase-issue-simulator.md)
- [ ] Faster crash detection while babysitting a live run: a live tail+Monitor watcher instead of the 15-25 min ScheduleWakeup blind spot that missed two mlx_lm.server Metal OOM crashes in bench 9 block E (live-crash-detection-during-a-run.md)

## Changelog

- 2026-09-05 Runner alarms landed: output-limit counters, 25-minute turn cap, at-budget pair stop, loop flag beside every row with a log, maxTokens rule in PLAN.md (Mendel `a41170a4`, site `4b3eb67`); Mac models.json edits still to apply after bench 9. Qwen3.8 budget item closed by the same rule
- 2026-09-05 README says what the project does not measure, five items with the owner's reasons; agent rules moved to AGENTS.md, "collapse" term out of CONVENTIONS.md (`backlog/non-goals` merge)
- 2026-09-05 Unslop of the internal docs: em dashes, "the law", daggers and capitals replaced across AGENTS, CONVENTIONS, EDITOR, PLANNING, INDEX, READMEs and the research runbooks (`128858c`)
- 2026-09-04 Mendel peak_context: rule stated, 21 rows recomputed from per-turn usage, two post-compaction values corrected, caveat narrowed to one retired harness (Mendel `fe6da234`)
- 2026-09-04 Mendel telemetry: peak_context caveat on the reports, tool_calls counting rule on the method page, all 17 rows recounted and unchanged (Mendel `bec00354`)
- 2026-09-04 EvalPlus smoke: four fixed problems, same budget both sides, level/better/worse; validation on the Mac pending (`benchmarks/evalplus-smoke.py`)
- 2026-09-04 Method pages stop naming models; specifics moved to the setup pages (`a0c77df`)
- 2026-09-04 One creep apparatus, one monitor: the sweep runner samples memory and liveness itself (`f5b764a`, `6effada`)
- 2026-09-04 Mendel retry rule: points off when the model failed, no penalty when the harness did (`c089dc5`, Mendel `0b0e1a24`)
- 2026-09-04 Gemma-12B pages split: retired entry stripped, llama f16 config in front, evidence on the data page (`102a5b6`)
