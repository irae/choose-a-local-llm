# Bonsai KV bias corpus

Status: pending owner decision. Filed 2026-09-04, re-filed 2026-09-05.
Needs hardware: yes for the runs that wait on it.

The scored PrismML fork row of Ternary-Bonsai-27B serves q4 KV with a
per-model bias file. The file is generated, not downloaded, and the
corpus that produced it is not recorded. Without it the row cannot be
reproduced, and two runs wait: the fork's blind thinking-high retry
from scratch, and the q8_0 KV arm without the bias file against the
q4 plus bias row.

The owner names the corpus, or says the row stands as measured and the
two runs are dropped.
