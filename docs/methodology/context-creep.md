# Context creep — decode speed against USED context

Allocation is storage; used tokens are what decode pays for. This test
finds the depth curve, the floor, and the "capped by" verdict for a
config. Common rules and the run loop apply
([common rules](./common-rules.md), [checklist](./checklist.md)).

## Requirements

- The server for ONE config, warmed up.
- The scoped memory watcher running from the first request.
- Append-only prompt growth (prompt-cache rule) — the sweep scripts in
  `tools/sweeps/` already do this.
- The pause rule: **creep slowly, ~25 s between depth steps.** The pause
  simulates real use — an agent's model waits on the user and on tool
  runs between requests — and it gives macOS time to compress other
  memory, which raises the measured ceiling (verified: ~2K extra tokens
  on Qwen3.6-35B MLX at limit 24000). A no-pause sweep understates the
  ceiling a real harness reaches.

## Steps

1. Grow a prompt in steps: 4K, 8K, 16K, 24K, 32K, then 16K steps.
2. Measure decode tok/s at each depth (server timings, or streamed
   chunks where the server has none). With a drafter, record draft
   acceptance beside every tok/s: a speculative-decoding number
   without its acceptance rate cannot be compared with a later run
   (research run 2 could not reproduce a published 45.0 py tok/s for
   that reason alone).
3. Stop at the first reading under the usability floor (ours: 8 tok/s),
   at OOM, or at the model's trained/max context — never earlier. **A
   sweep that stops at an arbitrary depth has not found a ceiling — it
   has just stopped.** Record "no ceiling found up to `<max>`" only
   after the sweep actually reached that number.
4. Check the watcher log per step for compression/swap events before
   trusting a slow step.
5. Verdict, one of: **speed** (drops under the floor), **OOM** (dies
   while still fast), **window** (the model's own limit arrives first),
   or **mem** (LM Studio only, below).
6. Record on every surface; the floor — not the window — is where the
   harness compaction threshold belongs.

## LM Studio: the compression-onset criterion

Context length cannot be pinned on LM Studio for some MLX models
(auto-fit always wins — [server lore](./server-lore.md)), so the raw
window is a loader estimate, not a measurement. For LM Studio configs:

- **The ceiling is the FIRST depth step whose watcher log shows material
  compression or swap** (hundreds of pages, not single digits).
- The reported tok/s comes from the last clean step before onset.
- The context-window column keeps the auto-fit estimate, flagged as a
  loader estimate; the trained max goes in a footnote.
- The engine stays functional well past onset — that functional range is
  worth a note for harness use, but it is not the ceiling.

## Multi-context (multi-agent) configs

Reported tok/s comes from ONE slot decoding alone, not all slots
decoding at once. Slots are parallel *contexts*, not parallel *use*: a
sub-agent's slot holds its place while idle, but a main agent and a
sub-agent rarely generate at the same instant. Depth-sweep the single
slot exactly as any other config; the other slots stay loaded but idle.
For N alternating contexts use `N_CONTEXTS` on the backend's creep
script. Round-robin works on all three backends: `mlx_lm.server` holds
several distinct KV caches when started with `--prompt-cache-size` at
least as large as `N_CONTEXTS`.

## The scripts

One per backend, all sharing `tools/sweeps/creep.py`, which owns the
method: the 25-second pause as a DEFAULT, append-only growth,
round-robin contexts, memory sampling, and the stop conditions.

- `tools/sweeps/creep_llama.py` — llama-server. `ENDPOINT=completion`
  (default) is raw and comparable with every published number here;
  `ENDPOINT=chat` is the path a harness uses. llama-server defaults
  `enable_thinking` to TRUE on the chat path, so set `THINKING=off`
  when that is what you mean.
- `tools/sweeps/creep_lmstudio.py` — LM Studio. Chat endpoint only.
- `tools/sweeps/creep_mlx.py` — `mlx_lm.server`. Set `SERVER_LOG`; this
  backend's generation thread can die while `/health` stays green.

## Measured law so far

MLX runtimes barely creep but hit hard memory ceilings; llama runtimes
creep faster but never OOM inside their window. Speculative decoding
costs depth — the floor arrives shallower with a drafter; measure both.

**The KV cache type can dominate everything else.** On Gemma-4-12B,
q8_0 KV falls through the 8 tok/s floor by 16K used tokens while f16 is
still at 13.0 tok/s at 131K — a 3.2x gap at 16K. Measure the KV type per
model before trusting a depth curve; see
`research/run2/results/gemma12-depth.md`.

## Do not try these — see git history

- **Parallel slot sweeps.** `llama_sweep_slot.py` used llama.cpp's
  `id_slot` to sweep one slot of a parallel server. The project measures
  round-robin instead: separate sessions keeping their own cache is the
  real shape, and parallel slots do not fit sub-agent use. Deleted
  2026-09-04.
- **A "slow" script beside a fast one.** `mlx_sweep_slow.py` differed
  from `mlx_sweep.py` by three lines and defaulted its pause to ZERO, so
  its name asserted behaviour its code did not have. Slow creep is now
  the default and cannot be lost by picking the wrong file. Deleted
  2026-09-04.
- **`sweep-one.sh` and `ceilings.sh`.** Both hardcoded a scratchpad path
  from a long-dead session and could not run. Deleted 2026-09-04.
- **LM Studio's `/v1/completions`.** Returns garbage on this build and
  streams the whole reply in one burst with no per-token pacing —
  verified 2026-08-29. Use chat completions there.

## Known pitfalls

- **A resident LM Studio silently shares the GPU.** `lms server stop`
  and `lms unload --all` leave the app, its Electron helpers and its GPU
  helper running. Quit the app (`osascript -e 'quit app "LM Studio"'`)
  and confirm. A sweep run beside it showed free memory at 55 MB.
- **Allocation is not depth.** Serving `-c 262144` proves the KV fits;
  it says nothing about decode speed at 262144 USED tokens. Reading one
  as the other produced a wrong "this row is stale" claim in run 2.
- **Allocating far more context than the sweep will reach** costs memory
  for nothing and can push the machine into compaction.
- **Free memory is the wrong meter.** It stays low after the first model
  load because the weights sit in the page cache. Read `Pages wired
  down`; see `research/run1/results/backend-diagnosis.md`.
