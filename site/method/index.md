# Scientific Method

This project answers one practical question per machine: **which local model, runtime, and configuration produces the best real coding work on this specific computer?**

Every method page in this section is hardware- and model-agnostic. Specific machine picks, commands, and numbers live on the [home page](/) and under [Models](/models/).

## Gated Testing Funnel

Running full coding-agent benchmarks on every quant and runtime wastes hundreds of GPU hours. Candidates move through four progressively more expensive stages, and a failure at any gate stops further testing for that configuration:

1. **Speed & Memory Ceiling ([Speed & Memory](/method/speed-and-memory)):** Pick the KV cache type, find the largest loadable context `-c`, and sweep real-text decode speed from `4K` to the usable ceiling. A configuration that drops below **8 tok/s** or cannot hold a practical coding window fails the speed/memory gate.
2. **Tool-Calling Smoke ([Agent Coding](/method/agent-coding)):** Run a short, deterministic multi-file dependency swap under the agent harness. Configurations that emit malformed tool calls, lack tool-calling chat templates, corrupt git state, or loop immediately are dropped before burning hours on full runs.
3. **Single-Turn Coding Quality ([Coding Quality](/method/quality)):** Run all 164 HumanEval+ problems in fast mode (`8192` reasoning budget, `16384` output cap, temperature `0`). Configurations below **0.800 base pass@1** fail the quality gate.
4. **End-to-End Agent Benchmark ([Agent Coding](/method/agent-coding)):** Run the full multi-file repository task (blind and/or guided) with live repetition-loop detection, compaction tracking, and a 100-point rubric graded against git diffs, test logs, and session telemetry.

## Core Measurement Rules

- **Measure real, used context — never allocated `-c` alone.** Allocating a `256K` KV cache proves only that weights and buffers fit at idle; usable context ends where memory pressure triggers swap growth, OOM, or decode speed drops below `8 tok/s`.
- **Disable prompt-cache illusions during speed tests.** Timing a repeated prompt reads cache hits instead of compute; every depth step uses fresh real code text.
- **Pin everything.** Every published row ties to an exact model file revision, server build, KV cache type, drafter flag, offload count, and reasoning effort. Changing any one of those produces a new configuration row.
- **Never rescue a failing agent.** When a model enters a repetition loop or breaks git state, the harness records the failure and stops. Prompt patches or sampler workarounds hide the defect instead of measuring it.

## What This Project Does Not Measure

- **Power draw and energy efficiency:** Important for datacenters, not for choosing which model codes better on an existing desktop or laptop.
- **Multi-user concurrent throughput:** One developer runs one primary agent at a time; multi-slot tests check round-robin sub-agent headroom rather than aggregate batch throughput.
- **Custom weight quantization:** Making and validating new quantization schemes is a separate discipline; we test published community weights with pinned revisions.
- **Exhaustive model catalogs:** The goal is identifying the few configurations worth coding with on real hardware, not ranking dozens of obsolete checkpoints.

Want to run this process on your own machine? See the [operator documentation on GitHub](https://github.com/irae/choose-a-local-llm/blob/master/docs/repo/README.md).
