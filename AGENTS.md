# Agent guide

This repo answers one question for one computer: which local model, runtime,
and configuration should I code with? It holds the measurements, the process
that produced them, and a website that publishes both.

**You only need to care about two things: the content, and the commands
below.** Everything else — the base path, the sitemap, the deploy workflow,
the Pages settings — is already wired and needs no thought.

## Commands

```bash
npm install                      # once
npm run dev                      # write and preview, http://localhost:5173
npm run verify                   # build + link check. Run before every commit.
npm run deploy -- "what changed" # build, verify, commit. Stops before pushing.
```

`npm run deploy` never pushes. It prints the push command for the owner to
run. Publishing is the owner's step, always.

If another agent is already serving on 5173, add a port:
`npm run dev -- --port 5174`.

## Full index — what to read, and when, to not make mistakes

Site and process docs:

- [EDITOR.md](./EDITOR.md) — before you change any page, wording, or
  layout. Page shape, vocabulary, where each file lives, how to record
  a measurement across every surface.
- [docs/methodology.md](./docs/methodology.md) — the law for
  measurements, split by task. Read its table and open the page for
  what you are about to do. The pages, and when they save you:
  - `docs/methodology/checklist.md` — before starting ANY benchmark,
    sweep, or scoring run. Agents forget the memory watcher and the
    idle/silent-crash monitor; this is the checklist that prevents it.
  - `docs/methodology/common-rules.md` — before writing or running any
    measurement script (prompt-cache rule, KV policy, record-everywhere
    rule — the one that catches people).
  - `docs/methodology/context-creep.md` — before a depth sweep, and
    before interpreting any LM Studio ceiling (compression-onset
    criterion).
  - `docs/methodology/memory-ceiling.md` — before probing allocation
    maxima or changing the wired limit.
  - `docs/methodology/evalplus.md` — before EvalPlus or any scoring
    benchmark. The budget-calibration rule lives here; skipping it
    once cost 38% of a score.
  - `docs/methodology/mendel.md` — before a Mendel run. The real
    instructions live in the Mendel repo; this page says where and the
    house rules (one at a time, daemon cleanup).
  - `docs/methodology/polyglot.md` — before an Aider polyglot run.
  - `docs/methodology/server-lore.md` — before touching any server,
    and FIRST when a run stalls or a number looks impossible.
- [docs/website-plan.md](./docs/website-plan.md) — before changing the
  site structure or the deploy. Not needed for content work.

Benchmark work:

- `benchmarks/PLANNING.md` — before planning a run or writing a
  `bench<N>/AGENT.md`. The coordinator/runner role split and the
  HANDOFF writing rules live here. Coordinators read it; runners never
  do.
- `benchmarks/INDEX.md` — start here to learn what each run found;
  links every run's state and results.
- `benchmarks/bench<N>/AGENT.md` — the runbook to execute for run N.
  Read the newest one before doing any benchmark work.
- `benchmarks/bench<N>/state.md` — the run's log; read before resuming
  or touching anything that run left behind.
- `benchmarks/bench4/lmstudio-forensics.md` — before any LM Studio
  work; it overrides older lore.
- `benchmarks/` (root) — the shared tools every run uses:
  `run-humaneval.sh`, `run_codegen_wrapper.py` (patched EvalPlus
  client), `calibrate.py`, `mem-watch.sh`, `calibration-*.json`.
- `tools/sweeps/` — depth-sweep scripts and fast memory watcher.
- `tools/mac-services.sh` + `tools/README-mac-services.md` — turn background
  login items off before a run and back on after. The script ships with
  no list; the README says how to build one. Read the README before you
  disable anything on the owner's Mac.
- `tools/archive-evidence.sh` — copy a run's session logs somewhere they
  survive. Run it before a run's worktree is removed. Evidence goes to
  `~/.local/share/choose-a-local-llm/evidence/`, not a cache directory,
  because losing it destroys the only proof behind a published number.
- `tools/mem-probe.py` — measure what the machine will wire for an MLX
  allocation. Investigation only; it is not part of run preparation.
  Read `Pages wired down`, never the allocation total.
- `HANDOFF.md` — the owner's working context for the next main-thread
  agent; read it first when starting a session. Not committed.

## Standing rules

