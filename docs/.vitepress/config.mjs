import { defineConfig } from 'vitepress'

export default defineConfig({
  title: 'Choosing a local coding LLM',
  description:
    'A repeatable process to find the best local model, runtime, and configuration for one specific computer.',
  base: '/choose-a-local-llm/',
  vite: {
    server: {
      allowedHosts: true,
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
      { text: 'Models', link: '/models/' },
      { text: 'Methodology', link: '/methodology' },
      { text: 'M1 Max 32 GB', link: '/setups/kamaji/' },
      { text: 'RTX 5060 Ti 16 GB', link: '/setups/arrietty/' },
    ],
    sidebar: [
      { text: 'Home', link: '/' },
      {
        text: 'Models',
        collapsed: false,
        items: [
          { text: 'All models', link: '/models/' },
          { text: 'Qwen3.8-27B', link: '/models/qwen3.8-27b' },
          { text: 'Qwen3.6-35B-A3B', link: '/models/qwen3.6-35b-a3b' },
          { text: 'Gemma-4-26B-A4B', link: '/models/gemma-4-26b-a4b' },
          { text: 'Gemma-4-12B-it', link: '/models/gemma-4-12b-it' },
          { text: 'Ternary Bonsai-27B', link: '/models/bonsai-27b' },
          { text: 'Ternary Bonsai-2-27B', link: '/models/bonsai-2-27b' },
        ],
      },
      {
        text: 'Benchmarks',
        collapsed: false,
        items: [
          { text: 'Decode speed vs context depth', link: '/benchmarks/decode-speed' },
          { text: 'HumanEval+', link: '/benchmarks/evalplus' },
          { text: 'Mendel', link: '/benchmarks/mendel' },
        ],
      },
      {
        text: 'Methodology',
        link: '/methodology',
        collapsed: true,
        items: [
          { text: 'Bench run checklist', link: '/methodology/checklist' },
          { text: 'Common rules', link: '/methodology/common-rules' },
          { text: 'KV cache pick', link: '/methodology/kv-cache-pick' },
          { text: 'Quantization', link: '/methodology/quantization' },
          { text: 'Context creep', link: '/methodology/context-creep' },
          { text: 'Memory ceiling', link: '/methodology/memory-ceiling' },
          { text: 'Wired limit', link: '/methodology/wired-limit' },
          { text: 'EvalPlus', link: '/methodology/evalplus' },
          { text: 'Thinking budget', link: '/methodology/reasoning-budget' },
          { text: 'Mendel', link: '/methodology/mendel' },
          { text: 'Server lore', link: '/methodology/server-lore' },
          { text: 'Status lines', link: '/methodology/status-lines' },
        ],
      },
      {
        text: 'M1 Max 32 GB',
        collapsed: false,
        items: [
          { text: 'Setup overview', link: '/setups/kamaji/' },
          { text: 'Comparison', link: '/setups/kamaji/comparison' },
          {
            text: 'Models',
            collapsed: true,
            items: [
              { text: 'Qwen3.8-27B', link: '/setups/kamaji/reports/qwen3.8-27b' },
              { text: 'Qwen3.6-35B-A3B', link: '/setups/kamaji/reports/qwen3.6-35b-a3b' },
              { text: 'Gemma-4-26B-A4B', link: '/setups/kamaji/reports/gemma-4-26b-a4b' },
              { text: 'Ternary Bonsai-2-27B', link: '/setups/kamaji/reports/bonsai-2-27b' },
              { text: 'Ternary Bonsai-27B', link: '/setups/kamaji/reports/bonsai-27b' },
              { text: 'Gemma-4-12B-it', link: '/setups/kamaji/reports/gemma-4-12b-it' },
            ],
          },
          { text: 'Historical', link: '/setups/kamaji/historical' },
        ],
      },
      {
        text: 'RTX 5060 Ti 16 GB',
        collapsed: false,
        items: [
          { text: 'Setup overview', link: '/setups/arrietty/' },
          { text: 'Comparison', link: '/setups/arrietty/comparison' },
          {
            text: 'Models',
            collapsed: true,
            items: [
              { text: 'Qwen3.8-27B', link: '/setups/arrietty/reports/qwen3.8-27b' },
              { text: 'Ternary Bonsai-2-27B', link: '/setups/arrietty/reports/bonsai-2-27b' },
              { text: 'Qwen3.6-35B-A3B', link: '/setups/arrietty/reports/qwen3.6-35b-a3b' },
              { text: 'Gemma-4-26B-A4B', link: '/setups/arrietty/reports/gemma-4-26b-a4b' },
              { text: 'Gemma-4-12B-it', link: '/setups/arrietty/reports/gemma-4-12b-it' },
            ],
          },
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
