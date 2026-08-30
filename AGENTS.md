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
- `HANDOFF.md` — the owner's working context for the next main-thread
  agent; read it first when starting a session. Not committed.

## Standing rules

- **Do not push.** The owner pushes, always.
- **Only the agent whose worktree has master checked out may merge into
  master.** Git enforces this: a branch lives in one worktree at a time, so
  from any other worktree the merge is refused. If you are not on master,
  commit on your branch and stop.
- **No one develops or runs benchmarks on master.** Before a benchmark run
  starts, create and check out a branch for it (for example `run4`). Commit
  the run's progress there. Merge to master only when the run finishes and
  its results are ready to publish. This keeps master free for site work and
  lets a benchmark run and site work proceed at the same time, each in its
  own worktree.
- **No superseded number on a current page.** Not in a table, not in prose.
  Old figures move to the setup's `historical.md`, which opens with a red
  warning telling readers not to use them. Only the `benchmarks/*.md` pages
  keep the full archive. See EDITOR.md.
- **Write prose in ASD-STE100 Simplified Technical English.** Short
  sentences, active voice, one idea per sentence.
- **Do not write code comments** unless the owner asks for them.
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
