# Night 3 — APPROVED 2026-08-28

Status: approved by the user on 2026-08-28. Written 2026-08-27.

## Decisions (answered by the user, 2026-08-28)

1. **Scope**: each model runs once, on its fastest depth curve. See the
   block table for the drops this causes.
2. **gemma12**: score BOTH modes, via LM Studio. Thinking-off first (its
   planned role), then thinking-on at budget 16384 (see the budget note).
   **gemma26**: thinking-on only, on MLX.
3. **Bonsai thinking-off pass**: yes, as the last block. Calibrate its
   budget first.
4. **Aider tier 2**: do not start. This night is a rolling score; the user
   decides later when the polyglot tier starts and with which models.
5. **qwen3.8 GGUF xhigh**: dropped — mlx-medium's 0.982 stands.
6. **bonsai-prism pi entry**: wait for tonight's q4 score; wire it in the
   morning session if it passes the gate.

## Execution rules (carry-overs, all mandatory)

- Write all prose in ASD-STE100 Simplified Technical English. Pass this rule
  to any sub-agent.
- Read first: `benchmarks/bench2/state.md` (the alarm/timeout wrapper fix history),
  `benchmarks/bench1/state.md` (older bug encyclopedia), `benchmarks/bench2/calibration.md`
  (budgets), README "Gate mechanics".
- One model on the GPU at a time. Port 8081. Wired limit stays 25000.
- GPU must be free before any server start; never kill a process you did not
  start; re-check every 20 minutes.
- **Heartbeat mandatory**: `ScheduleWakeup` 1200s after starting any block;
  verify real output growth, not process liveness; restart dead blocks; every
  wakeup ends with a new wakeup or the shutdown checklist.
- **Close background apps before the run starts** (night-2 lesson: memory
  pressure from Brave and friends is a competing explanation for the
  slowdowns; ask the user to close things before they leave, or note it if
  they did not). Start `benchmarks/mem-watch.sh` at run start and keep its log —
  it caught real swapping once and helps settle thermal-vs-memory. For short
  runs, depth-creep sweeps, or any run expected to end in OOM, run it at a
  short interval (20-30 s) instead of the 5-min default, so the final
  pre-OOM samples exist; the interval is worth parameterizing via env var.
- Timing is secondary; pass@1 is the signal. Expect decode-speed sag on long
  generations; do not chase it, just log it.
- Use the patched `benchmarks/run_codegen_wrapper.py` (post night-2 fix: no
  signal.alarm, 7200s client timeout). Do NOT run any block against a
  pre-fix wrapper. If EvalPlus was reinstalled, re-apply the venv rlimit
  patch per benchmarks/bench1/state.md.
- **Prompt-cache reuse is mandatory in any script you write** (README rule
  11): grow prompts append-only (previous prompt + the server's reply + new
  text), never insert before an existing prefix, verify reuse via llama's
  `prompt_n` delta. mlx_lm.server only reuses strict extensions.
