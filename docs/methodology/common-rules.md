# Common rules — every measurement, every script

These rules bind every test on every page. Test-specific steps live in
the per-test pages; the run loop lives in
[the checklist](./checklist.md). The speed test's own rules (prompts,
timings, prompt-cache reuse, the KV type decision) live in
[context creep](./context-creep.md).

1. **One model on the GPU at a time.** Fresh server start per
   configuration. Long runs go in background tasks.
2. **Warmup first.** Send a discarded warmup request; measure only after
   it.
3. **Read the server's own numbers, not wall clocks**, where the server
   has them. Each test page says which field to read on which backend.
4. **KV cache type is a per-model decision, never a default.** f16 and
   q8_0 are the candidates. q4_0 is banned for quality, with one
   exception: a vendor ships a per-model calibration for it (a KV bias
   file), and such a config must pass the [EvalPlus gate](./evalplus.md)
   before serving. The decision procedure is the short creep in
   [context creep](./context-creep.md#the-kv-cache-type-decision).
   Every existing q8_0 row is re-decided by that procedure as its sweep
   is re-run.
5. **API-or-nothing.** A config qualifies only if it serves an HTTP API
   a harness can use. CLI-only inference paths are disqualified.
6. **Keep thinking-on AND thinking-off data, both labeled — never
   replace one with the other.** The target setup is mixed: main agent
   thinks, sub-agents run thinking-off. Report tables show thinking-on;
   thinking-off goes in note text.
7. **Record each result on every surface in the same pass** — a result
   is not recorded until all agree: the model's
   `docs/setups/<setup>/benchmarks/*.md` (full data), its
   `docs/setups/<setup>/reports/*.md` page **including the summary
   line** (it goes stale easily), the setup's `comparison.md`, the
   generated tables (`models.json` + `node tools/gen-tables.mjs`), and
   the harness config (`~/.pi/agent/models.json`). Every server config
   gets a copy-paste command block in its report whose alias equals the
   harness model id. The report and comparison pages show only numbers
   measured under the CURRENT wired limit; superseded measurements move
   to the setup's `historical.md` (benchmarks pages keep the full
   archive).
8. **Never download a model on your own.** Every benchmarked model was
   chosen, downloaded, and tested by the owner; the cache holds the
   exact files and quants the results depend on. If a model or file is
   missing from the cache, STOP and ask the owner — a fresh download
   can silently pull a different revision or quant and invalidate the
   run. Downloads happen only on an explicit owner request, and then:
   **sequential, one at a time** on slow connections,
   needed-first order, never during meetings (parallel only when the
   user says so). Download only the exact files needed (`--hf-file` /
   `hf_hub_download`) — repos bundle huge F16 siblings and trap-named
   variants; verify file lists and `model_type`/layout compatibility
   before pulling.
9. **After tests, check for leftovers and clean up** (the checklist has
   the commands). Do not delete model files or tools early — keep
   variants for debugging until many successes.
