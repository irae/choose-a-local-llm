#!/usr/bin/env node
// Writes the local pi entries from the site data, the one surface
// `gen-tables.mjs` did not cover (`docs/methodology/common-rules.md`, rule 7).
//
//   node tools/gen-pi-models.mjs [--check] [--dry-run] [--target <file>]
//
// A row of `docs/setups/*/models.json` gets an entry when it carries a `pi`
// block: `{provider, id, contextWindow, maxTokens}`. Two rows of one model and
// one provider collapse to one entry, the largest window wins. The tool writes
// `contextWindow` and `maxTokens` only; every other field of an existing entry
// (thinking map, sampling, headers, credentials, other providers) survives.
// A new entry with no thinking map is reported, never guessed.

import { readFileSync, writeFileSync, existsSync } from 'node:fs'
import { homedir } from 'node:os'
import { globSync } from 'node:fs'

const args = process.argv.slice(2)
const CHECK = args.includes('--check')
const DRY = args.includes('--dry-run')
const target =
  args[args.indexOf('--target') + 1] && args.includes('--target')
    ? args[args.indexOf('--target') + 1]
    : `${homedir()}/.pi/agent/models.json`

const wanted = new Map()
for (const file of globSync('docs/setups/*/models.json')) {
  const data = JSON.parse(readFileSync(file, 'utf8'))
  for (const row of data.rows) {
    if (!row.pi || row.hidden || row.retired) continue
    const key = `${row.pi.provider}/${row.pi.id}`
    const seen = wanted.get(key)
    if (!seen || row.pi.contextWindow > seen.pi.contextWindow) wanted.set(key, row)
  }
}

if (!existsSync(target)) {
  console.error(`no pi config at ${target}. Pass --target <file>.`)
  process.exit(2)
}
const config = JSON.parse(readFileSync(target, 'utf8'))
config.providers = config.providers || {}

const changes = []
const created = []
for (const [key, row] of wanted) {
  const { provider, id, contextWindow, maxTokens } = row.pi
  config.providers[provider] = config.providers[provider] || { models: [] }
  const models = (config.providers[provider].models =
    config.providers[provider].models || [])
  let entry = models.find((m) => m.id === id)
  if (!entry) {
    entry = { id, contextWindow, maxTokens, generatedBy: 'gen-pi-models' }
    models.push(entry)
    created.push(`${key} (window ${contextWindow}) — set its thinking map by hand`)
    changes.push(`create ${key}`)
    continue
  }
  for (const [field, value] of [
    ['contextWindow', contextWindow],
    ['maxTokens', maxTokens],
  ]) {
    if (entry[field] === value) continue
    changes.push(`${key}: ${field} ${entry[field] ?? 'unset'} -> ${value}`)
    entry[field] = value
  }
}

if (!changes.length) {
  console.log(`pi entries match the site data (${wanted.size} models, ${target})`)
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
