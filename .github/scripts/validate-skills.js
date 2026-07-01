#!/usr/bin/env node
// Validates skill directories passed as CLI arguments.
// Called by .github/workflows/validate.yml on every PR that touches skills/.
//
// Usage:
//   node validate-skills.js <slug1> <slug2> ...
//
// Checks per skill:
//   1. Directory exists under skills/
//   2. metadata.json exists and is valid JSON
//   3. All required fields present (name, slug, description, category, tags, author, version, createdAt)
//   4. slug field matches directory name
//   5. category is a non-empty string (no value restriction — unknown values fall back to "other" in the app)
//   6. tags is an array
//   7. SKILL.md exists and is not empty (format is free — no content validation)

const fs   = require("fs")
const path = require("path")

const SKILLS_DIR     = path.join(__dirname, "..", "..", "skills")
const REQUIRED_FIELDS = ["name", "slug", "description", "category", "tags", "author", "version", "createdAt"]

const slugs = process.argv.slice(2).filter(Boolean)

if (slugs.length === 0) {
  console.log("No skills to validate.")
  process.exit(0)
}

let totalErrors = 0

for (const slug of slugs) {
  const skillDir = path.join(SKILLS_DIR, slug)
  const skillErrors = []

  const log = (msg) => console.log(`  [${slug}] ${msg}`)
  const err = (msg) => { skillErrors.push(msg); console.error(`  [${slug}] ❌ ${msg}`) }

  console.log(`\nValidating: ${slug}`)

  // 1. Directory exists?
  // If the directory is missing, the PR is removing this skill (deletion PR).
  // Deletion PRs don't need content validation — they only remove files.
  if (!fs.existsSync(skillDir) || !fs.statSync(skillDir).isDirectory()) {
    log(`ℹ️  Directory removed — skill is being deleted, skipping validation.`)
    continue
  }

  // 2. metadata.json exists?
  const metaPath = path.join(skillDir, "metadata.json")
  if (!fs.existsSync(metaPath)) {
    err("metadata.json not found")
    totalErrors += skillErrors.length
    continue
  }

  // 3. Valid JSON?
  let meta
  try {
    meta = JSON.parse(fs.readFileSync(metaPath, "utf-8"))
  } catch (e) {
    err(`metadata.json is not valid JSON: ${e.message}`)
    totalErrors += skillErrors.length
    continue
  }

  // 4. Required fields?
  const missing = REQUIRED_FIELDS.filter((f) => !(f in meta) || meta[f] === null || meta[f] === undefined)
  if (missing.length > 0) {
    err(`Missing or null fields: ${missing.join(", ")}`)
  }

  // 5. slug matches directory name?
  if (meta.slug !== slug) {
    err(`slug mismatch — metadata.slug is "${meta.slug}" but directory is "skills/${slug}/"`)
  }

  // 6. category is a non-empty string?
  if (!meta.category || typeof meta.category !== "string" || !meta.category.trim()) {
    err("category must be a non-empty string")
  }

  // 7. tags is an array?
  if (!Array.isArray(meta.tags)) {
    err("tags must be an array")
  }

  // 8. SKILL.md exists and not empty?
  const skillMdPath = path.join(skillDir, "SKILL.md")
  if (!fs.existsSync(skillMdPath)) {
    err("SKILL.md not found")
  } else {
    const content = fs.readFileSync(skillMdPath, "utf-8").trim()
    if (!content) {
      err("SKILL.md is empty")
    } else {
      log(`✅ SKILL.md present (${content.split("\n").length} lines)`)
    }
  }

  if (skillErrors.length === 0) {
    log("✅ All checks passed")
  }
  totalErrors += skillErrors.length
}

console.log("")
if (totalErrors > 0) {
  console.error(`❌ Validation failed with ${totalErrors} error(s). Fix the issues above before merging.`)
  process.exit(1)
} else {
  console.log("✅ All skills valid.")
  process.exit(0)
}
