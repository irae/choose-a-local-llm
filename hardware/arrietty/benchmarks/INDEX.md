# Findings by benchmark run — RTX 5060 Ti 16 GB (Linux)

One entry per run: the most interesting findings and conclusions, with
links to the full record. Newest first. Each `benchN/` folder holds that
run's runbook (`AGENT.md`), log (`state.md`), and results (`results.md`,
`results/`). Run numbers are shared with the Mac
(`hardware/kamaji/benchmarks/INDEX.md`).

## bench17, 2026-09-13 to 2026-09-15 ([report](bench17/report.md), [state](bench17/state.md), [results](bench17/results.md))

- Runbook: [bench17/AGENT.md](bench17/AGENT.md). The first run on this
  machine: six llama.cpp builds read with `llama-benchy` up to their
  deep context, three drafter climbs, seven guided agent rows and one
  blind row. No EvalPlus (owner, 2026-09-13).
- **The ISTA 3-bit Qwen3.8 is the pick for this card**: guided 85 and
  blind 91, both 8 of 8, at a 61440 window, no drafter, q8_0 KV,
  29.4 → 21.1 tok/s. The only build that finished the task.
- **The MTP drafter pays on this card on every build that has one**,
  unlike the dense Qwen3.8 on the Mac, but it costs VRAM: a smaller
  `-c` on the dense builds, more expert layers in host RAM on the MoE.
- **The desktop shares the card.** At about 440 MiB free the ISTA
  n-max 2 server died three times with a GPU launch timeout; no
  drafter, at 1.2 GB free, ran clean.
- **Gemma-4-12B fails the agent task on both builds and both thinking
  levels**, with zero commits each time. NVFP4 fits the trained window
  and reads 2 to 5 percent faster than the k-quant.
- **The MoE builds serve 97K at about 45 tok/s** with part of the
  experts in host RAM, and score 48.5 (Qwen3.6) and 37.5 (Gemma-26B)
  guided.
