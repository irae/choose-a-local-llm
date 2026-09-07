import { readFileSync, writeFileSync } from 'node:fs'
import { globSync } from 'node:fs'

const CHECK = process.argv.includes('--check')

const START = '<!-- gen:models-evaluated:start -->'
const END = '<!-- gen:models-evaluated:end -->'
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
  'qwen3.8-27b': 'qwen3.8-27b',
}

function mendelName(r) {
  const slug = MENDEL_SLUGS[r.model]
  const short = r.model.replace(/^.*\//, '')
  return slug ? `[${short}](../reports/${slug}.md)` : short
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
    '| model | serving | score | worst defect |',
    '|---|---|--:|---|',
  ]
  const sev = (d) => (d.match(/^(critical|medium|minor)/) || [])[1] || (d ? 'see report' : 'none found')
  const body = rows
    .filter((r) => r.local === 'True')
    .sort((a, b) => Math.min(b.score_total, (100 * (b.libraries_done === '' ? 8 : b.libraries_done)) / 8) - Math.min(a.score_total, (100 * (a.libraries_done === '' ? 8 : a.libraries_done)) / 8))
    .map((r) => `| ${mendelName(r)} | ${r.serving} | ${mendelScore(r)} | ${sev(r.defects)} |`)
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
  const header = ['| model | harness | score |', '|---|---|--:|']
  const body = rows
    .sort((a, b) => Math.min(b.score_total, (100 * (b.libraries_done === '' ? 8 : b.libraries_done)) / 8) - Math.min(a.score_total, (100 * (a.libraries_done === '' ? 8 : a.libraries_done)) / 8))
    .map((r) => `| ${mendelName(r)} | ${r.harness} | ${mendelScore(r)} |`)
  return [...header, ...body].join('\n')
}

function thinkingLevel(branch) {
  const m = String(branch).match(/-(xhigh|high|medium|low|off)-/)
  return m ? m[1] : 'default'
}

const SERVING_SHORT = { 'llama-server': 'llama', 'mlx_lm.server': 'mlx', 'lm-studio': 'lmstudio' }

function renderModelMendel(slug, blindRows, guidedRows) {
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
  const ladder = [26624, 32768, 49152, 57344, 65536, 81920, 98304, 131072, 163840, 212992, 262144]
  const config = (r) => {
    const peak = Number(r['telemetry.peak_context'])
    const pct = Number(r['telemetry.window_pct'])
    const est = peak > 0 && pct > 0 ? (peak / pct) * 100 : 0
    const snapped = est ? ladder.reduce((a, b) => (Math.abs(b - est) < Math.abs(a - est) ? b : a)) : 0
    const window = snapped ? `${Math.round(snapped / 1024)}k` : '?k'
    return `${SERVING_SHORT[r.serving] || esc(r.serving)}-${thinkingLevel(r.branch)}-ctx.${window}`
  }
  const header = [
    '| test | config | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |',
    '|---|---|--:|---|--:|--:|--:|--:|--:|--:|---|',
  ]
  const body = tagged.map(({ r, test }) => {
    const done = r.libraries_done === '' ? 8 : Number(r.libraries_done)
    const cap = capped(r)
    const raw = Number(r.score_total)
    const score = cap < raw ? `**${cap}** (raw ${raw})` : `**${cap}**`
    const minutes = r['telemetry.wall_clock_min'] === '' ? '—' : Number(r['telemetry.wall_clock_min']).toFixed(1)
    const state = r.invalid === 'True' ? 'invalid' : r.partial === 'True' ? 'partial' : 'done'
    const loop = r['telemetry.loop_flag'] === 'LOOP' ? esc(r['telemetry.loop_kind'] || 'yes') : ''
    return [
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
    ].join(' | ')
  }).map((line) => `| ${line} |`)
  return [...header, ...body].join('\n')
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

function sortRows(rows) {
  return [...rows].sort((a, b) => {
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
  }
}

function hasPending(r) {
  return ['maxCtx', 'gatedBy', 'tokShallow', 'tokDeep', 'memory', 'evalplus'].some(
    (k) => String(r[k]).includes('pending'),
  )
}

function renderTable(rows, { footnotes = true, sort = true } = {}) {
  const header = [
    footnotes
      ? '| # | Config | Max ctx | Gated by¹ | tok/s<br>(shallow → deep) | Memory<br>(at max ctx) | EvalPlus² |'
      : '| # | Config | Max ctx | Gated by | tok/s<br>(shallow → deep) | Memory<br>(at max ctx) | EvalPlus |',
    '|--:|---|--:|:--:|--:|--:|--:|',
  ]
  const ordered = sort ? sortRows(rows) : rows
  let anyStale = false
  const cell = (r, field) => {
    const stale = (r.stale || []).includes(field)
    if (stale) anyStale = true
    return `${r[field]}${stale ? '†' : ''}`
  }
  const body = ordered.map((r, i) => {
    const tok = `${cell(r, 'tokShallow')} → ${cell(r, 'tokDeep')}`
    return `| ${i + 1} | ${r.config} | ${cell(r, 'maxCtx')} | ${cell(r, 'gatedBy')} | ${tok} | ${cell(r, 'memory')} | ${cell(r, 'evalplus')} |`
  })
  const legend = anyStale
    ? ['', '† from an earlier serving config or method; re-run pending.']
    : []
  return [...header, ...body, ...legend].join('\n')
}

function majorName(config) {
  return config.split(',')[0].trim()
}

function renderHomeTable(data) {
  const seen = []
  const groups = new Map()
  for (const r of data.rows) {
    const name = majorName(r.config)
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
    return { ...pick, config: name }
  })
  return renderTable(best)
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
    return `  <div class="kpi"><b>${stat.value}</b><span>${stat.label}</span></div>`
  })
  return ['<div class="kpis">', ...tiles, '</div>'].join('\n')
}

