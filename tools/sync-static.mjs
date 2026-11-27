import { mkdirSync, copyFileSync, globSync } from 'node:fs'
import { basename } from 'node:path'

const JOBS = [
  { from: 'benchmarks/mendel/*.html', to: 'site/public/mendel' },
  { from: 'benchmarks/history/*.html', to: 'site/public/history' },
]

for (const { from, to } of JOBS) {
  const files = globSync(from)
  if (!files.length) continue
  mkdirSync(to, { recursive: true })
  for (const f of files) {
    copyFileSync(f, `${to}/${basename(f)}`)
    console.log(`synced: ${f} -> ${to}/`)
  }
}
