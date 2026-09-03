# Video research — quant-picking videos (2026-09-03)

The owner recalled two videos about instruction sets and MLX quant
quality. A sub-agent fetched both transcripts. NEITHER covers Apple
instruction sets or MLX quant quality — the remembered video is a
third one, not yet found. What they DO contain is still useful.

## https://youtu.be/hg26j0erUSo — "I Tested Every Qwen3.8-27B Quant:
Here's the Best One For Your GPU" (Kai, 2026-09-01)

- Quant makers differ by calibration, not just bits: Unsloth
  "dynamic", Bartowski (importance matrix calibrated on 63%
  tool-calling data), "Ridge". Protection targets differ per maker.
- Independent benchmarks (~$3,000 GPU time): 4-bit matches full BF16
  on TerminalBench; 1-bit collapses to near-random.
- Picks: 24 GB → Unsloth UD-Q4_K_XL; 32 GB → Q6/Q8; 16 GB →
  Bartowski IQ4_XS.
- KV cache at Q8 or full precision; Q4 KV badly degrades output.
- Apple note: MTP/speculative decoding "does nothing" on Apple
  Silicon (M4 measured flat with and without).
- Quant files get silently replaced (Unsloth, 2026-08-19) — pin
  revisions.

## https://youtu.be/0xUxO_9zqTU — "Run Qwen3.8-27B on ANY GPU"
(RepoChad, 2026-08-31)

- Nvidia/AMD tier guide; no Apple content.
- Architecture note: 64 layers, hybrid 3:1 DeltaNet/full-attention —
  only 16 of 64 layers grow KV with context. Relevant to our Qwen3.8
  window math.
- New low-bit quant method ("GSQRCO", transcribed name) producing
  IQ2XS/IQ3XS variants that beat older 2-bit quants.

## Open item

Find the actual video about ARM instruction-set variants in GGUF
names (dotprod vs i8mm) and well-made MLX quantizations. Until then,
the hardware facts stand on their own: M1 Max has dotprod, not i8mm
(M2+); verify with `sysctl -a | grep hw.optional`.
