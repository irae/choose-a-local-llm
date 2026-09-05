# Run 10 — draft, not a runbook yet

Status: draft, owner decisions taken 2026-09-05; the exact commands and
the per-block text come when the kit is written. Bench items only. The
order below is the run order. A runner drops a config at any gate by
the standards in `docs/methodology.md` (under the floor at the owner's
working depth, a WORSE smoke, a failed Mendel smoke), writes why in
`state.md`, and starts the next block. Only the owner's own
stop-and-ask lines pause the run.

## First session

- Mac pulls `benchmark` in `~/code/mendel-benchmark` (runner alarms,
  `a41170a4`) before any Mendel work.
- Archive the orphan Bonsai MLX blind session (2026-09-02 22:44, 52
  tool calls; no branch, no row) as "abandoned attempt; no branch, no
  result row" in `SESSIONS.md`, the way the aborted Qwen3.8 medium
  session is recorded, then `tools/archive-evidence.sh`.
- The Mendel smoke tool: one handed task (the `xtend` swap of
  `research/run2/results/mendel-probe-xtend.md`), a pi model id, a
  25-minute cap, the counters (tool calls, distinct, loop ratio,
  commits, clean tree). Research run 2 ran it by hand; this run writes
  it as a script in the Mendel kit and records what it wrote.
- The run watcher is on trial. On every scoring block start
  `benchmarks/run-watch.sh` as the checklist says, and start the
  `sunset/` scripts beside it (`sunset/mem-watch.sh` and
  `sunset/liveness-watch.sh`, their own log files). At block close
  compare what each saw: memory lines against memory lines, and every
  stall or death verdict against the other's, in `state.md`. A bug
  found in `run-watch.sh` during the run goes to a subagent on the
  best available model, dispatched by the runner at once; the run
  does not wait for it. When the new watcher matches the old ones over
  the whole run, delete `sunset/` at run close, in the same commit as
  the closing `state.md`.

## Blocks, in order

1. **Slow creeps still missing**, one per server config. Gemma-12B
   GGUF four slots (q8_0). Gemma-26B GGUF two slots, re-planned at f16
   with a `-c` the machine loads. LM Studio Gemma-12B wired memory at
   its 131K ceiling, one sweep step. Rows that share a server with a
   measured row share its curve (Qwen3.8 MLX low, Bonsai MLX off) and
   need nothing here.
2. **Mendel smoke, Qwen3.8 GGUF f16, effort medium.** The first
   question of the run: can the llama row do agent work at all, where
   the MLX row never completed. A pass sends the row to Mendel blind
   later in this run; a fail sends the model to research.
3. **Gemma-26B GGUF f16, full EvalPlus, thinking on.** The row moved
   from 8 tok/s at 24K to 17.3 at 197K; the score on the site is from
   q8_0. Owner rule: base pass@1 at or above 0.800 continues to the
   Mendel smoke and then Mendel blind in this run; below that it stops
   here and the owner decides against the competing models.
4. **Bonsai MLX thinking off, Mendel smoke, then guided and blind.**
   Run 9's deferred block C. The smoke first, one run each after it.
5. **Qwen3.8 GGUF f16 Mendel blind**, only if block 2 passed. Low
   priority against everything above; research on this model comes
   first if block 2 failed.
6. **Full EvalPlus for the remaining survivors**, last, in this order:
   Gemma-26B GGUF f16 thinking off (the secondary-model use), Qwen3.6
   GGUF thinking off (the daily driver's off mode, never scored),
   Qwen3.8 GGUF f16 effort medium (lowest; its cell carries the MLX
   score and research on the model comes first).

## Waiting on owner decisions, not in the run until decided

- Qwen3.8 MLX: the context grows past the 26624 window in agentic use
  and Metal OOMs (run 9 block E, three attempts). A smaller
  `contextWindow` or an earlier compaction trigger before any retry;
  the blind low row waits on the same decision.
- Bonsai on the PrismML fork: blind thinking-high retry and the q8_0
  KV arm without the bias file. Both wait on the KV bias corpus.

## Dropped from the draft

- The EvalPlus smoke on creep survivors: the smoke is the KV pick's
  gate and ran there; slot configs share their single-slot row's
  score.
- The Bonsai "known-difference" check: it would run the smoke on the
  two Bonsai configs to see whether four problems separate scores
  0.012 apart. The tool's own header says four problems cannot do that,
  so the check answers nothing.
