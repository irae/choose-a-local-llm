# Research run 1 — state

Created 2026-09-03 by the coordinator. No sessions yet.

Start here: read `AGENT.md`. Log every session below with a
handing-over section at the end, like the `benchmarks/bench<N>`
convention.

## Session 1 — 2026-09-03, goal 0 start

Worktree `../choose-a-local-llm-research1`, branch `research1`.

- 13:25 owner asked one question first: can desktop widgets go off for
  a run and come back with the layout intact.
- 13:25 backed up the widget layout to
  `~/chronod-layout-backup-20260903-132554/` before any change.
- 13:26 first screenshot captured the wrong display and showed no
  widgets. Wrong conclusion, corrected by the owner's screenshot: 15
  widgets on the desktop. Screen recording permission then denied.
- 13:35-13:38 ran the hide/restore test with the owner's approval.
  Result in `results/memory-gate.md`: the toggle frees 0 MB. Restore
  verified, `StandardHideWidgets = 0`.
- Measured the always-on background cost: about 910 MB total.
- Read `benchmarks/bench7/state.md` H1-H4. H1 says the dagger-sweep
  OOM started at 60-220 MB free with a ~23 GB Metal server not yet
  reclaimed. Background apps cannot explain that.

### Dotfiles split, same day

The owner ruled that their machine's own state must not be versioned.
Moved out of the repo and into `~/.config/choose-a-local-llm/`: the BTM
dump, both `print-disabled` baselines, the machine's boot inventory, and
the two label lists `mac-quiet.sh` used to hardcode.

The repo now carries the method only. `tools/README-mac-quiet.md` says
how to decide what to disable. `tools/mac-quiet.sh` ships with no list
and reads the config directory. `results/boot-audit.md` keeps what the
audit taught, without naming apps.

Branch history was rewritten before any push, so no dump ever existed in
a commit. New standing rules in `AGENTS.md`: never version the owner's
machine, and readable scripts for anything that changes it.

### Handing over

Open decisions for the owner:

1. Test stopping `chronod` (`launchctl bootout gui/$UID/com.apple.chronod`)?
   It is the only remaining lever on the 219 MB. Widgets vanish while
   the daemon is out. Layout is backed up.
2. A `Bash` permission for the network filter vendor CLI. The classifier
   blocked `list-preferences`, so the exact filter off/on command is
   still unknown.
4. The owner plans a reboot. The first thing after it is one idle
   baseline, untouched.
3. Direction: the evidence says the gate should measure free memory
   and wait for recovery after a large server dies, not police login
   items. Confirm before the gate designs get written.

Not started: goals 1, 2, 3.


## Session 1 continued — after the reboot, goal 0

- 16:07 owner rebooted. Set `iogpu.wired_limit_mb=24000` by hand and
  noted it resets to 0 on every boot.
- 16:25-16:42 four idle samples. Free memory moved across a 1284 MB
  band with nobody touching the machine. A scheduled `XProtect` scan
  took 1084 MB of it. Recorded as finding 3.
- 16:51 wrote `tools/mem-probe.py`. It grows an MLX allocation to a cap
  and records what the system wired behind it.
- 16:52 first probe run. Same 29696 MB allocation wired 12489 MB from a
  dirty machine and 25285 MB after pressure. Finding 4.
- 16:56 control run from the clean state. Its first probe wired 24257
  MB, which rules out probe ordering. Finding 5, with a candidate gate
  formula.
- Checklist updated: quit the LM Studio app rather than only unloading
  the model, reset the wired limit after every reboot, and settle
  before trusting any memory reading.

### Handing over, second pass

The owner's instinct about wired memory was right and it changed the
goal. The gate should not compare free memory to an idle baseline. It
should ask whether the memory a run needs can be wired.

Open, in the order that matters:

