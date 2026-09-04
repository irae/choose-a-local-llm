# The Bonsai scored config points at a file that no longer exists

Run 2, 2026-09-04. Found while preparing section B's q8_0 KV arm.
Nothing was run and nothing was regenerated.

## What is missing

The published `bonsai-prism` command, in
`docs/setups/m1-max-32gb/models.json` and the Bonsai report, is:

```
LLAMA_ATTN_ROT_DISABLE=1 ~/prism-llama/llama-server \
  -m .../Ternary-Bonsai-27B-Q2_g64.gguf \
  -ngl 999 -fa on -c 65536 --parallel 1 \
  --cache-type-k q4_0 --cache-type-v q4_0 \
  --kv-mean-center /tmp/Ternary-Bonsai-27B-kv-bias.gguf \
  --jinja --port 8081
```

`/tmp/Ternary-Bonsai-27B-kv-bias.gguf` **is gone.** `/tmp` is cleared on
reboot, and the machine rebooted before this session.

That file is part of the scored configuration. The EvalPlus row it
produced — **0.927 base / 0.890 plus**, the fork's best — cannot be
reproduced today by running the published command.

## The generator survives, but it does not restore the same file

`~/prism-llama/Bonsai-demo/scripts/make_kv_bias.sh` still exists, so a
bias file can be rebuilt. Its own header is the problem:

> Calibration does not need much data. The built-in corpus is a small
> synthetic example; for best results pass a text file representative of
> your workload.

So the bias is **corpus-dependent**, and the repo does not record which
corpus produced the scored file — built-in synthetic, or something the
owner supplied. Regenerating gives *a* valid bias, not *the* bias.

Rebuilding it blind would be worse than leaving it missing: the config
would look reproducible while quietly resting on a different calibration
than the published score. That is why nothing was regenerated here.

The header also notes the bias is optional — "without it the 4-bit KV
cache still runs, just with slightly lower quality" — so this affects
score reproduction, not the ability to serve.

## Consequences

1. **The Bonsai fork EvalPlus row is not reproducible as published.**
   Not wrong, and not necessarily stale — but it cannot be re-derived
   without knowing the calibration corpus.
2. **Section B's q8_0-versus-q4_0 arm cannot run as designed.** The
   comparison needs the q4_0-plus-bias arm as its baseline, and that
   baseline is unavailable.
3. It breaks the repo's own rule about machine state. `AGENTS.md` names
   three places and says "when in doubt it is not a cache". A file a
   published measurement depends on belongs in
   `~/.local/share/choose-a-local-llm/`, which is defined as the place
   for things that must survive. `/tmp` is not one of the three.

## Proposed, not applied

1. Ask the owner which corpus produced the scored bias file. If it was
   the built-in synthetic one, regeneration is exact and the problem
   disappears.
2. Regenerate it into
   `~/.local/share/choose-a-local-llm/Ternary-Bonsai-27B-kv-bias.gguf`
   and update the two commands in `models.json` and the Bonsai report to
   point there.
3. Record the corpus used, beside the file.

Only step 1 needs the owner. Steps 2 and 3 follow from the answer.
