# T2.1 — llama.cpp context ramp with the MTP drafter

Run 2, session 1, 2026-09-04, on the freshly rebooted machine.
`iogpu.wired_limit_mb=24000`, zero swap at start, no other model
resident. Script: `context-ramp.sh` in this folder. Server logs:
`~/.local/share/choose-a-local-llm/evidence/run2-context-ramp/`.

Model: `unsloth/gemma-4-12b-it-GGUF:Q4_K_XL` with its MTP draft model,
`--spec-draft-n-max 4`, `--parallel 1`, `-fa on`, q8_0 K and V, `--jinja`,
one slot. One warmup completion per arm: "Write a Python function that
parses ISO dates.", temperature 0, 200 tokens.

## Result

| Mode | Context | Loaded | Drafter allocated | Wired after load | Peak wired | Swap growth |
| --- | --- | --- | --- | --- | --- | --- |
| `-ngl 999` | 8192 | yes | yes | 10022 MB | 10028 MB | none |
| `-ngl 999` | 32768 | yes | yes | 10339 MB | 10345 MB | none |
| `-ngl 999` | 65536 | yes | yes | 10822 MB | 10822 MB | none |
| `-ngl 999` | 131072 | yes | yes | 11738 MB | 11744 MB | none |
| `-ngl 999` | 262144 | yes | yes | 13598 MB | 13604 MB | none |
| `--fit on` | 8192 | yes | yes | 10148 MB | 10055 MB | none |
| `--fit on` | 32768 | yes | yes | 10379 MB | 10358 MB | none |
| `--fit on` | 65536 | yes | yes | 10817 MB | 10822 MB | none |
| `--fit on` | 131072 | yes | yes | 11648 MB | 11653 MB | none |
| `--fit on` | 262144 | yes | yes | 13506 MB | 13511 MB | none |

Every arm served. Every arm allocated the drafter. Draft acceptance was
**0.57322 (137 accepted / 239 generated), mean length 3.25** in all ten
arms — identical, because the prompt and temperature are fixed.

## What it settles

**The drafter does not fail at 262144.** Run 7 recorded the MTP drafter
breaking the backend at the vetted 262144 config, and run 1 could only
show it working at 8192. The ramp closes the gap: on a prepared machine
the full 256K config loads, allocates the drafter, and serves, at a cost
of 13.6 GB wired.

So the failure was never the context. bench7 H2's reading — that
`-ngl 999` disables llama.cpp's automatic fitting and the drafter then
hits a hard Metal allocation failure — still explains the shape of the
old failure, but the trigger has to be machine STATE, not the context
number. On this machine, with 24000 MB wired allowed and nothing else
resident, there is room at every step.

**`--fit on` changes nothing here.** It is not a degradation path in
this range, because nothing needs degrading: it produced the same
contexts, the same drafter, and memory within 100 MB of the `-ngl 999`
arm. The two flags only diverge when the request does not fit, which
this ramp never reached.

**Memory scales gently.** 8192 to 262144 costs 3.6 GB, about 14 MB per
1000 tokens of context with q8_0 KV. The weights dominate: 10 GB of the
13.6 GB total is present at the smallest context.

## What it raises

The speed does not match the published page. Every arm measured
**27.3 tokens per second** of generation (36.5 ms per token) and 60-65
tokens per second of prompt evaluation. The published
`gemma-4-12b-it.md` records 45.0 py tokens per second for this
configuration.

Three things differ from that measurement and any of them could carry
it: the published run used f16 KV (the page says f16 measured +5.5 py
tok/s over q8_0, which does not cover a 40% gap), the published wired
limit was 27000 rather than 24000, and the build was 10621 / commit
c1d0e7a00 rather than the current homebrew 0.3.0. The page already
carries a note that a q8 re-probe under the current wired limit is
pending.

This is not a correction. It is one prompt, 200 tokens, measured for a
different purpose. It says a re-probe is worth doing before the 45.0
number is quoted again, and it is a proposal for the owner, not a change.

## What the ramp does not answer

Whether the drafter fails under memory pressure — the condition run 1
inferred. The ramp deliberately ran on a quiet machine. Reproducing the
original failure needs a second model resident or the wired limit low,
which is a different experiment and a riskier one.

## Meter note — the IOAccelerator question is closed

Run 1 found `vmmap --summary` IOAccelerator reading 1.7 MB while an
`mlx_lm.server` process held 8.5 GB, and left an open question: is that
meter useless in general, or only for MLX?

**In general.** Sampled on the live llama-server during the T1.1 replay,
while the model and its KV cache held about 13.6 GB of wired memory:

```
Physical footprint:         3.4G
IOAccelerator                64K
IOAccelerator (graphics)   9152K
```

IOAccelerator reads about 9 MB. `Physical footprint` reads 3.4 GB, also
far under the wired cost, because Metal buffers do not land in the
process footprint. Two different backends, the same answer.

So `Pages wired down` is the only meter that answers "how much memory
does this model hold". Neither IOAccelerator nor physical footprint may
be used for a memory-fit decision on this machine. The same sample also
shows `vmmap` reporting 478.6 MB swapped out in writable regions while
`sysctl vm.swapusage` reports zero swap used; trust the system counter.