- **Push only on owner request.** Never push on your own initiative.
  When the owner asks for a push or for stop-and-sync, push `master` —
  and only `master`. Refusing a requested push loses data; do it.
- **Only the agent whose worktree has master checked out may merge into
  master.** Git enforces this: a branch lives in one worktree at a time, so
  from any other worktree the merge is refused. If you are not on master,
  commit on your branch and stop.
- **A run branch is temporary and local; origin holds only `master`.**
  Planning a run (writing `bench<N>/AGENT.md`) happens on `master`.
  When the run starts on the benchmark machine, create a local branch
  for it (for example `run6`), commit the run's progress there, and
  merge it back into `master` when the run finishes. Never push a run
  branch to origin. The branch exists only so a benchmark run and site
  work can proceed at the same time, each in its own worktree; all
  communication between agents goes through `master`.
- **Stop and sync — when the owner asks to stop a run and merge.** The
  goal state: all work is on `master`, `master` is on `origin/master`,
  no run branch remains anywhere, no run worktree remains. Follow these
  steps in order:
  1. Commit all open work on the run branch, including `state.md` with
     a handing-over section. `git status` must be clean.
  2. Go to the master worktree. Run `git pull --ff-only origin master`.
  3. Run `git merge run<N>`.
  4. Run `git push origin master`. This push is required — the owner
     asked for it, so the push rule above permits it.
  5. Remove the run worktree: `git worktree remove
     ../choose-a-local-llm-run<N>`, then `git worktree prune`.
  6. Delete the branch: `git branch -d run<N>`. Use `-d`, not `-D` —
     if git refuses, the merge did not land; go back to step 3.
  7. Verify and report: `git branch` lists no run branch, `git
     rev-parse master origin/master` prints the same hash twice,
     `git status` is clean. Quote these outputs.
- **The main worktree belongs to the coordinator.** A runner never works
  in the main worktree of this repo or of `../mendel`. The runner
  creates a fresh sibling worktree for its run branch (for example
  `git worktree add ../choose-a-local-llm-run<N> -b run<N>`) and works
  only there.
- **How you enter the worktree depends on the work.**
  - *Research and planning* — interactive, the owner watches. Create
    the sibling worktree with `git worktree add`, then enter it with
    the `EnterWorktree` tool and its `path` argument. The owner's HUD
    reads the session working directory, so the tool call is what makes
    the branch visible to them. Leave with `ExitWorktree`,
    `action: "keep"` — never `remove`, the branch must survive to be
    merged. Do not call `EnterWorktree` with `name`: it builds under
    `.claude/worktrees/` off `origin/master` and breaks the sibling
    convention.
  - *Benchmark runs* — long and unattended. Stay with `git worktree
    add` plus `cd` in bash. No tool call, nothing to watch. Mendel runs use two mendel worktrees: the benchmark
  branch checkout (`../mendel-benchmark`) and the per-model worktrees
  that `run-worker.sh` creates. When the run closes, the runner removes
  its worktrees (`git worktree remove`, then `git worktree prune`) and
  keeps only the branches. Never reuse an old worktree — gitignored
  artifacts stay behind in it. The merge of a run branch into `master`
  happens from the master worktree only (see the merge rule above).
- **Out of credits is a pause, never a teardown.** When a run hits a
  billing, quota, or credit-exhaustion error: keep everything alive —
  the server, the worktree, the session. Record the time and the last
  event, tell the owner at once (this is the one situation where you
  interrupt with an escalation), and wait. Resume the SAME run when
  credits return. Only the owner can declare a credit-interrupted run
  lost. Tearing down throws away the tokens already spent.
- **Scoring runs on Fable.** Scoring a benchmark run is LLM judgment
  (rubric calls, defect severity, cost-basis decisions). Do it in a
  subagent on the Fable model (`claude-fable-5`), never on a smaller
  model. Mechanical steps — recompute, mirror, regenerate tables — may
  use any model.
- **Never download a model.** Every model in the cache was chosen,
  downloaded, and tested by the owner; results depend on those exact
  files, revisions, and quants. A missing model means STOP and ask the
  owner — never pull it yourself. See `docs/methodology/common-rules.md`.
- **Never run a bare `git stash`.** The stash list lives in the shared
  `.git` directory, not per-worktree, so parallel agents clobber or
  cross-apply each other's stashes. Save work in progress as a WIP
  commit on your own branch instead. If a stash is unavoidable, name it
  (`git stash push -m "<agent/run>: <what>"`) and apply or pop it by
  that name only (`git stash pop 'stash^{/<name>}'`) — never by index.
