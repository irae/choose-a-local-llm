# Night 4 state

## Start checks

- GPU: LM Studio server was left running on port 8081 with
  `google/gemma-4-12b` loaded (pinned `-c 158464 --parallel 4`) at the
  end of night 3. Stop it (`~/.cache/lm-studio/bin/lms unload
  google/gemma-4-12b` or equivalent) before starting bonsai-prism —
  llama-server needs port 8081 too.
- Read `night3/state.md` in full first — it has the complete history for
  everything handed to this file, including why the gemma-12b depth
  numbers were not written to the site.
- No background sweep, watcher, or Monitor processes should be running
  at night 4's start; night 3 closed clean (`ps aux | grep -E
  "mem-watch|lmstudio_sweep|llama-server|mlx_lm"` returned nothing).

## Next

Block 1: bonsai-prism resume. See `night4/NIGHT-AGENT.md`.
