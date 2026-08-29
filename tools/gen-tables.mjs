import { readFileSync, writeFileSync } from 'node:fs'
import { globSync } from 'node:fs'

const CHECK = process.argv.includes('--check')

const START = '<!-- gen:models-evaluated:start -->'
const END = '<!-- gen:models-evaluated:end -->'

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

function renderTable(data) {
  const header = [
    '| Config | Max ctx | Gated by¹ | tok/s<br>(shallow → deep) | Memory<br>(at max ctx) | EvalPlus² |',
    '|---|--:|:--:|--:|--:|--:|',
  ]
  const rows = sortRows(data.rows).map((r) => {
    const maxCtx = r.pendingRetest ? `*${r.maxCtx}*` : r.maxCtx
    const memory = r.pendingRetest ? `*${r.memory}*` : r.memory
    return `| ${r.config} | ${maxCtx} | ${r.gatedBy} | ${r.tokShallow} → ${r.tokDeep} | ${memory} | ${r.evalplus} |`
  })
  return [...header, ...rows].join('\n')
}

function applyTable(content, table) {
  const startIdx = content.indexOf(START)
  const endIdx = content.indexOf(END)
  if (startIdx === -1 || endIdx === -1 || endIdx < startIdx) {
    throw new Error(`missing or malformed ${START} / ${END} markers`)
  }
  const before = content.slice(0, startIdx + START.length)
  const after = content.slice(endIdx)
  return `${before}\n${table}\n${after}`
}

const dataFiles = globSync('docs/setups/*/models.json')
let drift = false

for (const dataFile of dataFiles) {
  const setupDir = dataFile.replace(/\/models\.json$/, '')
  const data = JSON.parse(readFileSync(dataFile, 'utf8'))
  const table = renderTable(data)

  const targets = [`${setupDir}/comparison.md`, 'docs/index.md']

  for (const target of targets) {
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
}

if (CHECK && drift) process.exit(1)
if (!CHECK) console.log('tables generated from docs/setups/*/models.json')
