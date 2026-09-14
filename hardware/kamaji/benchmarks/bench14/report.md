# Run 14 — report

The large form of the run's status line. See
`docs/methodology/status-lines.md`, "The site comparison, in full", for
the table rules. Three GGUF rows read with `llama-benchy` 0.4.0 on
real code text at the server's own sampling, wired 25000, and two
Mendel rows at levels the site did not have. No EvalPlus.

Speed and context:

| old/new | Config | Max ctx | Gated by | tok/s (shallow → deep) | Memory | acceptance |
|---|---|--:|:--:|--:|--:|--:|
| old (creep, 2026-09-06) | Qwen3.6-35B-A3B, GGUF, MTP n-max 3, q8_0 KV | 82k | speed | 36.5 → 9.2 | 25.8 GB | 100% (template) |
| new | Qwen3.6-35B-A3B, GGUF, MTP n-max 3, q8_0 KV | 82k | speed | **43.7 → 13.0** | 25.6 GB | 54 to 85% |
| old (creep, 2026-09-06) | Qwen3.6-35B-A3B, GGUF, MTP n-max 3, f16 KV | 41k | mem | 69.1 → 52.6 | 25.1 GB | 100% (template) |
| new | Qwen3.6-35B-A3B, GGUF, no drafter, f16 KV | 41k | mem | **49.8 → 38.3** | 24.0 GB | no drafter |
| old (creep, 2026-09-08) | Qwen3.8-27B, GGUF Q4_K_M (bartowski), MTP n-max 3, f16 KV | 72k | mem | 20.0 → 13.7 | 25.4 GB | flat (template) |
| new | Qwen3.8-27B, GGUF Q4_K_M (bartowski), MTP n-max 3, f16 KV | 72k | mem | **11.8 → 8.6** | 25.0 GB | 37 to 63% |

Mendel:

| old/new | test | model | serving | thinking | max ctx | score | libraries |
|---|---|---|---|---|--:|--:|---|
| old (bench11) | guided | Qwen3.6-35B-A3B, MTP n-max 3, q8_0 KV | llama-server | off | 82k | 62.5/100 | 8/8 |
| new | blind | Qwen3.6-35B-A3B, MTP n-max 3, q8_0 KV | llama-server | off | 82k | **50.5/100** | 8/8, critical, 3 compactions |
| old (bench12) | blind | Qwen3.8-27B Q4_K_M bartowski, MTP n-max 3, f16 KV | llama-server | medium | 64k | 76/100 | 8/8 |
| new | blind | Qwen3.8-27B Q4_K_M bartowski, MTP n-max 3, f16 KV | llama-server | **xhigh** | 64k | **93/100** | 8/8, medium, 213 min |

Gates:

| gate | block | result | verdict |
|---|---|---|---|
| `benchy_pass` from research run 4 | `benchy-gate` | yes, on the coordinator's reading of the drafter band | benchy blocks run |
| deep cell at `-c 40960` | `benchy-qwen36-f16-nodrafter` | HTTP 400 at depth 40960; a benchy request adds 768 tokens | re-read at 39936 |
| 82K cell against the 8 tok/s floor | `benchy-qwen36-q8-drafter` | 13.01 tok/s at 60 to 62 percent acceptance | window 81920 stands |
| 65.5K cell against the floor | `benchy-qwen38-bartowski-drafter` | 8.57 tok/s at 37 to 63 percent acceptance | window 65536 stands, thin margin |
| Mendel smoke, thinking off | `qwen36-smoke-off` | 10 calls, 1 commit, clean, 20 s | pass |
| Mendel smoke, xhigh | `qwen38-bartowski-smoke-xhigh` | 10 calls, 1 commit, clean, 150 s | pass |

## What the run established

- **The drafter is a per-model answer.** On Qwen3.6 the drafter earns
  its place: the q8_0 row with n-max 3 reads 43.7 at 4K and 13.0 at
  82K on sampled real text, above the creep's own numbers, at 54 to 85
  percent acceptance. The f16 arm without it reads 49.8 at 4K and 38.3
  at 40K, about 27 percent under the with-drafter creep at the same
  depths. On the 4-bit Qwen3.8 the drafter does not: 11.8 at 4K and
  8.6 at 65.5K, 40 percent under the creep, slower at 4K than the ISTA
  3-bit build with no drafter.
- **The creep's drafter numbers were ceilings, both ways.** The
  template continuation gives the drafter near-total acceptance, so a
  creep on a drafter row reads high; on Qwen3.6 q8_0 the creep also
  read low at depth against the sampled reader. Neither creep figure
  is a serving speed; the method page now says so.
- **The 4-bit Qwen3.8 at its own default level is the best local
  agent row, at 93.** Complete, no critical defect, three traps
  handled, 17 clean commits, on the 65536 window with three
  compactions. The same build at effort medium scored 87 and 76 on two
  earlier configurations. It runs at 8.6 tok/s at the deep end of that
  window.
- **Qwen3.6 with thinking off drops to 50.5 blind**, against 62.5
  guided at the same level and 63 blind with thinking on. It missed
  trap A with a runtime throw no test covered and left two removed
  packages declared.
- **A benchy request needs 768 tokens of headroom under `-c`.** The
  deepest cell on a window is `-c` minus 1024, rounded to the ladder.
- **Peak context overshoots the harness window on Qwen3.6.** The
  thinking-off row's counter read 97823 on a configured 81920, absorbed
  by the server's `-c 98304`. The same overshoot appeared in run 11.

## What the run cost

Eight blocks in order, one retry, about ten hours of GPU time. Each
benchy block cost about three times the runbook's estimate: benchy
sends a new prompt per request, so the server prefills the full
depth every time. The Mendel rows had no `results.json` entry after
scoring: the scorer wrote scores in prose, and a second subagent per
row built the entry, the matrix cells and the report. Two of those
subagents shared a scratch path and collided once; the second caught
it. Four harness faults came out of the scoring, all in the benchmark
repo: `score.mjs` reads trap A from the exit code and not the output,
its prettier check counts files the prompt forbids committing, the
rubric's default diff range picks up master drift past the run's base
commit, and `PLAN.md` names a report path that does not exist.
