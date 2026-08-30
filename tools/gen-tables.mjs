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
  const body = ordered.map((r, i) => {
    const maxCtx = r.pendingRetest ? `*${r.maxCtx}*` : r.maxCtx
    const memory = r.pendingRetest ? `*${r.memory}*` : r.memory
    return `| ${i + 1} | ${r.config} | ${maxCtx} | ${r.gatedBy} | ${r.tokShallow} → ${r.tokDeep} | ${memory} | ${r.evalplus} |`
  })
  return [...header, ...body].join('\n')
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
