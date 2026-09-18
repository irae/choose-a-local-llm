#!/usr/bin/env node
// Checks that CONTENT-MAP.md still describes tools/gen-tables.mjs and the
// pages. It changes nothing. Exit 1 on a mismatch, with the line to fix.
//
//   node tools/check-content-map.mjs
//
// Checks, in order:
//   1. every writeBlock and applyBlock call of the generator: its marker is
//      in the map, and the map's row names the call's block identifier;
//      a call whose marker the script cannot resolve is named in the map
//   2. every gen: marker of docs/**/*.md is one the generator writes, and
//      every marker the generator writes is on at least one page
//   3. every docs/, tools/ and benchmarks/ path the map names exists
//      (<setup>, <slug>, <id> stand for any name)
//   4. MENDEL_SLUGS and MENDEL_SPECS have the same keys, and every local
//      run of the CSVs has both
//   5. every evalplusRuns slug and every curves model is a models.<slug>
//      of its setup; a row whose spec matches no docs/binaries.json entry
//      is a warning

import { readFileSync, existsSync, globSync } from 'node:fs'

const GEN = 'tools/gen-tables.mjs'
const MAP = 'CONTENT-MAP.md'
const src = readFileSync(GEN, 'utf8')
const map = readFileSync(MAP, 'utf8')
const errors = []
const warnings = []

const markerName = (s) => s.match(/<!-- gen:(.+?):(?:start|end) -->/)?.[1]
const consts = new Map()
for (const m of src.matchAll(/const (\w+) = '(<!-- gen:[^']+ -->)'/g)) consts.set(m[1], markerName(m[2]))

function callsOf(name) {
  const out = []
  const re = new RegExp(`\\b${name}\\(`, 'g')
  for (const m of src.matchAll(re)) {
    if (src.slice(Math.max(0, m.index - 9), m.index) === 'function ') continue
    const line = src.slice(0, m.index).split('\n').length
    let depth = 1
    let i = m.index + m[0].length
    let arg = ''
    const args = []
    for (; i < src.length && depth > 0; i++) {
      const c = src[i]
      if (c === '(' || c === '[' || c === '{') depth++
      if (c === ')' || c === ']' || c === '}') depth--
      if (depth === 0) break
      if (c === ',' && depth === 1) { args.push(arg.trim()); arg = '' } else arg += c
    }
    if (arg.trim()) args.push(arg.trim())
    out.push({ line, text: src.slice(m.index, i + 1).replace(/\s+/g, ' '), args })
  }
  return out
}

const calls = []
for (const c of callsOf('writeBlock')) {
  if (c.args.length < 4) continue
  calls.push({ ...c, marker: c.args[1], block: c.args[3] })
}
for (const c of callsOf('applyBlock')) {
  if (c.args.length < 4) continue
  calls.push({ ...c, marker: c.args[1], block: c.args[3] })
}

const resolve = (expr) => {
  const lit = expr.match(/^'(<!-- gen:.+? -->)'$/)
  if (lit) return markerName(lit[1])
  if (consts.has(expr)) return consts.get(expr)
  return null
}
const ident = (expr) => expr.match(/^[A-Za-z_$][\w$]*/)?.[0] || expr

const mapRows = map.split('\n').filter((l) => /^\| `gen:/.test(l))
const mapMarkers = new Map()
for (const row of mapRows) {
  const name = row.match(/^\| `gen:([^`]+)`/)[1]
  const cells = row.split('|').map((s) => s.trim())
  const codes = [...cells[3].matchAll(/`([^`]+)`/g)].map((m) => m[1])
  mapMarkers.set(name, [...(mapMarkers.get(name) || []), ...codes])
}

const generatorMarkers = new Set([...src.matchAll(/<!-- gen:(.+?):(?:start|end) -->/g)].map((m) => m[1]))

for (const c of calls) {
  const name = resolve(c.marker)
  if (!name) {
    if (!map.includes(`\`${c.text}\``)) {
      errors.push(`${GEN}:${c.line}: the marker of \`${c.text}\` cannot be resolved; name that call in ${MAP} under "Calls the check script cannot resolve"`)
    }
    continue
  }
  const id = ident(c.block)
  if (!mapMarkers.has(name)) {
    errors.push(`${GEN}:${c.line}: writes \`gen:${name}\` and ${MAP} has no row for it; add one to "Generated blocks"`)
  } else if (!mapMarkers.get(name).includes(id)) {
    errors.push(`${GEN}:${c.line}: writes \`gen:${name}\` from \`${id}\`; the ${MAP} row for that marker names ${mapMarkers.get(name).map((s) => `\`${s}\``).join(', ')}; add \`${id}\` to its "Generator call" cell`)
  }
}
for (const name of mapMarkers.keys()) {
  if (!generatorMarkers.has(name)) errors.push(`${MAP} lists \`gen:${name}\` and ${GEN} never writes it; remove the row or fix the name`)
}

const pageMarkers = new Map()
for (const file of globSync('docs/**/*.md')) {
  for (const m of readFileSync(file, 'utf8').matchAll(/<!-- gen:(.+?):start -->/g)) {
    pageMarkers.set(m[1], [...(pageMarkers.get(m[1]) || []), file])
  }
}
for (const [name, files] of pageMarkers) {
  if (!generatorMarkers.has(name)) errors.push(`${files[0]}: carries \`gen:${name}\`, which ${GEN} never writes; the block is stale forever. Remove it or add the call`)
}
for (const name of generatorMarkers) {
  if (!pageMarkers.has(name)) errors.push(`${GEN} writes \`gen:${name}\` and no page under docs/ carries it`)
}

