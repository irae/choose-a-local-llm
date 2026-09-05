# Audit of the sweep scripts, before any rewrite

Run 2, 2026-09-04, at the owner's request. Findings only. **Nothing was
changed.** These are shared tools under `tools/`, and the instrument
behind published numbers should not be rewritten mid-run by a research
session.

## The near-duplicates are real

| Pair | Diff | What the second adds |
| --- | --- | --- |
| `llama_sweep.py` / `llama_sweep_slot.py` | **4 lines** | env-settable base URL, `id_slot`, a pause |
| `mlx_sweep.py` / `mlx_sweep_slow.py` | **3 lines** | a pause |

## The finding that matters: the pause rule is implemented once, in six scripts

`docs/methodology/context-creep.md` states the rule plainly — "creep
slowly, ~25 s between depth steps" — and says a no-pause sweep
understates the ceiling.

| Script | pause default | endpoint | death watchdog |
| --- | --- | --- | --- |
| `llama_sweep.py` | **25 s** | `/completion` | no |
| `llama_sweep_slot.py` | **0** | `/completion` | no |
| `mlx_sweep.py` | **none at all** | `/v1/completions` | yes |
| `mlx_sweep_slow.py` | **0** | `/v1/completions` | yes |
| `lmstudio_sweep.py` | **0** | `/v1/completions` | yes |
| `lmstudio_sweep_alt.py` | **0** | `/v1/chat/completions` | yes |

**`mlx_sweep_slow.py` is not slow.** Its name asserts the documented
behaviour and its code does not implement it: `STEP_SLEEP` defaults to
0. Any MLX or LM Studio sweep run without that variable set was a
no-pause sweep. By the method's own statement that is a sweep which
understates the ceiling.

That is a question about existing numbers, not only about tidiness.
Which past sweeps set `STEP_SLEEP` is checkable in the bench state files
and was not checked here.

All six do implement the 8 tok/s floor stop correctly.

## Two things that should NOT be unified

**`lmstudio_sweep_alt.py` is not a duplicate.** It grows N independent
prompts round-robin to simulate several agents each growing their own
session. Merging it away would delete a distinct experiment. It belongs
as a mode, not as a file.

**The backends differ in ways that are load-bearing:**

- LM Studio's `/v1/completions` returns garbage on this build and streams
  the whole reply in one burst — verified 2026-08-29 and documented in
  the script itself. It must use chat completions. llama-server uses raw
  `/completion`.
- Only llama-server has `id_slot`. LM Studio's context identity is
  whatever its prompt cache keys on, so the alt script uses disjoint
  block-number ranges to keep prefixes from colliding.
- MLX and LM Studio scripts carry a generation-thread death watchdog.
  **Neither llama script does.**

## Shape a rewrite could take, if the planner wants one

A shared runner owning the parts the method defines:

- append-only prompt growth (the prompt-cache rule)
- the depth ladder: 4K, 8K, 16K, 24K, 32K, then 16K steps
- cadence, defaulting to the documented 25 s and not to 0
- reading the memory watcher per step, which no script does today
- the stop criteria: floor, OOM, window
- one output format

Plus a thin adapter per backend owning only what genuinely differs:
endpoint and request shape, how decode speed is read, cache-hit
reporting, and liveness detection.

That gives one file per backend with multi-context as a flag, which is
what the owner asked for, without deleting the alternating experiment.

## What the docs would need

`context-creep.md` names `lmstudio_sweep_alt.py` for LM Studio and names
no script for llama.cpp or MLX. It should name one per backend, the way
it already does for LM Studio. The owner also asked for a closing
section listing what not to try, with the git history as the record, and
a list of known pitfalls. The pitfalls this audit found:

- a sweep script whose name promises a pause it does not default to
- LM Studio's raw completions endpoint being unusable on this build
- a resident LM Studio app silently sharing the GPU with a llama.cpp
  run, even after `lms server stop` and `lms unload --all`
- allocating far more context than the sweep will reach, which costs
  memory for nothing
