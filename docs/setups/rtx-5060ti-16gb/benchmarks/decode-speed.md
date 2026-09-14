# Decode speed vs context depth — RTX 5060 Ti 16 GB

Every benchmark here answers one question: **how fast does the model
decode when the context is actually full?** A near-empty prompt says
one number; a real coding session at depth says another. The test
runs first in the stack because everything else depends on its
answer: the harness compaction threshold, the "gated by" verdict, the
published max context. On this machine every reading comes from
`llama-benchy` on real code text at the server's own sampling, at two
or three depths per row; the `-c` ceiling is the largest value that
loads with every layer on the card.

Two rules to read the tables by:

- **The floor is 8 tok/s**: below it, a config is unusable for
  interactive work, whatever its window says.
- **Used tokens, not allocated.** Allocation is storage.

## Latest per model and backend

<!-- gen:decode-summary:start -->
| best curve | tok/s (shallow → deep) | at | gated by |
|---|--:|--:|---|
| [<ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="off" />](./gemma-4-12b-it.md) | pending → pending | pending | mem |
| [<ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="q8_0" effort="xhigh" />](./qwen3.8-27b.md) | pending → pending | pending | mem |
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" kv="q8_0" effort="on" />](./qwen3.6-35b-a3b.md) | pending → pending | pending | mem |
| [<ModelSpec base="Gemma-4-26B-A4B" quant="NVFP4Q8" server="llama-server" publisher="catlilface" repo="catlilface/Gemma-4-26B-A4B-NVFP4-GGUF" kv="f16" effort="on" />](./gemma-4-26b-a4b.md) | pending → pending | pending | mem |
<!-- gen:decode-summary:end -->

## Curves

Pending: the first run's tables land here when it closes, one row per
configuration with the depth buckets as columns, as on the reference
setup. Raw evidence: `hardware/rtx-5060ti-16gb/benchmarks/bench17/`
in the repo.

## Method, in one breath

[The measurement rules](../../../methodology/context-creep.md): fixed
real-text corpus, the server's own sampling, two runs per cell,
acceptance beside every drafter cell, GPU memory and host
`MemAvailable` recorded after every cell.
