import { readFileSync, existsSync, statSync, globSync } from 'node:fs'
import { join, dirname, resolve } from 'node:path'

const dist = resolve(process.argv[2] ?? 'docs/.vitepress/dist')

const config = readFileSync('docs/.vitepress/config.mjs', 'utf8')
const base = config.match(/^\s*base:\s*['"]([^'"]+)['"]/m)?.[1] ?? '/'

const pages = globSync('**/*.html', { cwd: dist })
let dead = 0
let checked = 0

const exists = (p) => {
  if (existsSync(p) && statSync(p).isFile()) return true
  if (existsSync(p + '.html')) return true
  if (existsSync(join(p, 'index.html'))) return true
  return false
}

for (const page of pages) {
  const html = readFileSync(join(dist, page), 'utf8')
  for (const m of html.matchAll(/\shref="([^"]+)"/g)) {
    let href = m[1]
    if (/^(https?:|mailto:|#|data:)/.test(href)) continue
    href = href.split('#')[0].split('?')[0]
    if (!href) continue

    let target
    if (href.startsWith('/')) {
      if (base !== '/' && !href.startsWith(base)) {
        checked++
        dead++
        console.log(`BASE  ${page}  ->  ${m[1]}  (absolute link missing the ${base} base)`)
        continue
      }
      target = join(dist, href.slice(base.length - 1))
    } else {
      target = resolve(dist, dirname(page), href)
    }

    checked++
    if (!exists(target)) {
      dead++
      console.log(`DEAD  ${page}  ->  ${m[1]}`)
    }
  }
}

console.log(`\nbase ${base} — ${checked} links checked, ${dead} dead`)
process.exit(dead ? 1 : 0)
