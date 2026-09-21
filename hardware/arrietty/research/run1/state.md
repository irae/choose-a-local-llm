# Research run 1 — state

Created 2026-09-20 by the coordinator. No session has run.

Start here: read `AGENT.md`, then `index.md`, which is the order. Log
every session below, and close each one with a handing-over section.

## Versions and sources

The executor writes each one here as it installs or downloads it.

| name | value | test |
| --- | --- | --- |
| `laya` package | | `harness` |
| checkpoint revisions | | `harness` |
| authors' repository commit | | `laya-claims` |
| datasets, with licence and commit | | `laya-claims`, `laya-portuguese` |

## Session 1 — 2026-09-21, executor on `arrietty`

Started at 00:29 on the coordinator's go: benchmark run 28 is closed and
the card is free.

Machine checks at the start. `tools/preflight.sh` exits 1 on this
machine. Four lines are not `ok`, and all four read macOS values that
Linux does not have: `ask apps` (no machine file), `fix login-items`
(`mac-services.sh`), `ask wired-limit` (`iogpu.wired_limit_mb`) and
`ask memory` (`sysctl` page size and swap). Bench 23 met the same
thing and did the checks by hand. This session does the same, and the
run goes on:

- `nvidia-smi`: 954 / 16311 MiB used, graphics only (Hyprland,
  quickshell, Xwayland, kitty, a browser). No compute job.
- `pgrep -x llama-server`: empty. No `mlx_lm`, no LM Studio, no Docker.
- `free -m`: 10570 MB free, 19491 MB available, swap 11364 MB used at
  the start. The swap level is pre-existing; judge it by its growth.
- `df -h ~`: 20 GB free on `/home`.
- `gh auth status` passes. The Claude login has 647 h left.
- Python 3.14.7 on the machine, `uv` 0.12.10, kernel 7.2.3-arch1-3.

Watcher. `benchmarks/run-watch.sh` needs `RUNWATCH_SERVER_LOG` or
`RUNWATCH_OUTPUT`, and this run serves no model and writes no server
log. It runs with the memory log as its own growth file, so the
silence probe never fires and the watcher is only the memory record,
which is what this run needs from it. `RUNWATCH_GPU_MIN_MB=0` turns
off the `llama-server` GPU check, because there is no server.
Log: `~/.local/share/choose-a-local-llm/research1-mem.log`. First
line 00:30:48, `free_mb=19512 gpu_used_mb=954`.