1. Test the gate formula against the models already measured. Take a
   model with a known working footprint and a known OOM, compute
   `min(free + 3000, wired_limit + 1300)` before each, and see if it
   predicts which one fails. Four points on one machine is not a law.
2. Decide the pre-run reset. A balloon before every run costs about a
   minute and leaves the machine at about 25 GB free. A wired probe
   sized to the run is slower to build but tests the real precondition.
   Untested either way, and the owner picks.
3. Redo the widget test. It is now cheap: the reboot proved the toggle
   does not stop the extensions loading, so the only remaining question
   is what stopping `chronod` frees. Needs the owner's approval.
4. Goals 1, 2 and 3 are untouched.

Machine state left behind: desktop widgets off, `StandardHideWidgets =
1`. `iogpu.wired_limit_mb=24000`, which will reset on the next reboot.
Nothing else changed. `tools/mac-quiet.sh` has never been run.


## Session 1, third pass — the rate question, and a probe that is not ready

The owner asked whether the balloon was fast or slow, and said the
choice must be slow by design: agent work stops constantly for tool
calls, tests and web requests, and every gap lets macOS compact. A
benchmark that allocates in a tight loop OOMs earlier than the workload
it stands for.

That was right, and checking it exposed two faults in my own work.

- 17:01 the probe filled blocks with `mx.ones`. A repeated value
  compresses to almost nothing, so the walk reported 35840 MB allocated
  on a 32 GB machine. Every allocation ceiling in findings 4 and 5 is
  void. Fill is now `mx.random.uniform`.
- 17:03 reran fast with incompressible data. It still did not fail. At
  peak: 436 MB free, 27270 MB compressor, 8192 MB swap, where swap had
  been 0 all day. macOS degrades instead of refusing. Finding 6.
- Stopped the run before the second probe rather than thrash the
  machine. It recovered to 26412 MB free on its own, leaving 863 MB of
  swap.
- Compared the two fills and found they are not comparable: `mx.ones`
  gave 25295 MB wired at peak with swap 0, random gave 3079 MB wired
  with 8 GB of swap. Different regimes. Under real scarcity macOS
  unwires GPU memory, so the second number is what survived eviction,
  not what MLX got.

`docs/methodology/memory-ceiling.md` now carries the rate rule: record
the rate with every ceiling, never compare across rates, and treat a
benchmark OOM as pessimistic about real agent use.

### Handing over, third pass

Do not build on the probe's absolute numbers. It allocates one flat
array. A server allocates weights once and then grows a KV cache, which
is a different shape and probably a different answer. The gate formula
in finding 5 is a hypothesis from four points in a regime a model will
not be in.

What is safe to carry forward:

1. Wired is the honest counter. The compressor can inflate everything
   else, including a total that looked like an allocation ceiling.
2. Starting state changes what an identical request receives.
3. Asking too fast degrades the machine rather than failing it, so a
   sweep can keep running on swap and report throughput that measures
   the swap file.

Next, in order:

1. Rebuild the probe to allocate like a server: a fixed block for
   weights, then a slowly growing second allocation for KV. Compare
   against a model with a known footprint before trusting any formula.
2. Only then revisit the gate.
3. Goals 1, 2 and 3 remain untouched.

Machine state: desktop widgets off. `iogpu.wired_limit_mb=24000`, which
resets on the next reboot. 863 MB of swap in use from the probe, which
will clear on its own or on reboot. `tools/mac-quiet.sh` has never been
run. Nothing else changed.


## Session 1, fourth pass — corrections applied, evidence given a home

Owner rulings applied.

- The two compaction corrections are DONE, not prepared. Applied to the
  mendel repo, report regenerated, rebased over four concurrent commits
  and pushed (`ce3a693..2cdb7ba`). The diff is two lines. First attempt
  reformatted both files because `json.dump` escapes non-ASCII by
  default; reverted and redone with `ensure_ascii=False`.
