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

- [ ] Real near-OOM in run 11 block 5: mediaanalysisd (macOS media indexing) at ~70% CPU competed for memory while the server held wired 25000; free RAM crashed 1565→62 MB in 20s, harness killed the run mid-work, uncommitted work lost (mediaanalysisd-memory-contention.md)
- [ ] pi's compaction may be too shallow under a small contextWindow: frequency climbed from 1/9min to 1/2-3min mid-run, several compactions freed only 1-8 points of headroom; research pi's compaction options (pi-compaction-efficiency.md)
- [ ] Shared-score rule: the owner's sentence for when two quants of one model carry their own scores (shared-score-quant-exception.md)
- [ ] Qwen3.6 GGUF pi entry at contextWindow 49152: keep on the daily driver, or raise back to 98304 (qwen36-entry-window.md)
- [ ] Qwen3.8 MLX window before any Mendel retry: smaller window, earlier compaction, or wait for the no-OOM research (qwen38-mlx-window.md)
- [ ] Bonsai KV bias corpus: name it, or the fork row stands and two runs are dropped (bonsai-kv-bias-corpus.md)
- [ ] Devstral Small 2 download: which files and revision (devstral-download.md)
- [ ] Budget for cloud Mendel re-runs, and which models go to polyglot (cloud-reruns-and-polyglot-tier.md)
- [ ] Mendel: score thinking-off configs that only have thinking-high rows (qwen3.6-35b-a3b confirmed gap) (mendel-thinking-off-gaps.md)
- [ ] local-llm-eval-tools: extract creep and the Mendel kit with history into two tools; hand-over prompt for the coordinator agent (local-llm-eval-tools-codebase-issue-simulator.md)
- [ ] Two owner questions left by the non-goals sweep: the positive half of the model entry criteria, and whether "a run gated by our own configuration is our fault" becomes a rule (non-goals-sweep-findings.md)
- [ ] New pi test idea: sub-agent hand-offs to keep the main agent's context clean, trading compactions for per-hand-off cache misses (pi-subagent-context-hygiene-test.md)

## Changelog

- 2026-09-06 Run branch rule rewritten to the run 10 practice: the runner pushes the run branch after every block, the coordinator merges at each report, the branch is deleted at close on origin too; the Mendel staging rule (never `git add -A` in the kit) is a standing rule (`AGENTS.md`, `docs/methodology/checklist.md`)
- 2026-09-06 Live loop stop in the Mendel runner: five identical tool calls in a row (three after a stall), an in-message shape cycle, or a one-character flood end the run as `repetition_loop` or `degenerate_output`; every loop seen so far is in `hardware/m1-max-32gb/research/loop-signatures.md` (Mendel `run-pi-rpc.mjs`, `PLAN.md`)
- 2026-09-06 Status lines: one template per update type in three sizes; short at every unattended wakeup, medium on a status request, large compares runs one table per task with carried cells marked (`docs/methodology/status-lines.md`, merge 1888b51)
- 2026-09-05 One folder per machine: `benchmarks/bench1`-`bench10`, `benchmarks/INDEX.md` and `research/run1`-`run3` moved under `hardware/m1-max-32gb/`; shared scripts, calibrations, `history/` and `mendel/` stay at `benchmarks/`; run branches commit inside their own run folder only (branch `hardware-folders`)
- 2026-09-05 Live crash watcher for scoring runs: `benchmarks/crash-watch.sh` tails the server log for the death signatures, probes one real completion on silence, exits 42 with the reason; checklist step 7 starts it beside every scoring run. The Mendel runner's `/slots`-only stall watchdog stays as it is: the runner never learns the server log path (branch `backlog/live-crash-detection`)
- 2026-09-05 Run 9 closed: KV picks, real `-c` ceilings, Gemma-12B GGUF scored; site, historical page and findings index updated; bench 10 draft de-duplicated
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
