import { readFileSync, existsSync, statSync } from 'node:fs'
import { globSync } from 'node:fs'
import { join, dirname, resolve, relative } from 'node:path'

const dist = resolve(process.argv[2] ?? 'docs/.vitepress/dist')
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
    const target = href.startsWith('/')
      ? join(dist, href)
      : resolve(dist, dirname(page), href)
    checked++
    if (!exists(target)) {
      dead++
      console.log(`DEAD  ${page}  ->  ${m[1]}`)
    }
  }
}

console.log(`\n${checked} links checked, ${dead} dead`)
process.exit(dead ? 1 : 0)
