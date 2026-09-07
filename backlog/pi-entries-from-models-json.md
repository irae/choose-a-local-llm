# Generate the pi entries from the site's `models.json`

Status: pending owner review. Filed 2026-09-07 at the owner's request.
Needs hardware: no for the tool; one dry run against the owner's file
on the Mac.

## The gap

When a model leaves the context creep, its config lands in
`docs/setups/<setup>/models.json` and `node tools/gen-tables.mjs`
updates every site table. The harness entry in `~/.pi/agent/models.json`
is the one surface the record-everywhere rule names
(`docs/methodology/common-rules.md`, rule 7) that no script writes.
The owner writes it by hand, so it lags or is missing: run 11 skipped
the Qwen3.6 MLX pair because no entry existed, and ran its Qwen3.6
GGUF pair on a 49152 window while the creep had found 82K.

## The ask

A tool, `tools/gen-pi-models.mjs`, that reads the site's `models.json`
and writes the local providers' entries into the owner's pi file:

- One entry per visible row that serves an HTTP API, under the
  provider its backend maps to (`llama` for llama-server, `mlx` for
  mlx_lm.server, `lmstudio` for LM Studio), model id equal to the
  serving alias, `contextWindow` from the row's clean depth rounded
  down to a 4096 multiple and at or under its `-c`, `maxTokens` and
  `reserveTokens` from the output budget rule, `reasoning` and the
  thinking map from the row's thinking levels.
- When a model has several rows on one backend, the tool picks the
  best for pi: the KV pick's row at the largest clean depth, the
  others as `modelOverrides` or skipped; the rule goes in the tool's
  header and in `EDITOR.md`.
- Merge, never overwrite: other providers, credentials and manual
  fields stay; a generated entry carries a marker field so the next
  run knows it may replace it. `--check` reports drift the way
  `gen-tables.mjs --check` does. `--dry-run` prints the diff.
- `models.json` rows gain the fields the tool needs (clean depth,
  thinking levels, backend to provider) where they are missing.

The Mendel worker then takes the entry from the same source instead
of copying the owner's file blind (`HANDOFF.md`, worker overrides).

## Out of scope

Cloud providers, credentials, and any entry the owner marks manual.
