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
6. **KV cache type: decided per model, by research, then by a short
   creep, before any full sweep.** Both f16 and q8_0 are candidates;
   q4_0 is banned for quality, with one exception: a vendor ships a
   per-model calibration for it (a vendor-shipped KV bias file), and such a
   config must pass the [EvalPlus gate](./evalplus.md) before serving.
   The procedure, in order:
   1. **Research the cache quality first.** Look for measured evidence
      that q8_0 KV is near-identical to f16 for THIS model: the quant
      publisher's own grading (unsloth grades its weight quants with
      KL-divergence graphs; cache-type graphs come from community
      benchmarks such as the localbench KL study), or a KL or
      benchmark comparison with the method shown. Trust it when the
      proof is there. Record the source beside the config. Some model
      families stay near-identical at q8_0 (KL under 0.04 in community
      measurements); others lose far more, and their MoE variants lose
      the most. Do not assume which group a model is in.
   2. **Short creep, both types, to 32K.** Below 32K a config is not
      useful, so 32K is the smallest depth that decides anything.
      Same command, only the cache types change. Record decode tok/s
      and wired memory at 4K and 32K for each type.
   3. **Predict the fit.** KV cost per token is linear:
      `kv_per_token = (wired_32k - wired_4k) / 28672`. A type fits at
      a target context when
      `wired_4k + kv_per_token × (target - 4096) + 1500 MB ≤ iogpu.wired_limit_mb`.
      The target is the model's trained window or the depth the
      short creep already shows is the speed floor, whichever is
      smaller.
   4. **Pick.** f16 when it fits at a useful context AND is faster at
      32K, or when step 1 says q8_0 costs this model quality. q8_0
      when f16 does not fit at a useful context; a slower cache that
      holds the context beats a faster one that does not. When the
      two curves are within 10% at 32K and both fit, q8_0.
   5. **Full creep on the pick.** When the prediction is not decisive
      (the fit is within the margin, or the curves cross), run the
      full creep on both; a creep is cheap next to a wrong published
      row. Publish the pick, and note the other type's 32K numbers.
   Measured on the reference setup: one dense 12B model at q8_0 fell
   under the floor by 16K while f16 was 3.2x faster there, still usable
   at 131K, and fit at the model's full window; see that setup's
   report. q8_0 can also lower MTP draft acceptance (one MoE model:
   81% → 68%). Every existing q8_0 row is re-decided by this rule as
   its sweep is re-run.
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
10. **Never download a model on your own.** Every benchmarked model was
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
11. **After tests, check for leftovers and clean up** (the checklist has
    the commands). Do not delete model files or tools early — keep
    variants for debugging until many successes.
