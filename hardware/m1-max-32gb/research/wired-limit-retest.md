# Research item — re-find `iogpu.wired_limit_mb` (top item of run 3)

The standing value is 24000, chosen on 2026-08-29. A second value,
22000 for when the owner works beside a run, was chosen the same day
and retired on 2026-09-06: the machine is a model server during a run.
Two things changed since the choice, and neither was fed back into it.
This item runs the ladder in
[the wired limit page](../../../docs/methodology/wired-limit.md) and
replaces the value or confirms it.

The owner is available for `sudo` and for a reboot after a panic. That
is why this item is first: nothing else in run 3 needs the owner
present, so this block uses the time when they are.

## History of the value

| value | date | why it was chosen | source |
| --- | --- | --- | --- |
| 27000 | 2026-08-25 | first value, picked to reach the deepest contexts | `c62a3df`; `docs/setups/m1-max-32gb/historical.md`, danger box |
| 24000 | 2026-08-25 | trial after 27000 made the machine too slow for normal use; capped Qwen3.6-35B at 40K | `8b171a1` |
| 25000 | 2026-08-25 | compromise: gave Qwen3.6-35B 96K instead of 40K | `4e154f4`; `docs/setups/m1-max-32gb/benchmarks/qwen3.6-35b-a3b.md` line 25 |
| 24000 + 22000 | 2026-08-29 | 25000 and 24000 measured the same ceiling, so higher bought nothing; 22000 added as the clean-gating value for when the owner uses the machine | `63ecc31`; `docs/setups/m1-max-32gb/index.md`, "The wired limit" |
| 24000 | 2026-09-06 | 22000 retired: the machine is a model server during a run, shared use is not a case we evaluate | `docs/setups/m1-max-32gb/historical.md`, "The 22000 in use wired limit" |

Every rung above was measured with **fast** sweeps. The slow-creep rule
landed in the same commit that set the 24000 policy.

## The two open facts

1. **25000 was never retried under the slow creep.** The 2026-08-29
   verdict "25000 and 24000 give the same ceiling" rests on fast-sweep
   ceilings, and a fast sweep understates a ceiling
   (`docs/methodology/memory-ceiling.md`, the rate rule). The
   comparison that retired 25000 is not a comparison the current rules
   would accept.
2. **Runs at 24000 already sit at 25.5 GB wired and serve.** The
   Gemma-26B GGUF f16 creep of run 9 held 25.5-25.6 GB wired for the
   whole sweep, over the 24000 MB limit, stable and not compacting
   (`../benchmarks/bench9/results.md`). Run 10 A2 held 25.3-25.5 GB
   clean, and run 10 A1 held 25.1 GB with free memory at 54-94 MB and
   compressor bursts above 100,000 pages
   (`../benchmarks/bench10/results.md`). So the sysctl bounds the
   Metal share, not total wired memory, and the machine is already
   working above the number we publish. Whether the sysctl still gates
   anything at 24000 is exactly what is untested.

## The ladder for this machine

32 GB physical. Rungs, in order, control first:

| rung | role |
| --- | --- |
| 24000 | control. Reproduces the standing value under the slow creep. |
| 25000 | the value retired without a slow-creep test. |
| 26000 | first new rung. |
| 27000 | the retired first value, now judged for unattended use only. |
| 28000 | last rung. Stop here whatever happens; 4768 MB from physical RAM. |

Two clean passes per rung, per the method page. A rung that panics or
locks up ends the ladder.

## Balloons

Both come from `docs/setups/m1-max-32gb/models.json`. Use the same `-c`
on every rung.

- **Largest GGUF, 25.6 GB:** `gemma26-gguf`,
  `unsloth/gemma-4-26b-a4b-it-GGUF:UD-Q4_K_XL`, MTP f16, n-max 2, one
  slot, `-c 212992`. This is the primary balloon: it is the config that
  already runs above the limit, so it is the one whose behaviour the
  ladder must explain.
- **Largest MLX, 22.5 GB:** `bonsai-mlx`,
  `prism-ml/Ternary-Bonsai-27B-mlx-2bit`, `--prompt-cache-size 2`. Run
  it at the chosen rung only, as a confirmation. MLX servers read
  almost nothing in `IOAccelerator`, so read `Pages wired down`
  (`run1/results/backend-diagnosis.md`).

No downloads. Both files are in the cache.

## Cost

About one hour per pass: load, `-c` check, slow creep at 25 s per step,
then the wired-recovery wait. Two passes per rung and five rungs is
about 10 hours, plus a reboot between rungs and one MLX confirmation
pass. Budget **10 to 12 hours across two sessions**. A panic adds a
reboot and a report read, not a re-run: a failed rung is not retried.

## Decision rule

- The value becomes the highest rung that passed twice clean, minus
  one rung.
- **If 24000 stays the answer, that is a result, not a failure.** It
  would mean the fast-sweep verdict of 2026-08-29 was right for the
  wrong reason, and the site gets the correct reason.
- Any change to either value supersedes every published context maximum
  measured under 24000. Those rows move to
  `docs/setups/m1-max-32gb/historical.md` in the same pass, and the
  machine file gets the new row. Both are `master` work, after the
  merge.
