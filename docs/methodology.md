# Methodology

This are stablished constraints for every test cycle. Do not skip steps. The rules are
split by task — read the page for the task you are about to do:

| Before you… | Read |
|---|---|
| Start ANY benchmark or sweep | [The bench run checklist](./methodology/checklist.md) |
| Write or run any measurement script | [Common rules](./methodology/common-rules.md) |
| Run a depth / context-creep sweep | [Context creep](./methodology/context-creep.md) |
| Probe a memory ceiling | [Memory ceiling](./methodology/memory-ceiling.md) |
| Run an EvalPlus scoring pass | [EvalPlus](./methodology/evalplus.md) |
| Run the Mendel agentic benchmark | [Mendel](./methodology/mendel.md) |
| Run the Aider polyglot benchmark | [Polyglot](./methodology/polyglot.md) |
| Touch a server, or debug a stall/crash | [Server lore](./methodology/server-lore.md) |

## Goals

One question for one computer: which local model, runtime, and
configuration should I code with? Speed alone does not pick a winner. A
config must hold a usable decode speed at real agent depths (our floor:
8 tok/s), fit in memory beside a harness, and pass the quality gates.
EvalPlus gates every config; Mendel and Aider polyglot rank the
survivors.

## How we pick models (reasoning to reuse)

- **Prefer MoE on bandwidth-limited hardware.** Decode scales with *active*
  parameters.
- **Prefer models with MTP support** — output-lossless free speed on llama.
  Note: speculative decoding (MTP or draft-model) costs depth — the floor
  arrives shallower with a drafter; measure both.
- **Take the newest strong models even if slow**; let the quality gate decide.
- **One compressed-frontier experiment at a time**, and read the
  vendor's serving docs before concluding anything.
- **Use the most popular mainstream quant repos** (HF download counts);
  verify exact file lists first.
- **Score the quant, once per model.** Published full-precision scores do
  not count: what you run is a quant. But narrow differences between
  runtimes' standard quants do not count either — score each model once
  per thinking mode and share that score across runtimes. Aggressive or
  calibrated quants (for example a vendor-calibrated q4 KV) are not narrow;
  each passes the gate separately.

## How we learn a config's limits

Three measurements bound every config; each has its own page above:

1. **Memory ceiling** — how much context the machine can allocate
   ([method](./methodology/memory-ceiling.md)).
2. **Depth curve** — decode speed against *used* context, down to the
   8 tok/s floor ([method](./methodology/context-creep.md)). Every
   config gets a "capped by" verdict: **speed**, **OOM**, **window**,
   or — on LM Studio — **mem** (compression/swap onset).
3. **Quality** — EvalPlus gate, then Mendel, then polyglot for
   survivors ([gate](./methodology/evalplus.md)).

## Runtimes

- **llama-server** (llama.cpp). The concurrency backbone: slots
  share one weight copy; MTP speculative decoding.
- **mlx_lm.server** (mlx-lm). Often faster decode and flatter depth
  curves, but no slots, f16 KV only, and hard memory ceilings.
- **A GUI-bundled runtime driven only through its CLI** is an approved
  exception to the no-GUI rule, when every step runs CLI-only (get, load,
  serve) and the model store stays shared with the app. Such an engine can
  support MLX architectures that mlx-lm lacks and implement their attention
  properly. Read [the server lore](./methodology/server-lore.md) before
  touching it.
- **One vendor fork is allowed** when it is the only backend for a model
  family — a ternary quant, a calibrated q4 KV, a matching drafter — and
  the vendor maintains it. Install it side by side, keep one build at a
  time, and label every result with the fork build.
- Default remains: no other forks, no `--HEAD` builds.

The reference setup names the runtimes it runs, with install paths and
aliases: [runtimes on this machine](./setups/m1-max-32gb/index.md#runtimes-on-this-machine).

## Where runs live

Run kits are in `benchmarks/bench<N>/` (runbook `AGENT.md`, log
`state.md`, results). Shared tools and calibrations sit in
`benchmarks/`. The findings index is `benchmarks/INDEX.md`. Nothing
outside `docs/` reaches the published site.
