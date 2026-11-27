import { readFileSync, writeFileSync, existsSync, mkdirSync, globSync } from 'node:fs'
import { dirname, basename } from 'node:path'
import { execSync } from 'node:child_process'

const CHECK = process.argv.includes('--check')
const WRITE_PRESETS = process.argv.includes('--write-presets')

const PARTIAL_NOTE =
  'Rows below 100 percent completeness. Completeness counts three measurements: tok/s, EvalPlus, and Mendel.'

function parseCsv(text) {
  const rows = []
  let row = []
  let field = ''
  let inQ = false
  for (let i = 0; i < text.length; i++) {
    const c = text[i]
    if (inQ) {
      if (c === '"') {
        if (text[i + 1] === '"') {
          field += '"'
          i++
        } else {
          inQ = false
        }
      } else {
        field += c
      }
    } else if (c === '"') {
      inQ = true
    } else if (c === ',') {
      row.push(field)
      field = ''
    } else if (c === '\n') {
      row.push(field)
      rows.push(row)
      row = []
      field = ''
    } else if (c !== '\r') {
      field += c
    }
  }
  if (field !== '' || row.length) {
    row.push(field)
    rows.push(row)
  }
  const header = rows.shift()
  return rows
    .filter((r) => r.length > 1)
    .map((r) => Object.fromEntries(header.map((h, i) => [h, r[i] ?? ''])))
}

const dataFiles = globSync('data/setups/*/models.json').sort()
if (!dataFiles.length) {
  console.error('no setup files found under data/setups/*/models.json')
  process.exit(1)
}

const RAW_SETUPS = dataFiles.map((file) => {
  const data = JSON.parse(readFileSync(file, 'utf8'))
  const hardwareId = data.hardwareId || data.setup
  if (!hardwareId || !data.hardwareSlug) {
    throw new Error(`${file}: missing hardwareId or hardwareSlug`)
  }
  return { file, hardwareId, data }
})

const HARDWARE_IDS = RAW_SETUPS.map((s) => s.hardwareId)
const HARDWARE_SLUG = Object.fromEntries(RAW_SETUPS.map((s) => [s.hardwareId, s.data.hardwareSlug]))
const HARDWARE_NAME = Object.fromEntries(RAW_SETUPS.map((s) => [s.hardwareId, s.data.hardwareName || s.data.hardwareSlug]))
const DEFAULT_HARDWARE_ID = HARDWARE_IDS.includes('kamaji') ? 'kamaji' : HARDWARE_IDS[0]

function hardwareOf(r) {
  if (r.hardware) {
    if (!HARDWARE_SLUG[r.hardware]) {
      throw new Error(`Mendel row "${r.model}" names unknown hardware "${r.hardware}"`)
    }
    return r.hardware
  }
  const model = String(r.model || '')
  const matched = HARDWARE_IDS.find((id) => model.includes(`, ${id})`))
  return matched || DEFAULT_HARDWARE_ID
}

const MENDEL_WALLS = Object.fromEntries(
  RAW_SETUPS.flatMap(({ hardwareId, data }) =>
    Object.entries(data.mendelWalls || {}).map(([branch, min]) => [`${hardwareId}:${branch}`, min]),
  ),
)

function mendelWallOf(r) {
  if (r.invalid === true || r.invalid === 'True') {
    const raw = r.telemetry?.wall_clock_min ?? r['telemetry.wall_clock_min']
    return raw == null || raw === '' ? null : Number(raw)
  }
  const min = MENDEL_WALLS[`${hardwareOf(r)}:${r.branch}`] ?? r.telemetry?.wall_clock_min ?? r['telemetry.wall_clock_min']
  return min == null || min === '' ? null : Number(min)
}

const MENDEL_SLUGS = {
  'qwen3.6-35b-a3b': 'qwen3.6-35b-a3b',
  'qwen3.6-35b-a3b (unsloth UD-Q4_K_XL, off)': 'qwen3.6-35b-a3b',
  'qwen3.6-35b-a3b-f16 (unsloth UD-Q4_K_XL, no drafter, on)': 'qwen3.6-35b-a3b',
  'Qwen3.6-35B-A3B (mlx 4-bit, on)': 'qwen3.6-35b-a3b',
  'qwen3.8-27b (bartowski Q4_K_M, xhigh)': 'qwen3.8-27b',
  'gemma-4-26b-a4b': 'gemma-4-26b-a4b',
  'prism-ml/Ternary-Bonsai-27B-mlx-2bit': 'bonsai-27b',
  'mlx-community/Qwen3.8-27B-4bit': 'qwen3.8-27b',
  'Qwen3.8-27B (mlx, low)': 'qwen3.8-27b',
  'Ternary-Bonsai-27B (mlx, low)': 'bonsai-27b',
  'gemma-4-12b': 'gemma-4-12b-it',
  'google/gemma-4-12b': 'gemma-4-12b-it',
  'Gemma-4-12B (low)': 'gemma-4-12b-it',
  'Gemma-4-12B (llama.cpp, off)': 'gemma-4-12b-it',
  'bonsai-prism': 'bonsai-27b',
  'bonsai-prism (f16 KV)': 'bonsai-27b',
  'qwen3.8-27b': 'qwen3.8-27b',
  'qwen3.8-27b (reserve 8192)': 'qwen3.8-27b',
  'qwen3.8-27b (ISTA IQ3_S-mtp)': 'qwen3.8-27b',
  'qwen3.8-27b (ISTA IQ3_S-mtp, xhigh)': 'qwen3.8-27b',
  'qwen3.8-27b (ISTA IQ3_S-mtp, low)': 'qwen3.8-27b',
  'qwen3.8-27b (AtomicChat AD-IQ3_S)': 'qwen3.8-27b',
  'gemma-4-12b-nvfp4 (FreedomAISVR NVFP4, off, arrietty)': 'gemma-4-12b-it',
  'qwen3.8-27b-iq3s (unsloth UD-IQ3_S, xhigh, arrietty)': 'qwen3.8-27b',
  'gemma-4-26b-a4b-nvfp4 (catlilface NVFP4Q8, high, arrietty)': 'gemma-4-26b-a4b',
  'gemma-4-12b-nvfp4 (FreedomAISVR NVFP4, high, arrietty)': 'gemma-4-12b-it',
  'gemma-4-12b-q4kxl (unsloth UD-Q4_K_XL, high, arrietty)': 'gemma-4-12b-it',
  'qwen3.6-35b-a3b-q4kxl (unsloth UD-Q4_K_XL, n-max2, high, arrietty)': 'qwen3.6-35b-a3b',
  'bonsai2-27b-pq2 (prism-ml PQ2_0, xhigh, arrietty)': 'bonsai-2-27b',
  'bonsai2-27b-pq2-f16 (prism-ml PQ2_0, xhigh, arrietty)': 'bonsai-2-27b',
  'bonsai2-27b-ptq1 (prism-ml PTQ1_0, xhigh, arrietty)': 'bonsai-2-27b',
  'bonsai2-27b-ptq1-f16 (prism-ml PTQ1_0, xhigh, arrietty)': 'bonsai-2-27b',
  'bonsai2-27b-ptq1-f16-orca (prism-ml PTQ1_0, refusal-ablation LoRA 1.0, xhigh, arrietty)': 'bonsai-2-27b',
  'qwen3.8-27b-ista (ISTA-DASLab IQ3_S-mtp, xhigh, arrietty)': 'qwen3.8-27b',
  'qwen3.8-27b-iq3s (unsloth UD-IQ3_S, xhigh, kamaji)': 'qwen3.8-27b',
}

