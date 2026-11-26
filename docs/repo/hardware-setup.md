# Hardware Setup

Prepare your machine once before running benchmarks so memory readings and ceilings are repeatable. Never commit your machine's local config or service lists to git.

## Local Config Directory

Store machine-specific configuration outside the repository under `~/.config/choose-a-local-llm/`:

- `machine.md` — Apps to quit before runs, thresholds (`iogpu.wired_limit_mb`, free-memory skip threshold), ports, tool paths, and observed baselines. Read by `tools/preflight.sh`.
- `services-user-agents.conf` / `services-system-daemons.conf` — macOS launchd labels toggled by `tools/mac-services.sh` (see `tools/README-mac-services.md` for how to build your own list safely from BTM and launchctl baselines).

Store persistent run evidence (session logs, generated KV bias files) under `~/.local/share/choose-a-local-llm/`, never `/tmp`.

## macOS (Apple Silicon)

Do these steps in order, with the owner present:

1. **Services list:** Build `services-user-agents.conf` and `services-system-daemons.conf` following `tools/README-mac-services.md`, disable background items with `tools/mac-services.sh turn-off`, and reboot.
2. **Wired memory limit (`iogpu.wired_limit_mb`):**
   - `sudo sysctl iogpu.wired_limit_mb=<MB>` caps the Metal/IOGPU wired allocation. Confirm the value took effect via `recommendedMaxWorkingSetSize` in `llama-server` startup logs.
   - Start above the default (~2/3 of RAM) and step up by 500–1000 MB using your largest model at its largest loadable `-c` with a slow depth sweep (60 s per step).
   - Stop at the first rung that panics, glitches, grows swap earlier than the rung below, or fails to raise the clean depth ceiling (meaning physical RAM now binds before the sysctl).
   - Pick the highest rung that passed cleanly twice, minus one rung of safety margin. Note that `0` resets on reboot; record the chosen value in `machine.md`.
   - Redo only after a macOS update, a new model size class, or a change to your background services list.
3. **Preflight check:** Run `tools/preflight.sh` before every benchmark session to confirm GPU availability, wired limit, and resting memory.

## Linux (Dedicated GPU / CUDA)

- **VRAM isolation:** Close heavy GPU consumers or measure with your real desktop baseline if the card drives your display (for example, leaving ~1–1.2 GB VRAM headroom on a shared 16 GB card prevents driver watchdog timeouts during long agent runs).
- **Explicit offload flags:** Always pass `-ngl 999 --fit off -fa on` to `llama-server` so automatic layer fitting does not silently alter placement between runs. Use explicit `--n-cpu-moe <N>` when measuring partial MoE expert offload.
- **Router service:** Use `tools/llama-router.sh` (`start`, `start prism`, `status`, `stop`, `install`) to serve presets from `hardware/<id>/models.ini` on port `8888`, one loaded model at a time.