- **No superseded number on a current page.** Not in a table, not in prose.
  Old figures move to the setup's `historical.md`, which opens with a red
  warning telling readers not to use them. Only the `benchmarks/*.md` pages
  keep the full archive. See EDITOR.md.
- **Write prose in ASD-STE100 Simplified Technical English.** Short
  sentences, active voice, one idea per sentence.
- **Do not write code comments** unless the owner asks for them.
- **Three places for machine state, and they are not interchangeable.**
  `~/.config/choose-a-local-llm/` holds configuration the owner edits.
  `~/.local/share/choose-a-local-llm/` holds evidence that must survive,
  because a cache is by definition safe to delete and a session log
  behind a published measurement is not. `~/.cache/choose-a-local-llm/`
  is for things that can be rebuilt. When in doubt it is not a cache.
- **Never version the owner's machine.** This repo is public work about
  a method. A list of the owner's login items, a BTM dump, a process
  list, or any other inventory of their apps is personal data and does
  not belong in git — not in a run folder, not as "raw output". Write
  the method into the repo and keep the machine's own state in
  `~/.config/choose-a-local-llm/`. A tool reads its list from there and
  ships with none. If you have already committed such a file, say so
  and rewrite the branch before it is pushed.
- **A script that changes the owner's Mac is read before it is run.**
  This is their main laptop and it cannot give them surprises. Optimize
  the script for a human reading it top to bottom, not for length. Few
  commands, not few lines.
  - Put the data first: named lists of what the script acts on, one
    item per line, grouped by why the item is in the list.
  - One small function per action, named for the action.
  - No `&&` chains and no one-liners. One command per line.
  - Print what happened per item, including what was skipped. Silence
    hides a wrong label.
  - Every change is reversible, and the reverse reads a state file the
    script itself wrote. Never reverse from a hardcoded list — that
    would undo the owner's own settings.
  - Guard both directions, and say what to do instead when refusing.
  - Header comment: what it does, both directions, and any step the
    owner must take (for example a reboot). This is the exception to
    the no-comments rule above, plus the group labels on the lists.
  `tools/mac-services.sh` is the reference shape.
- **Commit before you ask for review.**
- **Verify before you claim.** Run `npm run verify` and quote the result.
- Run kits live in `benchmarks/bench<N>/`; shared run tools in
  `benchmarks/`. Site prose calls them **benchmark runs**, numbered —
  never "night runs". When a run closes, add its findings to
  `benchmarks/INDEX.md`.
- **Every run kit has the same shape**: `AGENT.md` (the runbook),
  `state.md` (the log, deviations noted as they happen), `results.md`
  (the summary table), `results/` (raw output). Do not invent other
  names, and do not put anything in a `bench<N>/` that a later run will
  need — that goes in `benchmarks/` (root).
- **Improve shared tools in place; never copy them into a run folder.**
  A script that two runs need lives in `benchmarks/` (root). Copying it
  into a `bench<N>/` to tweak it forks it (this happened three times
  with `run-humaneval.sh` before the reorganization). Old copies inside
  `bench1/`-`bench2/` are archive, not tools — do not run them.
- **The methodology stays split by task.** `docs/methodology.md` is the
  overview only; a new rule, quirk, or lore item goes into the matching
  `docs/methodology/` page, not into the overview and not into a run
  file. The checklist stays a checklist: steps only, the "why" links
  out. A new test kind gets its own page, added in the same pass to the
  overview's table, the sidebar (`docs/.vitepress/config.mjs`), and the
  index above.
- **Two different `benchmarks/` exist — do not mix them.**
  `benchmarks/` at the repo root holds run kits and tools (never
  published). `docs/setups/<setup>/benchmarks/` holds the site's
  raw-data pages (published). "The benchmarks page" always means the
  site one.
- **When you add or move a file agents need, update the index above in
  the same commit** — a line nobody can find does not exist.
- `HANDOFF.md` is the owner's working context: gitignored, coordinator
  agents only, never the benchmark runner. Writing rules in
  `benchmarks/PLANNING.md`; every repo user starts with an empty one.

Nothing outside `docs/` reaches the published site.
