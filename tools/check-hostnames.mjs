#!/usr/bin/env node
import { readFileSync, readdirSync, statSync, existsSync, globSync } from 'node:fs'
import { join } from 'node:path'

const ids = new Set()

for (const file of globSync('data/setups/*/models.json')) {
  const data = JSON.parse(readFileSync(file, 'utf8'))
  if (data.hardwareId) ids.add(String(data.hardwareId))
}

if (existsSync('hardware')) {
  for (const entry of readdirSync('hardware')) {
    if (statSync(join('hardware', entry)).isDirectory()) ids.add(entry)
  }
}

const banned = [...ids].filter(Boolean).sort()
if (!banned.length) {
  console.error('hostname check failed: no hardware IDs discovered')
  process.exit(1)
}

const pattern = new RegExp(`\\b(${banned.map((s) => s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')).join('|')})\\b`, 'gi')

const files = globSync('site/**/*', {
  exclude: ['site/.vitepress/dist/**', 'site/.vitepress/cache/**', 'site/public/**'],
}).filter((f) => existsSync(f) && statSync(f).isFile())

let leaks = 0

for (const file of files) {
  for (const m of file.matchAll(pattern)) {
    console.error(`HOSTNAME LEAK  ${file}:path  matched "${m[0]}"`)
    leaks++
  }
  const lines = readFileSync(file, 'utf8').split('\n')
  for (let i = 0; i < lines.length; i++) {
    for (const m of lines[i].matchAll(pattern)) {
      console.error(`HOSTNAME LEAK  ${file}:${i + 1}  matched "${m[0]}"`)
      leaks++
    }
  }
}

if (leaks) {
  console.error(`\nhostname check failed: ${leaks} leak(s) across ${files.length} files (banned: ${banned.join(', ')})`)
  process.exit(1)
}

console.log(`hostname check passed: ${files.length} files, 0 leaks (banned: ${banned.join(', ')})`)
