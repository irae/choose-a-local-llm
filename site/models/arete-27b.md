# Arete-27B

Dense 27B reasoning model (`NousResearch_Arete-27B`, `bartowski Q3_K_M`) measured on RTX 5060 Ti 16 GB under `llama.cpp` v0.9.0 (`b12110`). Full Mendel agent evaluation is pending.

## Verdict

- **Strong quality gate and lowest forced-answer rate among 27Bs:** Fast-mode EvalPlus (`xhigh`, `8192` think / `16384` output) scored **0.976 / 0.951** (`0` empty) with only **7/164 forced answers** — the lowest forced rate of any 27B reasoning model tested, indicating crisp reasoning convergence.
- **Clean 64k window on 16 GB VRAM:** At `q8_0` KV with no drafter (`-c 65536`, harness window `61,440`), decode holds **27.60 → 20.07 tok/s** across `64,512` tokens at `15.4 GiB` peak VRAM (`15,771 MiB`), slightly slower than 3-bit [Qwen3.8-27B](/models/qwen3.8-27b) (`29.4 → 21.1 tok/s`) at the same window.
- **Agent status (pending):** Passed the Mendel tool-calling smoke cleanly (`14` tool calls, `1` commit, `122s`, clean tree). Full blind and guided Mendel runs are deferred to a future benchmark run, so Arete-27B is not yet ranked against finished coding agents.

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
