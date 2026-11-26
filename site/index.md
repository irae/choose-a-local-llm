# Choosing a Local Coding LLM

Measured decode speed at depth, real-memory context limits, HumanEval+ coding quality, and end-to-end coding agent scores across real consumer hardware. Over **325h+** of non-overlapping local benchmark compute (**110** scored local runs across **8** models and **2** machines, **9,444** agent tool calls, **427** commits; **339.5h** including documented diagnostic runs — see [Benchmarks](/benchmarks/)).

## Winners by Machine

- **[Apple M1 Max 32 GB](/setups/m1-max-32gb/):** [Qwen3.8-27B](/models/qwen3.8-27b) Q4_K_M (`f16` KV, no drafter, `xhigh`) leads all local coding agents at **93/100 blind** (8/8 libraries, 0 critical defects, `72k` context, `12.4 → 9.7 tok/s`), matching frontier cloud baselines. For longer windows, 3-bit [Qwen3.8-27B](/models/qwen3.8-27b) reaches `147k` (`80.5/100` blind) and [Qwen3.6-35B-A3B](/models/qwen3.6-35b-a3b) holds `43.7 → 13.0 tok/s` at `82k` (`83/100` guided).
- **[RTX 5060 Ti 16 GB](/setups/rtx-5060ti-16gb/):** [Qwen3.8-27B](/models/qwen3.8-27b) IQ3_S-mtp (`q8_0` KV, no drafter, `xhigh`) leads at **91/100 blind** and **85/100 guided** (both 8/8, `65k` context, `29.4 → 21.1 tok/s`) and serves as the author's sole daily-driver local model (~6–12 hours/month for personal finance automation). For 120k–240k context on 16 GB VRAM, [Ternary-Bonsai-2-27B](/models/bonsai-2-27b) reaches **82/100 blind** at `135k` (`PTQ1_0`, `f16` KV) and `240k` with `q8_0` KV (`73.5/100` blind, zero compactions).

## Best Configuration per Model

<!-- gen:home-best-per-model:start -->
<!-- gen:home-best-per-model:end -->

## Four Empirical Laws

1. **Unbounded thinking breaks single-turn benchmarks; an 8192 thinking budget fixes them.** Under fast mode (`8192` think / `16384` output), thinking-on beats thinking-off on every tested pair with zero empty answers. Across 12 natural re-runs of forced failures, zero ever passed with more thinking; in multi-turn Mendel runs, normal turns peak near ~1,400 thinking tokens.
2. **HumanEval+ is a gate, not an agent predictor.** [Gemma-4-12B](/models/gemma-4-12b-it) UD-Q4_K_XL posts the highest HumanEval+ score on the site (**0.988 / 0.963**) yet scores **0/100** on Mendel (zero commits).
3. **Hardware flips optimal configs — never copy flags across machines.** On M1 Max (Metal), `f16` KV beats `q8_0` on speed, MTP hurts dense 27B models, and `PTQ1_0` beats `PQ2_0` by 4× context. On RTX 5060 Ti (CUDA), `q8_0` KV doubles 27B context cleanly, MTP accelerates decode where VRAM allows, and `PQ2_0` decodes faster.
4. **Shallow speed hides deep-context collapse.** Partial dense-layer offload (`-ngl 45/64`) collapses to `5.1 → 2.3 tok/s`, whereas partial MoE expert offload (`--n-cpu-moe`) holds `45+ tok/s` at `97k`.

## Run This on Your Hardware

Read the [scientific method](/method/), browse [all 25 tested model files](/files/), or follow the [operator guide on GitHub](https://github.com/irae/choose-a-local-llm/blob/master/docs/repo/README.md).
