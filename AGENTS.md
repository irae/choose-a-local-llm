# Agent guide

This repo answers one question for one computer: which local model, runtime,
and configuration should I code with? It holds the measurements, the process
that produced them, and a website that publishes both.

You need to care about two things only: the content, and the commands
below. The base path, the sitemap, the deploy workflow, and the Pages
settings are already wired.

## Commands

```bash
npm install                      # once
npm run dev                      # write and preview, http://localhost:5173
npm run verify                   # build + link check. Run before every commit.
npm run deploy -- "what changed" # build, verify, commit. Stops before pushing.
```

`npm run deploy` never pushes. It prints the push command for the owner to
run. Publishing is always the owner's step.

If another agent is already serving on 5173, add a port:
`npm run dev -- --port 5174`.

## Full index

What to read, and when.

Site and process docs:

- [CONVENTIONS.md](./CONVENTIONS.md). Read it before you write any
  markdown or any script. It says which rules govern which kind of
  file, the shape of a measurement tool, and what every tool's header
  must say.
- [EDITOR.md](./EDITOR.md). Read it before you change any page,
  wording, or layout. Page shape, vocabulary, where each file lives,
  how to record a measurement across every surface.
- [docs/methodology.md](./docs/methodology.md). The rules for
  measurements, split by task. Read its table and open the page for
  what you are about to do. The pages, and when they save you:
  - `docs/methodology/checklist.md`. Before you start any benchmark,
    sweep, or scoring run. Agents forget the memory watcher and the
    idle/silent-crash monitor; this checklist prevents it.
  - `docs/methodology/common-rules.md`. Before you write or run any
    measurement script: prompt-cache rule, KV policy, record-everywhere
    rule (the one that catches people).
  - `docs/methodology/context-creep.md`. Before a depth sweep, and
    before you interpret any LM Studio ceiling (compression-onset
    criterion).
  - `docs/methodology/memory-ceiling.md`. Before you probe allocation
    maxima or change the wired limit.
  - `docs/methodology/wired-limit.md`. macOS only, and a setup task,
    not a run task. Before you search for a new
    `iogpu.wired_limit_mb`: the ladder, the stop condition, and how to
    pick the unattended and in-use values. Needs the owner present.
  - `docs/methodology/evalplus.md`. Before EvalPlus or any scoring
    benchmark. The budget-calibration rule lives here; skipping it
    once cost 38% of a score.
  - `docs/methodology/mendel.md`. Before a Mendel run. The real
    instructions live in the Mendel repo; this page says where, and
    gives the house rules (one at a time, daemon cleanup).
  - `docs/methodology/polyglot.md`. Before an Aider polyglot run.
  - `docs/methodology/server-lore.md`. Before you touch any server,
    and first when a run stalls or a number looks impossible.
- [docs/website-plan.md](./docs/website-plan.md). Before you change
  the site structure or the deploy. Not needed for content work.

Benchmark work:

- `benchmarks/PLANNING.md`. Before you plan a run or write a
  `bench<N>/AGENT.md`. The coordinator/runner role split and the
  HANDOFF writing rules live here. Coordinators read it; runners never
  do.
- `hardware/<hardware-id>/`. Everything that belongs to one machine.
  `<hardware-id>` is the same id the site uses for the setup under
  `docs/setups/`; today the only one is `m1-max-32gb`.
- `hardware/<hardware-id>/benchmarks/INDEX.md`. Start here to learn
  what each run found. It links every run's state and results.
- `hardware/<hardware-id>/benchmarks/bench<N>/AGENT.md`. The runbook
  for run N. Read the newest one before any benchmark work.
- `hardware/<hardware-id>/benchmarks/bench<N>/state.md`. The run's log.
  Read it before you resume or touch anything that run left behind.
- `hardware/<hardware-id>/benchmarks/bench4/lmstudio-forensics.md`.
  Before any LM Studio work; it overrides older lore.
- `hardware/<hardware-id>/research/run<N>/`. The research runs of that
  machine. Same kit shape as a bench run.