- **mlx dead-thread watchdog.** mlx_lm.server's generation thread can die
  (Metal OOM) while the process lives and `/health` returns 200 — the client
  then hangs forever. Any script that talks to an mlx server must watch the
  server log for the death signature ("Insufficient Memory", "Command buffer
  execution failed", a Traceback) and exit with code 42 the moment it
  appears, so the failure notifies instead of hanging. Recognize exit 42 as
  "server thread died: the last printed row is the ceiling"; restart or move
  on, do not retry the same depth blindly.
- If a codegen run stalls on one task far longer than its budget allows,
  check the SERVER log for a crash before blaming the model — /health can
  return 200 while a request thread is dead (night-2 mlx incident).
- Do not update HTML/comparison/pi — morning session with the user.
- Only bonsai-think may run while the user works, and only if the user says
  so that day. Everything else runs when the machine is free.
- Commit bench3 files per phase, in STE.

## Planned blocks (final order per user, 2026-08-28)

Rule for this night: each model runs once, on its fastest depth curve.
Dropped as duplicates of a faster or already-scored surface: gemma12 on
GGUF, gemma26 on GGUF, qwen38 GGUF xhigh (mlx-medium 0.982 stands). Known
gap: the GGUF surfaces stay unscored; gemma26-GGUF is the pi 256K deep-window
config — if that seat survives the morning decisions, gate it a later night.

This is a rolling score: the user decides after these results when the Aider
polyglot tier starts and with which models. Do not start Aider.

| block | what | budget | expected |
|---|---|---|---|
| qwen36-think | FIRST: finish the parked correction — regenerate the remaining 57 empties into `benchmarks/bench2/results/qwen36-think/`. Same config as the original run — this is a correction, not a new score | 26624 | small batch; its calibration outlier took 480s for one problem |
| gemma12-lmstudio | SECOND. Fresh 164 problems on LM Studio, its fastest/flattest curve (`lms server start --port 1234`, `lms load lmstudio-community/gemma-4-12B-it-MLX-4bit --context-length 32768 --gpu max --yes`; EvalPlus points at port 1234). Thinking-off first (calibrate the budget with the night-2 `calibrate.py` method), then thinking-on at 16384 | off: calibrate first; on: 16384 (see budget note below) | off likely fast; on has ~4/10 doomed cap-hitters — the budget note cuts the waste |
| gemma26-mlx | fresh 164 problems, thinking-on, `mlx-community/gemma-4-26b-a4b-it-4bit` on mlx_lm.server (its faster curve). mlx watchdog and `--prompt-cache-size 2` rules apply | 30000 | long; expect a real nonzero empty rate (cap-hit problems) |
| bonsai-prism | fresh 164 problems on the PrismML llama.cpp fork (user-approved exception to the no-forks rule), scoring the chosen desktop profile exactly: `~/prism-llama/llama-server -m <HF cache>/Ternary-Bonsai-27B-Q2_g64.gguf -c 65536 --cache-type-k q4_0 --cache-type-v q4_0 -fa on -ngl 999 --jinja --port 8081`, plus the calibration bias: run `make_kv_bias.sh` from `~/prism-llama/Bonsai-demo` first and add its `--kv-mean-center` file. NO drafter for scoring (spec decode is output-lossless, so it cannot change the score; serve with it later if wanted). Use the `Q2_g64` file only — the plain `Q2_0` and the published `dspark-Q4_1` are legacy layouts that do not load. Not a duplicate: Bonsai's mlx-f16 score exists (0.915/0.884); this gates the daily serving path against it | 10240 (same as the scored mlx block) | The A/B isolates two variables: GGUF-vs-mlx weight quantization and q4-KV-with-bias vs f16. If the score holds, the desktop profile (9.8 GB flat, floor ~30K) becomes Bonsai's daily serving path. If it drops, rescore at q8 KV (floor ~21K) before giving up on the fork |
| bonsai-off | fresh 164 problems thinking-off, on the same mlx-f16 config as the scored bonsai-think run | recalibrate first | likely fast; prices the sub-agent/background mode |

**Budget note for gemma12-think (user question answered here).** Do not tie
`max_tokens` to the 8 tok/s depth cutoff directly — a budget below what a
completion legitimately needs recreates the night-1 flaw (truncation scored
as model failure). But gemma12's calibration shows its budget mostly limits
WASTE, not ability: every completion that ever finished used ≤ 10,314
tokens; the cap-hitters (4/10) never converge at any budget and only burn
40-80 minutes each at deep-generation crawl speed. So set gemma12's budget
to 16384 (longest successful completion × 1.5, rounded) instead of 30000:
no legitimate completion is truncated, and each doomed problem costs half
the time. Record cap-hitters explicitly (finish_reason length) — they are
model failures, priced fairly at either budget.

For any thinking-off block: calibrate its budget first with the night-2
`calibrate.py` method (10 fixed problems, cap 30000) — thinking-off changes
output length completely; never reuse a thinking-on budget.

## Creativity clause (unchanged from night 2)

You are allowed and expected to invent fixes for problems this runbook did
not foresee. Fairness first (same treatment for every model except calibrated
budgets); smallest fix that works; document every deviation in
`benchmarks/bench3/state.md`; suspect the harness before the model. Park and continue
when a step needs the absent user; never leave a run without a scheduled next
check.

## Shutdown

Same checklist as night 2: stop servers and evalplus, confirm idle, finalize
`benchmarks/bench3/results.md` (block, budget, pass@1 base/plus, empty count,
regenerated count, incidents), final state.md entry, commit.