const pathPattern = /`((?:docs|tools|benchmarks)\/[^`\s]+)`/g
const seen = new Set()
for (const m of map.matchAll(pathPattern)) {
  let p = m[1].replace(/[,.;:]+$/, '')
  if (seen.has(p) || !/\.(md|json|csv|mjs|html)$/.test(p)) continue
  seen.add(p)
  const glob = p.replace(/<[^>]+>/g, '*')
  if (!globSync(glob).length) errors.push(`${MAP} names \`${p}\` and no such file exists`)
}

const keysOf = (name) => {
  const body = src.match(new RegExp(`const ${name} = (\\{[\\s\\S]*?\\n\\})`))?.[1]
  if (!body) { errors.push(`${GEN}: no \`${name}\` map found`); return [] }
  return Object.keys(eval(`(${body})`))
}
const slugs = keysOf('MENDEL_SLUGS')
const specs = keysOf('MENDEL_SPECS')
for (const k of slugs) if (!specs.includes(k)) errors.push(`${GEN}: MENDEL_SLUGS has "${k}" and MENDEL_SPECS does not; add its spec`)
for (const k of specs) if (!slugs.includes(k)) errors.push(`${GEN}: MENDEL_SPECS has "${k}" and MENDEL_SLUGS does not; add its page slug`)

function parseCsv(text) {
  const rows = []
  let row = [], field = '', inQ = false
  for (let i = 0; i < text.length; i++) {
    const c = text[i]
    if (inQ) {
      if (c === '"') { if (text[i + 1] === '"') { field += '"'; i++ } else inQ = false } else field += c
    } else if (c === '"') inQ = true
    else if (c === ',') { row.push(field); field = '' }
    else if (c === '\n') { row.push(field); rows.push(row); row = []; field = '' }
    else if (c !== '\r') field += c
  }
  if (field !== '' || row.length) { row.push(field); rows.push(row) }
  const header = rows.shift()
  return rows.filter((r) => r.length > 1).map((r) => Object.fromEntries(header.map((h, i) => [h, r[i] ?? ''])))
}
for (const csv of ['benchmarks/mendel/results.csv', 'benchmarks/mendel/results-guided.csv']) {
  if (!existsSync(csv)) continue
  const local = parseCsv(readFileSync(csv, 'utf8')).filter((r) => r.local === 'True')
  for (const model of new Set(local.map((r) => r.model))) {
    if (!slugs.includes(model)) errors.push(`${csv}: local run "${model}" has no MENDEL_SLUGS entry in ${GEN}; the report page and the model page omit it`)
    if (!specs.includes(model)) errors.push(`${csv}: local run "${model}" has no MENDEL_SPECS entry in ${GEN}; the generator will fail`)
  }
}

const binaries = JSON.parse(readFileSync('docs/binaries.json', 'utf8'))
const key = (s) => ['base', 'quant', 'publisher', 'server'].map((k) => s?.[k] || '').join('|')
const binaryKeys = new Set(binaries.flatMap((b) => [b.spec.quant, ...(b.quantAliases || [])].map((q) => key({ ...b.spec, quant: q }))))
for (const b of binaries) {
  if (!existsSync(`docs/binaries/${b.id}.md`)) errors.push(`docs/binaries.json: "${b.id}" has no docs/binaries/${b.id}.md; every config cell of that file links to a dead page`)
}
for (const file of globSync('docs/setups/*/models.json')) {
  const data = JSON.parse(readFileSync(file, 'utf8'))
  const models = Object.keys(data.models || {})
  for (const r of data.evalplusRuns || []) {
    if (!models.includes(r.slug)) errors.push(`${file}: evalplusRuns "${r.model}" has slug "${r.slug}", not a models.<slug> of this setup`)
    if (r.row && !data.rows.find((x) => x.id === r.row)) errors.push(`${file}: evalplusRuns "${r.model}" names row "${r.row}", which does not exist`)
  }
  for (const c of data.curves || []) {
    if (!models.includes(c.model)) errors.push(`${file}: curves "${c.arm}" has model "${c.model}", not a models.<slug> of this setup`)
  }
  for (const r of data.rows) {
    if (r.retired || !r.spec) continue
    if (!models.some((s) => r.config.startsWith(data.models[s].rowMatch))) errors.push(`${file}: row "${r.id}" matches no models.<slug>.rowMatch; no report page shows it`)
    if (!binaryKeys.has(key(r.spec))) warnings.push(`${file}: row "${r.id}" (${key(r.spec)}) matches no docs/binaries.json entry; its config cell has no link and no binary page holds it`)
  }
}

for (const w of warnings) console.warn(`warning: ${w}`)
if (errors.length) {
  console.error(`${MAP} does not match ${GEN} or the pages:`)
  for (const e of errors) console.error('  ' + e)
  process.exit(1)
}
console.log(`${MAP} matches ${GEN}: ${calls.length} block calls, ${generatorMarkers.size} markers, ${pageMarkers.size} on pages`)