- Session logs now have a home outside any gitignored scratch directory:
  `tools/archive-evidence.sh`, storing under
  `~/.local/share/choose-a-local-llm/evidence/`. Archived what survives
  of Mendel run 7: 76 files of run output, plus 3 pi transcripts. Only
  three `.pi-agent-*` directories still exist, which bounds the loss.
- NOT the cache directory. A cache is defined as safe to delete and this
  evidence is not; the XDG category for user data that must persist is
  the data directory. Keep `~/.cache/choose-a-local-llm/` for things
  that can be rebuilt.
- `benchmarks/PLANNING.md` step 3 is new and carries three requirements
  into every future run kit: log context at each compaction cycle so
  `peak_context` can be recomputed rather than trusted, archive evidence
  before the run closes, and do not count a split turn as a compaction.

### For the planner to review

`peak_context` remains unproven for every existing row. The audit could
only show it is CONSISTENT with being a maximum, because the session log
records that a compaction happened and not the context size at each one.
PLANNING.md now asks new runs to log it. Someone should decide whether
the existing rows carry a caveat, or whether the claim is dropped until
a run produces the evidence.


## Handing over — 2026-09-03, end of session

### Goals

- **Goal 0 CLOSED.** No idle baseline exists; the cold-start sequence in
  `docs/methodology/checklist.md` step 4 replaces the threshold gate.
- **Goal 1 PARTIAL.** Items 2 and 4 answered, item 3 answered, item 1
  (H4) not run — see below.
- **Goal 2 DONE.** Two compaction counts corrected and pushed to the
  mendel repo. No new thinking-level mislabels. `peak_context` cannot be
  proved from the logs and is flagged for the planner.
- **Goal 3 CLOSED** by owner decision: `agents-global.md` stays frozen,
  so the A/B has nothing to inform. Loop work moved to
  `research/run2/AGENT.md` item I.

### Running when this was written

A full-length replay of the failing `google-gemma-4-12b-low-guided` run,
on branch `repro-gemma-4-12b-low-guided-issue-13`, worktree
`../mendel-bench-repro-gemma-4-12b-low-guided`, evidence in
`~/.local/share/choose-a-local-llm/evidence/repro-gemma-4-12b-low-guided-full/`.
Five-hour cap. It answers one question: does the 72-call loop appear at
all when the machine is quiet.

**Until it does, every "no loop" number in this run is uncalibrated.**
Nothing here has produced a loop, so no negative result has a known
sensitivity. That caveat is attached wherever those numbers appear.

### Approved and not yet run

Goal 1 item 1, the H4 check. After the replay: load a large model on the
vetted `mlx_lm.server` Bonsai command purely to kill it, then poll
`vm_stat` free and `vmmap --summary <pid>` IOAccelerator side by side
every few seconds. The question is whether free memory reports recovery
before the GPU accounting does, and by how long. If it does, the pre-run
check has been reading the wrong meter.

### Machine state left behind

- Desktop widgets OFF (`StandardHideWidgets = 1`). Restore command in
  `results/restore.md`.
- `iogpu.wired_limit_mb=24000`, which resets on the next reboot.
- `tools/mac-quiet.sh` has never been run; no login item was disabled.
- LM Studio may be resident: it revives whenever any `lms` command runs.
- Two extra worktrees to remove when done:
  `../mendel-bench-repro-gemma-4-12b-low-guided` and this one.

### For the planner

- `peak_context` is unproven for every existing row. `benchmarks/PLANNING.md`
  step 3 now asks new runs to log context per compaction cycle. Someone
  must decide whether existing rows carry a caveat or drop the claim.
- The three Gemma-12B rows may be a ceiling we set, not the model.
  Evidence is in `results/invalid-runs.md`. That is an acceptance
  question, not a scoring one.
- A context ramp with the MTP drafter enabled would settle item 4, and a
  second ramp without `-ngl 999` would show whether automatic fitting
  degrades instead of failing. Both are benchmark measurements.
