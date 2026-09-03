# Research run 1 — backend failure diagnosis (Mac)

You are a research agent, not a benchmark runner. Read this file,
then `state.md` (keep it current). Write all prose in ASD-STE100
Simplified Technical English. `AGENTS.md` ground rules apply:
worktree-first, no bare stash, no model downloads, no pushes without
owner request.

The scoring-policy work that used to be goals 1-2 of this run was
done by the coordinator (see `results/scoring-penalty.md` and
`results/invalid-runs.md` — proposals awaiting the owner's pick).
Your single goal is the diagnosis only a Mac-local agent can do. Your
findings feed `../run2/` (runtime improvements).

## Goal 0 — clean-memory gate (TOP PRIORITY: confirm, test, settle
this before anything else)

OOM runs likely shared the machine with leftover apps (a browser was
probably open during at least one). MLX suffers most (hard wired
ceilings); GGUF is also affected. Draft protocol to test and refine —
the owner confirms the final version before it enters the checklist:

1. Baseline: measure the machine's true idle memory after a fresh
   reboot with login items pruned. Record it (free MB, wired MB,
   swap 0) as THE baseline number in `results/`.
2. Pre-run gate, before any server load or sweep:
   - `vm_stat` free+inactive within an agreed margin of baseline;
     swap-ins near zero over a 60 s window.
   - No disallowed process: browsers, Electron apps, Docker, media —
     build a denylist by scanning `ps aux` on a dirty vs clean boot.
   - WARN and list offenders; BAIL if killing them does not restore
     the margin. Never start a run on a dirty machine.
3. Reset procedure when dirty: quit offenders; if memory does not
   recover to baseline (macOS hoards compressed memory), REBOOT —
   test whether reboot-to-baseline is faster and more reliable than
   waiting. Evaluate trimming login items / launch agents that eat
   memory at startup (list them for the owner first).
4. Deliver: a `tools/` script proposal (check + warn/bail, callable
   from the checklist and run-worker) and the measured thresholds.
   Wire into `docs/methodology/checklist.md` only after the owner
   confirms.

## Goal 1 — backend failure deep-dive (diagnose, do not fix)

1. **Memory recovery after server death** (the dagger-sweep OOM,
   hypotheses in `benchmarks/bench7/state.md`): after stopping a big
   server, poll `vmmap --summary` AND `vm_stat` side by side; measure
   how long real recovery to the idle baseline takes; check whether
   the two accountings disagree (hypothesis H4).
2. **Gemma-12B newline flood**: read the three session logs, find the
   exact first divergence (failed edit → which token pattern), and
   record which stop/sampler/template settings the harness sent.
   Compare with the upstream reports in
   `../run2/results/web-serving-failures.md`.
3. **mlx-lm state**: record the installed mlx-lm/mlx versions; check
   them against the open dead-thread issues and unmerged PRs listed
   in run 2's research; confirm whether the Qwen3.8 26624 window is
   our config or the library.
4. **llama.cpp MTP drafter breakage**: capture the exact brew build
   and a minimal pinned repro command line (drafter alloc fails,
   /health stays green, every later request 500s) — the input for an
   upstream issue. Check whether the build predates llama.cpp PR
   23485 and PR 20817.

## Goal 2 — audit run labels against session logs

Two measurement errors are confirmed; audit EVERY current-version row
for both, from the session logs:

1. **Thinking level.** A run that asked for low but recorded only
   `thinkingLevel: high` ran at high — that is OUR benchmark error,
   not a model anomaly. Policy (owner, 2026-09-03): re-label the row
   as high. When a model then has two valid runs of the same config
   and level, keep the BEST as the row, mark it `best_of: <n>`, and
   put the low run back on the queue — pending a diagnosed way to
   actually run low (run 2's job). If low is unreachable on a
   harness, low is not offered for that model.
2. **Compactions.** pi writes a "split turn / No prior history"
   marker that is NOT a context compaction; two rows (qwen3.6,
   deepseek-v4-pro v1.1) had it miscounted and are fixed. Check every
   row's compaction count against real compaction events, and check
   that `peak_context` is the maximum across ALL compaction cycles,
   not the post-compaction value.

## Goal 3 — trial the tool-call rules (unscored)

`results/agents-global-trial.md` holds a draft "Tool calls" section
for `agents-global.md` and three trial designs. Pick the cheapest
design with the owner, run it OUTSIDE the scored benchmark (never as
a bench row, never by editing the frozen v1.0 file), and report
whether the rules change the failure patterns. The owner decides
adoption from your results.

## Deliverables

- `state.md`: running log + handing-over section.
- `results/backend-diagnosis.md`: one section per item above, with
  log excerpts, versions, and repro commands.
- No fixes, no config changes, no downloads, no pushes.
