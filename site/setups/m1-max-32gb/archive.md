# M1 Max 32 GB — Archive & Retired Builds

::: warning Historical & Retired Data
Entries on this page are **retired or superseded**. Do not use them for current model picks — use [M1 Max 32 GB](/setups/m1-max-32gb/) instead. Full raw run logs remain in git under `hardware/` on [GitHub](https://github.com/irae/choose-a-local-llm).
:::

## LM Studio (Retired) {#lm-studio}

LM Studio (`lms`, `mlx-engine 1.10.1`) entered testing as the only way to run MLX weights with parallel slots on [Gemma-4-12B](/models/gemma-4-12b-it). It was retired on 2026-09-07 for four blocking defects:

1. **Zero agent commits across three runs:** Blind high (15 calls), guided high (21 calls), and guided low (130 calls, 72 identical failing calls) all ended `model-failed` with newline floods on the thinking channel (`google/gemma-4-12b`, later removed from the LM Studio store).
2. **Lower coding quality on the same model:** Thinking-off EvalPlus scored **0.909 / 0.872** on LM Studio MLX 4-bit vs **0.976 / 0.939** on `llama-server` GGUF Q4_K_XL.
3. **Unpinnable context window:** Every CLI flag (`lms load -c`, `--context-length`), REST load key, and per-model config file was ignored by automatic fit (loading at `158,464` regardless of input). Thinking could not be enabled on the replacement entry (`gemma-4-12b-it-mlx`).
4. **Unstable background behavior:** Just-in-time loading and 20-minute idle unloads silently changed windows mid-run, the disk prompt cache thrashed at depth, and the desktop app held GPU memory until quit.

Its one real strength — `34.2 → 23.2 tok/s` across `131k` in `17.2 GB` — never translated into working agent code.

## Gemma-4-26B-A4B MLX (Retired) {#gemma-4-26b-a4b-mlx}

Retired on 2026-09-12. `mlx-community/gemma-4-26b-a4b-it-4bit` on `mlx_lm.server` decoded `49.3 → 23.4 tok/s` to `64k`, but:

- **Failed the Mendel agent smoke** at `65,536` window with zero commits after six tool calls when the server truncated a tool call mid-generation (no OOM, no server crash).
- **Low single-turn completion:** Pre-fast-mode EvalPlus scored `0.793 / 0.768` with `31/164` empty answers (MLX does not enforce server thinking budgets).
- The GGUF `UD-Q4_K_XL` build of the same model completes Mendel cleanly (`47.5` blind, `57` guided) and reaches `197k` context.

## Superseded Measurement Eras

Earlier M1 Max numbers were replaced as the measurement method matured:

- **Wired limits `27000` (too unstable for normal use), `22000` (retired shared-desktop mode), and `24000`:** Superseded by the standing `iogpu.wired_limit_mb=25000` limit, which expanded Qwen3.6 `q8_0` from `41k` to `82k` and `f16` from `33k` to `41k`.
- **Allocation-only context ramps & fast sweeps:** Early ramps checked 256-token probes without filling KV cache or pausing between steps, overstating MLX ceilings by 10–25K. Replaced by slow-creep and `llama-benchy` real-text depth curves.
- **Unbudgeted / 3072-token EvalPlus passes:** Early fixed 3072-token caps caused 30–38% empty answers on reasoning models; superseded by [fast-mode EvalPlus](/benchmarks/evalplus) (`8192` think / `16384` output).
- **Pre-v1.1 blind and pre-v3.0 guided Mendel runs:** Archived under [Older prompt versions](/benchmarks/mendel#older-prompt-versions).
