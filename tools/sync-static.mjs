// Copy plain-HTML artifacts into docs/public/ so VitePress serves them
// verbatim. Sources stay in benchmarks/ (the artifact tree); docs/public/
// is disposable and gitignored. Runs from predev/prebuild.
import { mkdirSync, copyFileSync, globSync } from 'node:fs'
import { basename } from 'node:path'

const JOBS = [
  { from: 'benchmarks/mendel/*.html', to: 'docs/public/mendel' },
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
