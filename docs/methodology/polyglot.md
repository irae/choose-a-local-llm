# Aider polyglot — the ranking benchmark

The last tier of the quality flow, for gate survivors only: the **Aider
polyglot benchmark** — 225 Exercism problems, 6 languages, 2 attempts
with test feedback, docker against your servers. Hours per model.

## Requirements

- The config passed the [EvalPlus gate](./evalplus.md) and has a
  [Mendel](./mendel.md) result.
- On this machine docker does not fit beside a loaded model: Aider runs
  driven from another computer against the Mac's server.
- Serve through the exact config from the model's report page (the
  copy-paste block). One model at a time.

## Steps

1. Start the config's server; warm up; watcher per
   [the checklist](./checklist.md).
2. Run the Aider polyglot suite from the driver machine against the
   server's API.
3. Record the score on every surface, labeled with the serving config.
