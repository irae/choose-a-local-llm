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
   chunks where the server has none).
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

## Multi-slot (multi-agent) configs

Reported tok/s comes from ONE slot decoding alone, not all slots
decoding at once. Slots are parallel *contexts*, not parallel *use*: a
sub-agent's slot holds its place while idle, but a main agent and a
sub-agent rarely generate at the same instant. Depth-sweep the single
slot exactly as any other config; the other slots stay loaded but idle.
For N alternating contexts on LM Studio use
`tools/sweeps/lmstudio_sweep_alt.py`.

## Measured law so far

MLX runtimes barely creep but hit hard memory ceilings; llama runtimes
creep faster but never OOM inside their window. Speculative decoding
costs depth — the floor arrives shallower with a drafter; measure both.
