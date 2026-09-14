# Run 13 — report

The large form of the run's status line. See
`docs/methodology/status-lines.md`, "The site comparison, in full", for
the table rules. One build only, `ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF:IQ3_S-mtp`
rev `d562806`, f16 KV, wired 25000, effort medium banned. Sampling
recorded for the first time on this machine: temperature 1.0, top_p
0.95, the values llama-server reads from the model file.

Quality:

| old/new | model | config scored | pass@1 base | pass@1 plus | completion | status |
|---|---|---|--:|--:|--:|---|
| old (bench12) | Qwen3.8-27B | ISTA IQ3_S-mtp, MTP n-max 3, f16 KV, effort medium, budget 8192 | 0.976 | 0.945 | 99% | 1 empty, 3h07 |
| new | Qwen3.8-27B | ISTA IQ3_S-mtp, no drafter, f16 KV, effort low, budget 8192 | 0.976 | **0.933** | 99% | 1 empty, 2h23 |
| new | Qwen3.8-27B | ISTA IQ3_S-mtp, no drafter, f16 KV, effort xhigh, budget 30000 | **0.945** | **0.921** | **97%** | **5 empty, all at the cap**, about 9h43 active |

Speed and context:

| old/new | Config | Max ctx | Gated by | tok/s (shallow → deep) | Memory |
|---|---|--:|:--:|--:|--:|
| old (research run 3) | Qwen3.8-27B, GGUF IQ3_S-mtp (ISTA), MTP n-max 3, f16 KV | 115k | mem | 15.1 → 9.7 | 24.2 GB |
| new | Qwen3.8-27B, GGUF IQ3_S-mtp (ISTA), no drafter, f16 KV | **147k** | **speed** | **14.1 → 8.3** | 24.4 GB |

Mendel:

| old/new | test | model | serving | thinking | max ctx | score | libraries |
|---|---|---|---|---|--:|--:|---|
| old (bench12) | blind | ISTA IQ3_S-mtp, MTP n-max 3, f16 KV | llama-server | medium | 115k | 76.5/100 | 8/8 |
| new | blind | ISTA IQ3_S-mtp, no drafter, f16 KV | llama-server | **xhigh** | **147k** | **80.5/100** | 8/8, 109 min |
| new | blind | ISTA IQ3_S-mtp, no drafter, f16 KV | llama-server | **low** | **147k** | **66/100** | **7/8, turn_timeout**, 163 min |

Gates:

| gate | block | result | verdict |
|---|---|---|---|
| five drafter cells at depth 256, `-c 106496` | `ista-nmax-shallow` | none 14.44, n1 14.35, n2 13.24, n3 12.41, n4 11.72 tok/s | no drafter fastest |
| ladder and creep, no drafter | `ista-nodrafter-creep` | `-c 163840` serves; clean to 147478 at 8.30 tok/s, floor at 163858, zero swap | ceiling 147478, speed-gated |
| five drafter cells at depth 98338, `-c 122880` | `ista-nmax-deep` | none 9.50, n1 9.03, n2 8.32, n3 7.89, n4 7.00 tok/s | no drafter fastest |
| serving pick | coordinator gate | no drafter, `-c 163840`, window 147456 | no trade to weigh |
| long-prompt completion at 144510 tokens | before `ista-mendel-xhigh` | real content returned | safe above 120K |
| Mendel smoke, xhigh | `ista-smoke-xhigh` | 10 calls, 1 commit, clean, 182 s | pass |
| Mendel smoke, low | `ista-smoke-low` | 9 calls, 1 commit, clean, 139 s | pass |
| EvalPlus calibration, low | `ista-evalplus-low` | 10 of 10 stop, max 3634 | budget 8192 |
| EvalPlus calibration, xhigh | `ista-evalplus-xhigh` | 9 stop, 1 at the 30000 cap | budget 30000, gate runs |

## What the run established

- **The drafter is a loss on this build at every depth.** Ten cells at
  two depths put no drafter ahead of every `n-max` on speed, and the
  no-drafter server takes `-c 163840` against 131072. Acceptance falls
  from 90 to 64 percent as the draft grows, faster than the draft
  earns. The creep with the drafter that read 9.7 at 115K ran at 100
  percent acceptance on a template continuation and is not a drafter
  speed; the drafter question is answered by the real-prompt cells.
- **The model's own default wins the agent task and loses the
  single-turn gate.** Mendel at xhigh scored 80.5, the highest local
  row at a level this project still runs, in less wall time and less
  context than low's 66. EvalPlus at xhigh scored 0.945 / 0.921 with
  five completions that never converged inside 30000 tokens, below
  low's 0.976 / 0.933, which matches medium on base. Thinking helps
  when there are tools and a repository; it hurts on a tiny problem
  with no feedback.
- **Sampling is a recorded condition now.** Both Mendel rows carry
  temperature 1.0 and top_p 0.95, read from the server's resolved
  parameters in the run's `meta.json`. Every earlier row is one draw at
  an unrecorded default.
- **A calibration file must record the level it resolved.** The first
  "low" calibration ran at xhigh because no extra body was passed and
  the chat template's default filled in. `calibrate.py` now records the
  requested extra body and the resolved effort on every row; the
  method page says the level is passed on every call.
- **The turn cap and the watcher silence window do not scale with
  xhigh.** One legitimate turn on a 147K window ran past the 25-minute
  turn cap and ended the low Mendel row as a partial; one xhigh
  completion ran past the watcher's 600 s silence window and produced a
  false dead-server verdict, fixed by raising it to 2700 s for the
  scoring run. Both are fixed timers that the generation length
  outgrew.
- **The macOS `reliability_guard` bug is per venv.** EvalPlus's
  evaluate step read 0.000 on every problem until the Darwin exemption
  from the first run on this machine was applied to this run's venv.

## What the run cost

Nine of ten blocks ran in order; the serving-pick block moved behind
the deep sweep because it needed those numbers. The xhigh gate took
about 9h43 of active time across a pause. One planning defect: the
runbook asked the runner to choose between configs, which is the
coordinator's job, and the pick came back to the coordinator. The
EvalPlus calibration ran once at the wrong level and cost a
recalibration. Alongside the run, at the owner's request, the runner
restored the three projector files run 12 deleted and verified every
GGUF on the machine against its publisher's sha256; all match.
