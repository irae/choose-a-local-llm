# Planning a benchmark run

This page is for the coordinator agent — the one that does repo design,
research, debugging, and planning. It explains how to turn open work
into a run kit that a smaller runner agent can execute with much less
context. The runner never reads this page; it reads only its runbook
and the methodology pages the runbook points to.

## The two roles

- **Coordinator** (strong model, full context): plans, investigates,
  fixes the harness, writes the runbook, spawns the runner, judges the
  results. Its working state lives in `HANDOFF.md` (local, gitignored —
  see "The handoff file" below).
- **Runner** (smaller model, minimal context): executes
  `benchmarks/bench<N>/AGENT.md` block by block. It gets everything it
  needs from that file and the pages it links. If the runner has to
  guess, the runbook failed.

## How to write `bench<N>/AGENT.md`

1. Create the next `benchmarks/bench<N>/` folder with the standard kit
   shape (`AGENT.md`, `state.md`, `results.md`, `results/` — see
   `AGENTS.md`, standing rules).
2. Open with the reading list: the run's `state.md` history, the
   relevant `docs/methodology/` pages, and any forensics file that
   overrides older lore. Point, do not paste — the runbook stays short.
   `docs/methodology/checklist.md` is ALWAYS on the list, and the
   runbook's first instruction is its step 1: create the run worktree
   and move into it before any other action. Runners skip this when
   the runbook only implies it — spell out the exact `git worktree
   add` command with the run's number. A benchmark runbook says bash
   and `cd`. A research or planning kit says `EnterWorktree` with
   `path` instead, because that work is interactive and the owner's
   HUD reads the session directory. See `AGENTS.md`, standing rules.
3. State the execution rules the runner must not relearn: local run
   branch in a fresh sibling worktree (the main worktree stays with the
   coordinator), no bare `git stash` — named stashes only, applied by
   name (see `AGENTS.md` standing rules), scoring in a subagent on the
   Fable model (`claude-fable-5`) — never a smaller model — because
   scoring is LLM judgment, the stop-and-sync procedure from `AGENTS.md` standing
   rules when the owner asks to stop (merge to `master`, push `master`,
   delete the branch, remove the worktree — that one push is required),
   one model on the GPU at a time, port, heartbeat cadence, the scoped
   memory watcher on every run, commit as results land, never push a
   run branch, never publish.
4. Write the blocks in priority order. Each block gives: the exact
   serving command, the exact run command (with every env var), where
   results land, what "done" means, and what to update when it is done
   (tables, `results.md`, `state.md`, commit).
5. Make every condition executable. "If promising" is a coordinator
   judgment — either resolve it while planning, or spell out the test
   the runner applies and what to do on each outcome.
6. Bake in the failure paths so the GPU never sits idle: what to check
   when output stops growing (server log first — see
   `docs/methodology/server-lore.md`), how to resume each block, and
   the order to start the next block the moment one ends. No approval
   gates.
7. Close the loop: when the run ends, the runner updates `state.md`
   with a clean handing-over section, and the coordinator adds the
   run's findings to `benchmarks/INDEX.md`.

The methodology carries the "how to not make mistakes":
`docs/methodology/checklist.md` is the run loop, `common-rules.md` the
measurement law, the per-test pages the specific steps, and
`server-lore.md` the debugging lore. A runbook never restates them; it
links them at the exact step where they apply.

## Spawning the runner

Give the runner a short prompt: the reading list (its `AGENT.md` first),
the standing prohibitions (push only on owner request — and then only
`master` — no publish), the heartbeat format,
and the instruction to keep working until every block is done or truly
blocked. Pass the STE prose rule on. Do not paste findings or history
into the prompt — that is what the files are for.

## The handoff file

`HANDOFF.md` at the repo root is the coordinator's working state: what
is mid-flight, what was decided and not yet written anywhere else, what
the next coordinator session must know. It is gitignored on purpose —
it is one person's current state, not repo content. Each repo user
starts with an empty one.

Rules for writing it:

- It is NOT for the benchmark runner. Runners read their
  `bench<N>/AGENT.md`; pointing a runner at the handoff leaks
  coordinator context and stale state into a run.
- State the desired next state, never what "is running" — the next
  session starts at an unknown time, and claims about live state go
  stale.
- Keep only what the next coordinator session needs and no other file
  holds. When something belongs to a run, move it to the run kit; when
  it is a durable rule, move it to the methodology or `AGENTS.md`.
