# Run 11 — state

One section per session, in order. Deviations as they happen. A
handing-over section at the end.

## Session 1

- Worktree made: `../choose-a-local-llm-run11`, branch `run11`, at
  `6dcd1e3`. `mendel-benchmark` pulled to `b0c1e8b2` on `benchmark`.
- Read the checklist. Ran `tools/preflight.sh`. Every line `ok` except
  `wired-limit`: `sysctl -n iogpu.wired_limit_mb` reads 25000 (matches
  the run's stated limit), but `~/.config/choose-a-local-llm/machine.md`
  still lists `24000 unattended, 22000 when the owner also uses the
  machine` — it was not edited to 25000 for this run. preflight's fix
  line tells the runner to `sudo sysctl iogpu.wired_limit_mb=24000`,
  which would undo the run's own limit. The runbook says any state
  other than "sysctl 25000 and preflight's wired-limit line ok" is
  stop and ask, and the runner never runs sudo.
- STOP AND ASK: machine file not updated to 25000. Block 1 not
  started. Waiting on the owner or the coordinator to fix the machine
  file (or say the mismatch is fine to proceed past).
- Owner's answer: the runfile wins. The live sysctl value (25000)
  is the real check; the machine file text is a stale reference on
  master, fixed there separately, and does not block this run. Only
  the owner could have set 25000. Resuming at block 1.
- Block 1: `-c 98304` (the largest ladder value) loaded and served a
  real completion (65.96 tok/s decode, draft 154/192). Skipped the
  65536 and 49152 ladder steps: a smaller `-c` uses less memory than
  98304, so they would load too, and the block only needs the largest
  serving value to pick the creep's `-c`.
- Owner asked to binary-search above the ladder toward the trained
  context (262144) before the creep, per context-creep.md step 1 (the
  ladder was a fixed check, not a ceiling search). Stopped the
  in-progress creep and killed the server for this. Binary search
  result: 98304 is the ceiling; every candidate above it up to 262144
  loads but OOMs on the first real completion (table in results.md).
  Waited for wired recovery to the preflight baseline (1781 MB) between
  every candidate.
- Running the full slow creep at 98304 now. Per the owner: if the
  creep OOMs or dies, drop `-c` and creep again; do not close this
  block without a stable, complete creep.
- Creep result at 98304 (q8_0 KV): STOP, `mem` verdict, page
  compaction on 3 depths in a row without speed recovery, at depth
  32818 (decode 36.5, 44.1, 31.2, 24.1, 19.6 tok/s over depths 4114,
  8222, 16386, 24602, 32818). This is far below the site's published
  8K+ clean-depth figure and the block's 46K gate.
- SUSPECT DEVIATION, not accepted as the block's clean-machine number:
  block 1 requires this creep on a machine "clean... right after the
  reboot, before any other model has loaded." The binary search just
  before this loaded and killed the model 8 times (candidates 262144
  down to 98304) on this same machine session, so the page cache and
  memory state were disturbed before this creep ran. That is the
  likely cause of the early compaction, not a real ceiling. Machine
  was not rebooted since binary search. Result recorded here as
  evidence but not treated as the block's clean-depth finding; a
  redo after a real clean start is needed before this row can close.
