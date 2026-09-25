#!/usr/bin/env node
// Writes the local pi entries from the site data, the one surface
// `gen-tables.mjs` did not cover (`docs/methodology/common-rules.md`, rule 7).
//
//   node tools/gen-pi-models.mjs [--check] [--dry-run] [--target <file>] [--settings <file>] [--setup <id>]
//   node tools/gen-pi-models.mjs --run-dir <dir> --id <pi id> [--window <N>] [--setup <id>]
//
// User mode (no --run-dir): only this machine's rows
// (`docs/setups/<hostname>/models.json`, or `--setup`) become entries; the
// other machines' rows are removed when the tool wrote them. A row gets an
// entry when it carries a `pi` block: `{provider, id, contextWindow}`. Two
// rows of one id collapse to one entry, the largest window wins. The tool
// sets `contextWindow`, removes `maxTokens` always (the row's value is the
// benchmark cap; daily work needs pi's default; docs/methodology/common-rules.md,
// rule 7), and points the `llama` provider at the router service
// (`tools/llama-router.sh`, port 8080, the official build or the PrismML
// build, one at a time). A model the running build does not hold gets the
// server's own "model not found" answer. A new entry copies its shape
// (thinking map, compat, cost) from an existing entry of the same model
// family, and is reported when none exists.
//
// The tool also writes `compaction.modelOverrides["<provider>/<id>"]` in
// `settings.json` (default `~/.pi/agent/settings.json`, `--settings <file>`)
// for every entry it manages, following a fixed curve on `contextWindow`:
// below 65536 -> `keepRecentTokens: 8192`; 65536 up to below 131072 ->
// 16384; 131072 and above -> no override (pi's default 20000). It never
// writes `reserveTokens` or `maxTokens` anywhere, in either file, and
// removes them from a key it owns when it finds them there (owner
// decision, 2026-09-25: pi's own defaults apply). `--check` and `--dry-run`
// cover both files.
//
// `--run-dir <dir> --id <pi id>` writes an isolated `models.json` and
// `settings.json` under `<dir>` for one model only, for the
// simulator(mendel) worker and `benchmarks/mendel-smoke.sh`: a run-dir
// config never reads or writes `~/.pi/agent/*`, except a read-only look at
// the user's `models.json` to copy an existing entry's shape (thinking
// map, compat, cost) for the same model family. `--window <N>` overrides
// the row's `contextWindow` (for example a depth-sweep window); the keep
// curve above then applies to that window.

import { readFileSync, writeFileSync, existsSync, mkdirSync } from 'node:fs'
import { homedir, hostname } from 'node:os'

const args = process.argv.slice(2)
const CHECK = args.includes('--check')
const DRY = args.includes('--dry-run')
const opt = (name, fallback) => (args.includes(name) ? args[args.indexOf(name) + 1] : fallback)
const setup = opt('--setup', hostname().split('.')[0].toLowerCase())

const ROUTERS = {
  llama: { name: 'llama-server', api: 'openai-completions', baseUrl: 'http://127.0.0.1:8080/v1', apiKey: 'no-key' },
}
const providerOf = (row) => row.pi.provider
const keepRecentFor = (window) => (window < 65536 ? 8192 : window < 131072 ? 16384 : null)
const family = (id) => id.split('-').slice(0, 2).join('-')

function loadWanted(dataFile) {
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
  return wanted
}

const runDir = opt('--run-dir', null)
if (runDir) {
  const id = opt('--id', null)
  if (!id) {
    console.error('--run-dir needs --id <pi id>')
    process.exit(2)
  }
  const dataFile = `docs/setups/${setup}/models.json`
  const wanted = loadWanted(dataFile)
  const found = [...wanted.values()].find((row) => row.pi.id === id)
  if (!found) {
    console.error(`no pi id "${id}" in ${dataFile}`)
    process.exit(1)
  }
  const provider = found.pi.provider
  const windowOpt = opt('--window', null)
  const contextWindow = windowOpt ? Number(windowOpt) : found.pi.contextWindow

  const userTarget = opt('--target', `${homedir()}/.pi/agent/models.json`)
  const userEntries = existsSync(userTarget)
    ? Object.values(JSON.parse(readFileSync(userTarget, 'utf8')).providers || {}).flatMap((p) => p.models || [])
    : []
  const templateOf = (modelId) => {
    const full = userEntries.filter((m) => m.thinkingLevelMap)
    return full.find((m) => m.id === modelId) || full.find((m) => family(m.id) === family(modelId)) || null
  }
  const template = templateOf(id)
  const entry = template ? { ...structuredClone(template), id, name: template.name } : { id }
  entry.contextWindow = contextWindow
  delete entry.maxTokens
  delete entry.generatedBy

  const providerBlock = { ...(ROUTERS[provider] || {}), models: [entry] }
  const runModels = { providers: { [provider]: providerBlock } }

  const keep = keepRecentFor(contextWindow)
  const runSettings = {
    compaction: { enabled: true, ...(keep != null ? { keepRecentTokens: keep } : {}) },
    retry: { enabled: true },
  }

  mkdirSync(runDir, { recursive: true })
  writeFileSync(`${runDir}/models.json`, `${JSON.stringify(runModels, null, 2)}\n`)
  writeFileSync(`${runDir}/settings.json`, `${JSON.stringify(runSettings, null, 2)}\n`)
  console.log(`${runDir}: ${id} window=${contextWindow} keep=${keep ?? 'default'}`)
  process.exit(0)
}

