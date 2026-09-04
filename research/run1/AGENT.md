# Research run 1: backend reliability research (Mac)

You are a research agent, not a benchmark runner. Read this file,
then `state.md` (keep it current). Write all prose in ASD-STE100
Simplified Technical English. `AGENTS.md` ground rules apply:
worktree-first, no bare stash, no model downloads, no pushes without
owner request.

This run is research, so it is interactive. Enter the worktree with
the tool, not with `cd`:

1. `git worktree add ../choose-a-local-llm-research1 -b research1`
2. `EnterWorktree` with `path:
   /Users/irae/code/choose-a-local-llm-research1`
3. Leave with `ExitWorktree`, `action: "keep"`.

The owner's HUD reads the session working directory. The tool call is
what makes the branch visible to them.

Every goal below is research. The wording gives starting points, not
finished procedures. Expand each goal where the evidence leads, add
alternatives the coordinator did not think of, and bring findings and
options to the owner instead of assuming one path. When a goal says
"maybe", it means maybe.

The coordinator did the scoring-policy proposals that used to live
here (`results/scoring-penalty.md`, `results/invalid-runs.md`,
shipped). Your findings feed `../run2/` (runtime improvements).

## Goal 0: clean-memory research (first)

Some OOM runs likely shared the machine with leftover apps (a browser
was probably open during at least one). MLX suffers most (hard wired
ceilings); GGUF is also affected. Research questions, open-ended:

- What does this machine's memory look like when it is idle? Measure
  after different states (fresh reboot, after quitting apps, after a
  big server dies) and learn how free/inactive/compressed/swap behave.
- What frees memory fastest and most reliably: quitting apps, waiting,
  purging, or a reboot? A reboot is one option to evaluate ("maybe
  reboot"), not the answer.
- What runs at startup and what could be disabled? The owner uses
  this Mac daily. Disable nothing; inventory login items and launch
  agents with their memory cost and present the list with trade-offs.
  The owner decides.
- What would a useful pre-run gate look like? Sketch options: warn
  and list offender processes, bail thresholds, a denylist learned
  from clean-vs-dirty boots, and what margin MLX needs vs GGUF.

Deliver findings, measured numbers, and one or more proposed gate and
reset designs with trade-offs. Nothing enters the checklist until the
owner picks one.

## Goal 1: backend failure deep-dive (diagnose, then prove and fix)

Diagnose first. When a diagnosis is solid, confirm it with a repro,
prove the fix, and apply it. A proven fix is a deliverable, not a
detour. Config changes that alter published measurements still go
through the owner. Starting points, expand as needed:

1. Memory recovery after server death (the dagger-sweep OOM,
   hypotheses in `benchmarks/bench7/state.md`): poll `vmmap
   --summary` and `vm_stat` side by side. How long does real recovery
   take? Do the accountings disagree (H4)? This overlaps goal 0; merge
   the evidence.
2. The Gemma-12B newline flood: find the exact first divergence in
   the three session logs and which stop/sampler/template settings
   the harness sent. Compare with the upstream reports in
   `../run2/results/web-serving-failures.md`.
3. mlx-lm state: installed versions vs the open dead-thread issues
   and unmerged PRs. Is the Qwen3.8 26624 window our config or the
   library? If a config fix exists, prove it.
4. The llama.cpp MTP drafter breakage: exact brew build, minimal
   pinned repro (drafter alloc fails, /health stays green, every
   later request 500s), whether the build predates llama.cpp PRs
   23485 and 20817. Updating the build is a candidate fix; test it
   if cheap.

## Goal 2: audit run labels against session logs

Two measurement errors are confirmed. Audit every current-version row
for both, from the session logs:

1. Thinking level: a run that asked for low but recorded only
   `thinkingLevel: high` ran at high. That is our benchmark error, not
   a model anomaly. Re-label the row as high. Two valid runs of the
   same config and level: keep the best as the row, mark it
   `best_of: <n>`, requeue the intended level, pending a diagnosed
   way to reach it. If a level is unreachable on a harness, it is not
   offered for that model.
2. Compactions: pi's "split turn / No prior history" marker is not a
   compaction; two rows were miscounted and are fixed. Check the
   rest. Also check that `peak_context` is the maximum across all
   compaction cycles, not the post-compaction value.

## Goal 3: trial the tool-call rules (unscored, two models only)

`results/agents-global-trial.md` holds a draft "Tool calls" section
and trial designs. Scope, so the trial does not eat the machine:

- Models: exactly two. First: `bonsai-prism`; its ~100-call ls loop
  on a typo'd path inspired the rules. Second: pick the remaining
  model with the worst tool-call failure record in the session logs
  (the mlx Bonsai parser crash and the Qwen3.8 runs are candidates).
- Task: one Mendel item only, handed directly. Give the model a
  single dependency to replace, not the GitHub issue fetch. Unscored.
- Compare with vs without the rules (pi `--append-system-prompt` or a
  skill): loop counts, tool errors, parser crashes from the session
  logs. The question is "how much better does it get", not a score.
- Never edit the frozen `agents-global.md` v1.0; the owner decides
  adoption from your comparison.

## Deliverables

- `state.md`: running log + handing-over section.
- `results/memory-gate.md`: goal-0 findings and proposed designs.
- `results/backend-diagnosis.md`: goal-1 findings with log excerpts,
  versions, repro commands, and the proven fixes applied.
- `results/label-audit.md` plus the corrected rows (goal 2).
- `results/tool-call-trial.md`: the goal-3 comparison.
- No model downloads; no pushes without owner request; config changes
  that alter published measurements go through the owner first.
