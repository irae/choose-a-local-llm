import { readFileSync, writeFileSync } from 'node:fs'
import { globSync } from 'node:fs'

const CHECK = process.argv.includes('--check')

const START = '<!-- gen:models-evaluated:start -->'
const END = '<!-- gen:models-evaluated:end -->'
const PARTIAL_START = '<!-- gen:models-evaluated-partial:start -->'
const PARTIAL_END = '<!-- gen:models-evaluated-partial:end -->'
const PARTIAL_NOTE =
  'Rows below 100 percent completeness. Completeness counts three measurements: tok/s, EvalPlus and Mendel.'
const KPI_START = '<!-- gen:model-kpis:start -->'
const KPI_END = '<!-- gen:model-kpis:end -->'
const MODEL_START = '<!-- gen:model-table:start -->'
const MODEL_END = '<!-- gen:model-table:end -->'
const CONFIGS_START = '<!-- gen:model-configs:start -->'
const CONFIGS_END = '<!-- gen:model-configs:end -->'
const EVALPLUS_START = '<!-- gen:evalplus-table:start -->'
const EVALPLUS_END = '<!-- gen:evalplus-table:end -->'
const DECODE_START = '<!-- gen:decode-summary:start -->'
const DECODE_END = '<!-- gen:decode-summary:end -->'
const MENDEL_LOCAL_START = '<!-- gen:mendel-local:start -->'
const MENDEL_LOCAL_END = '<!-- gen:mendel-local:end -->'
const MENDEL_CLOUD_START = '<!-- gen:mendel-cloud:start -->'
const MENDEL_CLOUD_END = '<!-- gen:mendel-cloud:end -->'
const MENDEL_GUIDED_START = '<!-- gen:mendel-guided:start -->'
const MENDEL_GUIDED_END = '<!-- gen:mendel-guided:end -->'
const MODEL_MENDEL_START = '<!-- gen:model-mendel:start -->'
const MODEL_MENDEL_END = '<!-- gen:model-mendel:end -->'

// Minimal CSV parser: handles quoted fields with embedded commas/quotes.
function parseCsv(text) {
  const rows = []
  let row = [], field = '', inQ = false
  for (let i = 0; i < text.length; i++) {
    const c = text[i]
    if (inQ) {
      if (c === '"') {
        if (text[i + 1] === '"') { field += '"'; i++ } else inQ = false
      } else field += c
    } else if (c === '"') inQ = true
    else if (c === ',') { row.push(field); field = '' }
    else if (c === '\n') { row.push(field); rows.push(row); row = []; field = '' }
    else if (c !== '\r') field += c
  }
  if (field !== '' || row.length) { row.push(field); rows.push(row) }
  const header = rows.shift()
  return rows
    .filter((r) => r.length > 1)
    .map((r) => Object.fromEntries(header.map((h, i) => [h, r[i] ?? ''])))
}

// Mendel model id -> this setup's report page slug.
const MENDEL_SLUGS = {
  'qwen3.6-35b-a3b': 'qwen3.6-35b-a3b',
  'qwen3.6-35b-a3b (unsloth UD-Q4_K_XL, off)': 'qwen3.6-35b-a3b',
  'qwen3.6-35b-a3b-f16 (unsloth UD-Q4_K_XL, no drafter, on)': 'qwen3.6-35b-a3b',
  'qwen3.8-27b (bartowski Q4_K_M, xhigh)': 'qwen3.8-27b',
  'gemma-4-26b-a4b': 'gemma-4-26b-a4b',
  'prism-ml/Ternary-Bonsai-27B-mlx-2bit': 'bonsai-27b',
  'mlx-community/Qwen3.8-27B-4bit': 'qwen3.8-27b',
  'Qwen3.8-27B (mlx, low)': 'qwen3.8-27b',
  'Ternary-Bonsai-27B (mlx, low)': 'bonsai-27b',
  'gemma-4-12b': 'gemma-4-12b-it',
  'google/gemma-4-12b': 'gemma-4-12b-it',
  'Gemma-4-12B (low)': 'gemma-4-12b-it',
  'Gemma-4-12B (llama.cpp, off)': 'gemma-4-12b-it',
  'bonsai-prism': 'bonsai-27b',
  'bonsai-prism (f16 KV)': 'bonsai-27b',
  'qwen3.8-27b': 'qwen3.8-27b',
  'qwen3.8-27b (reserve 8192)': 'qwen3.8-27b',
  'qwen3.8-27b (ISTA IQ3_S-mtp)': 'qwen3.8-27b',
  'qwen3.8-27b (ISTA IQ3_S-mtp, xhigh)': 'qwen3.8-27b',
  'qwen3.8-27b (ISTA IQ3_S-mtp, low)': 'qwen3.8-27b',
  'qwen3.8-27b (AtomicChat AD-IQ3_S)': 'qwen3.8-27b',
}

