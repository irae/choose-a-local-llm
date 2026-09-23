#!/usr/bin/env node
// Writes the local pi entries from the site data, the one surface
// `gen-tables.mjs` did not cover (`docs/methodology/common-rules.md`, rule 7).
//
//   node tools/gen-pi-models.mjs [--check] [--dry-run] [--target <file>] [--setup <id>]
//
// Only this machine's rows (`docs/setups/<hostname>/models.json`, or
// `--setup`) become entries; the other machines' rows are removed when the
// tool wrote them. A row gets an entry when it carries a `pi` block:
// `{provider, id, contextWindow}`. Two rows of one id collapse to one
// entry, the largest window wins. The tool sets `contextWindow`, removes
// `maxTokens` (pi's default is the value; owner, 2026-09-22), and points
// the `llama` provider at the router service (`tools/llama-router.sh`,
// port 8080, the official build or the PrismML build, one at a time). A
// model the running build does not hold gets the server's own "model
// not found" answer. A new entry copies its shape (thinking map, compat, cost)
// from an existing entry of the same model family, and is reported when
// none exists.

import { readFileSync, writeFileSync, existsSync } from 'node:fs'
import { homedir, hostname } from 'node:os'

const args = process.argv.slice(2)
const CHECK = args.includes('--check')
const DRY = args.includes('--dry-run')
const opt = (name, fallback) => (args.includes(name) ? args[args.indexOf(name) + 1] : fallback)
const target = opt('--target', `${homedir()}/.pi/agent/models.json`)
const setup = opt('--setup', hostname().split('.')[0].toLowerCase())

const ROUTERS = {
  llama: { name: 'llama-server', api: 'openai-completions', baseUrl: 'http://127.0.0.1:8080/v1', apiKey: 'no-key' },
}
const providerOf = (row) => row.pi.provider

const dataFile = `docs/setups/${setup}/models.json`
if (!existsSync(dataFile)) {
  console.error(`no ${dataFile}: this machine has no setup, or pass --setup <id>`)
  process.exit(2)
}
const wanted = new Map()
for (const row of JSON.parse(readFileSync(dataFile, 'utf8')).rows) {
  if (!row.pi || row.hidden || row.retired) continue
  const key = `${providerOf(row)}/${row.pi.id}`
  const seen = wanted.get(key)
  if (!seen || row.pi.contextWindow > seen.pi.contextWindow) wanted.set(key, row)
}

if (!existsSync(target)) {
  console.error(`no pi config at ${target}. Pass --target <file>.`)
  process.exit(2)
}
const config = JSON.parse(readFileSync(target, 'utf8'))
config.providers = config.providers || {}
const changes = []
const created = []

const allEntries = () => Object.values(config.providers).flatMap((p) => p.models || [])
const family = (id) => id.split('-').slice(0, 2).join('-')
const templateOf = (id) => {
  const full = allEntries().filter((m) => m.thinkingLevelMap)
  return full.find((m) => m.id === id) || full.find((m) => family(m.id) === family(id)) || null
}

for (const [key, row] of wanted) {
  const [provider] = key.split('/')
  const { id, contextWindow } = row.pi
  if (ROUTERS[provider]) {
    const p = (config.providers[provider] = config.providers[provider] || { ...ROUTERS[provider], models: [] })
    for (const [field, value] of Object.entries(ROUTERS[provider])) {
      if (p[field] === value) continue
      changes.push(`provider ${provider}: ${field} ${p[field] ?? 'unset'} -> ${value}`)
      p[field] = value
    }
  }
  config.providers[provider] = config.providers[provider] || { models: [] }
  const models = (config.providers[provider].models = config.providers[provider].models || [])
  let entry = models.find((m) => m.id === id)
  if (!entry) {
    const moved = allEntries().find((m) => m.id === id)
    const template = moved || templateOf(id)
    entry = template ? { ...structuredClone(template), id, name: moved ? template.name : `${id} (${provider})` } : { id }
    entry.contextWindow = contextWindow
    entry.generatedBy = 'gen-pi-models'
    delete entry.maxTokens
    models.push(entry)
    if (!template) created.push(`${key} (window ${contextWindow}) — no entry of family ${family(id)} to copy; set its thinking map by hand`)
    changes.push(`create ${key}${template ? ` from ${template.id}` : ''}`)
    continue
  }
  if (entry.contextWindow !== contextWindow) {
    changes.push(`${key}: contextWindow ${entry.contextWindow ?? 'unset'} -> ${contextWindow}`)
    entry.contextWindow = contextWindow
  }
  if ('maxTokens' in entry) {
    changes.push(`${key}: maxTokens ${entry.maxTokens} removed (pi default)`)
    delete entry.maxTokens
  }
}

// The router providers hold exactly the presets of this machine: every
// other entry there goes (another machine's row, a renamed id, a hidden
// row). In any other provider only entries this tool or a site row
// produced go; a hand-made entry (a cloud model) stays.
const siteIds = new Set()
for (const file of ['arrietty', 'kamaji'].map((s) => `docs/setups/${s}/models.json`)) {
  if (!existsSync(file)) continue
  for (const row of JSON.parse(readFileSync(file, 'utf8')).rows) if (row.pi) siteIds.add(row.pi.id)
}
for (const [provider, p] of Object.entries(config.providers)) {
  if (!p.models) continue
  const keep = []
  for (const m of p.models) {
    const wantedHere = wanted.has(`${provider}/${m.id}`)
    const managed = ROUTERS[provider] || m.generatedBy || siteIds.has(m.id)
    if (wantedHere || !managed) keep.push(m)
    else changes.push(`remove ${provider}/${m.id} (not a preset of ${setup})`)
  }
  p.models = keep
  const empty = !p.models.length && (provider === 'prism' || (!p.baseUrl && !p.headers && !p.compat && !p.modelOverrides))
  if (empty) {
    changes.push(`remove provider ${provider}: no entry left`)
    delete config.providers[provider]
  }
}

if (!changes.length) {
  console.log(`pi entries match the site data (${wanted.size} models of ${setup}, ${target})`)
  process.exit(0)
}
for (const line of changes) console.log(line)
for (const line of created) console.log(`NOTE ${line}`)
if (CHECK) {
  console.error(`STALE: ${target} does not match the site data. Run \`node tools/gen-pi-models.mjs\`.`)
  process.exit(1)
}
if (DRY) {
  console.log('--dry-run: nothing written')
  process.exit(0)
}
writeFileSync(target, `${JSON.stringify(config, null, 2)}\n`)
console.log(`updated: ${target}`)