- `benchmarks/` (root). The shared tools every run uses:
  `run-humaneval.sh`, `run_codegen_wrapper.py` (patched EvalPlus
  client), `calibrate.py`, `run-watch.sh` (the one watcher of a
  scoring run: writes the memory log, tails the server log for the
  death signatures, probes one real completion after the output file
  goes silent, exits 42 with the reason on stdout when the server is
  dead. Start it as a background task so the crash interrupts the
  coordinator; `--help` lists its `RUNWATCH_*` variables. It restarts
  nothing. A depth sweep needs no watcher, because its runner samples
  memory and liveness itself), `calibration-*.json`, `evalplus-smoke.py` (the fast fixed
  four-problem EvalPlus subset for a research trial. Not a score,
  never published. Same budget on both sides, read as level, better or
  worse; `docs/methodology/evalplus.md`. It replaced the older LM
  Studio concurrency smoke, now retired), `mendel-smoke.sh` (the
  handed task that gates a full Mendel run: one dependency swap across
  two files in a fixture it builds itself, one pi run under a
  25-minute cap, one SMOKE-MENDEL line, pass or fail. Unscored, never
  published; `--help` lists its `SMOKE_MENDEL_*` variables;
  `docs/methodology/mendel.md`), `loop-check.py` (repetition-loop detector for
  a pi session log: distinct-shape ratio in a sliding window,
  threshold 0.10; catches identical lines, counters, and short
  cycles).
- `tests/`. The tests for the shared tools in `benchmarks/`. One
  command, `tests/run.sh`, and `tests/fixtures/README.md` says where
  every fixture came from.
- `sunset/`. Scripts on their way out. They run beside their
  replacement for one run, then the directory is deleted. Its README
  says which run and what replaced them.
- `tools/sweeps/`. The depth-sweep tools. `creep.py` owns the method
  (depth ladder, pause, stop conditions, memory columns, liveness) and
  one `creep_<backend>.py` owns each backend. One command per sweep
  and one output file. The runner is its own monitor, so nothing else
  runs beside it (`docs/methodology/context-creep.md`).
- `tools/preflight.sh`. Run it FIRST in every run session. It reads
  the machine against `~/.config/choose-a-local-llm/machine.md` and
  prints one line per check (`ok`, `fix`, `ask`): GPU free, login
  items, firewall, wired limit, the starting memory numbers, and
  whether a reboot condition holds. It changes nothing and needs no
  sudo. All `ok` means the run starts with no question and no
  `turn-off`. `--help` lists the checks and the environment overrides
  (`docs/methodology/checklist.md`, "Before the run").
- `tools/mac-services.sh` and `tools/README-mac-services.md`. Turn
  background login items off before a run and back on after. The
  script ships with no list; the README says how to build one. Read
  the README before you disable anything on the owner's Mac.
- `tools/archive-evidence.sh`. Copy a run's session logs to a place
  where they survive. Run it before a run's worktree is removed.
  Evidence goes to `~/.local/share/choose-a-local-llm/evidence/`, not
  a cache directory, because losing it destroys the only proof behind
  a published number.
- `tools/mem-probe.py`. Measure what the machine will wire for an MLX
  allocation. Investigation only; not part of run preparation. Read
  `Pages wired down`, never the allocation total.
- `benchmarks/history/`. Finished reports the backlog decided on, kept
  whole. `tools/sync-static.mjs` serves them at `/history/<file>`, so a
  backlog item or a rule can link one as its evidence.
- `HANDOFF.md`. The owner's working context for the next main-thread
  agent. Read it first when you start a session. Not committed.

## Standing rules

- **Method pages never name a model.** `docs/methodology/` is reusable
  by anyone. Models, runtimes, commands and numbers of one machine
  live under `docs/setups/<setup>/`. Say "one dense 12B model on the
  reference setup" and link the setup's report (README, "How to use
  this repo").
- **Push only on owner request.** Never push on your own initiative,
  and never offer to publish. The owner asks when they want it.
  When the owner asks for a push or for stop-and-sync, push `master`
  and only `master`. Refusing a requested push loses data; do it.
- **Only the agent whose worktree has master checked out may merge into
  master.** Git enforces this: a branch lives in one worktree at a time,
  so any other worktree gets the merge refused. If you are not on
  master, commit on your branch and stop.
- **A run branch is temporary and local; origin holds only `master`.**
  Planning a run (writing `bench<N>/AGENT.md`) happens on `master`.
  When the run starts on the benchmark machine, create a local branch
  for it (for example `run6`), commit the run's progress there, and
  merge it back into `master` when the run finishes. Never push a run
  branch to origin. The branch exists only so a benchmark run and site
  work can proceed at the same time, each in its own worktree. All
  communication between agents goes through `master`.