function mendelName(r) {
  const slug = MENDEL_SLUGS[r.model]
  const short = r.model.replace(/^.*\//, '')
  return slug ? `[${short}](../reports/${slug}.md)` : short
}

// The spec cell: two lines, identity then serving details, rendered by
// the ModelSpec component in docs/.vitepress/theme. A missing or
// invalid field throws here or in the component at build time.
const EFFORTS = ['off', 'on', 'low', 'medium', 'high', 'xhigh', 'max']

function repoOf(row) {
  if (row.spec?.repo) return row.spec.repo
  const cmd = String(row.command || '').replace(/\\\n/g, ' ')
  const m = cmd.match(/(?:-hf|--model)[= ]([\w.-]+\/[\w.-]+)/)
  if (!m) throw new Error(`row ${row.id}: no Hugging Face repo in the command; add spec.repo`)
  return m[1]
}

function specTag(spec, { hide = '', label = '', repo = '', top = false } = {}) {
  for (const k of ['base', 'quant', 'server', 'publisher', 'kv']) {
    if (!spec?.[k]) throw new Error(`spec ${label || JSON.stringify(spec)}: missing ${k}`)
  }
  const card = repo || spec.repo
  if (!card) throw new Error(`spec ${label || spec.base}: missing repo`)
  const hideEffort = hide.split(',').includes('effort')
  if (!hideEffort && !EFFORTS.includes(spec.effort)) {
    throw new Error(`spec ${label || spec.base}: effort "${spec.effort}" is not one of ${EFFORTS.join(', ')}`)
  }
  const attrs = [
    `base="${spec.base}"`,
    `quant="${spec.quant}"`,
    `server="${spec.server}"`,
    `publisher="${spec.publisher}"`,
    `repo="${card}"`,
    spec.drafter ? `drafter="${spec.drafter}"` : '',
    `kv="${spec.kv}"`,
    spec.effort && !hideEffort ? `effort="${spec.effort}"` : '',
    hide ? `hide="${hide}"` : '',
    top ? 'top' : '',
  ].filter(Boolean)
  return `<ModelSpec ${attrs.join(' ')} />`
}

function scoreTag(value, sub = '', top = false, pill = '', note = '') {
  const clean = (v) => String(v).replace(/"/g, '')
  return `<ScoreCell value="${clean(value)}"${note ? ` note="${clean(note)}"` : ''}${pill ? ` pill="${clean(pill)}"` : ''}${sub ? ` sub="${clean(sub)}"` : ''}${top ? ' top' : ''} />`
}

// The EvalPlus cell "base/plus/completion%" renders as the two scores
// over the completion; the Mendel cell "score (partial NN%)" renders as
// the score over the test name and, for a partial, the libraries done.
function evalplusCell(text) {
  const m = String(text).match(/^([\d.]+\/[\d.]+)\/(\d+%|—)$/)
  return m ? { value: m[1], sub: m[2] === '—' ? '' : `${m[2]} completion` } : { value: String(text), sub: '' }
}

function mendelCellParts(r) {
  if (r.mendel === 'failed-smoke') return { value: '0', note: '0%', pill: 'failed-smoke' }
  const m = String(r.mendel).match(/^([\d.]+)(?:\s*\(partial\s*(\d+%)\))?$/)
  if (!m) return { value: String(r.mendel), note: '', pill: '' }
  return { value: m[1], note: m[2] || '', pill: `mendel-${r.mendelTest || 'blind'}` }
}

// The Coding cell of a row comes from the Mendel CSVs: every valid run
// of the current prompt version, blind or guided, whose spec matches
// the row's. The pick is the run with the most libraries done, then
// the higher capped score. A row with no matching run keeps the state
// word written in models.json.
function mendelKey(spec, slots) {
  return [...['base', 'quant', 'publisher', 'server', 'drafter', 'kv', 'effort'].map((k) => spec[k] || ''), slots].join('|')
}

function rowSlots(row) {
  const m = String(row.command || '').match(/--parallel (\d+)/)
  return m ? Number(m[1]) : 1
}

function runSlots(r) {
  const m = `${r.model_id} ${r.branch}`.match(/-(\d)x\b/)
  return m ? Number(m[1]) : 1
}

function deriveMendel(rows, blind, guided) {
  const runs = [
    ...blind.filter((r) => r.local === 'True').map((r) => ({ r, test: 'blind' })),
    ...guided.filter((r) => r.local === 'True').map((r) => ({ r, test: 'guided' })),
  ].map((x) => ({ ...x, key: mendelKey(mendelSpec(x.r), runSlots(x.r)) }))
  const done = (r) => (r.libraries_done === '' ? 8 : Number(r.libraries_done))
  const capped = (r) => Math.min(Number(r.score_total), (100 * done(r)) / 8)
  for (const row of rows) {
    if (!row.spec) continue
    if (/^[\d.]/.test(String(row.mendel))) {
      throw new Error(`row ${row.id}: mendel "${row.mendel}" is a number; the score comes from the Mendel CSVs, write only pending, not run, invalid or failed-smoke`)
    }
    const match = runs
      .filter((x) => x.key === mendelKey(row.spec, rowSlots(row)))
      .sort((a, b) => done(b.r) - done(a.r) || capped(b.r) - capped(a.r))[0]
    if (!match) continue
    const partial = match.r.partial === 'True'
    row.mendel = `${capped(match.r)}${partial ? ` (partial ${Math.round((100 * done(match.r)) / 8)}%)` : ''}`
    row.mendelTest = match.test
  }
}

// Mendel rows come from the benchmark CSVs, which carry the alias, the
// server, the KV type and the branch; the build and the drafter come
// from this map, keyed by the CSV `model` value.
const MENDEL_SPECS = {
  'qwen3.6-35b-a3b': { base: 'Qwen3.6-35B-A3B', quant: 'UD-Q4_K_XL', publisher: 'unsloth', repo: 'unsloth/Qwen3.6-35B-A3B-MTP-GGUF', drafter: 'mtp/3', effort: 'on', binary: true },
  'qwen3.6-35b-a3b (unsloth UD-Q4_K_XL, off)': { base: 'Qwen3.6-35B-A3B', quant: 'UD-Q4_K_XL', publisher: 'unsloth', repo: 'unsloth/Qwen3.6-35B-A3B-MTP-GGUF', drafter: 'mtp/3', binary: true },
  'qwen3.6-35b-a3b-f16 (unsloth UD-Q4_K_XL, no drafter, on)': { base: 'Qwen3.6-35B-A3B', quant: 'UD-Q4_K_XL', publisher: 'unsloth', repo: 'unsloth/Qwen3.6-35B-A3B-MTP-GGUF', drafter: '', effort: 'on', binary: true },
  'gemma-4-26b-a4b': { base: 'Gemma-4-26B-A4B', quant: 'UD-Q4_K_XL', publisher: 'unsloth', repo: 'unsloth/gemma-4-26b-a4b-it-GGUF', drafter: 'mtp/2', effort: 'on', binary: true },
  'prism-ml/Ternary-Bonsai-27B-mlx-2bit': { base: 'Ternary-Bonsai-27B', quant: '2-bit', publisher: 'prism-ml', repo: 'prism-ml/Ternary-Bonsai-27B-mlx-2bit', drafter: '', effort: 'on', binary: true },
  'Ternary-Bonsai-27B (mlx, low)': { base: 'Ternary-Bonsai-27B', quant: '2-bit', publisher: 'prism-ml', repo: 'prism-ml/Ternary-Bonsai-27B-mlx-2bit', drafter: '', binary: true },
  'mlx-community/Qwen3.8-27B-4bit': { base: 'Qwen3.8-27B', quant: '4-bit', publisher: 'mlx-community', repo: 'mlx-community/Qwen3.8-27B-4bit', drafter: '', effort: 'medium' },
  'Qwen3.8-27B (mlx, low)': { base: 'Qwen3.8-27B', quant: '4-bit', publisher: 'mlx-community', repo: 'mlx-community/Qwen3.8-27B-4bit', drafter: '' },
  'gemma-4-12b': { base: 'Gemma-4-12B', quant: 'Q4_K_XL', publisher: 'unsloth', repo: 'unsloth/gemma-4-12b-it-GGUF', drafter: '' },
  'google/gemma-4-12b': { base: 'Gemma-4-12B', quant: '4-bit', publisher: 'lmstudio-community', repo: 'lmstudio-community/gemma-4-12B-it-MLX-4bit', drafter: '' },
  'Gemma-4-12B (low)': { base: 'Gemma-4-12B', quant: '4-bit', publisher: 'lmstudio-community', repo: 'lmstudio-community/gemma-4-12B-it-MLX-4bit', drafter: '' },
  'Gemma-4-12B (llama.cpp, off)': { base: 'Gemma-4-12B', quant: 'Q4_K_XL', publisher: 'unsloth', repo: 'unsloth/gemma-4-12b-it-GGUF', drafter: '' },
  'bonsai-prism': { base: 'Ternary-Bonsai-27B', quant: 'Q2_g64', publisher: 'prism-ml', repo: 'prism-ml/Ternary-Bonsai-27B-gguf', drafter: '', server: 'prism-llama', kv: 'q4_0+bias', binary: true },
  'bonsai-prism (f16 KV)': { base: 'Ternary-Bonsai-27B', quant: 'Q2_g64', publisher: 'prism-ml', repo: 'prism-ml/Ternary-Bonsai-27B-gguf', drafter: '', server: 'prism-llama', binary: true },
  'qwen3.8-27b': { base: 'Qwen3.8-27B', quant: 'Q4_K_M', publisher: 'bartowski', repo: 'bartowski/Qwen3.8-27B-GGUF', drafter: 'mtp/3' },
  'qwen3.8-27b (reserve 8192)': { base: 'Qwen3.8-27B', quant: 'Q4_K_M', publisher: 'bartowski', repo: 'bartowski/Qwen3.8-27B-GGUF', drafter: 'mtp/3' },
  'qwen3.8-27b (bartowski Q4_K_M, xhigh)': { base: 'Qwen3.8-27B', quant: 'Q4_K_M', publisher: 'bartowski', repo: 'bartowski/Qwen3.8-27B-GGUF', drafter: 'mtp/3' },
  'qwen3.8-27b (ISTA IQ3_S-mtp)': { base: 'Qwen3.8-27B', quant: 'IQ3_S-mtp', publisher: 'ISTA-DASLab', repo: 'ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF', drafter: 'mtp/3' },
  'qwen3.8-27b (ISTA IQ3_S-mtp, xhigh)': { base: 'Qwen3.8-27B', quant: 'IQ3_S-mtp', publisher: 'ISTA-DASLab', repo: 'ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF', drafter: '' },
  'qwen3.8-27b (ISTA IQ3_S-mtp, low)': { base: 'Qwen3.8-27B', quant: 'IQ3_S-mtp', publisher: 'ISTA-DASLab', repo: 'ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF', drafter: '' },
  'qwen3.8-27b (AtomicChat AD-IQ3_S)': { base: 'Qwen3.8-27B', quant: 'AD-IQ3_S', publisher: 'AtomicChat', repo: 'AtomicChat/Qwen3.8-27B-GGUF', drafter: 'mtp/3' },
}

const MENDEL_SERVER = { 'llama-server': 'llama-server', 'mlx_lm.server': 'mlx_lm.server', 'lm-studio': 'lms' }

function mendelSpec(r) {
  const m = MENDEL_SPECS[r.model]
  if (!m) throw new Error(`Mendel row "${r.model}" has no entry in MENDEL_SPECS`)
  const level = thinkingLevel(r.branch)
  return {
    base: m.base,
    quant: m.quant,
    server: m.server || MENDEL_SERVER[r.serving] || r.serving,
    publisher: m.publisher,
    drafter: m.drafter,
    repo: m.repo,
    kv: m.kv || (r.kv_type === 'unquantized' || !r.kv_type ? 'f16' : r.kv_type),
    effort: level === 'default' ? m.effort : m.binary ? (level === 'off' ? 'off' : 'on') : level,
  }
}

function mendelCell(r) {
  const slug = MENDEL_SLUGS[r.model]
  const tag = specTag(mendelSpec(r), { label: r.model })
  return slug ? `[${tag}](../reports/${slug}.md)` : tag
}

function mendelScore(r) {
  const done = r.libraries_done === '' ? 8 : Number(r.libraries_done)
  const cap = Math.min(Number(r.score_total), (100 * done) / 8)
  return `**${cap}/100**${r.partial === 'True' ? ' (partial)' : ''}`
}

function currentPromptVersion(rows) {
  const num = (v) => String(v || 'v0').replace(/^v/, '').split('.').reduce((a, p) => a * 1000 + Number(p), 0)
  const latest = rows.map((r) => r.prompt_version).sort((a, b) => num(a) - num(b)).at(-1)
  return rows.filter((r) => r.prompt_version === latest)
}

function renderMendelLocal(rows) {
  const header = [
    '| config | score | worst defect |',
    '|---|--:|---|',
  ]
  const sev = (d) => (d.match(/^(critical|medium|minor)/) || [])[1] || (d ? 'see report' : 'none found')
  const body = rows
    .filter((r) => r.local === 'True')
    .sort((a, b) => Math.min(b.score_total, (100 * (b.libraries_done === '' ? 8 : b.libraries_done)) / 8) - Math.min(a.score_total, (100 * (a.libraries_done === '' ? 8 : a.libraries_done)) / 8))
    .map((r) => `| ${mendelCell(r)} | ${mendelScore(r)} | ${sev(r.defects)} |`)
  return [...header, ...body].join('\n')
}

function renderMendelCloud(rows) {
  const header = ['| model | harness | score |', '|---|---|--:|']
  const body = rows
    .filter((r) => r.local !== 'True')
    .sort((a, b) => Math.min(b.score_total, (100 * (b.libraries_done === '' ? 8 : b.libraries_done)) / 8) - Math.min(a.score_total, (100 * (a.libraries_done === '' ? 8 : a.libraries_done)) / 8))
    .map((r) => `| ${mendelName(r)} | ${r.harness} | ${mendelScore(r)} |`)
  return [...header, ...body].join('\n')
}

function renderMendelGuided(rows) {
  const header = ['| config | harness | score |', '|---|---|--:|']
  const body = rows
    .sort((a, b) => Math.min(b.score_total, (100 * (b.libraries_done === '' ? 8 : b.libraries_done)) / 8) - Math.min(a.score_total, (100 * (a.libraries_done === '' ? 8 : a.libraries_done)) / 8))
    .map((r) => `| ${r.local === 'True' ? mendelCell(r) : mendelName(r)} | ${r.harness} | ${mendelScore(r)} |`)
  return [...header, ...body].join('\n')
}

function thinkingLevel(branch) {
  const m = String(branch).match(/-(xhigh|high|medium|low|off)-/)
  return m ? m[1] : 'default'
}

function renderModelMendel(slug, blindRows, guidedRows, untrusted = []) {
  const distrust = (r) => untrusted.find((u) =>
    (!u.serving || u.serving === r.serving) && (!u.branch || new RegExp(u.branch).test(r.branch)))
  const tagged = [
    ...blindRows.map((r) => ({ r, test: 'blind' })),
    ...guidedRows.map((r) => ({ r, test: 'guided' })),
  ].filter(({ r }) => MENDEL_SLUGS[r.model] === slug)
  if (!tagged.length) return 'No Mendel run yet.'

  const capped = (r) => {
    const done = r.libraries_done === '' ? 8 : Number(r.libraries_done)
    return Math.min(Number(r.score_total), (100 * done) / 8)
  }
  tagged.sort((a, b) => capped(b.r) - capped(a.r))

  const esc = (v) => String(v ?? '').replace(/\|/g, '\\|')
  const thousands = (v) => {
    const n = Number(v)
    if (!Number.isFinite(n) || v === '') return '—'
    return `${Math.round(n / 1000).toLocaleString('en-US')}k`
  }
  const ladder = [26624, 32768, 49152, 57344, 65536, 81920, 98304, 114688, 131072, 147456, 163840, 212992, 262144]
  const config = (r) => {
    const peak = Number(r['telemetry.peak_context'])
    const pct = Number(r['telemetry.window_pct'])
    const est = peak > 0 && pct > 0 ? (peak / pct) * 100 : 0
    const snapped = est ? ladder.reduce((a, b) => (Math.abs(b - est) < Math.abs(a - est) ? b : a)) : 0
    return snapped ? `${Math.round(snapped / 1024)}k` : '?k'
  }
  const header = [
    '| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |',
    '|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|',
  ]
  const line = ({ r, test }) => {
    const done = r.libraries_done === '' ? 8 : Number(r.libraries_done)
    const cap = capped(r)
    const raw = Number(r.score_total)
    const score = cap < raw ? `**${cap}** (raw ${raw})` : `**${cap}**`
    const minutes = r['telemetry.wall_clock_min'] === '' ? '—' : Number(r['telemetry.wall_clock_min']).toFixed(1)
    const state = r.invalid === 'True' ? 'invalid' : r.partial === 'True' ? 'partial' : 'done'
    const loop = r['telemetry.loop_flag'] === 'LOOP' ? esc(r['telemetry.loop_kind'] || 'yes') : ''
    return `| ${[
      specTag(mendelSpec(r), { label: r.model }) + (distrust(r) ? ` ${distrust(r).marker || '†'}` : ''),
      `${test}-${esc(r.prompt_version)}`,
      config(r),
      score,
      `${done}/8/${state}`,
      minutes,
      thousands(r['telemetry.tokens_total']),
      thousands(r['telemetry.peak_context']),
      esc(r['telemetry.compactions'] || '0'),
      esc(r['telemetry.tool_calls'] || '0'),
      esc(r['telemetry.commits'] || '0'),
      loop,
    ].join(' | ')} |`
  }
  const blind = tagged.filter((t) => t.test === 'blind').map(line)
  const guided = tagged.filter((t) => t.test === 'guided').map(line)
  const parts = []
  if (blind.length) parts.push('Blind test:', '', ...header, ...blind)
  if (guided.length) parts.push(...(blind.length ? [''] : []), 'Guided test:', '', ...header, ...guided)
  const used = untrusted.filter((u) => tagged.some(({ r }) => distrust(r) === u))
  const kvNote = [
    '',
    'The window cell is the harness context window of that run. Rows before the KV pick of 2026-09-04 carry the type their runbook served, or `q8_0` where no record names one.',
  ]
  const legend = used.length
    ? [
        '',
        ...used.map((u) =>
          `${u.marker || '†'} ${u.reason}${u.page ? ` [${u.linkText || 'Why this runtime is not a candidate'}](${u.page}).` : ''}`,
        ),
      ]
    : []
  return [...parts, ...kvNote, ...legend].join('\n')
}

function parseCtx(s) {
  const nxk = s.match(/(\d+)x([\d.]+)k/i)
  if (nxk) return parseFloat(nxk[2]) * 1000
  const k = s.match(/([\d.]+)k/i)
  if (k) return parseFloat(k[1]) * 1000
  return parseFloat(s) || 0
}

function parseScore(evalplus) {
  const m = evalplus.match(/^([\d.]+)/)
  return m ? parseFloat(m[1]) : -1
}

function parseMendel(mendel) {
  if (mendel === 'failed-smoke') return 0
  const m = String(mendel ?? '').match(/^([\d.]+)/)
  return m ? parseFloat(m[1]) : null
}

function hasTok(r) {
  return !['tokShallow', 'tokDeep'].some((k) => String(r[k]).includes('pending'))
}

function completeness(r) {
  const parts = [hasTok(r), parseScore(r.evalplus) >= 0, parseMendel(r.mendel) !== null]
  return parts.filter(Boolean).length / parts.length
}

function isComplete(r) {
  return completeness(r) === 1
}

function composite(r) {
  const e = parseScore(r.evalplus)
  const m = parseMendel(r.mendel)
  if (e < 0 || m === null) return null
  return (e * 100 + m) / 2
}

function sortRows(rows) {
  return [...rows].sort((a, b) => {
    const ca = composite(a)
    const cb = composite(b)
    if (ca !== null && cb !== null && ca !== cb) return cb - ca
    if ((ca === null) !== (cb === null)) return ca === null ? 1 : -1
    const scoreDiff = parseScore(b.evalplus) - parseScore(a.evalplus)
    if (scoreDiff !== 0) return scoreDiff
    return parseCtx(b.maxCtx) - parseCtx(a.maxCtx)
  })
}

const GATED_BY = new Set(['mem', 'speed'])

function checkRows(rows, setup) {
  for (const r of rows) {
    if (r.retired) continue
    if (!GATED_BY.has(r.gatedBy)) {
      throw new Error(`${setup}: row ${r.id} has gatedBy "${r.gatedBy}"; allowed: ${[...GATED_BY].join(', ')}`)
    }
    if (typeof r.mendel !== 'string' || !r.mendel) {
      throw new Error(`${setup}: row ${r.id} has no mendel cell; write "pending", "not run" or "invalid"`)
    }
  }
}

function hasPending(r) {
  return !isComplete(r)
}

// Bold marks the best two of a column, and any further row within 15
// percent of the column's span (best minus worst) of the second-best
// value. Memory reads lower as better.
function topSet(rows, read, { lower = false } = {}) {
  const vals = rows.map((r) => read(r)).map((v) => (Number.isFinite(v) ? v : null))
  const ranked = [...new Set(vals.filter((v) => v !== null))].sort((x, y) => (lower ? x - y : y - x))
  if (!ranked.length) return new Set()
  const second = ranked[Math.min(1, ranked.length - 1)]
  const span = Math.abs(ranked[0] - ranked[ranked.length - 1])
  const near = (v) => Math.abs(v - second) <= 0.15 * span && (lower ? v > second : v < second)
  return new Set(rows.filter((r, i) => vals[i] !== null && (vals[i] === ranked[0] || vals[i] === second || near(vals[i]))))
}

function renderTable(rows, { footnotes = true, sort = true, start = 0, memory = true } = {}) {
  const header = [
    `| Model / Config | Ctx | Cap | tok/s |${memory ? ' Memory<br>(at max ctx) |' : ''} EvalPlus | Coding |`,
    `|---|--:|:--:|--:|${memory ? '--:|' : ''}--:|--:|`,
  ]
  const ordered = sort ? sortRows(rows) : rows
  const num = (s) => parseFloat(String(s).replace(/[^\d.]/g, ''))
  const top = {
    maxCtx: topSet(ordered, (r) => parseCtx(r.maxCtx)),
    tokShallow: topSet(ordered, (r) => num(r.tokShallow)),
    tokDeep: topSet(ordered, (r) => num(r.tokDeep)),
    memory: topSet(ordered, (r) => num(r.memory), { lower: true }),
    evalplus: topSet(ordered, (r) => parseScore(r.evalplus) >= 0 ? parseScore(r.evalplus) : NaN),
    mendel: topSet(ordered, (r) => (r.mendel === 'failed-smoke' ? NaN : parseMendel(r.mendel) ?? NaN)),
    composite: topSet(ordered, (r) => (r.mendel === 'failed-smoke' ? NaN : composite(r) ?? NaN)),
  }
  let anyStale = false
  const cell = (r, field) => {
    const stale = (r.stale || []).includes(field)
    if (stale) anyStale = true
    const value = `${r[field]}${stale ? '†' : ''}`
    const bold = top[field]?.has(r) ? `**${value}**` : value
    return r.abandoned ? `*${bold}*` : bold
  }
  const body = ordered.map((r, i) => {
    const tokStale = ['tokShallow', 'tokDeep'].some((f) => (r.stale || []).includes(f))
    if (tokStale) anyStale = true
    const tok = r.abandoned
      ? `*${cell(r, 'tokShallow')} → ${cell(r, 'tokDeep')}*`
      : `<TokCell shallow="${r.tokShallow}" deep="${r.tokDeep}"${tokStale ? ' stale' : ''}${top.tokShallow.has(r) ? ' top-shallow' : ''}${top.tokDeep.has(r) ? ' top-deep' : ''} />`
    const spec = specTag(r.spec, { label: r.id, repo: repoOf(r), top: top.composite.has(r) })
    const config = r.abandoned ? `${spec} ${r.abandoned.marker || '💀'}` : spec
    const ev = evalplusCell(r.evalplus)
    const md = mendelCellParts(r)
    const stale = (f) => ((r.stale || []).includes(f) ? '†' : '')
    return `| ${config} | ${cell(r, 'maxCtx')} | ${cell(r, 'gatedBy')} | ${tok} |${memory ? ` ${cell(r, 'memory')} |` : ''} ${scoreTag(ev.value + stale('evalplus'), ev.sub, top.evalplus.has(r))} | ${scoreTag(md.value + stale('mendel'), '', top.mendel.has(r), md.pill, md.note)} |`
  })
  const legend = anyStale
    ? ['', '† from an earlier serving config or method; re-run pending.']
    : []
  const seenPages = new Set()
  for (const r of ordered) {
    if (!r.abandoned || seenPages.has(r.abandoned.page)) continue
    seenPages.add(r.abandoned.page)
    legend.push(
      '',
      `${r.abandoned.marker || '💀'} ${r.abandoned.reason} [Why it is not a candidate](${r.abandoned.page}).`,
    )
  }
  return [...header, ...body, ...legend].join('\n')
}

function majorName(config) {
  return config.split(',')[0].trim()
}

function buildName(config) {
  return config.split(',').slice(0, 2).map((s) => s.trim()).join(', ')
}

function renderHomeTable(data) {
  const seen = []
  const groups = new Map()
  for (const r of data.rows) {
    const name = buildName(r.config)
    if (!groups.has(name)) {
      groups.set(name, [])
      seen.push(name)
    }
    groups.get(name).push(r)
  }
  const best = seen.map((name) => {
    const rows = groups.get(name)
    const complete = rows.filter((r) => !hasPending(r))
    const pick = sortRows(complete.length ? complete : rows)[0]
    const rest = pick.config.split(',').slice(2).map((s) => s.trim()).join(', ')
    return { ...pick, config: rest ? `${name}, ${rest}` : name }
  })
  return renderTable(best, { memory: false })
}

function applyBlock(content, startMark, endMark, block, target) {
  const startIdx = content.indexOf(startMark)
  const endIdx = content.indexOf(endMark)
  if (startIdx === -1 || endIdx === -1 || endIdx < startIdx) {
    throw new Error(`missing or malformed ${startMark} / ${endMark} markers in ${target}`)
  }
  const before = content.slice(0, startIdx + startMark.length)
  const after = content.slice(endIdx)
  return `${before}\n${block}\n${after}`
}

function applyTable(content, table) {
  return applyBlock(content, START, END, table, 'comparison target')
}

function renderKpis(model) {
  const tiles = model.kpis.map((name) => {
    const stat = model.stats[name]
    if (!stat) throw new Error(`kpi "${name}" has no entry in stats`)
    const limit = (field, max) => {
      const text = String(stat[field] || '')
      if (text.length > max) throw new Error(`kpi "${name}": ${field} is ${text.length} characters, the limit is ${max}: "${text}"`)
      if (/[;—]/.test(text)) throw new Error(`kpi "${name}": ${field} reads as an explanation, not a qualifier: "${text}"`)
    }
    limit('value', 22)
    limit('label', 44)
    limit('sub', 44)
    const sub = stat.sub ? `<small>${stat.sub}</small>` : ''
    return `  <div class="kpi"><b>${stat.value}</b><span>${stat.label}</span>${sub}</div>`
  })
  return ['<div class="kpis">', ...tiles, '</div>'].join('\n')
}

function modelRows(data, model) {
  const rows = data.rows.filter(
    (r) => r.config.startsWith(model.rowMatch) && !r.hidden && !r.retired,
  )
  const extra = (model.extraRows || []).filter((r) => !r.hidden && !r.retired)
  const sorted = sortRows([...rows, ...extra])
  return [...sorted.filter(isComplete), ...sorted.filter((r) => !isComplete(r))]
}

function retiredRows(data, model) {
  const rows = data.rows.filter((r) => r.config.startsWith(model.rowMatch) && r.retired)
  const extra = (model.extraRows || []).filter((r) => r.retired)
  return [...rows, ...extra]
}

function renderModelTable(data, model) {
  const rows = modelRows(data, model)
  const complete = rows.filter(isComplete)
  const rest = rows.filter((r) => !isComplete(r))
  const parts = []
  if (complete.length) parts.push(renderTable(complete, { footnotes: false, sort: false }))
  if (rest.length) {
    if (complete.length) parts.push('', PARTIAL_NOTE, '')
    parts.push(renderTable(rest, { footnotes: false, sort: false, start: complete.length }))
  }
  const lines = retiredRows(data, model).map(
    (r) => `Retired entries: ${r.config} — ${r.retired.reason} ([details](${r.retired.details})).`,
  )
  return lines.length ? [...parts, '', ...lines].join('\n') : parts.join('\n')
}

function renderModelConfigs(data, model) {
  const blocks = modelRows(data, model).map((r) => {
    const spec = specTag(r.spec, { label: r.id, repo: repoOf(r) })
    return [spec, '', ...(r.note ? [r.note, ''] : []), '```bash', r.command, '```'].join('\n')
  })
  return blocks.join('\n\n')
}

function renderEvalplusTable(data) {
  const header = [
    '| config | budget | pass@1 base | pass@1 plus | empty | completion |',
    '|---|--:|--:|--:|--:|--:|',
  ]
  const completion = (empty) => {
    const m = /^(\d+)\/(\d+)$/.exec(empty || '')
    return m ? `${Math.round(((m[2] - m[1]) / m[2]) * 100)}%` : '—'
  }
  const runs = data.evalplusRuns || []
  const specOf = (r) => {
    if (r.spec) return specTag(r.spec, { label: r.model })
    const row = data.rows.find((x) => x.id === r.row)
    if (!row) throw new Error(`EvalPlus run "${r.model}" names no row and no spec`)
    return specTag(row.spec, { label: row.id, repo: repoOf(row) })
  }
  const top = topSet(runs, (r) => parseFloat(r.base))
  const body = runs.map((r) => {
    if (!r.budget) throw new Error(`EvalPlus run "${r.model}" has no budget`)
    return `| [${specOf(r)}](./${r.slug}.md) | ${r.budget} | ${top.has(r) ? `**${r.base}**` : r.base} | ${r.plus} | ${r.empty} | ${completion(r.empty)} |`
  })
  return [...header, ...body].join('\n')
}

function renderDecodeSummary(data) {
  const header = [
    '| best curve | tok/s (shallow → deep) | at | gated by |',
    '|---|--:|--:|---|',
  ]
  let anyStale = false
  const cell = (r, field) => {
    const stale = (r.stale || []).includes(field)
    if (stale) anyStale = true
    return `${r[field]}${stale ? '†' : ''}`
  }
  const body = Object.entries(data.models || {}).flatMap(([slug, model]) => {
    const backends = new Map()
    for (const r of modelRows(data, model).filter((r) => !r.abandoned)) {
      const backend = (r.config.split(',')[1] || '').trim().replace(/[^A-Za-z].*$/, '') || 'other'
      if (!backends.has(backend)) backends.set(backend, [])
      backends.get(backend).push(r)
    }
    return [...backends.values()].map((rows) => {
      const complete = rows.filter((r) => !hasPending(r))
      const pick = sortRows(complete.length ? complete : rows)[0]
      return `| [${specTag(pick.spec, { label: pick.id, repo: repoOf(pick) })}](./${slug}.md) | ${cell(pick, 'tokShallow')} → ${cell(pick, 'tokDeep')} | ${cell(pick, 'maxCtx')} | ${cell(pick, 'gatedBy')} |`
    })
  })
  const legend = anyStale
    ? ['', '† from an earlier serving config or method; re-run pending.']
    : []
  return [...header, ...body, ...legend].join('\n')
}

const dataFiles = globSync('docs/setups/*/models.json')
let drift = false

for (const dataFile of dataFiles) {
  const setupDir = dataFile.replace(/\/models\.json$/, '')
  const data = JSON.parse(readFileSync(dataFile, 'utf8'))
  checkRows(data.rows, data.setup)
  const mendelBlindAll = parseCsv(readFileSync('benchmarks/mendel/results.csv', 'utf8'))
  const mendelGuidedAll = parseCsv(readFileSync('benchmarks/mendel/results-guided.csv', 'utf8'))
  const mendelBlind = currentPromptVersion(mendelBlindAll.filter((r) => r.invalid !== 'True'))
  const mendelGuided = currentPromptVersion(mendelGuidedAll.filter((r) => r.invalid !== 'True'))
  deriveMendel(data.rows, mendelBlind, mendelGuided)
  // An abandoned row keeps its numbers on the model page only: the comparison
  // and the home table answer "what should I run", and it is not a candidate.
  const visible = data.rows.filter((r) => !r.hidden && !r.retired && !r.abandoned)
  const completeRows = visible.filter(isComplete)
  const partialRows = sortRows(visible.filter((r) => !isComplete(r) && completeness(r) >= 0.4))
  const comparisonTable = renderTable(completeRows, { memory: false })
  const partialTable = renderTable(partialRows, { sort: false, start: completeRows.length, memory: false })
  const homeTable = renderHomeTable({ ...data, rows: visible })

  const targets = [
    [`${setupDir}/comparison.md`, comparisonTable, [PARTIAL_START, PARTIAL_END, partialTable]],
    ['docs/index.md', homeTable],
  ]

  for (const [target, table, partial] of targets) {
    const original = readFileSync(target, 'utf8')
    let updated = applyTable(original, table)
    if (partial) updated = applyBlock(updated, partial[0], partial[1], partial[2], target)
    if (updated === original) continue
    if (CHECK) {
      console.error(`STALE: ${target} does not match ${dataFile}. Run \`npm run docs:tables\`.`)
      drift = true
    } else {
      writeFileSync(target, updated)
      console.log(`updated: ${target}`)
    }
  }

  const typePages = [
    [`${setupDir}/benchmarks/evalplus.md`, EVALPLUS_START, EVALPLUS_END, renderEvalplusTable(data)],
    [`${setupDir}/benchmarks/decode-speed.md`, DECODE_START, DECODE_END, renderDecodeSummary(data)],
    [`${setupDir}/benchmarks/mendel.md`, MENDEL_LOCAL_START, MENDEL_LOCAL_END, renderMendelLocal(mendelBlind)],
    [`${setupDir}/benchmarks/mendel.md`, MENDEL_CLOUD_START, MENDEL_CLOUD_END, renderMendelCloud(mendelBlind)],
    [`${setupDir}/benchmarks/mendel.md`, MENDEL_GUIDED_START, MENDEL_GUIDED_END, renderMendelGuided(mendelGuided)],
  ]
  for (const [target, mstart, mend, block] of typePages) {
    const original = readFileSync(target, 'utf8')
    const updated = applyBlock(original, mstart, mend, block, target)
    if (updated === original) continue
    if (CHECK) {
      console.error('STALE: ' + target + ' does not match ' + dataFile + '. Run `npm run docs:tables`.')
      drift = true
    } else {
      writeFileSync(target, updated)
      console.log(`updated: ${target}`)
    }
  }

  for (const [slug, model] of Object.entries(data.models || {})) {
    const target = `${setupDir}/reports/${slug}.md`
    const original = readFileSync(target, 'utf8')
    let updated = applyBlock(original, KPI_START, KPI_END, renderKpis(model), target)
    updated = applyBlock(updated, MODEL_START, MODEL_END, renderModelTable(data, model), target)
    updated = applyBlock(updated, CONFIGS_START, CONFIGS_END, renderModelConfigs(data, model), target)
    updated = applyBlock(updated, MODEL_MENDEL_START, MODEL_MENDEL_END, renderModelMendel(slug, mendelBlindAll, mendelGuidedAll, model.mendelUntrusted), target)
    if (updated === original) continue
    if (CHECK) {
      console.error(`STALE: ${target} does not match ${dataFile}. Run \`npm run docs:tables\`.`)
      drift = true
    } else {
      writeFileSync(target, updated)
      console.log(`updated: ${target}`)
    }
  }
}

if (CHECK && drift) process.exit(1)
if (!CHECK) console.log('tables generated from docs/setups/*/models.json')
