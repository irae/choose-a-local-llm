# Planning a benchmark run

This page is for the coordinator agent — the one that does repo design,
research, debugging, and planning. It explains how to turn open work
into a run kit that a smaller runner agent can execute with much less
context. The runner never reads this page; it reads only its runbook
and the methodology pages the runbook points to.

## Three kinds of work, three places

- `benchmarks/bench<N>/` — a bench run: hardware only, no judgment.
  A small runner executes exact commands.
- `research/run<N>/` — a research run: needs judgment and web access,
  AND the benchmark machine.
- `backlog/<mnemonic-name>.md` — one file per item, issue-tracker
  style: things to do that need no benchmark hardware (tooling, method
  pages, runner code, site restructures), not yet decided or scheduled,
  and reviewed by the owner before any agent picks one up. An item is
  not a prompt; the agent that takes it writes its own plan. An
  approved item is worked in its own sibling worktree and branch,
  reviewed by the coordinator (or the owner, when the owner asked for
  it), and merged to `master` only when both agree. When it lands, its
  backlog file is deleted in the same commit. Everything else is
  planning and stays with the coordinator.

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
2. Open with one short essentials section: the run's `state.md`
   history, the worktree command, and the rules that apply to every
   block. Do not front-load a reading list. Each block names the
   documents it needs at its own start, and the runner reads them
   there. Reason: a fresh, small context gets more attention from an
   agent than a page read an hour earlier; the runbook is already in
   the right order, so the right file gets read at the right time.
   Point, do not paste — the runbook stays short.
   `docs/methodology/checklist.md` is still the first block's reading, and the
   runbook's first instruction is its step 1: create the run worktree
   and move into it before any other action. Runners skip this when
   the runbook only implies it — spell out the exact `git worktree
   add` command with the run's number. A benchmark runbook says bash
   and `cd`. A research or planning kit says `EnterWorktree` with
   `path` instead, because that work is interactive and the owner's
   HUD reads the session directory. See `AGENTS.md`, standing rules.
3. Require the run to record its own evidence, and say where.
   - **Context per compaction cycle.** `peak_context` claims to be the
     maximum across all cycles, and today that cannot be checked: the
     session log records that a compaction happened but not the context
     size at each one. Have the run log the context reading at every
     cycle, so the maximum can be recomputed instead of trusted.
   - **Session logs must leave the scratch directory.** Mendel run 7
     produced 17 local rows and only 8 surviving session logs. The rest
     lived under a gitignored `scratchpad/` and went away with their
     worktrees, so those rows cannot be audited, defended or reproduced.
     End every run by archiving its evidence:
     `tools/archive-evidence.sh <runs-dir> <run-slug>`, which copies to
     `~/.local/share/choose-a-local-llm/evidence/`.
   - **A split turn is not a compaction.** pi writes a `compaction`
     record for both. The split turn carries a summary beginning
     `No prior history`. Counting it inflates the number; it did, twice,
     in run 7.
4. Never write a `sudo` command into a runbook. The runner verifies
   the machine read-only (`sysctl -n iogpu.wired_limit_mb`, `pgrep`,
   `vm_stat`) and, only when a value is wrong, reports it and shows the
   owner the command to run. The owner's Mac is not the runner's to
   change.
5. State the execution rules the runner must not relearn: local run
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
6. Write the blocks in priority order. Each block gives: the exact
   serving command, the exact run command (with every env var), where
   results land, what "done" means, and what to update when it is done
   (tables, `results.md`, `state.md`, commit).
7. Make every condition executable. "If promising" is a coordinator
   judgment — either resolve it while planning, or spell out the test
   the runner applies and what to do on each outcome.
8. Bake in the failure paths so the GPU never sits idle: what to check
   when output stops growing (server log first — see
   `docs/methodology/server-lore.md`), how to resume each block, and
   the order to start the next block the moment one ends. No approval
   gates.
9. Close the loop: when the run ends, the runner updates `state.md`
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

## When the owner asks what is pending

List software, bench and project items: things that produce an
artifact (a page, a tool, a run, a decision recorded in a file). Do not
list transient workflow state: what is pushed, what is staged, which
agent is running, which window to use. That belongs in the handoff's
current-state section, not in an answer.

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
- Keep it SMALL (owner rule, 2026-09-03). The handoff exists to pick
  up where things are and to say WHERE the detail lives. Committed
  content gets a pointer, never a summary. Only uncommitted state,
  open decisions, and in-flight work earn sentences. The handoff
  itself opens with a "Handoff guidelines" section that carries these
  rules and is never removed on a rewrite.
