# Run 19 — report

The large form of the run's status line
(`docs/methodology/status-lines.md`, "The site comparison, in full").
EvalPlus on every row of the RTX 5060 Ti 16 GB setup, eight blocks,
2026-09-15 to 2026-09-16, no block waited on a human. Every empty count
below comes from the samples file; the runner's `results.md` says
`0/164` on every row, which is wrong on six of them.

| old/new | # | Config | Level | Budget | Base | Plus | Empty | Cause | Wall |
|---|--:|---|---|--:|--:|--:|--:|---|--:|
| old | — | Qwen3.8-27B ISTA IQ3_S-mtp, f16 KV, Mac | xhigh | 30000 | 0.945 | 0.921 | 5/164 | budget | 583.2 |
| new | — | Qwen3.8-27B ISTA IQ3_S-mtp, q8_0 KV | xhigh | 20500 | 0.945 | 0.909 | 7/164 | † unproven | 217.6 |
| old | — | Qwen3.8-27B unsloth UD-IQ3_S, f16 KV, Mac | xhigh | 20000 | 0.945 | 0.927 | 8/164 | † unproven | 615.6 |
| new | — | Qwen3.8-27B unsloth UD-IQ3_S, q8_0 KV | xhigh | 19000 | **0.957** | 0.921 | 3/164 | † unproven | 289.6 |
| old | — | Qwen3.6-35B-A3B UD-Q4_K_XL, q8_0 KV, Mac | on | 26624 | 0.957 | 0.939 | 2/164 | budget | 301.5 |
| new | — | Qwen3.6-35B-A3B UD-Q4_K_XL, q8_0 KV, MTP n-max 2 | on | 24154 | 0.945 | 0.902 | 6/164 | † unproven | 192.0 |
| old | — | Gemma-4-26B-A4B UD-Q4_K_XL, f16 KV, Mac | on | 30000 | 0.896 | 0.872 | 16/164 | budget | 347.0 |
| new | — | Gemma-4-26B-A4B NVFP4Q8, f16 KV, `--n-cpu-moe 7` | on | 12500 | 0.909 | 0.878 | 14/164 | † unproven | 215.3 |
| new | — | Gemma-4-12B NVFP4, f16 KV | off | 8192 | 0.927 | 0.896 | 0/164 | none | 51.1 |
| new | — | Gemma-4-12B NVFP4, f16 KV | on | 8192 | 0.659 | 0.640 | 53/164 | † unproven | 203.9 |
| new | — | Gemma-4-12B UD-Q4_K_XL, f16 KV | on | 8192 | 0.793 | 0.780 | 34/164 | † unproven | 259.0 |
| old | — | Gemma-4-12B UD-Q4_K_XL, f16 KV, Mac | off | 8192 | 0.976 | 0.939 | 0/164 | none | 43.1 |
| new | — | Gemma-4-12B UD-Q4_K_XL, f16 KV | off | 8192 | 0.951 | 0.909 | 0/164 | none | 26.1 |

Findings:

- **The runner counted empties from a log line, not from the samples.**
  Six rows carry empties it reported as none. The coordinator
  re-derived every row and corrected the site on 2026-09-16. Run 21's
  runbook writes the counting command out.
- **Thinking off is the level for Gemma-12B on this card.** At thinking
  on every failure is an empty answer on the k-quant, and 53 of 56 on
  NVFP4; the calibrations predicted it with four and five of ten
  answers at the 30000 cap. Thinking off delivers every answer in 26
  and 51 minutes.
- **The card and the Mac agree within about one point on base** for
  every build both machines scored, at budgets of 19000 to 24154 here
  against 20000 to 30000 there. The card's walls are a third to a half
  of the Mac's.
- **The drafter arm is the crash risk on this card.** Two Xid 8
  watchdog crashes on the ISTA drafter arm at about 440 MiB of free
  VRAM; every no-drafter block ran clean. A drafter never changes an
  answer at temperature 0, so the score stands.
- **The Gemma-12B thinking-on budget was corrected mid-block**: the
  runner set 1700 as a waste limiter, the owner restored the 8192
  floor, and the 32 answers already done stayed.

Gates: none. Items: the ISTA Qwen3.8 file still sits in
`~/.cache/llama.cpp/hf/`; the owner moves it. The `hf-cache-migration`
branch is in `master`. Every empty here is `† unproven` because the
run branch predates the finish log; run 21 records the cause on two of
these configs under a thinking budget
(`docs/methodology/evalplus.md`, "Unproven yet").
