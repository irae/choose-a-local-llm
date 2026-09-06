# Research run 3, task list

Not started. The runbook (`AGENT.md`) and the rest of the kit appear
when the run starts. Items are one file each in `../`, in the order
the run takes them; the executor checks them off here as it goes and
writes results beside the item (`../<mnemonic>/results.md`).

- [ ] Wired limit retest, first because the owner is present for sudo
  and a reboot (../wired-limit-retest.md; the procedure is
  `docs/methodology/wired-limit.md`)
- [ ] A config that reaches Mendel never runs out of memory: the
  in-turn margin, the mlx and llama findings, four tests in order
  (../no-oom-at-mendel.md; attachments in ../no-oom-at-mendel/)
- [ ] pi compaction at a lowered window, two to four models, the
  summary scored (../compaction-experiment.md)
- [ ] Qwen3.8-27B: vision off, alternative GGUF quants (../qwen38-configs.md;
  finding attached: ../kv-quant-on-m1.md)
- [ ] Container trials: the survey, then at most three candidates
  through the three quick checks (../container-trials.md)

Waits on the owner: `backlog/devstral-download.md`,
`backlog/bonsai-kv-bias-corpus.md`, `backlog/qwen38-mlx-window.md`.
