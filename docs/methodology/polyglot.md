# Aider polyglot — the ranking benchmark

The last tier of the quality flow, for gate survivors only: the **Aider
polyglot benchmark** — 225 Exercism problems, 6 languages, 2 attempts
with test feedback, docker against your servers. Hours per model.

## Requirements

- The config passed the [EvalPlus gate](./evalplus.md).
- [Mendel](./mendel.md) is a soft filter, not a gate. The intent is to
  send only the configs that do well on Mendel to polyglot, because
  polyglot costs hours per model. The owner can decide to run polyglot
  before Mendel is ready for a config, or for all gate survivors.
- Docker rarely fits beside a loaded model. Drive Aider from another
  computer against the server when it does not; the setup page says
  which.
- Serve through the exact config from the model's report page (the
  copy-paste block). One model at a time.

## Steps

1. Start the config's server; warm up; watcher per
   [the checklist](./checklist.md).
2. Run the Aider polyglot suite from the driver machine against the
   server's API.
3. Record the score on every surface, labeled with the serving config.
