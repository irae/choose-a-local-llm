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
