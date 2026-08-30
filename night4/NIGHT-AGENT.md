# Night 4 — carried over from night 3, 2026-08-29

Everything below was left open at the end of night 3. Read
`night3/state.md` first for the full history and why each item is here.

## Execution rules (carry-overs, all mandatory)

Same as night 3's, unchanged — see `night3/NIGHT-AGENT.md`'s "Execution
rules" section: STE prose, one model on the GPU at a time, port 8081,
heartbeat every ≤20 min, mlx dead-thread watchdog, prompt-cache-reuse
rule, "commit deviations, suspect the harness before the model."

**New this round**: run the memory probe for every sweep or benchmark,
scoped to that run only (start it right before, stop it right after —
see `docs/methodology.md`'s "Benchmark runs" section and the owner's
direct correction in `night3/state.md`'s gemma12 v2 section). A run
without the watcher is not valid and cannot be written to the site.

Per `AGENTS.md`: benchmark runs live on their own branch now, not
master. Branch before starting block 1 below.

## Blocks, in order

1. **bonsai-prism** (PrismML fork A/B, resume). Paused at 72/164 —
   partial results already committed
   (`night3/results/bonsai-prism/`). Resume with the identical serving
   command from `HANDOFF.md`'s "Block 4 resume details"-style section
   (`LLAMA_ATTN_ROT_DISABLE=1 ~/prism-llama/llama-server -m <HF cache
   path> --alias bonsai-prism -ngl 999 -fa on -c 65536 --parallel 1
   --cache-type-k q4_0 --cache-type-v q4_0 --kv-mean-center
   /tmp/Ternary-Bonsai-27B-kv-bias.gguf --jinja --port 8081` — regenerate
   the bias file with `~/prism-llama/Bonsai-demo/scripts/make_kv_bias.sh`
   equivalent if `/tmp` was wiped, see `night3/state.md` for the exact
   corpus and command used) and `EVALPLUS_MAX_NEW_TOKENS=10240
   night3/run-humaneval.sh bonsai-prism bonsai-prism`. Run
   `night2/mem-watch.sh` throughout (not scoped-short for this one — it's
   a long EvalPlus run, not a depth sweep; interval 20-30s per the
   lore). When done: record in `night4/state.md` and `night4/results.md`,
   compare against Bonsai's existing MLX score (0.915/0.884), update the
   site if it passes the gate, commit.
2. **bonsai-off** (thinking-off pass on the existing mlx-f16 config).
   Recalibrate the budget first with `night2/calibrate.py`'s method (10
   fixed problems, cap 30000) — never reuse the thinking-on budget.
3. **LM Studio gemma-12b real ceiling.** Night 3's pinned sweeps
   (`tools/sweeps/lmstudio_sweep.py`, `lmstudio_sweep_alt.py`) only ran
   up to a pinned 158,464-token context — copied from an old auto-fit
   value, not the model's trained max (262,144). Re-pin the load to the
   full trained max (`lms load google/gemma-4-12b -c 262144 --parallel 4
   --gpu max -y` — check memory fits first, `lms load ... --estimate-only`
   or watch `context_fit` in the LM Studio server log) and re-run both
   sweeps with the scoped memory watcher, all the way to the model's real
   speed floor or OOM (methodology rule 6: "must run to the model's
   trained/max context length"). Only then decide whether to supersede
   the site's existing "170k" figure (from LM Studio's auto-fit, already
   flagged there as a loader quirk) — do not just overwrite it with a
   smaller pinned number again.
4. **Gemma-12B thinking-on EvalPlus** (previously blocked). Night 3
   confirmed thinking works for `google/gemma-4-12b` via LM Studio
   (`reasoning_content` populated by default, no working toggle found —
   see `docs/methodology.md`'s LM Studio lore section). This unblocks
   the previously-blocked thinking-on score. Calibrate the budget first
   (10 fixed problems, cap 30000, per the standard method); expect a
   real, non-trivial empty-completion rate from budget-exhausted
   reasoning (Gemma-26B got 28% at budget 30000; a 16-problem smoke test
   at budget 16384 got 25% — see `night3/state.md`). Score the full 164,
   record honestly including the empty count, do not try to raise the
   budget indefinitely to chase zero empties.

## Report format for heartbeat checks

Same as night 3: "Block N (model): done X/Y, [num]h[num]min left."

## First moves if this session dies

1. `ps aux | grep -E "run_codegen_wrapper|run-humaneval|mlx_sweep|lmstudio_sweep|mem-watch"`
   and check `night4/results/` plus any sweep logs in `/tmp` for what was
   in flight.
2. `git status`; commit anything uncommitted (never push).
3. Re-read this file and `night3/state.md`'s closing sections — they are
   more current than anything else.