const target = opt('--target', `${homedir()}/.pi/agent/models.json`)
const settingsTarget = opt('--settings', `${homedir()}/.pi/agent/settings.json`)
const dataFile = `docs/setups/${setup}/models.json`
const wanted = loadWanted(dataFile)

if (!existsSync(target)) {
  console.error(`no pi config at ${target}. Pass --target <file>.`)
  process.exit(2)
}
if (!existsSync(settingsTarget)) {
  console.error(`no pi settings at ${settingsTarget}. Pass --settings <file>.`)
  process.exit(2)
}
const config = JSON.parse(readFileSync(target, 'utf8'))
config.providers = config.providers || {}
const changes = []
const created = []

const allEntries = () => Object.values(config.providers).flatMap((p) => p.models || [])
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
const removedKeys = []
for (const [provider, p] of Object.entries(config.providers)) {
  if (!p.models) continue
  const keep = []
  for (const m of p.models) {
    const wantedHere = wanted.has(`${provider}/${m.id}`)
    const managed = ROUTERS[provider] || m.generatedBy || siteIds.has(m.id)
    if (wantedHere || !managed) keep.push(m)
    else {
      changes.push(`remove ${provider}/${m.id} (not a preset of ${setup})`)
      removedKeys.push(`${provider}/${m.id}`)
    }
  }
  p.models = keep
  const empty = !p.models.length && (provider === 'prism' || (!p.baseUrl && !p.headers && !p.compat && !p.modelOverrides))
  if (empty) {
    changes.push(`remove provider ${provider}: no entry left`)
    delete config.providers[provider]
  }
}

// A managed model override (compaction.modelOverrides in settings.json) is
// keyed the same way as a models.json entry: owned when its provider is a
// router, when the tool created it (`generatedBy`), or when a site row on
// any machine names its id. An override the tool does not own is never
// touched.
const managedKeys = new Set(removedKeys)
for (const [provider, p] of Object.entries(config.providers)) {
  for (const m of p.models || []) {
    if (ROUTERS[provider] || m.generatedBy || siteIds.has(m.id)) managedKeys.add(`${provider}/${m.id}`)
  }
}

const settings = JSON.parse(readFileSync(settingsTarget, 'utf8'))
const settingsChanges = []
if (settings.compaction && 'reserveTokens' in settings.compaction) {
  settingsChanges.push(`compaction.reserveTokens ${settings.compaction.reserveTokens} removed (pi default)`)
  delete settings.compaction.reserveTokens
}
settings.compaction = settings.compaction || {}
const overrides = settings.compaction.modelOverrides || {}
for (const key of managedKeys) {
  const row = wanted.get(key)
  const desired = row ? keepRecentFor(row.pi.contextWindow) : null
  const existing = overrides[key]
  if (existing && 'reserveTokens' in existing) {
    settingsChanges.push(`modelOverrides[${key}].reserveTokens ${existing.reserveTokens} removed (pi default)`)
    delete existing.reserveTokens
  }
  if (desired == null) {
    if (existing && 'keepRecentTokens' in existing) {
      settingsChanges.push(`modelOverrides[${key}] removed (window past the curve, pi default)`)
      delete overrides[key]
    } else if (existing && !Object.keys(existing).length) {
      delete overrides[key]
    }
    continue
  }
  if (existing?.keepRecentTokens !== desired) {
    settingsChanges.push(`modelOverrides[${key}].keepRecentTokens ${existing?.keepRecentTokens ?? 'unset'} -> ${desired}`)
    overrides[key] = { ...existing, keepRecentTokens: desired }
  }
}
if (Object.keys(overrides).length) settings.compaction.modelOverrides = overrides
else delete settings.compaction.modelOverrides

if (!changes.length && !settingsChanges.length) {
  console.log(`pi entries and compaction settings match the site data (${wanted.size} models of ${setup}, ${target})`)
  process.exit(0)
}
for (const line of changes) console.log(line)
for (const line of settingsChanges) console.log(line)
for (const line of created) console.log(`NOTE ${line}`)
if (CHECK) {
  console.error(`STALE: ${target} or ${settingsTarget} does not match the site data. Run \`node tools/gen-pi-models.mjs\`.`)
  process.exit(1)
}
if (DRY) {
  console.log('--dry-run: nothing written')
  process.exit(0)
}
if (changes.length) {
  writeFileSync(target, `${JSON.stringify(config, null, 2)}\n`)
  console.log(`updated: ${target}`)
}
if (settingsChanges.length) {
  writeFileSync(settingsTarget, `${JSON.stringify(settings, null, 2)}\n`)
  console.log(`updated: ${settingsTarget}`)
}
