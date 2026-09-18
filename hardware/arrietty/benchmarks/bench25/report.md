# Run 25 — report

The large form of the run's status line
(`docs/methodology/status-lines.md`, "The site comparison, in full").
The Q4_K_M build of an abliterated Qwen3.8-27B, served with part of its
weights in host RAM, at effort medium by owner overrule. Three of nine
blocks ran, 2026-09-18; a gate ended the run at the speed sweep.

The question: this card holds 16 GB and the file is 15.66 GiB, so the
model cannot serve from VRAM alone. Fix the window at 65536, keep the
KV cache and as many layers as fit inside a VRAM cap, and let host RAM
hold the rest. **The cap is this run's own rule** (owner, 2026-09-17):
used VRAM stays at or below 13811 MiB, which leaves 2.5 GB for the
system. The card's standing rule has no reserve.

## What ran

| block | result |
|---|---|
| `machine-setup` | file fetched, sha256 and size match, 29G free disk |
| `qwen38-oblit-q4km-offload-ladder` | **`-ngl 45` of 64**, four loads |
| `sweep-qwen38-oblit-q4km` | every depth under the 8 tok/s floor |

The ladder, at `-c 65536` and q8_0 KV:

| `-ngl` | VRAM at load | verdict |
|--:|--:|---|
| 43 | 12945 MiB | pass |
| 51 | 14963 MiB | fail, over the cap |
| 47 | 13965 MiB | fail, over the cap |
| 45 | 13397 MiB | **pass**, 13426 MiB under a real 64K request |

The sweep, `-c 65536`, q8_0 KV, `-ngl 45`, no drafter:

| depth | 4096 | 24576 | 49152 | 64512 |
|---|--:|--:|--:|--:|
| tok/s | 5.13 | 3.49 | 2.67 | 2.31 |

## The gate, and the decision

The sweep's speed gate fired: no depth reaches the 8 tok/s usability
floor. The runner reported the numbers and a candidate reading; the
coordinator ended the run there (2026-09-18). A full EvalPlus at about
3 tok/s would spend most of a day to score a config that already fails
the floor, and an agent row cannot run under it at all. The
calibration, the EvalPlus block, the forced re-run, the smoke and the
blind row did not run.

## Findings

- **Weights in host RAM cost about 4.4 times the speed on this card.**
  The same model's Q3_K_M build, entirely in VRAM, reads 22.67 tok/s at
  4K (run 23). This reads 5.13 with 19 of 64 layers in host RAM. At
  depth the gap widens: 16.74 against 2.31 at about 64K.
- **Memory was never the limit; the bus was.** VRAM held flat at 13422
  to 13424 MiB against the 13811 MiB cap through the whole sweep. There
  was headroom and it bought nothing, because the cost is the transfer
  of 19 layers per token, not capacity.
- **A 16 GB card can serve a 15.66 GiB model at a 64K window, and the
  result is not usable.** The run answers the question it existed to
  ask, and the answer is negative. This closes the host-RAM offload
  question for a dense 27B on this card.
- **A smaller window does not rescue it.** At q8_0 the cache costs 34
  MiB per 1024 tokens, so halving the window to 32768 frees 1088 MiB,
  and the ladder's own two loads put a layer at about 226 MiB. That is
  about four more layers, near `-ngl 49`, which leaves 15 layers in
  host RAM instead of 19. The estimate is arithmetic from two loads,
  not a measurement, and it does not reach the floor.
- **The pair with run 23 is a speed and memory pair, not a quality
  one.** No quality or agent number exists for this build, by the
  gate's own decision.

## Pending

- Nothing on this card. A quality row for this build would need a
  serving config that reaches the floor, and none exists here.
- The same file on the reference setup, where 32 GB of unified memory
  holds it with no offload at all, is a different question and a
  different machine.
