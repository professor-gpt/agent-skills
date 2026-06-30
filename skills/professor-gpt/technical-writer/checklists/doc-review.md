# Documentation Review Checklist

Run this checklist before publishing any technical document.
Mark: ✅ Pass · ❌ Fail · N/A

---

## A. Accuracy

- [ ] Every command in the doc can be copy-pasted and run without modification
- [ ] Code examples are tested against the current version (not a stale copy)
- [ ] Version numbers, URLs, and config keys match the actual software
- [ ] Screenshots and diagrams reflect the current UI/architecture
- [ ] "Coming soon" or "in development" sections are removed or clearly labeled

## B. Completeness

- [ ] Prerequisites are listed before the first step (with specific versions)
- [ ] Every error code or exception mentioned has a recovery path
- [ ] All parameters in code examples are defined (no mystery variables)
- [ ] Destructive operations (delete, reset) have a warning + confirmation step
- [ ] Links to related docs included where relevant

## C. Clarity

- [ ] First paragraph answers: what is this, who is it for, what does it do?
- [ ] Technical jargon is defined on first use (or linked to a glossary)
- [ ] Sentences are ≤ 25 words (scan for long ones and split)
- [ ] Passive voice count < 10% (find with: `was`, `were`, `been`, `by the`)
- [ ] No filler phrases: "In order to", "Please note that", "It should be noted"
- [ ] Headers are action-oriented or descriptive, not generic ("Overview", "Details")

## D. Structure

- [ ] Quick Start / Getting Started section exists and runs in < 5 minutes
- [ ] H1 → H2 → H3 hierarchy is consistent (no skipped levels)
- [ ] Tables used for reference data (parameters, config options, error codes)
- [ ] Lists used for sequences (numbered) and non-ordered items (bullets)
- [ ] Code blocks have language tag for syntax highlighting (```typescript, ```bash)
- [ ] Long pages have a table of contents

## E. Code Examples

- [ ] Every code block has a language identifier
- [ ] Import statements included (reader can run example standalone)
- [ ] Error handling shown (not just happy path)
- [ ] Placeholder values are visually distinct: `YOUR_API_KEY`, `<your-token>`, `:id`
- [ ] No output is shown that contradicts the code (run it to verify)
- [ ] For shell commands: prompt (`$` or `#`) indicates whether root is needed

## F. Navigation & Discoverability

- [ ] Every page has a clear title (shows in browser tab and search results)
- [ ] Meta description written (for docs sites with SEO)
- [ ] Internal links use descriptive text ("see Rate Limits"), not "click here"
- [ ] Broken links checked (use a link checker tool)
- [ ] Search terms a user would type are present in the content naturally

## G. Tone & Style

- [ ] Consistent voice throughout (not mixing first/second/third person)
- [ ] Addresses reader as "you" (second person, direct)
- [ ] No "simply", "just", "easy", "obviously" — these dismiss difficulty
- [ ] No marketing language in technical docs ("powerful", "seamless", "robust")
- [ ] Negative examples labeled clearly (❌ or "Don't")
- [ ] Warnings and notes styled consistently (`> **Note:**`, `> **Warning:**`)

---

## Quick Fixes Reference

| Problem | Find | Fix |
|---------|------|-----|
| Passive voice | "is handled by", "was created" | "handles", "created" |
| Filler opener | "In order to X, you need to Y" | "To X: Y" |
| Vague config ref | "update your settings" | "set `fieldName` in `config.ts`" |
| Missing unit | "set timeout to 30" | "set `timeout` to `30000` (30 seconds)" |
| Stale example | version number in code block | pin to a version range or test against HEAD |
| Broken link | any `href` to external site | run `npx linkinator ./docs` to find 404s |

---

## Sign-off

Before publishing, confirm:
- [ ] Tested by someone who wasn't involved in writing
- [ ] Reviewed by a subject matter expert for accuracy
- [ ] Published URL is correct and page is indexed (or noindex if internal)
