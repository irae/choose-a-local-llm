# Run 10 — state

Created 2026-09-05 by the coordinator. No sessions yet.

Start here: read `AGENT.md`. Log every session below with a
handing-over section at the end.

## Session 1, 2026-09-05

Worktree `../choose-a-local-llm-run10` on branch `run10`, verified with
`git worktree list`. Mendel repo pulled to `d99ff4d` (`a41170a4` in).
GPU was free. LM Studio quit and confirmed gone. Background services
already off from a prior session. `iogpu.wired_limit_mb` already 24000
(no reboot needed to set it).

Deviation: swap in use at start (818.75M used, `Pages wired down`
113513), and this session runs Block A speed sweeps. The checklist's
reboot condition holds, but the owner chose to skip the reboot. Any
speed number from Block A carries this as a recorded deviation; watch
for swap growth during the sweeps as the invalidating signal.

Starting Block A.
