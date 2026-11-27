import { readFileSync, existsSync, globSync } from 'node:fs'
import { defineConfig } from 'vitepress'

const setupFiles = globSync('data/setups/*/models.json').sort()
const setups = setupFiles.map((f) => JSON.parse(readFileSync(f, 'utf8')))
const binaries = JSON.parse(readFileSync('data/binaries.json', 'utf8'))

const modelTitles = new Map()
for (const s of setups) {
  for (const [slug, m] of Object.entries(s.models || {})) {
    if (modelTitles.has(slug)) continue
    const matchRow = (s.rows || []).find((r) => r.config?.startsWith(m.rowMatch) && r.spec?.base)
    modelTitles.set(slug, matchRow?.spec?.base || slug)
  }
}
const modelEntries = [...modelTitles.entries()]
  .sort((a, b) => a[1].localeCompare(b[1]))
  .map(([slug, text]) => ({ text, link: `/models/${slug}` }))

const setupSidebarItems = setups.map((s) => {
  const slug = s.hardwareSlug
  const items = [{ text: 'Overview & picks', link: `/setups/${slug}/` }]
  if (existsSync(`site/setups/${slug}/archive.md`)) {
    items.push({ text: 'Archive & retired', link: `/setups/${slug}/archive` })
  }
  return {
    text: s.hardwareName || slug,
    collapsed: false,
    items,
  }
})

export default defineConfig({
  title: 'Choosing a local coding LLM',
  description:
    'Measured decode speed, context limits, coding quality, and agent performance for local coding LLMs across real hardware.',
  base: '/choose-a-local-llm/',
  head: [
    ['link', { rel: 'preconnect', href: 'https://fonts.googleapis.com' }],
    ['link', { rel: 'preconnect', href: 'https://fonts.gstatic.com', crossorigin: '' }],
    [
      'link',
      {
        rel: 'stylesheet',
        href: 'https://fonts.googleapis.com/css2?family=Martian+Mono:wght@400;500;600&family=Public+Sans:ital,opsz,wght@0,9..40,400;0,9..40,500;0,9..40,600;0,9..40,700;1,9..40,400&display=swap',
      },
    ],
    ['meta', { name: 'theme-color', content: '#f3f6f4', media: '(prefers-color-scheme: light)' }],
    ['meta', { name: 'theme-color', content: '#101614', media: '(prefers-color-scheme: dark)' }],
  ],
  vite: {
    server: {
      allowedHosts: true,
    },
  },
  cleanUrls: true,
  sitemap: { hostname: 'https://irae.github.io/choose-a-local-llm/' },
  lastUpdated: true,
  themeConfig: {
    search: { provider: 'local' },
    nav: [
      { text: 'Home', link: '/' },
      {
        text: 'Setups',
        items: setups.map((s) => ({
          text: s.hardwareName || s.hardwareSlug,
          link: `/setups/${s.hardwareSlug}/`,
        })),
      },
      { text: 'Models', link: '/models/' },
      { text: 'Benchmarks', link: '/benchmarks/' },
      { text: 'Method', link: '/method/' },
    ],
    sidebar: [
      { text: 'Home', link: '/' },
      {
        text: 'Setups',
        collapsed: false,
        items: setupSidebarItems,
      },
      {
        text: 'Models',
        collapsed: false,
        items: [
          { text: 'All models', link: '/models/' },
          ...modelEntries,
        ],
      },
      {
        text: 'Benchmarks',
        collapsed: false,
        items: [
          { text: 'Overview & Compute Ledger', link: '/benchmarks/' },
          { text: 'Decode Speed', link: '/benchmarks/decode-speed' },
          { text: 'HumanEval+', link: '/benchmarks/evalplus' },
          { text: 'Mendel', link: '/benchmarks/mendel' },
          { text: `Model Files (${binaries.length})`, link: '/files/' },
        ],
      },
      {
        text: 'Method',
        collapsed: true,
        items: [
          { text: 'Overview & Funnel', link: '/method/' },
          { text: 'Speed & Memory', link: '/method/speed-and-memory' },
          { text: 'Coding Quality', link: '/method/quality' },
          { text: 'Agent Coding', link: '/method/agent-coding' },
        ],
      },
    ],
    socialLinks: [
      { icon: 'github', link: 'https://github.com/irae/choose-a-local-llm' },
    ],
    outline: [2, 3],
    footer: {
      message:
        'Measured and written by <a href="https://github.com/irae">Irae Carvalho</a>. Source on <a href="https://github.com/irae/choose-a-local-llm">GitHub</a>.',
      copyright: 'Copyright © 2026 <a href="https://github.com/irae">Irae Carvalho</a>',
    },
  },
})
