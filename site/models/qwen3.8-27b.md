# Qwen3.8-27B

Dense 27B reasoning model and the top local coding agent on both tested machines.

## Verdict

- **M1 Max 32 GB (`Q4_K_M`, `f16` KV, no drafter, `xhigh`):** Best overall local coding agent at **93/100 blind** (8/8 libraries, 0 critical defects, 1 medium, 3 compactions, 213 min; also confirmed at **91/100** under an 8192 thinking budget with zero budget fires), matching frontier cloud baselines. Fast-mode EvalPlus scores **0.982 / 0.951** (`9/164` forced) across a `72k` window (`12.4 → 9.7 tok/s`).
- **M1 Max 32 GB 3-bit (`ISTA IQ3_S-mtp` / `unsloth UD-IQ3_S`, `f16` KV, `xhigh`):** Doubles usable context to `147k` (speed-capped near `8 tok/s`), both scoring **0.976 / 0.945** in fast-mode EvalPlus. ISTA scores **80.5/100 blind** (**87/100** under an 8192 thinking budget). Unsloth scored **90.5/100 blind** with an anomaly — it merged `master` mid-run and is not strictly base-comparable (guided scored `62.5` partial at the 300-minute cap).
- **RTX 5060 Ti 16 GB (`ISTA IQ3_S-mtp`, `q8_0` KV, no drafter, `xhigh`):** Best 16 GB coding agent at **91/100 blind** and **85/100 guided** (both 8/8, `61,440` harness window, `29.4 → 21.1 tok/s`, **0.976 / 0.933** EvalPlus). With an adjusted compaction trigger, this configuration is the author's sole daily-driver local model (~6–12 hours/month for personal finance workflows and automation scripts).
- **Serve gotchas:** Always run at the model's published default **`xhigh`** (effort `medium` is retired after repeated regressions; effort `low` scored `66/100` while using more wall time and context than `xhigh`). Drop the MTP drafter on both machines — it loses speed on M1 Max real text, and on 16 GB CUDA `mtp/2` left only ~440 MiB VRAM free and crashed 3× under desktop contention. `OBLITERATUS/Qwen3.8-27B-OBLITERATED` is retired ([RTX archive](/setups/rtx-5060ti-16gb/archive#qwen3-8-27b-obliterated)).

## Configurations

<!-- gen:model-configs:start -->
<!-- gen:model-configs:end -->

## Decode Speed vs Context Depth

<!-- gen:model-curves:start -->
<!-- gen:model-curves:end -->

## HumanEval+

<!-- gen:model-evalplus:start -->
<!-- gen:model-evalplus:end -->

## Mendel Agent Runs

<!-- gen:model-mendel:start -->
<!-- gen:model-mendel:end -->

## Model Files

<!-- gen:model-files:start -->
<!-- gen:model-files:end -->
