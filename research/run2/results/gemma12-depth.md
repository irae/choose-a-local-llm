# Gemma-12B depth curves — the KV type, not the model, was the ceiling

Run 2, 2026-09-04. llama-server, `unsloth/gemma-4-12b-it-GGUF:Q4_K_XL`,
house method (`docs/methodology/context-creep.md`): raw `/completion`,
append-only growth, 25 s pause per step, memory watcher running, machine
clean with LM Studio quit.

Raw logs beside this file: `depth-sweep.log` (q8 + MTP),
`depth-nomtp.log` (q8, no MTP), `depth-f16-nomtp.log` and
`depth-f16-deep.log` (f16, no MTP).

## The curves

| used tokens | q8 + MTP | q8, no MTP | **f16, no MTP** |
| --- | --- | --- | --- |
| 4115 | 13.82 | 14.15 | **24.64** |
| 8235 | 8.74 | 10.64 | **24.05** |
| 16411 | **6.53 — floor** | **7.12 — floor** | 22.66 |
| 24587 | — | — | 21.59 |
| 32819 | — | — | 20.58 |
| 49159 | — | — | 18.75 |
| 65551 | — | — | 17.42 |
| 81943 | — | — | 15.87 |
| 98335 | — | — | 14.91 |
| 114726 | — | — | 13.94 |
| **131118** | — | — | **13.04** |

Floor is 8 tok/s. Both q8 arms stop there by 16K. **The f16 arm never
reaches it** — it was still at 13.04 tok/s at 131118 used tokens, where
the sweep's depth list ended.

**This is half a curve.** Gemma-4-12B's trained maximum is 262144, and
the sweep stopped at 131118 because of how it was set up, not because
anything gave way. See the limits section.

## What this settles

**The published row is correct.** `13.8 → 6.5`, 16k, gated by speed,
reproduced at 13.82 → 6.53. Earlier in this run I suggested that row
might be stale on the grounds that the same config allocates 262144
happily. That was wrong, and it was the exact error the method page opens
by warning about: allocation is storage, used tokens are what decode
pays for.

**The KV type is the ceiling, not the model.** Switching q8 to f16 turns
a config that dies at 16K into one still usable at 131K. At 16411 the
gap is **3.2x**.

**The MTP drafter costs speed at depth.** Dropping it gained 22% at 8K
and 9% at 16K. The drafter pays off on short prompts, which is where the
published 45.0 py figure came from, and stops paying as the context
fills.

## Where this contradicts a standing rule

`docs/methodology/common-rules.md` rule 6 makes q8 the default because
"the context it unlocks overrules f16's **~1% speed edge**".

On this model the edge is not 1%, and the context argument inverts: f16
KV at 262144 measured **15.8 GB wired**, inside the 24000 limit, so f16
does not cost the context here. It costs about 2 GB of headroom and buys
a curve that stays usable eight times deeper.

The rule already carries a per-model caveat that q8 can lower decode
speed, citing Gemma-26B. This is that caveat firing far harder than the
headline number suggests. The ask is in `planner-notes.md`; nothing here
changes a published page.

## Honest limits

- **Raw `/completion`, not chat.** Comparable with every published row,
  but not the path pi uses. The chat path adds a system turn and tool
  definitions to every request, so real use reaches a given depth sooner.
- **The sweep stopped early, and that is a method violation.**
  `context-creep.md` says to stop at the floor, at OOM, or at the
  model's trained maximum, "never earlier", and that "a sweep that stops
  at an arbitrary depth has not found a ceiling — it has just stopped".
  This one stopped at 131118 for two reasons, both mine: the server was
  started at `-c 139264` to save memory, and the depth list ended at
  131072.

  **Gemma-4-12B's trained maximum is 262144.** The curve is therefore
  half-finished. Completing it needs a server at `-c 262144` — f16 KV
  measured 15.8 GB wired there, inside the 24000 limit, so it fits — and
  depths continuing 147456, 163840, 180224, 196608, 212992, 229376,
  245760, 262144. **This is the first GPU item to run next.**
- **Quality is assumed, not measured, for f16.** Rule 6 states q8 is
  byte-identical to f16 at temperature 0, so the KV type should not move
  a score. No EvalPlus run has tested that on this model — and the GGUF
  quant itself has never been scored at all.