const MENDEL_SPECS = {
  'qwen3.6-35b-a3b': { base: 'Qwen3.6-35B-A3B', quant: 'UD-Q4_K_XL', publisher: 'unsloth', repo: 'unsloth/Qwen3.6-35B-A3B-MTP-GGUF', drafter: 'mtp/3', effort: 'on', binary: true },
  'qwen3.6-35b-a3b (unsloth UD-Q4_K_XL, off)': { base: 'Qwen3.6-35B-A3B', quant: 'UD-Q4_K_XL', publisher: 'unsloth', repo: 'unsloth/Qwen3.6-35B-A3B-MTP-GGUF', drafter: 'mtp/3', binary: true },
  'qwen3.6-35b-a3b-f16 (unsloth UD-Q4_K_XL, no drafter, on)': { base: 'Qwen3.6-35B-A3B', quant: 'UD-Q4_K_XL', publisher: 'unsloth', repo: 'unsloth/Qwen3.6-35B-A3B-MTP-GGUF', drafter: '', effort: 'on', binary: true },
  'Qwen3.6-35B-A3B (mlx 4-bit, on)': { base: 'Qwen3.6-35B-A3B', quant: '4-bit', publisher: 'mlx-community', repo: 'mlx-community/Qwen3.6-35B-A3B-4bit', drafter: '', effort: 'on', binary: true },
  'gemma-4-26b-a4b': { base: 'Gemma-4-26B-A4B', quant: 'UD-Q4_K_XL', publisher: 'unsloth', repo: 'unsloth/gemma-4-26b-a4b-it-GGUF', drafter: 'mtp/2', effort: 'on', binary: true },
  'prism-ml/Ternary-Bonsai-27B-mlx-2bit': { base: 'Ternary-Bonsai-27B', quant: '2-bit', publisher: 'prism-ml', repo: 'prism-ml/Ternary-Bonsai-27B-mlx-2bit', drafter: '', effort: 'on', binary: true },
  'Ternary-Bonsai-27B (mlx, low)': { base: 'Ternary-Bonsai-27B', quant: '2-bit', publisher: 'prism-ml', repo: 'prism-ml/Ternary-Bonsai-27B-mlx-2bit', drafter: '', binary: true },
  'mlx-community/Qwen3.8-27B-4bit': { base: 'Qwen3.8-27B', quant: '4-bit', publisher: 'mlx-community', repo: 'mlx-community/Qwen3.8-27B-4bit', drafter: '', effort: 'medium' },
  'Qwen3.8-27B (mlx, low)': { base: 'Qwen3.8-27B', quant: '4-bit', publisher: 'mlx-community', repo: 'mlx-community/Qwen3.8-27B-4bit', drafter: '' },
  'gemma-4-12b': { base: 'Gemma-4-12B', quant: 'Q4_K_XL', publisher: 'unsloth', repo: 'unsloth/gemma-4-12b-it-GGUF', drafter: '' },
  'google/gemma-4-12b': { base: 'Gemma-4-12B', quant: '4-bit', publisher: 'lmstudio-community', repo: 'lmstudio-community/gemma-4-12B-it-MLX-4bit', drafter: '' },
  'Gemma-4-12B (low)': { base: 'Gemma-4-12B', quant: '4-bit', publisher: 'lmstudio-community', repo: 'lmstudio-community/gemma-4-12B-it-MLX-4bit', drafter: '' },
  'Gemma-4-12B (llama.cpp, off)': { base: 'Gemma-4-12B', quant: 'Q4_K_XL', publisher: 'unsloth', repo: 'unsloth/gemma-4-12b-it-GGUF', drafter: '' },
  'bonsai-prism': { base: 'Ternary-Bonsai-27B', quant: 'Q2_g64', publisher: 'prism-ml', repo: 'prism-ml/Ternary-Bonsai-27B-gguf', drafter: '', server: 'prism-llama', kv: 'q4_0+bias', binary: true },
  'bonsai-prism (f16 KV)': { base: 'Ternary-Bonsai-27B', quant: 'Q2_g64', publisher: 'prism-ml', repo: 'prism-ml/Ternary-Bonsai-27B-gguf', drafter: '', server: 'prism-llama', binary: true },
  'qwen3.8-27b': { base: 'Qwen3.8-27B', quant: 'Q4_K_M', publisher: 'bartowski', repo: 'bartowski/Qwen3.8-27B-GGUF', drafter: 'mtp/3' },
  'qwen3.8-27b (reserve 8192)': { base: 'Qwen3.8-27B', quant: 'Q4_K_M', publisher: 'bartowski', repo: 'bartowski/Qwen3.8-27B-GGUF', drafter: 'mtp/3' },
  'qwen3.8-27b (bartowski Q4_K_M, xhigh)': { base: 'Qwen3.8-27B', quant: 'Q4_K_M', publisher: 'bartowski', repo: 'bartowski/Qwen3.8-27B-GGUF', drafter: 'mtp/3' },
  'qwen3.8-27b (ISTA IQ3_S-mtp)': { base: 'Qwen3.8-27B', quant: 'IQ3_S-mtp', publisher: 'ISTA-DASLab', repo: 'ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF', drafter: 'mtp/3' },
  'qwen3.8-27b (ISTA IQ3_S-mtp, xhigh)': { base: 'Qwen3.8-27B', quant: 'IQ3_S-mtp', publisher: 'ISTA-DASLab', repo: 'ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF', drafter: '' },
  'qwen3.8-27b (ISTA IQ3_S-mtp, low)': { base: 'Qwen3.8-27B', quant: 'IQ3_S-mtp', publisher: 'ISTA-DASLab', repo: 'ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF', drafter: '' },
  'qwen3.8-27b (AtomicChat AD-IQ3_S)': { base: 'Qwen3.8-27B', quant: 'AD-IQ3_S', publisher: 'AtomicChat', repo: 'AtomicChat/Qwen3.8-27B-GGUF', drafter: 'mtp/3' },
  'gemma-4-12b-nvfp4 (FreedomAISVR NVFP4, off, arrietty)': { base: 'Gemma-4-12B', quant: 'NVFP4', publisher: 'FreedomAISVR', repo: 'FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF', drafter: '', binary: true },
  'qwen3.8-27b-iq3s (unsloth UD-IQ3_S, xhigh, arrietty)': { base: 'Qwen3.8-27B', quant: 'UD-IQ3_S', publisher: 'unsloth', repo: 'unsloth/Qwen3.8-27B-GGUF', drafter: '' },
  'gemma-4-26b-a4b-nvfp4 (catlilface NVFP4Q8, high, arrietty)': { base: 'Gemma-4-26B-A4B', quant: 'NVFP4Q8', publisher: 'catlilface', repo: 'catlilface/Gemma-4-26B-A4B-NVFP4-GGUF', drafter: '', binary: true },
  'gemma-4-12b-nvfp4 (FreedomAISVR NVFP4, high, arrietty)': { base: 'Gemma-4-12B', quant: 'NVFP4', publisher: 'FreedomAISVR', repo: 'FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF', drafter: '', binary: true },
  'gemma-4-12b-q4kxl (unsloth UD-Q4_K_XL, high, arrietty)': { base: 'Gemma-4-12B', quant: 'UD-Q4_K_XL', publisher: 'unsloth', repo: 'unsloth/gemma-4-12b-it-GGUF', drafter: '', binary: true },
  'qwen3.6-35b-a3b-q4kxl (unsloth UD-Q4_K_XL, n-max2, high, arrietty)': { base: 'Qwen3.6-35B-A3B', quant: 'UD-Q4_K_XL', publisher: 'unsloth', repo: 'unsloth/Qwen3.6-35B-A3B-MTP-GGUF', drafter: 'mtp/2', binary: true },
  'bonsai2-27b-ptq1-f16 (prism-ml PTQ1_0, xhigh, arrietty)': { base: 'Ternary-Bonsai-2-27B', quant: 'PTQ1_0', publisher: 'prism-ml', repo: 'prism-ml/Ternary-Bonsai-2-27B-gguf', drafter: '', server: 'prism-llama', kv: 'f16' },
  'bonsai2-27b-ptq1-f16-orca (prism-ml PTQ1_0, refusal-ablation LoRA 1.0, xhigh, arrietty)': { base: 'Ternary-Bonsai-2-27B', quant: 'PTQ1_0', publisher: 'prism-ml', repo: 'prism-ml/Ternary-Bonsai-2-27B-gguf', drafter: '', server: 'prism-llama', kv: 'f16', adapter: 'refusal-ablation LoRA 1.0' },
  'bonsai2-27b-ptq1 (prism-ml PTQ1_0, xhigh, arrietty)': { base: 'Ternary-Bonsai-2-27B', quant: 'PTQ1_0', publisher: 'prism-ml', repo: 'prism-ml/Ternary-Bonsai-2-27B-gguf', drafter: '', server: 'prism-llama', kv: 'q8_0' },
  'bonsai2-27b-pq2-f16 (prism-ml PQ2_0, xhigh, arrietty)': { base: 'Ternary-Bonsai-2-27B', quant: 'PQ2_0', publisher: 'prism-ml', repo: 'prism-ml/Ternary-Bonsai-2-27B-gguf', drafter: '', server: 'prism-llama', kv: 'f16' },
  'bonsai2-27b-pq2 (prism-ml PQ2_0, xhigh, arrietty)': { base: 'Ternary-Bonsai-2-27B', quant: 'PQ2_0', publisher: 'prism-ml', repo: 'prism-ml/Ternary-Bonsai-2-27B-gguf', drafter: '', server: 'prism-llama', kv: 'q8_0' },
  'qwen3.8-27b-ista (ISTA-DASLab IQ3_S-mtp, xhigh, arrietty)': { base: 'Qwen3.8-27B', quant: 'IQ3_S-mtp', publisher: 'ISTA-DASLab', repo: 'ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF', drafter: '' },
  'qwen3.8-27b-iq3s (unsloth UD-IQ3_S, xhigh, kamaji)': { base: 'Qwen3.8-27B', quant: 'UD-IQ3_S', publisher: 'unsloth', repo: 'unsloth/Qwen3.8-27B-GGUF', drafter: '' },
}

const EFFORTS = ['off', 'on', 'low', 'medium', 'high', 'xhigh', 'max']
const MENDEL_SERVER = { 'llama-server': 'llama-server', 'mlx_lm.server': 'mlx_lm.server', 'lm-studio': 'lms' }

function repoOf(row) {
  if (row.spec?.repo) return row.spec.repo
  const cmd = String(row.command || '').replace(/\\\n/g, ' ')
  const m = cmd.match(/(?:-hf|--model)[= ]([\w.-]+\/[\w.-]+)/)
  if (!m) throw new Error(`row ${row.id}: no Hugging Face repo in the command; add spec.repo`)
  return m[1]
}

const BINARIES = JSON.parse(readFileSync('data/binaries.json', 'utf8'))
const binaryKey = (spec) => ['base', 'quant', 'publisher', 'server'].map((k) => spec?.[k] || '').join('|')
const BINARY_PAGES = new Map(
  BINARIES.flatMap((b) => [b.spec.quant, ...(b.quantAliases || [])].map((quant) => [binaryKey({ ...b.spec, quant }), `/files/${b.id}`])),
)
const binaryPageOf = (spec) => BINARY_PAGES.get(binaryKey(spec)) || ''
const binaryMatch = (b) => {
  const keys = new Set([b.spec.quant, ...(b.quantAliases || [])].map((quant) => binaryKey({ ...b.spec, quant })))
  return (spec) => keys.has(binaryKey(spec))
}

const MODEL_SLUG_BY_BASE = new Map()
for (const { data } of RAW_SETUPS) {
  for (const [slug, m] of Object.entries(data.models || {})) {
    const matchRow = (data.rows || []).find((r) => r.config?.startsWith(m.rowMatch) && r.spec?.base)
    if (matchRow) MODEL_SLUG_BY_BASE.set(matchRow.spec.base, slug)
  }
}

function specTag(spec, { hide = '', label = '', repo = '', top = false, hardware = '', modelPage = '' } = {}) {
  for (const k of ['base', 'quant', 'server', 'publisher', 'kv']) {
    if (k === 'server' && hide.split(',').includes('server')) continue
    if (!spec?.[k]) throw new Error(`spec ${label || JSON.stringify(spec)}: missing ${k}`)
  }
  const card = repo || spec.repo
  if (!card) throw new Error(`spec ${label || spec.base}: missing repo`)
  const hideEffort = hide.split(',').includes('effort')
  if (!hideEffort && !EFFORTS.includes(spec.effort)) {
    throw new Error(`spec ${label || spec.base}: effort "${spec.effort}" is not one of ${EFFORTS.join(', ')}`)
  }
  const attrs = [
    `base="${spec.base}"`,
    `quant="${spec.quant}"`,
    `server="${spec.server}"`,
    `publisher="${spec.publisher}"`,
    `repo="${card}"`,
    spec.drafter ? `drafter="${spec.drafter}"` : '',
    spec.offload ? `offload="${spec.offload}"` : '',
    spec.adapter ? `adapter="${spec.adapter}"` : '',
    `kv="${spec.kv}"`,
    spec.effort && !hideEffort ? `effort="${spec.effort}"` : '',
    hardware ? `hardware="${hardware}"` : '',
    binaryPageOf(spec) ? `page="${binaryPageOf(spec)}"` : '',
    modelPage ? `model-page="${modelPage}"` : '',
    hide ? `hide="${hide}"` : '',
    top ? 'top' : '',
  ].filter(Boolean)
  return `<ModelSpec ${attrs.join(' ')} />`
}

