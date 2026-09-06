# Extract the two tools into `local-llm-eval-tools`

Status: pending owner review of the prompt below. The owner creates the
folder and runs `git init`, then hands the prompt to a coordinator
agent in another pane. Nothing started here.
Filed: 2026-09-04 at the owner's request; rewritten 2026-09-06 to a
hand-over prompt, both tools in scope.
Needs hardware: no for extraction and refactor; a smoke run of each
tool against a served model at the end.

What moves, and where it is today:

| tool | source | history |
| --- | --- | --- |
| `slow-context-creep` | this repo, `tools/sweeps/creep.py` and `creep_llama.py`, `creep_mlx.py`, `creep_lmstudio.py`; method: `docs/methodology/context-creep.md` | 18 commits on `tools/sweeps/` |
| `codebase-issue-simulator` | `../mendel-benchmark`, branch `benchmark`, folder `benchmark/` (worktree of `../mendel`); plus `benchmarks/loop-check.py` from this repo, which `run-worker.sh` calls by path | 116 commits on `benchmark/` |

The runner alarms evidence: `benchmarks/history/runner-alarms-output-limit-and-loop-stop.html`.

Open for the owner, answered in the prompt as assumptions: Mendel's
results data (`results*.json`, `results*.csv`, `runs/`, the reports)
leaves the tree and stays only in history; the worker stays bash plus
node; the licence is the owner's choice, MIT assumed.

---

## Prompt for the coordinator agent

You are the coordinator for a new repository, `local-llm-eval-tools`.
The owner created the folder and ran `git init`. You have autonomy to
build the repository. You run on a medium effort model. Extraction
sub-agents run on a standard tier model at high effort. Code review
runs on the standard tier. Implementers run on the standard or cheap
tier, your call per task. Write all prose in ASD-STE100 Simplified
Technical English and pass that rule to every sub-agent.

### Goal

One repository, several small tools, each one shaped like the others:
one folder per tool, one README per tool, one README at the root, one
licence, nothing else shared at the top level. The root README says
these are the tools the owner uses to choose a local model for their
own hardware, links to `choose-a-local-llm` (the measurements and the
site), and lists each tool in one line.

Two tools now:

- `slow-context-creep`. A depth sweep that grows a prompt step by step
  against a served model and records decode speed, memory and the
  stop verdict. Backends: llama-server, mlx_lm.server, LM Studio.
- `codebase-issue-simulator`. Several models each implement one issue
  of a real repository through the pi harness; the tool keeps the run
  honest (nudges, budgets, loop stop, evidence), scores it from a
  verification battery plus a rubric, and generates the report.

Each tool ends with: simple documentation, a simple stated goal, some
behavior tests, and one example in its README. The example is
abstract and fits in one file of prose plus commands: for the creep
tool, the way `choose-a-local-llm` runs it; for the simulator, Mendel
issue 13 (eight small dependencies to replace), described, not
shipped as files.

### Sources

- `../choose-a-local-llm`: `tools/sweeps/creep.py`, `creep_llama.py`,
  `creep_mlx.py`, `creep_lmstudio.py`. Method page:
  `docs/methodology/context-creep.md`. Also `benchmarks/loop-check.py`,
  the repetition-loop verdict the simulator's worker calls by path.
- `../mendel-benchmark`: branch `benchmark`, folder `benchmark/`. It is
  a worktree of `../mendel`. Read `benchmark/PLAN.md` end to end, then
  `run-worker.sh` and `run-pi-rpc.mjs`, before you touch anything.
- House rules the tools must keep: `../choose-a-local-llm/docs/methodology/mendel.md`
  and `benchmarks/PLANNING.md` (worktree first, no bare stash, one run
  at a time, credit exhaustion is a pause, scoring on a strong model).
  `benchmark/agents-global.md` stays frozen at v1.0; a new version is a
  new results epoch.

Never edit `../choose-a-local-llm`, `../mendel` or `../mendel-benchmark`.
They are in use by live runs.

### Step 1: extract with history

Delegate each extraction to one sub-agent, in a scratch clone, never
in the source checkouts. Use `git filter-repo` (or `git subtree split`
where it gives the same result): keep only the commits that touched
the tool's paths, drop every other file from every commit, and rename
the paths into the tool's folder. Commit messages, authors and dates
survive.

- Creep: `--path tools/sweeps/` renamed to `slow-context-creep/`. Leave
  out `lmstudio_concurrency_probe.py` and `prism-probe.sh` unless the
  creep files import them.
- Simulator: `--path benchmark/` renamed to `codebase-issue-simulator/`.
  Check for files outside `benchmark/` the scripts depend on before
  the filter runs; it is one shot. Then bring `loop-check.py` in from
  `choose-a-local-llm` with its own history, and change the path in
  `run-worker.sh` in the same commit.

Bring both histories into the new repository with
`git fetch` and `git merge --allow-unrelated-histories`. Verify: commit
count per tool against `git log --oneline -- <path> | wc -l` in the
source, `git ls-files` shows nothing foreign, every script references
only files that exist. Show the owner the counts and the file list
before any push.

Mendel's measurements (`results*.json`, `results*.csv`, `runs/`, the
generated reports) leave the tree in one commit after the merge. They
stay in history; the owner's mirror in `choose-a-local-llm` keeps the
live copies.

### Step 2: plan the refactor

Load the superpowers brainstorming skill, then the writing-plans
skill, and write one plan per tool inside the repository. The plan
states which files exist after the refactor, what each exports or
consumes, the test blocks by intent, and the README outline. Stop for
the owner's review before the refactor starts.

Refactor targets, both tools:

- One entry point per tool, one README with the same section order:
  what it does, install, run, output, tests, example.
- Generic method separated from any one target. For the simulator, a
  task definition is a folder: target repository and base ref, issue
  text, prompt variants with versions, rubric, verification battery
  command, completion unit and its maximum, cleanup hooks. The runner,
  scorer and report generator read a task, not Mendel. The results
  file keeps the field names `PLAN.md` documents, because
  `choose-a-local-llm` reads them.
- Tests test behavior, not implementation: a fake server for the creep
  tool, a fake pi session for the simulator. Keep and extend any test
  that already exists in the sources.
- The worker stays bash plus node. Python stays for the creep tool.

### Step 3: implement and prove

Delegate implementation per plan task to implementers; review every
task with a code-review sub-agent before you merge it. Prove each tool
at the end:

- Creep: a smoke sweep against a served model, or the fake server when
  no model is available, reproduces the output shape
  `choose-a-local-llm` consumes (header, one row per step, events,
  the STOP line).
- Simulator: the Mendel task, written in the new task format, replays
  one existing row on a cheap model, unscored: same worker command
  shape, same telemetry fields, same evidence pack, same report.

Report to the owner: what moved, what each README says, which tests
run, what the smoke runs showed, and what you left out and why.
