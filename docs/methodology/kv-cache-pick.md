# KV cache pick — f16 or q8_0, per model

The first test a model gets. It decides the cache type every later
measurement runs with, so nothing else is measured before it. Common
rules and the run loop apply ([common rules](./common-rules.md),
[checklist](./checklist.md)).

## What is being decided

llama-server can hold the KV cache at f16 or at q8_0. q8_0 halves the
cache memory and unlocks a larger context on the same machine. On some
models it costs nothing; on others it cuts decode speed by half or
more before 32K and lowers the quality of the answers. Which group a
model is in cannot be assumed. It is measured once, and the pick is
then part of the model's published command.

Lower types are not candidates. q4_0 loses too much precision for most
models. One exception exists: a vendor that ships a per-model
calibration for it (a KV bias file). Such a config is an edge case, and
it goes through the EvalPlus gate on its own before it serves anything.
MLX runtimes hold f16 only, so this test does not apply to them.

## The procedure

1. **Research the cache quality.** Look for measured evidence that
   q8_0 KV is near-identical to f16 for THIS model: the quant
   publisher's own grading (KL-divergence graphs), or a community KL or
   benchmark comparison with the method shown. Record the source beside
   the config. Some families stay near-identical at q8_0; others lose
   far more, and their MoE variants lose the most.
2. **Short creep, both types, to 32K.** Below 32K a config is not
   useful, so 32K is the smallest depth that decides anything. Same
   command, only the cache types change, `-c` just above 32K. The
   short creep is the [context creep](./context-creep.md) with
   `DEPTH_LIST="4096,8192,16384,24576,32768"`. Record decode tok/s and
   wired memory at 4K and 32K for each type, and draft acceptance where
   a drafter runs.
3. **Predict the fit.** KV cost per token is linear:
   `kv_per_token = (wired_32k - wired_4k) / 28672`. A type fits at a
   target context when
   `wired_4k + kv_per_token × (target - 4096) + margin ≤ wired limit`.
   The margin and the limit are values in the machine file. The target
   is the model's trained window or the depth the short creep already
   shows is the speed floor, whichever is smaller.
4. **Candidate pick.** f16 when it fits at a useful context AND is
   faster at 32K, or when step 1 says q8_0 costs this model quality.
   q8_0 when f16 does not fit at a useful context; a slower cache that
   holds the context beats a faster one that does not. When the two
   curves are within 10% at 32K and both fit, q8_0. When the fit is
   inside the margin or the curves cross, both types stay candidates
   and the full creep decides.
5. **EvalPlus smoke on the candidate**, against the other type, same
   budget both sides ([the smoke](./evalplus.md#the-smoke)). LEVEL or
   BETTER confirms the pick. WORSE means the faster cache costs
   answers: the pick moves to the other type, or to a bench item when
   both look bad. The smoke takes minutes per side; a wrong pick costs
   every later measurement of the model.

Write the short-creep tables, the arithmetic, the smoke lines and the
pick into the run's results. The pick is final for the model until a
runtime change re-opens it. Rows measured at the other type before the
pick existed are hidden on the site until re-measured.

## What the first picks showed

On the reference setup, one dense 12B model at q8_0 fell under the 8
tok/s floor by 16K while f16 was 3.2x faster there, still usable at
131K, and fit at the model's full window. Two more models moved to
f16 for speed alone (more than 2x at 32K), and one MoE model stayed at
q8_0 because f16 did not load at a useful context. q8_0 also lowered
MTP draft acceptance on one MoE model (81% to 68%). The smoke read
LEVEL on every pick so far. The evidence is in the setup's reports and
run logs.

## Pitfalls

- **A server that loads is not a server that works.** With `-ngl 999`
  a `-c` that does not fit can report "model loaded" and answer every
  completion with a 500 and "Insufficient Memory" in its log. Verify
  every candidate `-c` with one real completion before the creep.
- **The published `-c` is not the target.** The short creep needs only
  32K plus the prompt. Allocating the full window for it wastes memory
  and can push the machine into compaction.
