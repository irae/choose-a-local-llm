import { defineConfig } from 'vitepress'

export default defineConfig({
  title: 'Choosing a local coding LLM',
  description:
    'A repeatable process to find the best local model, runtime, and configuration for one specific computer.',
  base: '/choose-a-local-llm/',
  vite: {
    server: {
      allowedHosts: ['irae-kamaji.tailc9708.ts.net', '100.73.3.114'],
    },
  },
  cleanUrls: true,
  sitemap: { hostname: 'https://irae.github.io/choose-a-local-llm/' },
  lastUpdated: true,
  srcExclude: ['website-plan.md'],
  themeConfig: {
    search: { provider: 'local' },
    nav: [
      { text: 'Home', link: '/' },
      { text: 'Methodology', link: '/methodology' },
      { text: 'M1 Max 32 GB', link: '/setups/m1-max-32gb/' },
    ],
    sidebar: [
      { text: 'Home', link: '/' },
      {
        text: 'Methodology',
        link: '/methodology',
        collapsed: true,
        items: [
          { text: 'Bench run checklist', link: '/methodology/checklist' },
          { text: 'Common rules', link: '/methodology/common-rules' },
          { text: 'Context creep', link: '/methodology/context-creep' },
          { text: 'Memory ceiling', link: '/methodology/memory-ceiling' },
          { text: 'EvalPlus', link: '/methodology/evalplus' },
          { text: 'Mendel', link: '/methodology/mendel' },
          { text: 'Polyglot', link: '/methodology/polyglot' },
          { text: 'Server lore', link: '/methodology/server-lore' },
        ],
      },
      {
        text: 'M1 Max 32 GB',
        collapsed: false,
        items: [
          { text: 'Setup overview', link: '/setups/m1-max-32gb/' },
          { text: 'Comparison', link: '/setups/m1-max-32gb/comparison' },
          {
            text: 'Models',
            collapsed: false,
            items: [
              { text: 'Qwen3.6-35B-A3B', link: '/setups/m1-max-32gb/reports/qwen3.6-35b-a3b' },
              { text: 'Gemma-4-26B-A4B', link: '/setups/m1-max-32gb/reports/gemma-4-26b-a4b' },
              { text: 'Gemma-4-12B-it', link: '/setups/m1-max-32gb/reports/gemma-4-12b-it' },
              { text: 'Ternary Bonsai-27B', link: '/setups/m1-max-32gb/reports/bonsai-27b' },
              { text: 'Qwen3.8-27B', link: '/setups/m1-max-32gb/reports/qwen3.8-27b' },
            ],
          },
          {
            text: 'Benchmarks',
            collapsed: false,
            items: [
              { text: 'Decode speed vs context depth', link: '/setups/m1-max-32gb/benchmarks/decode-speed' },
              { text: 'EvalPlus', link: '/setups/m1-max-32gb/benchmarks/evalplus' },
              { text: 'Mendel', link: '/setups/m1-max-32gb/benchmarks/mendel' },
              { text: 'Aider polyglot', link: '/setups/m1-max-32gb/benchmarks/polyglot' },
            ],
          },
          { text: 'Historical', link: '/setups/m1-max-32gb/historical' },
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