- **Stop and sync, when the owner asks to stop a run and merge.** The
  goal state: all work is on `master`, `master` is on `origin/master`,
  no run branch remains anywhere, no run worktree remains. Follow these
  steps in order:
  1. Commit all open work on the run branch, including `state.md` with
     a handing-over section. `git status` must be clean.
  2. Go to the master worktree. Run `git pull --ff-only origin master`.
  3. Run `git merge run<N>`.
  4. Run `git push origin master`. This push is required. The owner
     asked for it, so the push rule above permits it.
  5. Remove the run worktree: `git worktree remove
     ../choose-a-local-llm-run<N>`, then `git worktree prune`.
  6. Delete the branch: `git branch -d run<N>`. Use `-d`, not `-D`.
     If git refuses, the merge did not land; go back to step 3.
  7. Verify and report: `git branch` lists no run branch, `git
     rev-parse master origin/master` prints the same hash twice,
     `git status` is clean. Quote these outputs.
- **The main worktree belongs to the coordinator.** A runner never works
  in the main worktree of this repo or of `../mendel`. The runner
  creates a fresh sibling worktree for its run branch (for example
  `git worktree add ../choose-a-local-llm-run<N> -b run<N>`) and works
  only there.
- **How you enter the worktree depends on the work.**
  - *Research and planning* is interactive; the owner watches. Create
    the sibling worktree with `git worktree add`, then enter it with
    the `EnterWorktree` tool and its `path` argument. The owner's HUD
    reads the session working directory, so the tool call is what makes
    the branch visible to them. Leave with `ExitWorktree`,
    `action: "keep"`, never `remove`: the branch must survive to be
    merged. Do not call `EnterWorktree` with `name`: it builds under
    `.claude/worktrees/` off `origin/master` and breaks the sibling
    convention.
  - *Benchmark runs* are long and unattended. Use `git worktree add`
    plus `cd` in bash. No tool call, nothing to watch. Mendel runs use
    two mendel worktrees: the benchmark branch checkout
    (`../mendel-benchmark`) and the per-model worktrees that
    `run-worker.sh` creates. When the run closes, the runner removes
    its worktrees (`git worktree remove`, then `git worktree prune`)
    and keeps only the branches. Never reuse an old worktree;
    gitignored artifacts stay behind in it. The merge of a run branch
    into `master` happens from the master worktree only (see the merge
    rule above).
- **Out of credits is a pause, never a teardown.** When a run hits a
  billing, quota, or credit-exhaustion error: keep the server, the
  worktree, and the session alive. Record the time and the last event,
  tell the owner at once (this is the one situation where you
  interrupt with an escalation), and wait. Resume the same run when
  credits return. Only the owner can declare a credit-interrupted run
  lost. A teardown throws away the tokens already spent.
- **Model tiers, never model names.** Permanent docs say which tier
  of model a job needs, not which vendor or model: **cheap** for
  scouting and mechanical steps, **average** for most agent work,
  **standard** for planning and review, **best** for judgment. Which
  model fills a tier is the owner's choice and lives outside the repo.
  Runbooks of a run in progress may name a model; permanent docs never
  do.
- **Scoring runs on the best tier.** Scoring a benchmark run is LLM
  judgment (rubric calls, defect severity, cost-basis decisions). Do
  it in a subagent on the best available model, never on a smaller
  one. Mechanical steps (recompute, mirror, regenerate tables) may use
  any tier.
- **Bug fixes during a run use the best tier.** When a run tool
  breaks while the run is going and the owner is away, the runner
  dispatches a subagent on the best available model to fix it and
  continues; the run does not wait.
- **Run the exact files the runbook names.** A missing or different
  file is stop-and-ask. Downloading is a planning decision written into
  the runbook (`docs/methodology/common-rules.md`, rule 8).
- **Run `tests/run.sh` after you touch any script under
  `benchmarks/`.** It is one command and it needs no server.
- **Never edit a shell script while it runs.** The shell reads the file
  as it executes, so an edit changes the running program. Wait for the
  run to end, or write a new file.
- **A harness stops a run; it never rescues it.** When a model falls
  into a repetition loop, record the stop and report it. Do not add a
  prompt-layer instruction or a sampler trick to keep the run going;
  that hides the defect instead of measuring it.
- **Never run a bare `git stash`.** The stash list lives in the shared
  `.git` directory, not per worktree, so parallel agents clobber or
  cross-apply each other's stashes. Save work in progress as a WIP
  commit on your own branch instead. If a stash is unavoidable, name it
  (`git stash push -m "<agent/run>: <what>"`) and apply or pop it by
  that name only (`git stash pop 'stash^{/<name>}'`), never by index.
- **No superseded number on a current page.** Not in a table, not in
  prose. Old figures move to the setup's `historical.md`, which opens
  with a red warning that tells readers not to use them. Only the
  `benchmarks/*.md` pages keep the full archive. See EDITOR.md.
- **Write prose in ASD-STE100 Simplified Technical English.** Short
  sentences, active voice, one idea per sentence.
