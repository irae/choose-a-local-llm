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

## Goal — backend failure deep-dive (diagnose, do not fix)

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

## Goal 2 — trial the tool-call rules (unscored)

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
