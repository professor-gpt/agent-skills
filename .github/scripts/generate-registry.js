#!/usr/bin/env node
// Generates registry.json from all skill directories under skills/.
// Called by .github/workflows/registry.yml on every push to main.
//
// metadata.json schema (per skill):
//   name        — display name  (e.g. "Code Reviewer")
//   slug        — directory key (e.g. "code-reviewer")
//   description — short description
//   category    — free string (unknown values fall back to "other" in the app)
//   tags        — string[]
//   author      — string
//   version     — semver string
//   createdAt   — ISO 8601 date string
//   agents?     — string[] (optional override; defaults to [])
//   license?    — string   (optional override; defaults to "MIT")
//
// registry.json output shape matches catalog.ts RegistryEntry:
//   name        ← metadata.slug   (used as skill id in the app)
//   title       ← metadata.name   (display name)
//   skillMdUrl  ← computed from repo + slug
//   metadataUrl ← computed from repo + slug
//   files       ← all file paths in the skill directory (relative)
//   (all other fields pass through from metadata)

const fs   = require("fs")
const path = require("path")

const ROOT       = path.join(__dirname, "..", "..")
const SKILLS_DIR = path.join(ROOT, "skills")

// In CI: GITHUB_REPOSITORY = "owner/repo" (set by GitHub Actions env)
const GITHUB_REPOSITORY = process.env.GITHUB_REPOSITORY ?? "professor-gpt/agent-skills"
const RAW_BASE = `https://raw.githubusercontent.com/${GITHUB_REPOSITORY}/main`

// ── Collect all file paths in a directory (relative to that directory) ────────
function collectFiles(dirPath, baseDir) {
  const files = []
  for (const entry of fs.readdirSync(dirPath, { withFileTypes: true })) {
    const fullPath = path.join(dirPath, entry.name)
    if (entry.isFile()) {
      files.push(path.relative(baseDir, fullPath).replace(/\\/g, "/"))
    } else if (entry.isDirectory()) {
      files.push(...collectFiles(fullPath, baseDir))
    }
  }
  return files
}

// ── Collect skill directories (supports 2-level namespaced structure) ─────────
// Skills live at skills/<username>/<slug>/ (namespaced, new style).
// Legacy flat skills at skills/<slug>/ are also supported as a fallback.
//
// Returns: Array of { slug: "username/skill-slug", dirPath: "/abs/path" }
function collectSkillDirs(skillsDir) {
  const dirs = []
  for (const entry of fs.readdirSync(skillsDir, { withFileTypes: true })) {
    if (!entry.isDirectory()) continue
    const dirPath  = path.join(skillsDir, entry.name)
    const metaPath = path.join(dirPath, "metadata.json")

    if (fs.existsSync(metaPath)) {
      // Legacy flat skill: skills/slug/metadata.json
      dirs.push({ slug: entry.name, dirPath })
    } else {
      // Namespaced: skills/username/skill-slug/metadata.json
      let subEntries
      try { subEntries = fs.readdirSync(dirPath, { withFileTypes: true }) }
      catch { continue }

      for (const sub of subEntries) {
        if (!sub.isDirectory()) continue
        const subDir  = path.join(dirPath, sub.name)
        const subMeta = path.join(subDir, "metadata.json")
        if (fs.existsSync(subMeta)) {
          dirs.push({ slug: `${entry.name}/${sub.name}`, dirPath: subDir })
        }
      }
    }
  }
  return dirs
}

// ── Read and map all skill directories ────────────────────────────────────────
const skills   = []
const warnings = []

for (const { slug, dirPath } of collectSkillDirs(SKILLS_DIR)) {
  const skillDir = dirPath
  const metaPath = path.join(skillDir, "metadata.json")

  let meta
  try {
    meta = JSON.parse(fs.readFileSync(metaPath, "utf-8"))
  } catch (e) {
    warnings.push(`[${slug}] metadata.json parse error: ${e.message} — skipping`)
    continue
  }

  const files = collectFiles(skillDir, skillDir)

  skills.push({
    // Registry fields (matches catalog.ts RegistryEntry)
    name:        meta.slug ?? slug,                              // id used by app
    title:       meta.name ?? slug,                              // display name
    description: meta.description ?? "",
    version:     meta.version ?? "1.0.0",
    author:      meta.author ?? "community",
    tags:        Array.isArray(meta.tags) ? meta.tags : [],
    category:    meta.category ?? "other",
    agents:      Array.isArray(meta.agents) ? meta.agents : [], // optional override
    license:     meta.license ?? "MIT",                         // optional override
    skillMdUrl:  `${RAW_BASE}/skills/${slug}/SKILL.md`,
    metadataUrl: `${RAW_BASE}/skills/${slug}/metadata.json`,
    files,

    // Internal — used for sorting only, removed before output
    _createdAt: meta.createdAt ?? "1970-01-01T00:00:00.000Z",
  })
}

// Sort newest first
skills.sort((a, b) =>
  new Date(b._createdAt).getTime() - new Date(a._createdAt).getTime()
)

// Strip internal sorting field
for (const s of skills) delete s._createdAt

// ── Write registry.json ───────────────────────────────────────────────────────
const registry = {
  version:   "1",
  updatedAt: new Date().toISOString(),
  skills,
}

fs.writeFileSync(
  path.join(ROOT, "registry.json"),
  JSON.stringify(registry, null, 2) + "\n",
  "utf-8"
)

console.log(`✅ registry.json generated — ${skills.length} skill(s)`)

if (warnings.length > 0) {
  console.warn("\nWarnings:")
  for (const w of warnings) console.warn(" •", w)
}