function modelRows(data, model) {
  const rows = data.rows.filter(
    (r) => r.config.startsWith(model.rowMatch) && !r.hidden && !r.retired,
  )
  const extra = (model.extraRows || []).filter((r) => !r.hidden && !r.retired)
  return [...rows, ...extra]
}

function retiredRows(data, model) {
  const rows = data.rows.filter((r) => r.config.startsWith(model.rowMatch) && r.retired)
  const extra = (model.extraRows || []).filter((r) => r.retired)
  return [...rows, ...extra]
}

function renderModelTable(data, model) {
  const table = renderTable(modelRows(data, model), { footnotes: false, sort: false })
  const lines = retiredRows(data, model).map(
    (r) => `Retired entries: ${r.config} — ${r.retired.reason} ([details](${r.retired.details})).`,
  )
  return lines.length ? [table, '', ...lines].join('\n') : table
}

function renderModelConfigs(data, model) {
  const blocks = modelRows(data, model).map((r, i) => {
    const note = r.note ? ` ${r.note}` : ''
    return ['**#' + (i + 1) + ' — ' + r.config + '.**' + note, '', '```bash', r.command, '```'].join('\n')
  })
  return blocks.join('\n\n')
}

function renderEvalplusTable(data) {
  const header = [
    '| model | mode | pass@1 base | pass@1 plus | empty | completion |',
    '|---|---|--:|--:|--:|--:|',
  ]
  const completion = (empty) => {
    const m = /^(\d+)\/(\d+)$/.exec(empty || '')
    return m ? `${Math.round(((m[2] - m[1]) / m[2]) * 100)}%` : '—'
  }
  const body = (data.evalplusRuns || []).map(
    (r) => `| [${r.model}](./${r.slug}.md) | ${r.mode} | ${r.base} | ${r.plus} | ${r.empty} | ${completion(r.empty)} |`,
  )
  return [...header, ...body].join('\n')
}

function renderDecodeSummary(data) {
  const header = [
    '| model | best curve | tok/s (shallow → deep) | at | gated by |',
    '|---|---|--:|--:|---|',
  ]
  let anyStale = false
  const cell = (r, field) => {
    const stale = (r.stale || []).includes(field)
    if (stale) anyStale = true
    return `${r[field]}${stale ? '†' : ''}`
  }
  const body = Object.entries(data.models || {}).flatMap(([slug, model]) => {
    const backends = new Map()
    for (const r of modelRows(data, model)) {
      const backend = (r.config.split(',')[1] || '').trim().replace(/[^A-Za-z].*$/, '') || 'other'
      if (!backends.has(backend)) backends.set(backend, [])
      backends.get(backend).push(r)
    }
    return [...backends.values()].map((rows) => {
      const complete = rows.filter((r) => !hasPending(r))
      const pick = sortRows(complete.length ? complete : rows)[0]
      const detail = pick.config.split(',').slice(1).join(',').trim() || '—'
      return `| [${majorName(pick.config)}](./${slug}.md) | ${detail} | ${cell(pick, 'tokShallow')} → ${cell(pick, 'tokDeep')} | ${cell(pick, 'maxCtx')} | ${cell(pick, 'gatedBy')} |`
    })
  })
  const legend = anyStale
    ? ['', '† from an earlier serving config or method; re-run pending.']
    : []
  return [...header, ...body, ...legend].join('\n')
}

function checkRefs(content, count, target) {
  for (const m of content.matchAll(/#(\d+)/g)) {
    const n = parseInt(m[1], 10)
    if (n > count) {
      throw new Error(`${target}: reference #${n} exceeds the ${count} visible config rows`)
    }
  }
}

const dataFiles = globSync('docs/setups/*/models.json')
let drift = false

for (const dataFile of dataFiles) {
  const setupDir = dataFile.replace(/\/models\.json$/, '')
  const data = JSON.parse(readFileSync(dataFile, 'utf8'))
  checkRows(data.rows, data.setup)
  const visible = data.rows.filter((r) => !r.hidden && !r.retired)
  const comparisonTable = renderTable(visible.filter((r) => !hasPending(r)))
  const homeTable = renderHomeTable({ ...data, rows: visible })

  const targets = [
    [`${setupDir}/comparison.md`, comparisonTable],
    ['docs/index.md', homeTable],
  ]

  for (const [target, table] of targets) {
    const original = readFileSync(target, 'utf8')
    const updated = applyTable(original, table)
    if (updated === original) continue
    if (CHECK) {
      console.error(`STALE: ${target} does not match ${dataFile}. Run \`npm run docs:tables\`.`)
      drift = true
    } else {
      writeFileSync(target, updated)
      console.log(`updated: ${target}`)
    }
  }

  const mendelBlindAll = parseCsv(readFileSync('benchmarks/mendel/results.csv', 'utf8'))
  const mendelGuidedAll = parseCsv(readFileSync('benchmarks/mendel/results-guided.csv', 'utf8'))
  const mendelBlind = currentPromptVersion(mendelBlindAll.filter((r) => r.invalid !== 'True'))
  const mendelGuided = currentPromptVersion(mendelGuidedAll.filter((r) => r.invalid !== 'True'))
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
    updated = applyBlock(updated, MODEL_MENDEL_START, MODEL_MENDEL_END, renderModelMendel(slug, mendelBlindAll, mendelGuidedAll), target)
    checkRefs(updated, modelRows(data, model).length, target)
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
