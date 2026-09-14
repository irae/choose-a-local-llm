# Findings by benchmark run — RTX 5060 Ti 16 GB (Linux)

One entry per run: the most interesting findings and conclusions, with
links to the full record. Newest first. Each `benchN/` folder holds that
run's runbook (`AGENT.md`), log (`state.md`), and results (`results.md`,
`results/`). Run numbers are shared with the Mac
(`hardware/m1-max-32gb/benchmarks/INDEX.md`).

## bench17, started 2026-09-13 ([state](bench17/state.md), [results](bench17/results.md))

- Runbook: [bench17/AGENT.md](bench17/AGENT.md). The first run on this
  machine: five llama.cpp builds read with `llama-benchy` up to their
  deep context, three of them NVFP4, then the agent smoke, the guided
  agent task, and the blind task for the builds that finish it. In
  progress; findings land here at the close.
