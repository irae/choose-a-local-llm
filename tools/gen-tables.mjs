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
  const rows = data.rows.filter((r) => r.config.startsWith(model.rowMatch) && !r.hidden)
  const extra = (model.extraRows || []).filter((r) => !r.hidden)
  return [...rows, ...extra]
}

function renderModelTable(data, model) {
  return renderTable(modelRows(data, model), { footnotes: false, sort: false })
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
    '| model | mode | pass@1 base | pass@1 plus | empty |',
    '|---|---|--:|--:|--:|',
  ]
  const body = (data.evalplusRuns || []).map(
    (r) => `| [${r.model}](./${r.slug}.md) | ${r.mode} | ${r.base} | ${r.plus} | ${r.empty} |`,
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
  const visible = data.rows.filter((r) => !r.hidden)
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

  const typePages = [
    [`${setupDir}/benchmarks/evalplus.md`, EVALPLUS_START, EVALPLUS_END, renderEvalplusTable(data)],
    [`${setupDir}/benchmarks/decode-speed.md`, DECODE_START, DECODE_END, renderDecodeSummary(data)],
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
