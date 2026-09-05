# Run 9 — state

Created 2026-09-04 by the coordinator. No sessions yet.

Start here: read `AGENT.md`. Log every session below with a
handing-over section at the end.

## Session 1 — 2026-09-04

### For the planner: a docs gap in block A1b / context-creep.md

Block A1b's instruction is "the published command (its published `-c`)
with the picked cache type." When the published `-c` OOMs (as it does
on all three block A1 models under this run's `iogpu.wired_limit_mb`),
the natural read is "lower `-c` to whatever loads, run the creep, done."
That is wrong: a context creep exists to FIND the model's ceiling, so
its target is the model's real trained context (GGUF
`<arch>.context_length`, or the setup report's own trained-window note
— e.g. Gemma-26B's report already says "full 256K trained window"),
not the previously published serving `-c`. A creep that stops at
"window" only because the chosen `-c` was too small is not a finding;
it is the test not having run far enough. A creep that stops on a real
condition (floor, OOM, or memory compaction) below the published `-c`
IS a valid, complete result — no rework needed there.

The fix that already exists and is proven: **the prefill jump**
(`research/run2/results/gemma12-depth.md`, "The prefill shortcut, and
why it is trustworthy"). Instead of re-creeping from 4K after raising
`-c`, start `DEPTH_LIST` at the last previously-verified depth (a
control point, to catch any surprise) plus the new deeper target(s);
the runner grows the prompt to that depth in one jump and continues
normally. Measured deviation from a full slow creep: 2.8%, on the
pessimistic side (arriving fast gives macOS less time to yield memory,
so it is a safe, conservative shortcut). Up to 5% deviation is
acceptable by this project's own standard.

Suggested doc fix: `context-creep.md` step 0 / block A1b in a future
run's AGENT.md should say explicitly: "when the published `-c` fails to
load or produces only a window verdict, binary-search upward toward
the model's real trained context (check GGUF metadata or the setup
report), and use a prefill-jump `DEPTH_LIST` (last good depth + new
target(s)) rather than re-running the full curve."

### Correction made mid-run-9

Block A1b's Qwen3.8 and Gemma-26B full creeps were first run at their
published `-c` (32768 and 262144) and, for Gemma-26B, a first fallback
`-c` (131072) chosen ad hoc rather than toward the trained max. Both
produced a "window" verdict — an artifact of an undersized `-c`, not a
real ceiling. Qwen3.6's mem-stop result at `-c 49152` is unaffected and
stays as published (a real stop condition, reached well under its
`-c`). Redoing Qwen3.8 and Gemma-26B: binary-search the largest
loadable `-c` toward each model's 262144 trained context, then a
prefill-jump creep from the last verified depth to find where a real
stop condition (floor/OOM/mem) actually triggers.

### Deviation: block B3 text contradicts itself on the drafter

Block B3's title is "Mendel guided on Gemma-12B GGUF, thinking off,
f16 KV, no drafter" and its row-note requirement says the config note
must read "f16 KV, no MTP". But the body's server instruction says
"Start the published `gemma-4-12b` command with `f16` in both cache
types (keep `-c 262144` **and the drafter at n-max 4**)" — the
opposite of the title.

Followed the title and the row-note (two mentions, no drafter) over
the body's one mention, on the read that "keep -c 262144" was the
actual instruction and "and the drafter at n-max 4" is a copy-paste
leftover from the block A1/B1 server commands, which all keep the
drafter. Started the server WITHOUT `--spec-type draft-mtp
--spec-draft-n-max 4`, f16 both cache types, `-c 262144`. Flag for the
coordinator to fix the block text.

### Block E — harness fix applied

Backed up `~/.pi/agent/models.json` to
`~/.config/choose-a-local-llm/models.json.bak-20260905`. Edited entry
`mlx-community/Qwen3.8-27B-4bit`: `maxTokens` 16384 → 8192.
`contextWindow` unchanged at 26624. Renamed the invalid run's branch
(zero commits, three Metal OOM crashes) to keep the slot free:
`mlx-community-Qwen3.8-27B-4bit-low-guided-v3-issue-13` →
`...-attempt1` in `~/code/mendel`. Starting
`./run-worker.sh mlx-community/Qwen3.8-27B-4bit pi guided low`.

## Handing over — run9 close

Blocks run, in order:
- **A / A1b** (KV-cache creep, three models): all three closed, real
  hardware ceilings found (not the published `-c` values, which all
  OOM). Qwen3.6 = q8_0 @ `-c 49152`; Qwen3.8 = f16 @ `-c 49152`;
  Gemma-26B = f16 @ `-c 212992`. See `results.md` for the full tables
  and the corrections mid-run (an earlier version of this run wrongly
  accepted an undersized `-c` as a ceiling; that mistake and its fix
  are documented in `results.md` and a fix note is now in
  `docs/methodology/checklist.md`).
- **B0** (EvalPlus smoke, the two f16 picks): closed. Qwen3.8 f16
  level with q8_0. Gemma-26B f16 level with q8_0 (both fail the same
  known-hard problem identically).
- **B1** (Gemma-12B GGUF EvalPlus, thinking off): closed. 0.976/0.939,
  0 empty — beats the published MLX score (0.909/0.872) by 0.067,
  needs its own row (quants don't share a score here).
- **B3** (Mendel guided, Gemma-12B GGUF, thinking off, f16, no MTP):
  closed. Partial, 3/8, raw 58 / capped 37.5, `model_budget_exhausted`.
  Block B3's own text was self-contradictory on the drafter (title/note
  said "no drafter", body said "keep the drafter") — followed the
  title/note; flag for the coordinator to fix the text.
- **E** (Qwen3.8 MLX harness fix + guided-low retry): closed as
  invalid after three attempts. The harness fix (`maxTokens` 8192)
  works, but a separate, still-open issue remains: real Metal OOM
  crashes from the context growing past the configured 26624-token
  window during agentic use. See `results.md` for the full account.
  Branch chain: `...-attempt1` (run-7's original bug), `...-attempt2`
  (this run, no server started), `...-attempt3` (this run, two real
  OOM crashes, zero commits).
- **C** (Bonsai MLX, guided + blind, thinking off): **not run — the
  owner deferred it to run10.**

Machine state left behind: `iogpu.wired_limit_mb` is 24000 (resets to
0 on next reboot, per the cold-start sequence). No `llama-server` or
`mlx_lm` process running. No memory watcher running. LM Studio was
quit at session start and never reopened. All run worktrees (Mendel
side) removed; only the `mendel-bench-repro-gemma-4-12b-low-guided`
worktree remains, pre-existing and untouched by this session. Evidence
(`benchmarks/bench9/results/`) is committed on `run9`, not yet
archived via `tools/archive-evidence.sh` — the coordinator should run
that after the merge if the run's evidence needs archiving per the
usual close-out.

This closes run9. Merging into `master` now per the owner's explicit
instruction.
