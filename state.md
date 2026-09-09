
## Needs coordinator

- 2026-09-08, preflight: the machine file (`~/.config/choose-a-local-llm/machine.md`)
  still says wired limit 24000/22000. AGENT.md's own rule for this run sets it to
  25000 (owner, 2026-09-07), and the live `sysctl -n iogpu.wired_limit_mb` already
  reads 25000, matching AGENT.md. Preflight's `fix wired-limit` line would set it
  BACK to 24000, which would break AGENT.md's own rule, and the checklist forbids
  sudo by the runner. Candidate answer: the machine file needs its own update to
  25000, not the sysctl. Treating the live value as correct and proceeding, since
  it already matches AGENT.md.