- **Terminology follows the community.** Repetition loop, degeneration,
  tool-call loop. Never "collapse" for repetition
  (`hardware/m1-max-32gb/research/run2/results/terminology.md`).
- **Do not write code comments** unless the owner asks for them.
- **Three places for machine state, and they are not interchangeable.**
  `~/.config/choose-a-local-llm/` holds configuration the owner edits.
  `~/.local/share/choose-a-local-llm/` holds evidence that must
  survive: a cache is by definition safe to delete, and a session log
  behind a published measurement is not. `~/.cache/choose-a-local-llm/`
  is for things that can be rebuilt. When in doubt, it is not a cache.
- **Never version the owner's machine.** This repo is public work about
  a method. A list of the owner's login items, a BTM dump, a process
  list, or any other inventory of their apps is personal data and does
  not belong in git, not in a run folder and not as "raw output". Write
  the method into the repo and keep the machine's own state in
  `~/.config/choose-a-local-llm/`. A tool reads its list from there and
  ships with none. If you have already committed such a file, say so
  and rewrite the branch before it is pushed.
- **A script that changes the owner's Mac is read before it is run.**
  This is their main laptop and it cannot give them surprises. Optimize
  the script for a human who reads it top to bottom, not for length.
  Few commands, not few lines.
  - Put the data first: named lists of what the script acts on, one
    item per line, grouped by why the item is in the list.
  - One small function per action, named for the action.
  - No `&&` chains and no one-liners. One command per line.
  - Print what happened per item, including what was skipped. Silence
    hides a wrong label.
  - Every change is reversible, and the reverse reads a state file the
    script itself wrote. Never reverse from a hardcoded list; that
    would undo the owner's own settings.
  - Guard both directions, and say what to do instead when refusing.
  - Header comment: what it does, both directions, and any step the
    owner must take (for example a reboot). This is the exception to
    the no-comments rule above, plus the group labels on the lists.
  `tools/mac-services.sh` is the reference shape.
- **Commit before you ask for review.**
- **Verify before you claim.** Run `npm run verify` and quote the result.
- Run kits live in `hardware/<hardware-id>/benchmarks/bench<N>/`;
  research kits in `hardware/<hardware-id>/research/run<N>/`; shared run
  tools in `benchmarks/`. Site prose calls them **benchmark runs**,
  numbered, never "night runs". When a run closes, add its findings to
  `hardware/<hardware-id>/benchmarks/INDEX.md`.
- **A run branch commits inside its own run folder only.** That is
  `hardware/<hardware-id>/benchmarks/bench<N>/` or
  `hardware/<hardware-id>/research/run<N>/`, plus the Mendel kit's own
  repository for Mendel rows. A run branch never edits `models.json`,
  the site pages, the method pages, or any other shared file. Scoring,
  publishing and every shared-file change happen on `master` after the
  merge.
- **When master moves a run folder, rename it on the run branch first.**
  On the run branch, `git mv` the run folder to the same new path,
  commit, then merge `master`. Both sides renamed the same path, so the
  merge is clean.
- **Every run kit has the same shape**: `AGENT.md` (the runbook),
  `state.md` (the log, deviations noted as they happen), `results.md`
  (the summary table), `results/` (raw output). Do not invent other
  names. Do not put anything in a `bench<N>/` that a later run will
  need; that goes in `benchmarks/` (root).
- **Improve shared tools in place; never copy them into a run folder.**
  A script that two runs need lives in `benchmarks/` (root). A copy in
  a `bench<N>/` forks it (this happened three times with
  `run-humaneval.sh` before the reorganization). Old copies inside
  `bench1/`-`bench2/` are archive, not tools. Do not run them.
- **The methodology stays split by task.** `docs/methodology.md` is the
  overview only. A new rule, quirk, or lore item goes into the matching
  `docs/methodology/` page, not into the overview and not into a run
  file. The checklist stays a checklist: steps only, the "why" links
  out. A new test kind gets its own page, added in the same pass to the
  overview's table, the sidebar (`docs/.vitepress/config.mjs`), and the
  index above.
- **Two different `benchmarks/` exist. Do not mix them.**
  `benchmarks/` at the repo root holds run kits and tools (never
  published). `docs/setups/<setup>/benchmarks/` holds the site's
  raw-data pages (published). "The benchmarks page" always means the
  site one.
- **When you add or move a file agents need, update the index above in
  the same commit.** A line nobody can find does not exist.
- `HANDOFF.md` is the owner's working context: gitignored, coordinator
  agents only, never the benchmark runner. Writing rules in
  `benchmarks/PLANNING.md`; every repo user starts with an empty one.

Nothing outside `docs/` reaches the published site.
