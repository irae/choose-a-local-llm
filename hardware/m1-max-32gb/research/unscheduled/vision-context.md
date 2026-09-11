# vision-context — what a local model can do with images, and how much context survives beside them

Status: unscheduled. Drafted 2026-09-11 from the owner's direction and
the coordinator's proposal. Research, not a gate: the outcome is a
set of measurements and a place for them on the site, not a score
that ranks rows.

## Why

Two uses need images with context: parsing PDFs, bills and bank or
credit-card statements, where text tools lose the tables and the
failproof input is the page PNG plus the extracted text; and
frontend work, where the agent reads screenshots to check layout and
CSS defects beside the page's own code. Both need the model to see
and to keep a working amount of text context at the same time.
EvalPlus and simulator(mendel) do not measure that; a vision task set
does.

Every GGUF row on the site runs with `--no-mmproj`. Three builds have
their projector on disk: Qwen3.8, Qwen3.6 and Gemma-26B. Run 15's
`vision-ladder` block gives the first numbers for two of them: the
largest `-c` with the projector on, the wired cost, the token cost
of one page image, and the decode speed. This item takes it from
there.

## Questions

1. **Vision creep.** With one page image in every step, at what
   used depth does each vision server cross the 8 tok/s floor or run
   out of memory, and how does that compare with its text creep. The
   creep tool sends text only; it needs an image per step (a change
   in `local-llm-eval-tools`, not in this repo).
2. **Image token cost by size.** The same page at three pixel widths
   (about 800, 1200, 1600), the prompt token count of each, and
   whether the smallest one still reads the table. Sets the page size
   the parser sends.
3. **Reading a table.** A fixed statement page whose line items the
   model must return as JSON; pass is arithmetic, the items sum to
   the printed total. Text-only (`pdftotext -layout` into the same
   prompt), image-only, and image plus text, on each server. Says
   which path the parser should take and whether the image adds
   anything on a clean PDF.
4. **Reading a screenshot.** A screenshot of a web page with one
   planted CSS defect, with and without the page's HTML in the
   prompt; the answer must name the element and the property, and
   with the HTML, the line. Says whether frontend review is viable
   locally and with how much context left.
5. **Where it goes on the site.** A vision column is not a
   completeness criterion today. Proposal: a "Vision" section on the
   model pages with the ladder and the task results, and a row note
   on the comparison; a fourth completeness criterion only if the
   owner says so after the numbers are in.

## Inputs the owner provides

- One real statement page as PDF, kept on the Mac, never committed;
  a synthetic page (run 15 builds one from text) stands in for the
  creep and the size question but not for the reading question.
- One small web page with a planted CSS defect, or the owner's
  approval for the coordinator to write one into the item's folder.

## Out of scope

- Document OCR models (GLM-OCR, PaddleOCR-VL, DeepSeek-OCR-2): a
  download, and a separate item if the projector path fails.
- Any change to the simulator(mendel) runner; a vision task set is a
  different simulator and the owner designs it.
- The ISTA Qwen3.8 build and MLX servers, until the two GGUF servers
  above have numbers.
