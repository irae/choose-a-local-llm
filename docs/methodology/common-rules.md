# Common rules — every measurement, every script

These rules bind every test on every page. Test-specific steps live in
the per-test pages; the run loop lives in
[the checklist](./checklist.md).

1. **One model on the GPU at a time.** Fresh server start per
   configuration. Long runs go in background tasks.
2. **Warmup first.** Send a discarded warmup request; measure only after
   it.
3. **Fixed prompts**, temperature 0, fixed token count (we use 256),
   identical across every model and config:
   - py: `Write a Python function that parses ISO dates.`
   - js: `Write a JavaScript function that deep clones an object.`
   Two languages matter: speculative-decoding acceptance differs by
   language, so a single-prompt benchmark can mislead.
4. **Read the server's own timings, not wall clocks**, where available.
   llama-server: `.timings` from `/completion` (`prompt_per_second`,
   `predicted_per_second`, `draft_n`, `draft_n_accepted`).
   mlx_lm.server has no per-request timings — measure decode by
   streaming and timing the token chunks. LM Studio: the server log is
   ground truth ([server lore](./server-lore.md)).
5. **Benchmark scripts must reuse the server's prompt cache perfectly.**
   Grow prompts append-only: each request's prompt = the previous prompt
   + the server's own reply + the new text. Never insert before an
   existing prefix, and never use a fixed suffix that later steps insert
   before. llama-server reuses any longest common prefix;
   mlx_lm.server only reuses strict extensions. Verify reuse via llama's
   `.timings.prompt_n` (must be the delta, not the total).
6. **KV cache policy: 8-bit (q8_0) is the default.** Near-lossless
   (verified byte-identical outputs vs f16 at temperature 0); the
   context it unlocks overrules f16's ~1% speed edge. Every published
   config uses q8 — no exceptions, even trained-window-limited configs.
   Caveat to measure per model: q8 can lower MTP draft acceptance and
   decode speed (Gemma-26B js: 81% → 68%). q4_0 is banned for quality —
   with one exception: a vendor ships a per-model calibration for it
   (PrismML's Bonsai bias); such a config must pass the
   [EvalPlus gate](./evalplus.md) before serving.
7. **API-or-nothing.** A config qualifies only if it serves an HTTP API
   a harness can use. CLI-only inference paths are disqualified.
8. **Keep thinking-on AND thinking-off data, both labeled — never
   replace one with the other.** The target setup is mixed: main agent
   thinks, sub-agents run thinking-off. Report tables show thinking-on;
   thinking-off goes in note text.
9. **Record each result on every surface in the same pass** — a result
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
10. **Downloads: sequential, one at a time** on slow connections,
    needed-first order, never during meetings (parallel only when the
    user says so). Download only the exact files needed (`--hf-file` /
    `hf_hub_download`) — repos bundle huge F16 siblings and trap-named
    variants; verify file lists and `model_type`/layout compatibility
    before pulling.
11. **After tests, check for leftovers and clean up** (the checklist has
    the commands). Do not delete model files or tools early — keep
    variants for debugging until many successes.