function scoreTag(value, sub = '', top = false, pill = '', note = '') {
  const clean = (v) => String(v).replace(/"/g, '')
  return `<ScoreCell value="${clean(value)}"${note ? ` note="${clean(note)}"` : ''}${pill ? ` pill="${clean(pill)}"` : ''}${sub ? ` sub="${clean(sub)}"` : ''}${top ? ' top' : ''} />`
}

function evalplusCell(text) {
  const m = String(text).match(/^([\d.]+\/[\d.]+)\/(\d+%|—)$/)
  return m ? { value: m[1], sub: m[2] === '—' ? '' : `${m[2]} completion` } : { value: String(text), sub: '' }
}

function mendelCellParts(r) {
  if (r.mendel === 'failed-smoke') return { value: '0', note: '0%', pill: 'failed-smoke' }
  if (r.mendel === 'model-failed' || r.mendelFailed) return { value: '0', note: '0%', pill: 'model-failed' }
  const m = String(r.mendel).match(/^([\d.]+)(?:\s*\(partial\s*(\d+%)\))?$/)
  if (!m) return { value: String(r.mendel), note: '', pill: '' }
  return { value: m[1], note: m[2] || '', pill: `mendel-${r.mendelTest || 'blind'}` }
}

function mendelKey(spec, slots) {
  return [...['base', 'quant', 'publisher', 'server', 'drafter', 'kv', 'effort', 'adapter'].map((k) => spec[k] || ''), slots].join('|')
}

function rowSlots(row) {
  const m = String(row.command || '').match(/--parallel (\d+)/)
  return m ? Number(m[1]) : 1
}

function runSlots(r) {
  const m = `${r.model_id} ${r.branch}`.match(/-(\d)x\b/)
  return m ? Number(m[1]) : 1
}

function thinkingLevel(branch) {
  const m = String(branch).match(/-(xhigh|high|medium|low|off)-/)
  return m ? m[1] : 'default'
}

function mendelSpec(r) {
  const m = MENDEL_SPECS[r.model]
  if (!m) throw new Error(`Mendel row "${r.model}" has no entry in MENDEL_SPECS`)
  const level = thinkingLevel(r.branch)
  return {
    base: m.base,
    quant: m.quant,
    server: m.server || MENDEL_SERVER[r.serving] || r.serving,
    publisher: m.publisher,
    drafter: m.drafter,
    repo: m.repo,
    adapter: m.adapter,
    kv: m.kv || (r.kv_type === 'unquantized' || !r.kv_type ? 'f16' : r.kv_type),
    effort: level === 'default' ? m.effort : m.binary ? (level === 'off' ? 'off' : 'on') : level,
  }
}

function deriveMendel(rows, blind, guided) {
  const runs = [
    ...blind.filter((r) => r.local === 'True').map((r) => ({ r, test: 'blind' })),
    ...guided.filter((r) => r.local === 'True').map((r) => ({ r, test: 'guided' })),
  ].map((x) => ({ ...x, key: mendelKey(mendelSpec(x.r), runSlots(x.r)) }))
  const done = (r) => (r.libraries_done === '' ? 8 : Number(r.libraries_done))
  const capped = (r) => Math.min(Number(r.score_total), (100 * done(r)) / 8)
  for (const row of rows) {
    if (!row.spec) continue
    if (/^[\d.]/.test(String(row.mendel))) {
      throw new Error(`row ${row.id}: mendel "${row.mendel}" is a number; write pending, not run, invalid, model-failed, or failed-smoke`)
    }
    const rowKey = mendelKey({ ...row.spec, drafter: row.mendelDrafter ?? row.spec.drafter }, rowSlots(row))
    const match = runs
      .filter((x) => x.key === rowKey)
      .sort((a, b) => done(b.r) - done(a.r) || capped(b.r) - capped(a.r))[0]
    if (!match) continue
    const partial = match.r.partial === 'True'
    row.mendel = `${capped(match.r)}${partial ? ` (partial ${Math.round((100 * done(match.r)) / 8)}%)` : ''}`
    row.mendelTest = match.test
    row.mendelFailed = match.r['telemetry.commits'] === '0'
    if (row.simulatorWall == null) row.simulatorWall = mendelWallOf(match.r)
  }
}

function mendelCell(r, { global = false, linkModel = true } = {}) {
  const slug = MENDEL_SLUGS[r.model]
  const setup = hardwareOf(r)
  return specTag(mendelSpec(r), {
    label: r.model,
    hardware: global ? HARDWARE_SLUG[setup] : '',
    modelPage: linkModel && slug ? `/models/${slug}` : '',
  })
}

function mendelScore(r) {
  const done = r.libraries_done === '' ? 8 : Number(r.libraries_done)
  const cap = Math.min(Number(r.score_total), (100 * done) / 8)
  return `**${cap}/100**${r.partial === 'True' ? ' (partial)' : ''}`
}

function currentPromptVersion(rows) {
  const num = (v) => String(v || 'v0').replace(/^v/, '').split('.').reduce((a, p) => a * 1000 + Number(p), 0)
  const latest = rows.map((r) => r.prompt_version).sort((a, b) => num(a) - num(b)).at(-1)
  return rows.filter((r) => r.prompt_version === latest)
}

function checkMendelImport() {
  const countCsv = (f) => parseCsv(readFileSync(f, 'utf8')).length
  const countJson = (f) => JSON.parse(readFileSync(f, 'utf8')).runs.length
  const pairs = [
    ['blind', 'benchmarks/mendel/results.csv', 'benchmarks/mendel/results.json', 'benchmarks/mendel/report.html'],
    ['guided', 'benchmarks/mendel/results-guided.csv', 'benchmarks/mendel/results-guided.json', 'benchmarks/mendel/report-guided.html'],
  ]
  const errors = []
  for (const [test, csv, json, html] of pairs) {
    if (!existsSync(csv) || !existsSync(json)) continue
    const inCsv = countCsv(csv)
    const inJson = countJson(json)
    if (inCsv !== inJson) {
      errors.push(`${test}: ${csv} has ${inCsv} runs, ${json} has ${inJson}`)
      continue
    }
    if (!existsSync(html)) continue
    const runs = JSON.parse(readFileSync(json, 'utf8')).runs
    const newest = runs[runs.length - 1]?.model
    const page = readFileSync(html, 'utf8')
    const escaped = String(newest).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
    if (newest && !page.includes(newest) && !page.includes(escaped)) {
      errors.push(`${test}: ${html} does not show "${newest}"`)
    }
  }
  const slugKeys = Object.keys(MENDEL_SLUGS)
  const specKeys = Object.keys(MENDEL_SPECS)
  for (const k of slugKeys) if (!specKeys.includes(k)) errors.push(`MENDEL_SLUGS has "${k}" without MENDEL_SPECS`)
  for (const k of specKeys) if (!slugKeys.includes(k)) errors.push(`MENDEL_SPECS has "${k}" without MENDEL_SLUGS`)
  for (const csv of ['benchmarks/mendel/results.csv', 'benchmarks/mendel/results-guided.csv']) {
    if (!existsSync(csv)) continue
    for (const r of parseCsv(readFileSync(csv, 'utf8')).filter((x) => x.local === 'True')) {
      if (!MENDEL_SLUGS[r.model]) errors.push(`${csv}: local run "${r.model}" missing from MENDEL_SLUGS`)
      if (!MENDEL_SPECS[r.model]) errors.push(`${csv}: local run "${r.model}" missing from MENDEL_SPECS`)
    }
  }
  if (!errors.length) return
  console.error('Mendel data consistency check failed:')
  for (const e of errors) console.error('  ' + e)
  process.exit(1)
}
checkMendelImport()

function mendelRuns(file, hardwareId) {
  return JSON.parse(readFileSync(file, 'utf8'))
    .runs.filter((r) => r.local && r.invalid !== true && hardwareOf(r) === hardwareId)
    .map((r) => ({
      ...r,
      libraries_done: r.libraries_done == null ? 8 : Number(r.libraries_done),
      kv_type: r.kv_type || 'f16',
      telemetry: r.telemetry || {},
    }))
}

function buildKey(spec) {
  return ['base', 'quant', 'publisher', 'server'].map((k) => spec[k] || '').join('|')
}

function onRetiredBuild(rows) {
  const retired = new Set(rows.filter((row) => (row.abandoned || row.retired) && row.spec).map((row) => buildKey(row.spec)))
  return (r) => (r.local === true || r.local === 'True') && retired.has(buildKey(mendelSpec(r)))
}

function pill(text, tone = 'gray') {
  return `<span class="ms-pill cs-pill cs-pill-${tone}">${text}</span>`
}

function mendelWindow(r) {
  const note = String(r.config_note || '')
  const m = note.match(/(?:contextWindow|window)\s+(\d{4,6})/i)
  if (m) return Number(m[1])
  const t = r.telemetry
  const peak = Number(t.peak_context)
  const pct = Number(t.window_pct)
  const est = peak > 0 && pct > 0 ? (peak / pct) * 100 : 0
  const ladder = [24576, 26624, 32768, 36864, 40960, 49152, 53248, 57344, 65536, 81920, 98304, 114688, 122880, 131072, 147456, 163840, 212992, 262144]
  return est ? ladder.reduce((a, b) => (Math.abs(b - est) < Math.abs(a - est) ? b : a)) : 0
}

let mendelSiteRows = []
function siteRowFor(run) {
  const key = mendelKey(mendelSpec(run), runSlots(run))
  return mendelSiteRows.find(
    (row) =>
      row.spec &&
      !row.retired &&
      (!row.hardwareId || row.hardwareId === hardwareOf(run)) &&
      mendelKey({ ...row.spec, drafter: row.mendelDrafter ?? row.spec.drafter }, rowSlots(row)) === key,
  )
}

const mendelCapped = (r) => Math.min(Number(r.score_total), (100 * r.libraries_done) / 8)
const mendelWall = (r) => mendelWallOf(r) ?? NaN
const mendelCtxUse = (r) => (Number(r.telemetry.compactions) || 0) * 100 + (Math.round(Number(r.telemetry.window_pct)) || 0)

function twoLines(pills) {
  const text = (p) => p.replace(/<[^>]+>/g, '')
  const total = pills.reduce((n, p) => n + text(p).length, 0)
  const first = []
  let used = 0
  for (const p of pills) {
    if (first.length && used + text(p).length > total / 2) break
    first.push(p)
    used += text(p).length
  }
  const rest = pills.slice(first.length)
  const line = (ps) => `<span class="pills">${ps.join(' ')}</span>`
  return rest.length ? `${line(first)}<br>${line(rest)}` : line(first)
}

function mendelRow(r, { test = '', top = {}, global = false, linkModel = true } = {}) {
  const t = r.telemetry
  const k = (v) => (v == null || v === '' ? '—' : `${Math.round(Number(v) / 1000)}k`)
  const m = (v) => (v == null || v === '' ? '—' : `${(Number(v) / 1e6).toFixed(1)}M`)
  const tokensCell = (t) =>
    t.tokens_total ? `<span class="ctxuse">${k(t.tokens_out)}<br>${pill(m(t.tokens_total), 'gray')}</span>` : k(t.tokens_out)
  const bold = (text, set) => (set?.has(r) ? `**${text}**` : text)
  const done = r.libraries_done
  const cap = mendelCapped(r)
  const score = scoreTag(cap, '', top.score?.has(r), '', done < 8 ? `${Math.round((100 * done) / 8)}%` : '')
  const wall = Number.isNaN(mendelWall(r)) ? '—' : bold(`${Math.round(mendelWall(r))} min`, top.wall)
  const window = mendelWindow(r)
  const site = siteRowFor(r)
  const windowStale = site?.pi?.contextWindow > window
  const windowCell = window ? `${bold(`${Math.round(window / 1024)}k`, top.window)}${windowStale ? '†' : ''}` : '—'
  const speed = site
    ? `<TokCell shallow="${site.tokShallow}" deep="${site.tokDeep}"${top.tokShallow?.has(r) ? ' top-shallow' : ''}${top.tokDeep?.has(r) ? ' top-deep' : ''} />`
    : ''
  const ctxSpeed = speed ? `<span class="ctxuse">${windowCell}<br>${speed}</span>` : windowCell
  const comp = Number(t.compactions) || 0
  const use = bold(`${mendelCtxUse(r)}%`, top.ctx)
  const ctx = comp
    ? `<span class="ctxuse">${use}<br>${pill(`${comp} compaction${comp > 1 ? 's' : ''}`, 'yellow')}</span>`
    : use
  const counts = { critical: 0, medium: 0, minor: 0 }
  for (const d of r.defects || []) if (d.severity in counts) counts[d.severity] += 1
  const bugs = [
    counts.critical ? pill(`${counts.critical} critical`, 'red') : '',
    counts.medium ? pill(`${counts.medium} medium`, 'yellow') : '',
    counts.minor ? pill(`${counts.minor} minor`, 'gray') : '',
  ].filter(Boolean)
  const bugsCell = bugs.length ? twoLines(bugs) : pill('0 bugs', 'green')
  const nudges = [t.nudges_tooling ? `${t.nudges_tooling}t` : '', t.nudges_model ? `${t.nudges_model}m` : ''].filter(Boolean)
  const stats = [
    Number(t.commits) === 0 ? pill('model-failed', 'red') : '',
    t.tool_calls != null ? pill(`calls ${t.tool_calls}/${t.tool_errors ?? 0}`) : '',
    pill(`commits ${t.commits ?? 0}`),
    t.failed_commits ? pill(`failed commits ${t.failed_commits}`, 'red') : '',
    t.assistant_msgs ? pill(`turns ${t.assistant_msgs}`) : '',
    nudges.length ? pill(`nudges ${nudges.join(' ')}`, 'yellow') : '',
    t.loop_flag === 'LOOP' ? pill(`loop ${t.loop_kind || ''}`.trim(), 'red') : '',
    Number(t.truncation_pct) ? pill(`trimmed ${t.truncation_pct}%`) : '',
  ].filter(Boolean)
  const cells = [
    mendelCell(r, { global, linkModel }),
    ...(test ? [pill(`mendel-${test}`, test === 'blind' ? 'yellow' : 'green')] : []),
    score,
    wall,
    ctxSpeed,
    tokensCell(t),
    ctx,
    bugsCell,
    twoLines(stats),
  ]
  return `| ${cells.join(' | ')} |`
}

function mendelTable(rows, { test = false, global = false, linkModel = true } = {}) {
  const header = [
    `| Model / Config |${test ? ' Test |' : ''} Score | Wall | Ctx / speed | Out/Total | Ctx use | Bugs | Stats |`,
    `|---|${test ? '---|' : ''}--:|--:|--:|--:|--:|---|---|`,
  ]
  const capped = (r) => Math.min(Number(r.score_total), (100 * r.libraries_done) / 8)
  const ordered = [...rows].sort((a, b) => capped(b) - capped(a))
  const top = {
    score: topSet(ordered, mendelCapped),
    wall: topSet(ordered, mendelWall, { lower: true }),
    window: topSet(ordered, mendelWindow),
    ctx: topSet(ordered, mendelCtxUse, { lower: true }),
    tokShallow: topSet(ordered, (r) => parseFloat(siteRowFor(r)?.tokShallow)),
    tokDeep: topSet(ordered, (r) => parseFloat(siteRowFor(r)?.tokDeep)),
  }
  const body = ordered.map((r) => mendelRow(r, { test: test ? r.test : '', top, global, linkModel }))
  return [...header, ...body].join('\n')
}

function renderMendelStale(blindAll, guidedAll) {
  const stale = (all) => {
    const current = new Set(currentPromptVersion(all).map((r) => `${hardwareOf(r)}:${r.branch}`))
    return all.filter((r) => !current.has(`${hardwareOf(r)}:${r.branch}`))
  }
  const rows = [
    ...stale(blindAll).map((r) => ({ ...r, test: 'blind' })),
    ...stale(guidedAll).map((r) => ({ ...r, test: 'guided' })),
  ]
  if (!rows.length) return 'No stale row.'
  return mendelTable(rows, { test: true, global: true })
}

function renderMendelCloud(rows) {
  const header = ['| model | harness | score |', '|---|---|--:|']
  const body = rows
    .filter((r) => r.local !== 'True')
    .sort(
      (a, b) =>
        Math.min(b.score_total, (100 * (b.libraries_done === '' ? 8 : b.libraries_done)) / 8) -
        Math.min(a.score_total, (100 * (a.libraries_done === '' ? 8 : a.libraries_done)) / 8),
    )
    .map((r) => `| ${r.model.replace(/^.*\//, '')} | ${r.harness} | ${mendelScore(r)} |`)
  return [...header, ...body].join('\n')
}

function renderBinaryMendel(blindRows, guidedRows, match) {
  const tagged = [
    ...blindRows.map((r) => ({ r, test: 'blind' })),
    ...guidedRows.map((r) => ({ r, test: 'guided' })),
  ].filter(({ r }) => match(r))
  if (!tagged.length) return 'No Mendel run yet.'

  const capped = (r) => {
    const done = r.libraries_done === '' ? 8 : Number(r.libraries_done)
    return Math.min(Number(r.score_total), (100 * done) / 8)
  }
  tagged.sort((a, b) => capped(b.r) - capped(a.r))

  const esc = (v) => String(v ?? '').replace(/\|/g, '\\|')
  const thousands = (v) => {
    const n = Number(v)
    if (!Number.isFinite(n) || v === '') return '—'
    return `${Math.round(n / 1000).toLocaleString('en-US')}k`
  }
  const ladder = [26624, 32768, 49152, 57344, 65536, 81920, 98304, 114688, 131072, 147456, 163840, 212992, 262144]
  const winStr = (r) => {
    const peak = Number(r['telemetry.peak_context'])
    const pct = Number(r['telemetry.window_pct'])
    const est = peak > 0 && pct > 0 ? (peak / pct) * 100 : 0
    const snapped = est ? ladder.reduce((a, b) => (Math.abs(b - est) < Math.abs(a - est) ? b : a)) : 0
    return snapped ? `${Math.round(snapped / 1024)}k` : '?k'
  }
  const header = [
    '| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |',
    '|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|',
  ]
  const line = ({ r, test }) => {
    const done = r.libraries_done === '' ? 8 : Number(r.libraries_done)
    const cap = capped(r)
    const raw = Number(r.score_total)
    const score = cap < raw ? `**${cap}** (raw ${raw})` : `**${cap}**`
    const wall = mendelWallOf(r)
    const minutes = wall == null || Number.isNaN(wall) ? '—' : wall.toFixed(1)
    const state = r.invalid === 'True' ? 'invalid' : r['telemetry.commits'] === '0' ? 'model-failed' : r.partial === 'True' ? 'partial' : 'done'
    const loop = r['telemetry.loop_flag'] === 'LOOP' ? esc(r['telemetry.loop_kind'] || 'yes') : ''
    const slug = MENDEL_SLUGS[r.model]
    return `| ${[
      specTag(mendelSpec(r), {
        label: r.model,
        hardware: HARDWARE_SLUG[hardwareOf(r)],
        modelPage: slug ? `/models/${slug}` : '',
      }),
      `${test}-${esc(r.prompt_version)}`,
      winStr(r),
      score,
      `${done}/8/${state}`,
      minutes,
      thousands(r['telemetry.tokens_total']),
      thousands(r['telemetry.peak_context']),
      esc(r['telemetry.compactions'] || '0'),
      esc(r['telemetry.tool_calls'] || '0'),
      esc(r['telemetry.commits'] || '0'),
      loop,
    ].join(' | ')} |`
  }
  const blind = tagged.filter((t) => t.test === 'blind').map(line)
  const guided = tagged.filter((t) => t.test === 'guided').map(line)
  const parts = []
  if (blind.length) parts.push('Blind test:', '', ...header, ...blind)
  if (guided.length) parts.push(...(blind.length ? [''] : []), 'Guided test:', '', ...header, ...guided)
  return parts.join('\n')
}

function parseCtx(s) {
  const nxk = String(s).match(/(\d+)x([\d.]+)k/i)
  if (nxk) return parseFloat(nxk[2]) * 1000
  const k = String(s).match(/([\d.]+)k/i)
  if (k) return parseFloat(k[1]) * 1000
  return parseFloat(s) || 0
}

function parseScore(evalplus) {
  const m = String(evalplus).match(/^([\d.]+)/)
  return m ? parseFloat(m[1]) : -1
}

function parseMendel(mendel) {
  if (mendel === 'failed-smoke' || mendel === 'model-failed') return 0
  const m = String(mendel ?? '').match(/^([\d.]+)/)
  return m ? parseFloat(m[1]) : null
}

function mendelFailedCell(r) {
  return r.mendel === 'failed-smoke' || r.mendel === 'model-failed' || r.mendelFailed === true
}

function hasTok(r) {
  return !['tokShallow', 'tokDeep'].some((k) => String(r[k]).includes('pending'))
}

function completeness(r) {
  const parts = [hasTok(r), parseScore(r.evalplus) >= 0, parseMendel(r.mendel) !== null]
  return parts.filter(Boolean).length / parts.length
}

function isComplete(r) {
  return completeness(r) === 1
}

function composite(r) {
  const e = Math.max(parseScore(r.evalplus), 0)
  const m = parseMendel(r.mendel) ?? 0
  return (e * 100 + m) / 2
}

function sortRows(rows) {
  return [...rows].sort((a, b) => {
    const ca = composite(a)
    const cb = composite(b)
    if (ca !== null && cb !== null && ca !== cb) return cb - ca
    const scoreDiff = parseScore(b.evalplus) - parseScore(a.evalplus)
    if (scoreDiff !== 0) return scoreDiff
    return parseCtx(b.maxCtx) - parseCtx(a.maxCtx)
  })
}

const GATED_BY = new Set(['mem', 'speed', 'pending'])

function checkRows(rows, slug) {
  for (const r of rows) {
    if (r.retired) continue
    if (!GATED_BY.has(r.gatedBy)) {
      throw new Error(`${slug}: row ${r.id} has gatedBy "${r.gatedBy}"; allowed: ${[...GATED_BY].join(', ')}`)
    }
    if (typeof r.mendel !== 'string' || !r.mendel) {
      throw new Error(`${slug}: row ${r.id} has no mendel cell`)
    }
    if (r.spec && !binaryPageOf(r.spec)) {
      throw new Error(`${slug}: row "${r.id}" (${binaryKey(r.spec)}) matches no data/binaries.json entry`)
    }
  }
}

function topSet(rows, read, { lower = false } = {}) {
  const vals = rows.map((r) => read(r)).map((v) => (Number.isFinite(v) ? v : null))
  const ranked = [...new Set(vals.filter((v) => v !== null))].sort((x, y) => (lower ? x - y : y - x))
  if (!ranked.length) return new Set()
  const second = ranked[Math.min(1, ranked.length - 1)]
  const span = Math.abs(ranked[0] - ranked[ranked.length - 1])
  const near = (v) => Math.abs(v - second) <= 0.15 * span && (lower ? v > second : v < second)
  return new Set(rows.filter((r, i) => vals[i] !== null && (vals[i] === ranked[0] || vals[i] === second || near(vals[i]))))
}

function renderTable(
  rows,
  { footnotes = true, sort = true, memory = true, hardware = false, hide = '', linkModel = true, pageLink = (r) => r.abandoned.page } = {},
) {
  const header = [
    `| Model / Config | Ctx | tok/s |${memory ? ' Memory<br>(at max ctx) |' : ''} HumanEval+ | Coding | Wall |`,
    `|---|--:|--:|${memory ? '--:|' : ''}--:|--:|--:|`,
  ]
  const hm = (min) => {
    if (min == null || Number.isNaN(Number(min))) return '—'
    const m = Math.round(min)
    return `${Math.floor(m / 60)}h${String(m % 60).padStart(2, '0')}`
  }
  const wallTotal = (r) => {
    if (r.evalplusWall == null || r.simulatorWall == null) return NaN
    return Number(r.evalplusWall) + Number(r.simulatorWall)
  }
  const wall = (r, isTop = false) => {
    if (r.evalplusWall == null && r.simulatorWall == null) return '—'
    const sum = (Number(r.evalplusWall) || 0) + (Number(r.simulatorWall) || 0)
    const partial = r.evalplusWall == null || r.simulatorWall == null ? '†' : ''
    const text = `${hm(sum)}${partial}`
    const body = isTop ? `<b>${text}</b>` : text
    return `<span title="EvalPlus ${hm(r.evalplusWall)} · Mendel ${hm(r.simulatorWall)}">${body}</span>`
  }
  const ordered = sort ? sortRows(rows) : rows
  const num = (s) => parseFloat(String(s).replace(/[^\d.]/g, ''))
  const top = {
    maxCtx: topSet(ordered, (r) => parseCtx(r.maxCtx)),
    tokShallow: topSet(ordered, (r) => num(r.tokShallow)),
    tokDeep: topSet(ordered, (r) => num(r.tokDeep)),
    memory: topSet(ordered, (r) => num(r.memory), { lower: true }),
    evalplus: topSet(ordered, (r) => (parseScore(r.evalplus) >= 0 ? parseScore(r.evalplus) : NaN)),
    mendel: topSet(ordered, (r) => (mendelFailedCell(r) ? NaN : parseMendel(r.mendel) ?? NaN)),
    composite: topSet(ordered, (r) => (mendelFailedCell(r) ? NaN : composite(r) ?? NaN)),
    wall: topSet(ordered, wallTotal, { lower: true }),
  }
  let anyStale = false
  const cell = (r, field) => {
    const stale = (r.stale || []).includes(field)
    if (stale) anyStale = true
    const value = `${r[field]}${stale ? '†' : ''}`
    const bold = top[field]?.has(r) ? `**${value}**` : value
    return r.abandoned ? `*${bold}*` : bold
  }
  const body = ordered.map((r) => {
    const tokStale = ['tokShallow', 'tokDeep'].some((f) => (r.stale || []).includes(f))
    if (tokStale) anyStale = true
    const capWord = (r.stale || []).includes('gatedBy') ? `${r.gatedBy}†` : r.gatedBy
    const tok = r.abandoned
      ? `*${cell(r, 'tokShallow')} → ${cell(r, 'tokDeep')}, ${capWord}*`
      : `<TokCell shallow="${r.tokShallow}" deep="${r.tokDeep}" cap="${capWord}"${tokStale ? ' stale' : ''}${top.tokShallow.has(r) ? ' top-shallow' : ''}${top.tokDeep.has(r) ? ' top-deep' : ''} />`
    const modelSlug = r.modelSlug || MODEL_SLUG_BY_BASE.get(r.spec?.base)
    const spec = specTag(r.spec, {
      label: r.id,
      repo: repoOf(r),
      top: top.composite.has(r),
      hardware: hardware ? r.hardwareSlug : '',
      modelPage: linkModel && modelSlug ? `/models/${modelSlug}` : '',
      hide,
    })
    const config = r.abandoned ? `${spec} ${r.abandoned.marker || '💀'}` : spec
    const ev = evalplusCell(r.evalplus)
    const evStale = (r.stale || []).includes('evalplus')
    if (evStale) anyStale = true
    const evCell = scoreTag(`${ev.value}${evStale ? '†' : ''}`, ev.sub, top.evalplus.has(r))
    const md = mendelCellParts(r)
    const mdStale = (r.stale || []).includes('mendel')
    if (mdStale) anyStale = true
    const mdCell = scoreTag(`${md.value}${mdStale ? '†' : ''}`, '', top.mendel.has(r), md.pill, md.note)
    const cells = [
      config,
      cell(r, 'maxCtx'),
      tok,
      ...(memory ? [cell(r, 'memory')] : []),
      evCell,
      mdCell,
      wall(r, top.wall.has(r)),
    ]
    return `| ${cells.join(' | ')} |`
  })
  const legend =
    footnotes && anyStale ? ['', '† from an earlier serving config or method; re-run pending.'] : []
  const seenPages = new Set()
  for (const r of ordered) {
    if (!r.abandoned) continue
    const page = pageLink(r)
    if (seenPages.has(page)) continue
    seenPages.add(page)
    legend.push('', `${r.abandoned.marker || '💀'} ${r.abandoned.reason} [Details](${page}).`)
  }
  return [...header, ...body, ...legend].join('\n')
}

function applyBlock(content, startMark, endMark, block, target) {
  const startIdx = content.indexOf(startMark)
  const endIdx = content.indexOf(endMark)
  if (startIdx === -1 || endIdx === -1 || endIdx < startIdx) {
    throw new Error(`missing or malformed ${startMark} / ${endMark} markers in ${target}`)
  }
  const before = content.slice(0, startIdx + startMark.length)
  const after = content.slice(endIdx)
  return `${before}\n${block}\n${after}`
}

const PRESET_KEYS = { m: 'model', ngl: 'n-gpu-layers', fa: 'flash-attn', c: 'ctx-size', t: 'threads', b: 'batch-size', ub: 'ubatch-size', n: 'predict' }
const PRESET_DROP = new Set(['model', 'alias', 'port', 'host'])
const PRESET_FILES = { 'llama-server': 'models.ini', 'prism-llama': 'models-prism-llama.ini' }

function presetOf(r) {
  if (!r.pi || !PRESET_FILES[r.spec.server]) return null
  const cmd = r.command.replace(/\\\n/g, ' ')
  const hf = cmd.match(/hf download (\S+) ([^\s)"]+)/)
  const loraDir = cmd.match(/D=([^;\s]+);/)
  const loraTail = cmd.match(/echo "\$D([^"]+)"/)
  const lora = loraDir && loraTail ? `${loraDir[1]}${loraTail[1]}` : null
  const flat = cmd.replace(/"\$\([^]*?\)"/g, '_')
  const tokens = flat.split(/\s+/).slice(1)
  const lines = [`[${r.pi.id}]`]
  if (hf) lines.push(`hf-repo = ${hf[1]}`, `hf-file = ${hf[2]}`)
  for (let i = 0; i < tokens.length; i++) {
    const t = tokens[i]
    if (!t.startsWith('-')) continue
    let key = t.replace(/^-+/, '')
    key = PRESET_KEYS[key] || key
    const next = tokens[i + 1]
    const hasValue = next !== undefined && !next.startsWith('-')
    if (hasValue) i++
    if (PRESET_DROP.has(key)) continue
    if (key === 'lora') {
      if (lora) lines.push(`lora = ${lora}`)
      continue
    }
    lines.push(`${key} = ${hasValue ? next : 'true'}`)
  }
  lines.push('reasoning-budget = 8192', 'reasoning-budget-message = Thinking budget reached. Give the final answer now.')
  return lines.join('\n')
}

function presetRows(rows) {
  const seen = new Map()
  for (const r of rows) {
    const p = presetOf(r)
    if (!p || seen.has(r.pi.id)) continue
    seen.set(r.pi.id, { row: r, preset: p })
  }
  return [...seen.values()]
}

function renderSetupPresets(data) {
  const rows = sortRows(data.rows.filter((r) => !r.hidden && !r.retired && !r.abandoned)).map((r) => ({ ...r, data }))
  const sections = []
  for (const [server, label] of [
    ['llama-server', 'Official `llama-server` presets'],
    ['prism-llama', 'PrismML fork (`prism-llama`) presets'],
  ]) {
    const presets = presetRows(rows.filter((r) => r.spec.server === server))
    if (!presets.length) continue
    sections.push(
      `### ${label}`,
      '',
      '```ini',
      presets.map((p) => p.preset).join('\n\n'),
      '```',
    )
  }
  return sections.length ? sections.join('\n') : 'No llama.cpp router presets on this setup.'
}

function writePresetFile(data) {
  if (!WRITE_PRESETS) return
  const rows = sortRows(data.rows.filter((r) => !r.hidden && !r.retired)).map((r) => ({ ...r, data }))
  for (const [server, file] of Object.entries(PRESET_FILES)) {
    const presets = presetRows(rows.filter((r) => r.spec.server === server))
    const target = `hardware/${data.hardwareId}/${file}`
    if (!presets.length) continue
    const block = [
      `# ${server} presets of ${data.hardwareName || data.hardwareSlug}. Generated by tools/gen-tables.mjs from`,
      `# data/setups/${data.hardwareSlug}/models.json; never hand-edit. Serve with`,
      `# tools/llama-router.sh${server === 'prism-llama' ? ' start prism' : ' start'}, or: llama-server --models-preset ${target} --models-max 1`,
      '',
      ...presets.map((p) => `${p.preset}\n`),
    ].join('\n')
    const local = block.replace(/^lora = ~\//gm, `lora = ${process.env.HOME}/`)
    writeFileSync(target, local)
    console.log(`updated: ${target}`)
  }
}

function modelRows(data, model) {
  const rows = data.rows.filter((r) => r.config.startsWith(model.rowMatch) && !r.hidden && !r.retired)
  const extra = (model.extraRows || []).filter((r) => !r.hidden && !r.retired)
  const sorted = sortRows([...rows, ...extra])
  return [...sorted.filter(isComplete), ...sorted.filter((r) => !isComplete(r))]
}

function fastRun(r) {
  return r.think === 8192 || r.mode === 'thinking off'
}

function renderEvalplusTable(datas, { slug: onlySlug, hardware: showHardware = true, match = null, fast = 'all', linkModel = true } = {}) {
  const header = [
    '| config | think | budget | Scores | empties | forced | tok/s | wall |',
    '|---|--:|--:|--:|--:|--:|--:|--:|',
  ]
  const same = (a, b) => ['base', 'quant', 'publisher', 'server'].every((k) => a?.[k] === b?.[k])
  const rowOf = (r) => (r.row ? r.data.rows.find((x) => x.id === r.row) : r.data.rows.find((x) => same(x.spec, r.spec)))
  const hm = (min) => {
    if (min == null) return '—'
    const m = Math.round(min)
    return `${Math.floor(m / 60)}h${String(m % 60).padStart(2, '0')}`
  }
  const completion = (empty) => {
    const m = /^(\d+)\/(\d+)$/.exec(empty || '')
    return m ? `${Math.round(((m[2] - m[1]) / m[2]) * 100)}%` : '—'
  }
  const runs = datas
    .flatMap((data) => (data.evalplusRuns || []).map((r) => ({ ...r, data })))
    .filter((r) => !onlySlug || r.slug === onlySlug)
    .filter((r) => !match || match(r.spec || r.data.rows.find((x) => x.id === r.row)?.spec))
    .filter((r) => fast !== 'only' || fastRun(r))
    .sort((a, b) => fastRun(b) - fastRun(a) || parseFloat(b.base) - parseFloat(a.base) || parseFloat(b.plus) - parseFloat(a.plus))
  if (!runs.length) return fast === 'only' ? 'No fast-mode run yet.' : 'No EvalPlus run yet.'
  const specOf = (r) => {
    const hardware = showHardware ? r.data.hardwareSlug : ''
    const modelPage = linkModel ? `/models/${r.slug}` : ''
    if (r.spec) return specTag(r.spec, { label: r.model, hardware, modelPage })
    const row = r.data.rows.find((x) => x.id === r.row)
    if (!row) throw new Error(`EvalPlus run "${r.model}" names no row and no spec`)
    return specTag(row.spec, { label: row.id, repo: repoOf(row), hardware, modelPage })
  }
  const top = topSet(runs.filter(fastRun), (r) => parseFloat(r.base))
  const body = runs.map((r) => {
    if (!r.budget) throw new Error(`EvalPlus run "${r.model}" has no budget`)
    const think = r.think ? String(r.think) : r.mode === 'thinking off' ? 'none' : '—'
    const matched = rowOf(r)
    return `| ${specOf(r)} | ${think}${fastRun(r) ? '' : '†'} | ${r.budget} | ${scoreTag(`${r.base}/${r.plus}`, completion(r.empty) === '—' ? '' : `${completion(r.empty)} completion`, top.has(r))} | ${r.emptyCause ?? '† unproven'} | ${r.forced ?? '—'} | ${matched ? `<TokCell shallow="${matched.tokShallow}" deep="${matched.tokDeep}" />` : '—'} | ${hm(r.wall)} |`
  })
  const legend = runs.some((r) => !fastRun(r))
    ? ['', '† not fast mode: a thinking budget other than 8192, or none. Kept for the record; only fast-mode rows compare across models.']
    : []
  return [...header, ...body, ...legend].join('\n')
}

const CURVE_BUCKETS = [
  4096, 8192, 16384, 24576, 32768, 40960, 49152, 65536, 81920, 98304,
  131072, 163840, 196608, 212992, 245760, 262144,
]

function curveBucket(depth) {
  return CURVE_BUCKETS.reduce((best, b) => (Math.abs(b - depth) < Math.abs(best - depth) ? b : best), CURVE_BUCKETS[0])
}

const CURVE_CELL = /^<CurveCell value="\d+(\.\d+)?"( depth="\d+(\.\d+)?K")?( served)? \/>$/

function curveCell(value, { depth = '', served = false } = {}) {
  const n = Number(value)
  const shown = Number.isFinite(n) ? String(n.toFixed(n >= 100 ? 0 : 2).replace(/0$/, '')) : String(value)
  const cell = `<CurveCell value="${shown}"${depth ? ` depth="${depth}"` : ''}${served ? ' served' : ''} />`
  if (!CURVE_CELL.test(cell)) throw new Error(`curve cell "${cell}" does not match allowed shape`)
  return cell
}

function renderCurvesTable(arms, { includeMachine = true, includeModel = false } = {}) {
  if (!arms.length) return 'No decode curve recorded yet.'
  const label = (d) => `${Math.round(d / 1024)}K`
  const pillDepth = (d) => `${(d / 1024).toFixed(1)}K`
  const binned = arms.map((a) => {
    const bins = new Map()
    for (const [depth, value] of Object.entries(a.points || {})) {
      const b = curveBucket(Number(depth))
      const prev = bins.get(b)
      if (!prev || Number(depth) > prev.depth) bins.set(b, { depth: Number(depth), value })
    }
    return { ...a, bins }
  })
  const buckets = [...new Set(binned.flatMap((a) => [...a.bins.keys()]))].sort((x, y) => x - y)
  const mixed = new Set(
    buckets.filter((b) => new Set(binned.map((a) => a.bins.get(b)?.depth).filter(Boolean).map(pillDepth)).size > 1),
  )
  let anyCreep = false
  const shallowOf = (a) => {
    const first = buckets.find((b) => a.bins.has(b))
    return first == null ? -Infinity : Number(a.bins.get(first).value)
  }
  const rows = [...binned]
    .sort((a, b) => shallowOf(b) - shallowOf(a))
    .map((a) => {
      const creep = a.method === 'creep'
      if (creep) anyCreep = true
      const parts = []
      if (includeModel) {
        const modelTitle = [...MODEL_SLUG_BY_BASE.entries()].find(([, s]) => s === a.model)?.[0] || a.model
        parts.push(`[${modelTitle}](/models/${a.model})`)
      }
      if (includeMachine) parts.push(a.machine)
      parts.push(a.arm)
      if (a.c) parts.push(`-c ${label(a.c)}`)
      if (creep && a.wired) parts.push(`wired ${a.wired}`)
      const name = `${parts.join(', ')}${creep ? ' †' : ''}`
      const cells = buckets.map((b) => {
        const hit = a.bins.get(b)
        if (!hit) return ''
        return curveCell(hit.value, { depth: mixed.has(b) ? pillDepth(hit.depth) : '', served: a.served })
      })
      return `| ${name} | ${cells.join(' | ')} |`
    })
  const legend = [
    '',
    'The served arm of each config is in bold. A pill under a reading shows its exact depth when arms in that column differed.',
  ]
  const chart = includeModel ? `<DecodeChart machine="${arms[0].machine}" />` : `<DecodeChart model="${arms[0].model}" />`
  if (anyCreep) {
    legend.push(
      '',
      '† measured with the earlier context-creep tool rather than `llama-benchy` on real code text. The two methods are not directly comparable.',
    )
  }
  return [chart, '', `| arm | ${buckets.map(label).join(' | ')} |`, `|---|${buckets.map(() => '--:').join('|')}|`, ...rows, ...legend].join('\n')
}

function renderModelCurve(slug, datas) {
  const arms = datas.flatMap((data) =>
    (data.curves || []).filter((c) => c.model === slug).map((c) => ({ ...c, machine: data.hardwareSlug })),
  )
  return renderCurvesTable(arms, { includeMachine: true, includeModel: false })
}

function renderDecodeCurves(datas) {
  return datas
    .map((data) => {
      const arms = (data.curves || []).map((c) => ({ ...c, machine: data.hardwareSlug }))
      return [`### ${data.hardwareName} (\`${data.hardwareSlug}\`)`, '', renderCurvesTable(arms, { includeMachine: false, includeModel: true })].join('\n')
    })
    .join('\n\n')
}

function renderDecodeSummary(datas) {
  const header = ['| best curve | tok/s (shallow → deep) | at |', '|---|--:|--:|']
  let anyStale = false
  const num = (s) => parseFloat(String(s).replace(/[^\d.]/g, ''))
  const picks = datas.flatMap((data) =>
    Object.entries(data.models || {}).flatMap(([slug, model]) => {
      const backends = new Map()
      for (const r of modelRows(data, model).filter((r) => !r.abandoned)) {
        const backend = (r.config.split(',')[1] || '').trim().replace(/[^A-Za-z].*$/, '') || 'other'
        if (!backends.has(backend)) backends.set(backend, [])
        backends.get(backend).push(r)
      }
      return [...backends.values()].map((rows) => {
        const complete = rows.filter(isComplete)
        const pick = sortRows(complete.length ? complete : rows)[0]
        return { ...pick, hardwareId: data.hardwareId, hardwareSlug: data.hardwareSlug, slug }
      })
    }),
  )
  const ordered = [...picks].sort((a, b) => (num(b.tokShallow) || -Infinity) - (num(a.tokShallow) || -Infinity))
  const top = {
    tokShallow: topSet(ordered, (r) => num(r.tokShallow)),
    tokDeep: topSet(ordered, (r) => num(r.tokDeep)),
    maxCtx: topSet(ordered, (r) => parseCtx(r.maxCtx)),
  }
  const cell = (r, field) => {
    const stale = (r.stale || []).includes(field)
    if (stale) anyStale = true
    const value = `${r[field]}${stale ? '†' : ''}`
    return top[field]?.has(r) ? `**${value}**` : value
  }
  const body = ordered.map((r) => {
    const tokStale = ['tokShallow', 'tokDeep'].some((f) => (r.stale || []).includes(f))
    if (tokStale) anyStale = true
    const capWord = (r.stale || []).includes('gatedBy') ? `${r.gatedBy}†` : r.gatedBy
    const tok = `<TokCell shallow="${r.tokShallow}" deep="${r.tokDeep}" cap="${capWord}"${tokStale ? ' stale' : ''}${top.tokShallow.has(r) ? ' top-shallow' : ''}${top.tokDeep.has(r) ? ' top-deep' : ''} />`
    const label = specTag(r.spec, {
      label: r.id,
      repo: repoOf(r),
      hardware: r.hardwareSlug,
      modelPage: `/models/${r.slug}`,
    })
    return `| ${label} | ${tok} | ${cell(r, 'maxCtx')} |`
  })
  const legend = anyStale ? ['', '† from an earlier serving config or method; re-run pending.'] : []
  return [...header, ...body, ...legend].join('\n')
}

function buildSiteStats(datas) {
  const round1 = (n) => Math.round(n * 10) / 10
  let evalplusNetMin = 0
  let evalplusGrossMin = 0
  let evalplusRuns = 0
  const byMachine = {}

  for (const data of datas) {
    const runs = data.evalplusRuns || []
    const net = runs.reduce((s, r) => s + Number(r.ownWall ?? r.wall ?? 0), 0)
    const gross = runs.reduce((s, r) => s + Number(r.wall ?? 0), 0)
    evalplusNetMin += net
    evalplusGrossMin += gross
    evalplusRuns += runs.length
    byMachine[data.hardwareSlug] = {
      name: data.hardwareName,
      evalplusNetMin: net,
      evalplusRuns: runs.length,
      mendelMin: 0,
      mendelRuns: 0,
    }
  }

  let mendelLocalMin = 0
  let mendelLocalRuns = 0
  let mendelCloudMin = 0
  let mendelCloudRuns = 0
  let totalTokens = 0
  let outputTokens = 0
  let toolCalls = 0
  let commits = 0

  for (const file of ['benchmarks/mendel/results.json', 'benchmarks/mendel/results-guided.json']) {
    if (!existsSync(file)) continue
    const runs = JSON.parse(readFileSync(file, 'utf8')).runs || []
    for (const r of runs) {
      if (r.local) {
        const w = mendelWallOf(r) || 0
        mendelLocalMin += w
        mendelLocalRuns++
        const slug = HARDWARE_SLUG[hardwareOf(r)]
        if (byMachine[slug]) {
          byMachine[slug].mendelMin += w
          byMachine[slug].mendelRuns++
        }
        const t = r.telemetry || {}
        totalTokens += Number(t.tokens_total) || 0
        outputTokens += Number(t.tokens_out) || 0
        toolCalls += Number(t.tool_calls) || 0
        commits += Number(t.commits) || 0
      } else {
        const w = Number(r.telemetry?.wall_clock_min) || 0
        mendelCloudMin += w
        mendelCloudRuns++
      }
    }
  }

  const localActiveHoursExact = (evalplusNetMin + mendelLocalMin) / 60
  const modelSlugs = new Set(datas.flatMap((d) => Object.keys(d.models || {})))
  const activeConfigs = datas.reduce((s, d) => s + d.rows.filter((r) => !r.hidden && !r.retired && !r.abandoned).length, 0)
  const curvesCount = datas.reduce((s, d) => s + (d.curves || []).length, 0)
  const executedBenchRuns = datas.reduce((s, d) => s + (Number(d.benchRuns) || 0), 0)

  const byMachineOut = Object.fromEntries(
    Object.entries(byMachine).map(([slug, m]) => [
      slug,
      {
        name: m.name,
        evalplusNetHours: round1(m.evalplusNetMin / 60),
        evalplusRuns: m.evalplusRuns,
        mendelHours: round1(m.mendelMin / 60),
        mendelRuns: m.mendelRuns,
        totalHours: round1((m.evalplusNetMin + m.mendelMin) / 60),
      },
    ]),
  )

  return {
    generatedFrom: 'data + benchmarks/mendel',
    localActiveHours: round1(localActiveHoursExact),
    displayHours: `${Math.floor(localActiveHoursExact)}h+`,
    breakdown: {
      evalplusNetHours: round1(evalplusNetMin / 60),
      evalplusGrossHours: round1(evalplusGrossMin / 60),
      evalplusRuns,
      mendelLocalHours: round1(mendelLocalMin / 60),
      mendelLocalRuns,
      mendelCloudHours: round1(mendelCloudMin / 60),
      mendelCloudRuns,
    },
    telemetry: {
      totalTokens,
      outputTokens,
      toolCalls,
      commits,
    },
    counts: {
      machines: datas.length,
      models: modelSlugs.size,
      binaries: BINARIES.length,
      activeConfigs,
      curves: curvesCount,
      executedBenchRuns,
    },
    byMachine: byMachineOut,
  }
}

function renderComputeLedger(stats) {
  const machines = Object.entries(stats.byMachine)
  const header = [
    `| Category | ${machines.map(([, m]) => m.name).join(' | ')} | Total |`,
    `|---|${machines.map(() => '--:').join('|')}|--:|`,
  ]
  const epNet = `| **EvalPlus — net active GPU time** (${stats.breakdown.evalplusRuns} runs) | ${machines.map(([, m]) => `${m.evalplusNetHours.toFixed(1)}h (${m.evalplusRuns})`).join(' | ')} | **${stats.breakdown.evalplusNetHours.toFixed(1)}h** |`
  const epGross = `| *EvalPlus — gross effective wall (incl. spliced carry-over)* | ${machines.map(() => '—').join(' | ')} | *${stats.breakdown.evalplusGrossHours.toFixed(1)}h* |`
  const mdLocal = `| **Mendel local — structured JSON** (${stats.breakdown.mendelLocalRuns} runs) | ${machines.map(([, m]) => `${m.mendelHours.toFixed(1)}h (${m.mendelRuns})`).join(' | ')} | **${stats.breakdown.mendelLocalHours.toFixed(1)}h** |`
  const subtotal = `| **Verified JSON local subtotal (non-overlapping)** | ${machines.map(([, m]) => `**${m.totalHours.toFixed(1)}h**`).join(' | ')} | **${stats.localActiveHours.toFixed(1)}h** |`
  const cloud = `| Cloud Mendel baselines (${stats.breakdown.mendelCloudRuns} runs) | ${machines.map(() => '—').join(' | ')} | ${stats.breakdown.mendelCloudHours.toFixed(1)}h |`
  const summary = [
    '',
    `Local Mendel telemetry across ${stats.breakdown.mendelLocalRuns} JSON runs: **${(stats.telemetry.totalTokens / 1e6).toFixed(1)}M** total tokens (**${(stats.telemetry.outputTokens / 1e6).toFixed(2)}M** output), **${stats.telemetry.toolCalls.toLocaleString('en-US')}** tool calls, **${stats.telemetry.commits}** commits. Dataset catalog: **${stats.counts.models}** models, **${stats.counts.binaries}** model files, **${stats.counts.activeConfigs}** active configs, **${stats.counts.curves}** decode curves, **${stats.counts.executedBenchRuns}** executed benchmark runs.`,
  ]
  return [...header, epNet, epGross, mdLocal, subtotal, cloud, ...summary].join('\n')
}

let drift = false
const writtenMarkers = new Set()

function syncFile(target, content) {
  const original = existsSync(target) ? readFileSync(target, 'utf8') : null
  if (original === content) return
  if (CHECK) {
    console.error(`STALE: ${target} is out of date. Run \`npm run docs:tables\`.`)
    drift = true
  } else {
    mkdirSync(dirname(target), { recursive: true })
    writeFileSync(target, content)
    console.log(`updated: ${target}`)
  }
}

function writeBlock(target, marker, block) {
  writtenMarkers.add(marker)
  const start = `<!-- gen:${marker}:start -->`
  const end = `<!-- gen:${marker}:end -->`
  const original = readFileSync(target, 'utf8')
  const updated = applyBlock(original, start, end, block, target)
  if (updated === original) return
  if (CHECK) {
    console.error(`STALE: ${target} (${marker}) does not match data/. Run \`npm run docs:tables\`.`)
    drift = true
  } else {
    writeFileSync(target, updated)
    console.log(`updated: ${target}`)
  }
}

function writeOptionalBlock(target, marker, block) {
  writtenMarkers.add(marker)
  const start = `<!-- gen:${marker}:start -->`
  const end = `<!-- gen:${marker}:end -->`
  const original = readFileSync(target, 'utf8')
  if (!original.includes(start) && !original.includes(end)) return
  const updated = applyBlock(original, start, end, block, target)
  if (updated === original) return
  if (CHECK) {
    console.error(`STALE: ${target} (${marker}) does not match data/. Run \`npm run docs:tables\`.`)
    drift = true
  } else {
    writeFileSync(target, updated)
    console.log(`updated: ${target}`)
  }
}

const HEAD_TIME = Date.parse(execSync('git log -1 --format=%cI').toString().trim())
const isNew = (r) => Boolean(r.added) && HEAD_TIME - Date.parse(r.added) < 48 * 3600 * 1000

const modelsAll = new Map()
const setupsAll = []
const blindRunsAll = []
const guidedRunsAll = []
let cloudBlind = []
let cloudGuided = []

for (const { file, hardwareId, data } of RAW_SETUPS) {
  data.hardwareId = hardwareId
  const validModels = Object.keys(data.models || {})
  for (const r of data.evalplusRuns || []) {
    if (!validModels.includes(r.slug)) throw new Error(`${file}: evalplusRuns "${r.model}" has unknown slug "${r.slug}"`)
    if (r.row && !data.rows.find((x) => x.id === r.row)) throw new Error(`${file}: evalplusRuns "${r.model}" names missing row "${r.row}"`)
  }
  for (const c of data.curves || []) {
    if (!validModels.includes(c.model)) throw new Error(`${file}: curves "${c.arm}" has unknown model "${c.model}"`)
  }
  checkRows(data.rows, data.hardwareSlug)
  for (const r of data.rows) {
    r.hardwareId = hardwareId
    r.hardwareSlug = data.hardwareSlug
  }

  const ofSetup = (r) => r.local !== 'True' || hardwareOf(r) === hardwareId
  const live = ((retired) => (r) => !retired(r))(onRetiredBuild(data.rows))
  const mendelBlindAll = parseCsv(readFileSync('benchmarks/mendel/results.csv', 'utf8')).filter(ofSetup).filter(live)
  const mendelGuidedAll = parseCsv(readFileSync('benchmarks/mendel/results-guided.csv', 'utf8')).filter(ofSetup).filter(live)
  const mendelBlind = currentPromptVersion(mendelBlindAll.filter((r) => r.invalid !== 'True'))
  const mendelGuided = currentPromptVersion(mendelGuidedAll.filter((r) => r.invalid !== 'True'))
  const rawLocal = (r) => r.local === 'True' && r.invalid !== 'True'
  data.mendelBlindRaw = parseCsv(readFileSync('benchmarks/mendel/results.csv', 'utf8')).filter(ofSetup).filter(rawLocal)
  data.mendelGuidedRaw = parseCsv(readFileSync('benchmarks/mendel/results-guided.csv', 'utf8')).filter(ofSetup).filter(rawLocal)
  deriveMendel(data.rows, mendelBlind, mendelGuided)

  const blindRuns = mendelRuns('benchmarks/mendel/results.json', hardwareId).filter(live)
  const guidedRuns = mendelRuns('benchmarks/mendel/results-guided.json', hardwareId).filter(live)

  for (const [slug, model] of Object.entries(data.models || {})) {
    const rows = modelRows(data, model)
      .filter((r) => !r.abandoned)
      .map((r) => ({ ...r, hardwareSlug: data.hardwareSlug, modelSlug: slug }))
    modelsAll.set(slug, [...(modelsAll.get(slug) || []), ...rows])
  }

  setupsAll.push(data)
  blindRunsAll.push(...blindRuns)
  guidedRunsAll.push(...guidedRuns)
  cloudBlind = mendelBlind
  cloudGuided = mendelGuided
}

mendelSiteRows = setupsAll.flatMap((d) => d.rows)

// 1. Always generate site-stats.json
const stats = buildSiteStats(setupsAll)
syncFile('site/.vitepress/data/site-stats.json', `${JSON.stringify(stats, null, 2)}\n`)

// 1b. decode-curves.json feeds the DecodeChart component
const modelTitleOf = (slug) => [...MODEL_SLUG_BY_BASE.entries()].find(([, s]) => s === slug)?.[0] || slug
const decodeCurves = {
  models: [...new Set(setupsAll.flatMap((d) => (d.curves || []).map((c) => c.model)))]
    .map((slug) => ({ slug, title: modelTitleOf(slug) }))
    .sort((a, b) => a.title.localeCompare(b.title)),
  machines: setupsAll.map((d) => ({ slug: d.hardwareSlug, name: d.hardwareName })),
  curves: setupsAll.flatMap((d) =>
    (d.curves || []).map((c) => ({
      model: c.model,
      machine: d.hardwareSlug,
      arm: c.arm.replace(/`/g, ''),
      c: c.c || null,
      served: Boolean(c.served),
      creep: c.method === 'creep',
      points: [
        ...Object.entries(c.points || {})
          .reduce((bins, [depth, value]) => {
            const b = curveBucket(Number(depth))
            if (!bins.has(b) || Number(depth) > bins.get(b)[0]) bins.set(b, [Number(depth), Number(value)])
            return bins
          }, new Map())
          .values(),
      ].sort((x, y) => x[0] - y[0]),
    })),
  ),
}
syncFile('site/.vitepress/data/decode-curves.json', `${JSON.stringify(decodeCurves)}\n`)

// 2. Always auto-generate site/files/index.md and site/files/<id>.md (100% data-driven)
function generateFilePages(datas) {
  const expectedFiles = new Set(['index.md', ...BINARIES.map((b) => `${b.id}.md`)])
  if (existsSync('site/files')) {
    for (const f of globSync('site/files/*.md')) {
      const name = basename(f)
      if (!expectedFiles.has(name)) {
        console.error(`ORPHAN FILE: ${f} has no matching entry in data/binaries.json`)
        drift = true
      }
    }
  }

  const blindRaw = datas.flatMap((d) => d.mendelBlindRaw)
  const guidedRaw = datas.flatMap((d) => d.mendelGuidedRaw)

  const byModel = new Map()
  for (const b of BINARIES) {
    if (!byModel.has(b.model)) byModel.set(b.model, [])
    byModel.get(b.model).push(b)
  }

  const indexSections = [
    '---',
    'editLink: false',
    'generated: true',
    '---',
    '',
    '# Model Files',
    '',
    `Every tested model weight file (${BINARIES.length} files across ${byModel.size} models), generated automatically from structured benchmark data.`,
    '',
  ]

  for (const [slug, bins] of [...byModel.entries()].sort((a, b) => a[0].localeCompare(b[0]))) {
    const modelName = bins[0].spec.base
    indexSections.push(`## [${modelName}](/models/${slug})`, '', '| File | Quant | Publisher | Server | Tested On |', '|---|---|---|---|---|')
    for (const b of bins) {
      const machines = b.setups
        .map((id) => {
          const hwSlug = HARDWARE_SLUG[id] || id
          const hwName = HARDWARE_NAME[id] || hwSlug
          return `[${hwName}](/setups/${hwSlug}/)`
        })
        .join(', ')
      indexSections.push(`| [${b.file}](/files/${b.id}) | \`${b.spec.quant}\` | ${b.spec.publisher} | \`${b.spec.server}\` | ${machines} |`)
    }
    indexSections.push('')
  }
  syncFile('site/files/index.md', `${indexSections.join('\n').trimEnd()}\n`)

  for (const b of BINARIES) {
    const same = binaryMatch(b)
    const rows = datas.flatMap((data) =>
      data.rows.filter((r) => same(r.spec)).map((r) => ({ ...r, hardwareSlug: data.hardwareSlug, data })),
    )
    const live = sortRows(rows.filter((r) => !r.retired))
    const retired = rows.filter((r) => r.retired)

    const testedLinks = b.setups
      .map((id) => {
        const hwSlug = HARDWARE_SLUG[id] || id
        const hwName = HARDWARE_NAME[id] || hwSlug
        return `[${hwName}](/setups/${hwSlug}/)`
      })
      .join(', ')

    const configParts = []
    if (live.length) {
      configParts.push(renderTable(live, { footnotes: false, sort: false, hardware: true, linkModel: false }))
    } else if (b.statusNote) {
      configParts.push(b.statusNote)
    } else if (!retired.length) {
      configParts.push('No active configuration row.')
    }
    for (const r of retired) {
      configParts.push('', `Retired (${r.data.hardwareName}): ${r.config} — ${r.retired.reason} ([archive](${r.retired.details})).`)
    }

    const presets = presetRows(live)
    const presetParts = []
    if (presets.length) {
      const best = presets[0]
      presetParts.push(
        `Best served preset (${best.row.data.hardwareName}, \`${best.row.spec.server}\`, pi id \`${best.row.pi.id}\`):`,
        '',
        '```ini',
        best.preset,
        '```',
      )
      if (presets.length > 1) {
        presetParts.push('', '### All presets for this file')
        for (const p of presets) {
          presetParts.push(
            '',
            `#### \`${p.row.pi.id}\` (${p.row.data.hardwareName})`,
            '',
            '```ini',
            p.preset,
            '```',
          )
        }
      }
    }
    const commandsSeen = new Set()
    const uniqueCmds = live.filter((r) => {
      if (!r.command || commandsSeen.has(r.command)) return false
      commandsSeen.add(r.command)
      return true
    })
    if (uniqueCmds.length) {
      presetParts.push('', '### Direct serve commands')
      for (const r of uniqueCmds) {
        presetParts.push('', `${r.data.hardwareName} (${r.spec.kv} KV${r.spec.drafter ? `, ${r.spec.drafter}` : ''}):`, '', '```bash', r.command, '```')
      }
    }
    if (!presetParts.length) {
      presetParts.push('No served command recorded for this file.')
    }

    const evalplus = renderEvalplusTable(datas, { match: same, hardware: true, linkModel: false })
    const mendel = renderBinaryMendel(blindRaw, guidedRaw, (r) => same(mendelSpec(r)))

    const doc = [
      '---',
      'editLink: false',
      'generated: true',
      '---',
      '',
      `# ${b.title}`,
      '',
      '| Field | Value |',
      '|---|---|',
      `| Model | [${b.spec.base}](/models/${b.model}) |`,
      `| Quant | \`${b.spec.quant}\` |`,
      `| Publisher | ${b.spec.publisher} |`,
      `| Server | \`${b.spec.server}\` |`,
      `| Hugging Face Repo | [${b.repo}](https://huggingface.co/${b.repo}) |`,
      `| File | \`${b.file}\` |`,
      `| Pinned Revision | ${b.revision ? `\`${b.revision}\`` : 'unpinned'} |`,
      `| Tested On | ${testedLinks} |`,
      '',
      '## Served configurations',
      '',
      configParts.join('\n'),
      '',
      '## Serve presets',
      '',
      presetParts.join('\n'),
      '',
      '## HumanEval+ runs',
      '',
      evalplus,
      '',
      '## Mendel runs',
      '',
      mendel,
      '',
    ].join('\n')

    syncFile(`site/files/${b.id}.md`, doc)
  }
}

generateFilePages(setupsAll)

// 3. Setup pages
for (const data of setupsAll) {
  const target = `site/setups/${data.hardwareSlug}/index.md`
  const visible = data.rows.filter((r) => !r.hidden && !r.retired && !r.abandoned)
  const completeRows = visible.filter(isComplete)
  const mainAll = completeRows.length < 2 && visible.length > completeRows.length
  const mainRows = mainAll ? visible : completeRows
  const partialPool = visible.filter((r) => !mainRows.includes(r))
  const partialPicked = partialPool.filter((r) => completeness(r) >= 0.4 || isNew(r))
  const partialAll = partialPicked.length < 2 && partialPool.length > partialPicked.length
  const partialRows = sortRows(partialAll ? partialPool : partialPicked)
  const allNote = (all) => (all ? ['', 'Fewer than two rows pass the filter of this table, so it shows every row it can hold.'] : [])

  const completeTable = [renderTable(mainRows, { memory: false }), ...allNote(mainAll)].join('\n')
  const partialTable = partialRows.length
    ? [renderTable(partialRows, { sort: false, memory: false }), ...allNote(partialAll)].join('\n')
    : 'All active configurations on this machine are complete.'

  writeBlock(target, 'setup-complete', completeTable)
  writeBlock(target, 'setup-partial', partialTable)
  writeBlock(target, 'setup-evalplus', renderEvalplusTable([data], { hardware: false, fast: 'only' }))
  writeBlock(target, 'setup-presets', renderSetupPresets(data))
  writePresetFile(data)
}

// 4. Home page
const bestPerModel = [...modelsAll].map(([slug, rows]) => {
  const complete = rows.filter(isComplete)
  return { ...sortRows(complete.length ? complete : rows)[0], modelSlug: slug }
})
writeBlock('site/index.md', 'home-best-per-model', renderTable(bestPerModel, { memory: false, hardware: true, hide: 'server' }))

// 5. Models index & canonical model pages
const allModelRows = [...modelsAll.values()].flat()
writeBlock('site/models/index.md', 'models-complete', renderTable(allModelRows.filter(isComplete), { memory: false, hardware: true, hide: 'server' }))
writeBlock('site/models/index.md', 'models-incomplete', renderTable(allModelRows.filter((r) => !isComplete(r)), { memory: false, hardware: true, hide: 'server' }))

function renderModelAgent(slug) {
  const mine = (rows) => currentPromptVersion(rows).filter((r) => MENDEL_SLUGS[r.model] === slug)
  const blind = mine(blindRunsAll)
  const guided = mine(guidedRunsAll)
  if (!blind.length && !guided.length) return 'No agent run yet.'
  const out = []
  if (blind.length) out.push('Blind test:', '', mendelTable(blind, { global: true, linkModel: false }), '')
  if (guided.length) out.push('Guided test:', '', mendelTable(guided, { global: true, linkModel: false }), '')
  out.push('Older prompt versions of these runs are on [the Mendel page](/benchmarks/mendel#older-prompt-versions).')
  return out.join('\n')
}

function renderModelCompare(slug) {
  const sibling = setupsAll
    .flatMap((data) => Object.entries(data.models || {}))
    .find(([key, model]) => key === slug && model.compareWith)?.[1]?.compareWith
  if (!sibling) return ''
  const theirs = modelsAll.get(sibling) || []
  if (!theirs.length) return ''
  const rows = [...(modelsAll.get(slug) || []), ...theirs]
  const siblingName = [...MODEL_SLUG_BY_BASE.entries()].find(([, s]) => s === sibling)?.[0] || sibling
  return [
    `Every config of both models ranked together. Sibling model: [${siblingName}](/models/${sibling}).`,
    '',
    renderTable(rows, { memory: false, hardware: true, hide: 'server', footnotes: false }),
  ].join('\n')
}

for (const [slug, rows] of modelsAll) {
  const target = `site/models/${slug}.md`
  const retiredLines = setupsAll.flatMap((data) => {
    const model = data.models?.[slug]
    if (!model) return []
    return data.rows
      .filter((r) => r.config.startsWith(model.rowMatch) && r.retired)
      .map((r) => `Retired (${data.hardwareName}): ${r.config} — ${r.retired.reason} ([archive](${r.retired.details})).`)
  })
  const configsBlock = [
    renderTable(rows, { memory: false, hardware: true, hide: 'server', linkModel: false }),
    ...retiredLines.map((l) => `\n${l}`),
  ].join('\n')

  writeBlock(target, 'model-configs', configsBlock)
  writeBlock(target, 'model-curves', renderModelCurve(slug, setupsAll))
  writeBlock(target, 'model-evalplus', renderEvalplusTable(setupsAll, { slug, hardware: true, linkModel: false }))
  writeBlock(target, 'model-mendel', renderModelAgent(slug))
  const fileLines = BINARIES.filter((b) => b.model === slug).map((b) => {
    const machines = b.setups.map((id) => HARDWARE_NAME[id] || HARDWARE_SLUG[id] || id).join(', ')
    return `- [${b.title}](/files/${b.id}) — ${machines}`
  })
  writeBlock(target, 'model-files', fileLines.join('\n'))
  const compare = renderModelCompare(slug)
  if (compare) writeOptionalBlock(target, 'model-compare', compare)
}

// 6. Benchmark pages
writeBlock('site/benchmarks/index.md', 'compute-ledger', renderComputeLedger(stats))
writeBlock('site/benchmarks/decode-speed.md', 'decode-summary', renderDecodeSummary(setupsAll))
writeBlock('site/benchmarks/decode-speed.md', 'decode-curves', renderDecodeCurves(setupsAll))
writeBlock('site/benchmarks/evalplus.md', 'evalplus-fast', renderEvalplusTable(setupsAll, { fast: 'only' }))
writeBlock('site/benchmarks/mendel.md', 'mendel-local', mendelTable(currentPromptVersion(blindRunsAll), { global: true }))
writeBlock('site/benchmarks/mendel.md', 'mendel-cloud', renderMendelCloud(cloudBlind))
writeBlock('site/benchmarks/mendel.md', 'mendel-guided', mendelTable(currentPromptVersion(guidedRunsAll), { global: true }))
writeBlock('site/benchmarks/mendel.md', 'mendel-guided-cloud', renderMendelCloud(cloudGuided))
writeBlock('site/benchmarks/mendel.md', 'mendel-stale', renderMendelStale(blindRunsAll, guidedRunsAll))

// 7. Strict cell-shape & marker checks across site/
const CELL_SHAPES = [
  ['CurveCell', CURVE_CELL],
  ['TokCell', /^<TokCell shallow="[^"]+" deep="[^"]+"( cap="[^"]*")?( stale)?( top-shallow)?( top-deep)? \/>$/],
]
const badCells = []
const unknownMarkers = []
for (const file of globSync('site/**/*.md')) {
  const text = readFileSync(file, 'utf8')
  for (const [name, shape] of CELL_SHAPES) {
    for (const m of text.matchAll(new RegExp(`<${name}[^>]*/>`, 'g'))) {
      if (!shape.test(m[0])) badCells.push(`${file}: ${m[0]}`)
    }
  }
  for (const m of text.matchAll(/<!-- gen:(.+?):start -->/g)) {
    if (!writtenMarkers.has(m[1])) unknownMarkers.push(`${file}: gen:${m[1]}`)
  }
}
if (badCells.length) {
  console.error('cell shape check failed:')
  for (const b of badCells.slice(0, 20)) console.error('  ' + b)
  process.exit(1)
}
if (unknownMarkers.length) {
  console.error('unknown gen: markers in site/:')
  for (const u of unknownMarkers) console.error('  ' + u)
  process.exit(1)
}

if (CHECK && drift) process.exit(1)
if (!CHECK) console.log(`tables, stats, and ${BINARIES.length} file pages generated from data/`)
