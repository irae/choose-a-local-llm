# RTX 5060 Ti 16 GB — Archive & Retired Builds

::: warning Historical & Retired Data
Entries on this page are **retired or dropped**. Do not use them for current model picks — use [RTX 5060 Ti 16 GB](/setups/rtx-5060ti-16gb/) instead. Full raw run logs remain in git under `hardware/` on [GitHub](https://github.com/irae/choose-a-local-llm).
:::

## Qwen3.8-27B OBLITERATED (Retired) {#qwen3-8-27b-obliterated}

Retired on 2026-09-20. Both GGUF files of `OBLITERATUS/Qwen3.8-27B-OBLITERATED` (revision `a58c3b5`) were removed after failing usability and agent gates:

- **`Q3_K_M` (`12.57 GiB`, `q8_0` KV, `65k` window):**
  - **Cannot run agent tasks:** Its Mendel tool smoke ended in 9 seconds with zero tool calls because the file's embedded chat template lacks `tools` and `tool_call` handling (`--jinja` has nothing to parse, so tool calls print as plain text).
  - **Lowest coding quality on the card:** Under a one-time effort-medium override (`think=3986`, `budget=6034`), EvalPlus scored **0.854 / 0.787** with `3/164` model-caused empties (`5/164` forced; all four forced failures stayed wrong at `30000`), far below the 3-bit [Qwen3.8-27B](/models/qwen3.8-27b) builds (`0.963–0.976` base).
  - Decode speed read `22.67 → 16.74 tok/s` across `65k` (~23% slower than the 3-bit builds).
- **`Q4_K_M` (`15.66 GiB`, `q8_0` KV, `-ngl 45/64`, `64k` window):**
  - **Below the 8 tok/s usability floor at every depth:** Keeping 19 of 64 dense layers in host RAM under a `13,811 MiB` VRAM cap decoded at **5.13 tok/s** at 4K, **3.49** at 24K, **2.67** at 49K, and **2.31 tok/s** at `64.5k` — ~4.4× slower than fully on-card `Q3_K_M`.
  - Halving context to `32k` frees only ~4 layers (`1,088 MiB`), still well below the floor. Stopped at the speed gate; no EvalPlus or Mendel run.

## Dropped Community Repacks

- **`michaelw9999/Qwen3.6-35B-A3B-NVFP4-MTP-GGUF`** ([file page](/files/qwen36-michaelw9999-nvfp4)): Failed to load in `llama-server` with `wrong number of tensors; expected 1101, got 1079` regardless of `-c` or `--n-cpu-moe`. Dropped in favor of mainstream `unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL`.
