# RTX 5060 Ti 16 GB

Desktop Linux CUDA workstation (Blackwell, compute capability 12.0) running `llama-server` and the PrismML `llama.cpp` fork.

## Hardware & Standing Limits

- **GPU & Host:** NVIDIA GeForce RTX 5060 Ti 16 GB VRAM (`16,311 MiB`), 12 CPU threads, 32 GB system RAM, Linux.
- **Shared display headroom:** The GPU drives the desktop, so long agent runs require ~1–1.2 GB of free VRAM headroom to avoid driver watchdog timeouts.
- **Explicit placement:** Every row runs `-ngl 999 --fit off -fa on` so `llama-server` never alters offload placement silently.
- **Retired builds:** Qwen3.8-27B OBLITERATED (`Q3_K_M` and `Q4_K_M`) and dropped repacks live in the [RTX 5060 Ti archive](/setups/rtx-5060ti-16gb/archive).

## Top Picks

- **Best overall coding agent & daily driver:** [Qwen3.8-27B](/models/qwen3.8-27b) IQ3_S-mtp (`ISTA-DASLab`, `q8_0` KV, no drafter, `xhigh`) — **91/100 blind** and **85/100 guided** (both 8/8, `61,440` harness window, `29.4 → 21.1 tok/s`), **0.976 / 0.933** fast-mode EvalPlus (`11/164` forced). With an adjusted compaction trigger, this is the author's sole daily-driver local config (~6–12 hours/month for personal finance workflows: reading email, gathering bills and statements, and building automation scripts).
- **Best long-context 27B:** [Ternary-Bonsai-2-27B](/models/bonsai-2-27b) (`prism-ml` fork `prism-b10685-7dffb15`, `xhigh`) — **82/100 blind** on `PTQ1_0` `f16` KV (`135k`, `42.1 → 22.4 tok/s`, **0.976 / 0.945** EvalPlus); **77/100 blind** on `PQ2_0` `f16` KV (`119k`, `46.3 → 25.1 tok/s`); **73.5/100 blind** on `PTQ1_0` `q8_0` KV (`240k`, blind peak `225,161` tokens with zero compactions); **75/100 blind** with refusal-ablation LoRA 1.0 (0 critical defects). *Stock `llama-server` cannot load these packings.*
- **Fastest MoE (partial CPU-MoE offload):** [Qwen3.6-35B-A3B](/models/qwen3.6-35b-a3b) UD-Q4_K_XL (`--n-cpu-moe 21`, `mtp/2`, `q8_0` KV, `97k`, `61.2 → 45.4 tok/s`, **0.976 / 0.933** EvalPlus, **48.5/100 guided** 6/8).
- **Newest candidates (Run 33, `llama.cpp` v0.9.0 / b12110):** [Arete-27B](/models/arete-27b) Q3_K_M (`64k`, `27.6 → 20.1 tok/s`, **0.976 / 0.951** EvalPlus with only `7/164` forced, passed agent smoke; Mendel pending). [S5-nano](/models/s5-nano) (`Q8_0` `261k` `0.811 / 0.726`; `BF16` `204k` `0.841 / 0.774`) failed the Mendel tool smoke on both quants.

## RTX 5060 Ti CUDA Quirks

- **`q8_0` KV works cleanly on CUDA:** Unlike Metal, `q8_0` KV incurs minimal speed penalty and expands 27B windows dramatically (`65k` vs `53k` on Qwen3.8; `240k` vs `135k` on Bonsai-2 `PTQ1_0`), though `f16` KV led `q8_0` on Bonsai-2 blind Mendel on both packings (`82 vs 73.5`, `77 vs 60.5`, 1 run each).
- **MTP speed vs stability:** On 27B models, `mtp/2` boosts decode (`45.9 → 26.2 tok/s` on Qwen3.8 ISTA) but cut free VRAM to ~440 MiB and crashed 3× under desktop contention. Dropping the drafter leaves ~1.2 GB free and runs clean.
- **MoE vs dense offload:** Partial MoE expert offload (`--n-cpu-moe 7` or `21`) sustains `45+ tok/s` at `97k`, whereas dense layer offload (`-ngl 45/64`) collapsed to `5.1 → 2.3 tok/s`.

## Complete Configurations

<!-- gen:setup-complete:start -->
<!-- gen:setup-complete:end -->

## In-Progress Configurations

<!-- gen:setup-partial:start -->
<!-- gen:setup-partial:end -->

## Fast-Mode HumanEval+

<!-- gen:setup-evalplus:start -->
<!-- gen:setup-evalplus:end -->

## Router Serve Presets

<!-- gen:setup-presets:start -->
<!-- gen:setup-presets:end -->
