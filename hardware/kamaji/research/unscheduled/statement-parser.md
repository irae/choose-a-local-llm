# Statement parser: bills and bank statements, PDF in, tables out, no internet

Status: draft 2026-09-10, unscheduled, not committed; the owner reviews
it first. Needs hardware: yes, the Mac, and a container the owner is
building. This item is the first use of the project's picks on real
private data, and its evaluation is a new one, not EvalPlus and not
Mendel.

## The goal

Utility bills, bank and credit card statements arrive as PDFs. Some
carry real text, some are scans, and the text tools often lose the
tables. The parser turns each PDF into a CSV per table and a markdown
report per document, in private folders, with no network. Later stages
are other agents: analysis, graphs, reconciliation. The strong local
models then build, test and debug the parser against the real data,
all offline.

## The sandbox

A dockerized agent with no internet access, every tool installed at
build time: `pdftotext` and `pdftoppm` (poppler), `pdfplumber` and
`pypdfium2` for text and table geometry, an OCR model server, a text
model server, and the coding agent (pi) with bash, read, write and
edit. Private folders mounted read-only for input and read-write for
output. The image cannot fetch a model or a package at run time, so
the model files and the wheels are baked in or mounted.

Open question for the owner: does the container run the model servers
too, or does it talk to llama-server on the host over the Docker
bridge. The host path keeps one wired budget and one set of model
files; the in-container path is the fully sealed one.

## The three extraction paths, scored the same way

1. Text only: `pdftotext -layout` per page, then the text model with a
   JSON schema for the fields and the line items.
2. OCR model to text model: a document OCR model (GLM-OCR 0.9B,
   PaddleOCR-VL 0.9B, DeepSeek-OCR-2, or Qwen3-VL at 4B or 8B, all in
   llama.cpp) renders each page to markdown with tables kept, then the
   same extractor runs on the markdown.
3. Image plus text: the page PNG at 150 dpi and the pdftotext output
   both go to a vision-capable row, Gemma-26B or Qwen3.8 with its
   projector, which reconciles them.

Every path ends in the same check: line items must sum to the totals
the document states. A page that fails the check goes to the agent
path, pi with the same tools, which decides what to try next. The
agent is the fallback, not the first path.

## The gold set and the score

Ten to twenty of the owner's own pages: real-text bills, scanned
bills, a bank statement with a multi-page table, a card statement with
a table that crosses a page break. One hand-checked JSON per page:
issuer, account, period, due date, total, and every line item. The
score is field accuracy and line-item row accuracy per path per model,
plus wall time per page. The smallest model that reaches 100 percent
on totals across the set is the pick.

## Candidates inside the wired budget

An OCR model of 1 to 6 GB fits beside Qwen3.8 ISTA at `-c 32768` or
beside Gemma-12B with room under 25000. Qwen3.6 at f16 KV is the
fastest text extractor but its `-c 40960` server alone is 25 GB, so it
runs without a second model. The expected result, to be measured: the
text-only path wins on speed for real-text PDFs, which are most
statements; the OCR-model path wins on scanned tables; the image-plus-
text path is the fallback for pages where the two disagree.

## What this item produces

A results table per path and model on the gold set, the pick, the
container definition the owner reviewed, and the parser as a project
of its own outside this repo. No number from it reaches the site's
model tables; it may earn a page of its own if the owner wants one.
