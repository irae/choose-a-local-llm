import { mkdirSync, copyFileSync, globSync, readFileSync, writeFileSync } from 'node:fs'
import { basename } from 'node:path'

const JOBS = [
  { from: 'benchmarks/mendel/*.html', to: 'site/public/mendel' },
  { from: 'benchmarks/history/*.html', to: 'site/public/history' },
  { from: 'site/.vitepress/theme/fonts/OFL-*.txt', to: 'site/public/fonts' },
]

const hardwareSlugs = new Map(globSync('data/setups/*/models.json').map((file) => {
  const { hardwareId, hardwareSlug } = JSON.parse(readFileSync(file, 'utf8'))
  return [hardwareId.toLowerCase(), hardwareSlug]
}))
const hostnames = [...hardwareSlugs.keys()].map((id) => id.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')).join('|')
const hardwareRef = new RegExp(`\\bhardware/(${hostnames})/|\\b(${hostnames})\\b`, 'gi')

for (const { from, to } of JOBS) {
  const files = globSync(from)
  if (!files.length) continue
  mkdirSync(to, { recursive: true })
  for (const f of files) {
    const target = `${to}/${basename(f)}`
    if (f.endsWith('.html') && hostnames) {
      const html = readFileSync(f, 'utf8').replace(hardwareRef, (_, pathId, nameId) => {
        const slug = hardwareSlugs.get((pathId || nameId).toLowerCase())
        return pathId ? `${slug}:` : slug
      })
      writeFileSync(target, html)
    } else {
      copyFileSync(f, target)
    }
    console.log(`synced: ${f} -> ${to}/`)
  }
}
