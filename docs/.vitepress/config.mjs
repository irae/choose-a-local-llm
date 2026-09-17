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
              { text: 'Ternary Bonsai-27B', link: '/setups/kamaji/reports/bonsai-27b' },
              { text: 'Gemma-4-12B-it', link: '/setups/kamaji/reports/gemma-4-12b-it' },
            ],
          },
          {
            text: 'Binaries',
            collapsed: true,
            items: [
              { text: 'Qwen3.8-27B Q4_K_M bartowski', link: '/setups/kamaji/binaries/qwen38-bartowski-q4km' },
              { text: 'Qwen3.8-27B IQ3_S-mtp ISTA', link: '/setups/kamaji/binaries/qwen38-ista-iq3s-mtp' },
              { text: 'Qwen3.8-27B UD-IQ3_S unsloth', link: '/setups/kamaji/binaries/qwen38-unsloth-ud-iq3s' },
              { text: 'Qwen3.8-27B AD-IQ3_S AtomicChat', link: '/setups/kamaji/binaries/qwen38-atomicchat-ad-iq3s' },
              { text: 'Qwen3.8-27B UD-Q3_K_XL unsloth', link: '/setups/kamaji/binaries/qwen38-unsloth-ud-q3kxl' },
              { text: 'Qwen3.8-27B MLX 4-bit', link: '/setups/kamaji/binaries/qwen38-mlx-4bit' },
              { text: 'Qwen3.6-35B-A3B UD-Q4_K_XL unsloth', link: '/setups/kamaji/binaries/qwen36-unsloth-ud-q4kxl' },
              { text: 'Qwen3.6-35B-A3B MLX 4-bit', link: '/setups/kamaji/binaries/qwen36-mlx-4bit' },
              { text: 'Gemma-4-26B-A4B UD-Q4_K_XL unsloth', link: '/setups/kamaji/binaries/gemma26-unsloth-ud-q4kxl' },
              { text: 'Gemma-4-26B-A4B MLX 4-bit', link: '/setups/kamaji/binaries/gemma26-mlx-4bit' },
              { text: 'Gemma-4-12B Q4_K_XL unsloth', link: '/setups/kamaji/binaries/gemma12-unsloth-q4kxl' },
              { text: 'Gemma-4-12B MLX 4-bit LM Studio', link: '/setups/kamaji/binaries/gemma12-lmstudio-mlx-4bit' },
              { text: 'Bonsai-27B MLX 2-bit', link: '/setups/kamaji/binaries/bonsai-mlx-2bit' },
              { text: 'Bonsai-27B Q2_g64 prism fork', link: '/setups/kamaji/binaries/bonsai-prism-q2g64' },
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
              { text: 'Qwen3.6-35B-A3B', link: '/setups/arrietty/reports/qwen3.6-35b-a3b' },
              { text: 'Gemma-4-26B-A4B', link: '/setups/arrietty/reports/gemma-4-26b-a4b' },
              { text: 'Gemma-4-12B-it', link: '/setups/arrietty/reports/gemma-4-12b-it' },
            ],
          },
          {
            text: 'Binaries',
            collapsed: true,
            items: [
              { text: 'Gemma-4-12B NVFP4 FreedomAISVR', link: '/setups/arrietty/binaries/gemma12-freedomaisvr-nvfp4' },
              { text: 'Gemma-4-12B UD-Q4_K_XL unsloth', link: '/setups/arrietty/binaries/gemma12-unsloth-ud-q4kxl' },
              { text: 'Qwen3.8-27B UD-IQ3_S unsloth', link: '/setups/arrietty/binaries/qwen38-unsloth-ud-iq3s' },
              { text: 'Qwen3.8-27B IQ3_S-mtp ISTA', link: '/setups/arrietty/binaries/qwen38-ista-iq3s-mtp' },
              { text: 'Qwen3.6-35B-A3B UD-Q4_K_XL unsloth', link: '/setups/arrietty/binaries/qwen36-unsloth-ud-q4kxl' },
              { text: 'Qwen3.6-35B-A3B NVFP4 michaelw9999', link: '/setups/arrietty/binaries/qwen36-michaelw9999-nvfp4' },
              { text: 'Gemma-4-26B-A4B NVFP4Q8 catlilface', link: '/setups/arrietty/binaries/gemma26-catlilface-nvfp4q8' },
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
