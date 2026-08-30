# Night 4 state

## Start checks

- Before block 1: make sure no model is loaded in LM Studio
  (`~/.cache/lm-studio/bin/lms ps`) and stop its server
  (`lms server stop`) — llama-server needs port 8081.
- Read `night4/lmstudio-forensics.md` and `night3/state.md` in full
  first. The forensics file changes how blocks 2-4 must run.
- No background sweep, watcher, or Monitor processes should be running
  at night 4's start.
- Branch before block 1; never push.

## Next

Block 1: bonsai-prism resume. See `night4/NIGHT-AGENT.md`.
