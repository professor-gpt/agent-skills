---
name: silentuser/skill-builder-pro
description: Use this skill when the user wants to create, validate, improve, or convert a prompt/workflow into a production-ready AI agent SKILL.md file. Also activates when the user asks to test, simulate, or quality-check an existing skill. Covers all categories including developer, business, creative, and operations roles.
category: ai-ml
tags: [skill-building, agent-skills, skill-validation, prompt-engineering, skill-qa, skillops]
---

# Skill: Skill Builder Pro

## Description

This skill transforms user requirements — a role, a workflow, a tech stack, a business process, a short prompt, or an existing draft — into a complete, validated, production-ready AI agent skill package. It covers the full lifecycle:

- **Build**: Category-specific wizard to gather requirements and generate a structured SKILL.md (single-file or multi-file with companion files)
- **Validate**: Frontmatter checks, description quality scoring, trigger clarity analysis, safety scan, risk pattern detection
- **Test**: Generate "should trigger" and "should not trigger" examples, paraphrased trigger variants, edge-case scenarios
- **Improve**: Identify gaps, rewrite weak descriptions, expand workflows, strengthen guardrails
- **Manage**: Version tracking, deprecation notes, install-command generation, category tagging

The skill supports two orientations, inferred or explicitly chosen by the user:

- **Problem-first**: The user describes a desired outcome. The skill builds an agent workflow that guides toward that outcome.
- **Tool-first**: The user works with a specific tool, API, platform, or MCP server. The skill teaches the agent how to use that tool effectively.
- **Hybrid**: The skill supports both modes, but one is designated as primary.

## Instructions

### Phase A — Activation & Orientation

1. When the user describes a need for an AI agent skill (or provides a prompt, SOP, role description, GitHub URL, or existing skill to improve), confirm that you will build/validate/improve a skill package. Do NOT ask whether they want a skill — assume yes and begin gathering.

2. Ask exactly these classification questions (present as a compact list, not one at a time):
   - **Category**: Which category best fits this skill? (present the full category tree from `./references/skill-categories.md` §1 as a condensed pick-list)
   - **Orientation**: Problem-first (user describes desired outcome → skill guides workflow), Tool-first (user works with a specific tool/API/platform → skill teaches agent how to use it), or Hybrid?
   - **Specialization**: What specific role, domain, or focus area within that category? (e.g., "React frontend developer", "Procurement analyst", "Sales call coach")

3. Ask these context-gathering questions once the user engages:
   - What are 2–3 concrete use cases or tasks this skill should handle?
   - What input types will the agent receive? (documents, code, URLs, structured data, voice transcripts, etc.)
   - What output format(s) should the agent produce? (Markdown report, JSON, code files, table, email draft, etc.)
   - What tools, APIs, frameworks, or systems are involved? (name specific versions if relevant)
   - What guardrails or boundaries are important? (data privacy, industry regulations, audience, jurisdiction)
   - What is the expected install target? (Claude Code, Cursor, a custom agent platform, GitHub skill registry)

4. Based on the answers, decide the output complexity:
   - **Single-file SKILL.md**: For focused, self-contained skills (simple productivity, short-form writing, single-task skills)
   - **Multi-file package**: For skills in coding, design, devops, analysis, research, legal, business, security, or any domain where companion files (reference docs, code templates, worked examples, checklists) materially improve agent output quality. Default to multi-file for these categories.

### Phase B — Generate the Skill Package

5. Before writing, load the relevant reference material:
   - Category-specific wizard prompts from `./references/skill-categories.md` §2
   - Quality criteria from `./references/quality-criteria.md` §1–§7
   - The generation brief template from `./templates/generation-brief.md`
   - The SKILL.md output template from `./templates/skill-md-template.md`

6. Assemble a structured generation brief internally (do not display to user unless they request it). Use the schema from `./templates/generation-brief.md`. The brief captures: category, specialization, orientation, use cases, input sources, tools, workflow steps, output formats, quality criteria, guardrails, language/tone, install target, and package complexity decision.

7. Generate the complete skill package:
   - Write SKILL.md first, following the frontmatter rules and structural template from `./templates/skill-md-template.md`
   - For multi-file packages: create companion files (max 5 additional files) in `references/`, `examples/`, `templates/`, or `scripts/` directories. Each companion file must CONTAIN specific, actionable knowledge — not generic advice. See `./references/quality-criteria.md` §6 for the CONTAIN rule.
   - Ensure the frontmatter `name` is ASCII kebab-case, 2–5 words
   - Ensure the `description` field is trigger-oriented: what the skill does, when to use it, trigger phrases, relevant tasks, clear boundaries (see `./references/quality-criteria.md` §2 for description quality standards)
   - Ensure Instructions contain ≥5 numbered steps describing AGENT actions (Ask, Generate, Validate, Retrieve, Apply, Output, Parse) — never human workflow verbs (Define, Choose, Decide, Sketch, Conduct, Consult)

8. Before presenting the output, run the full QA suite from `./references/quality-criteria.md` against your own generated output. Check:
   - Frontmatter validity (all 4 required fields, valid category enum, valid kebab-case name)
   - Description trigger clarity score (1–10; must be ≥7)
   - Instruction steps describe agent actions (not human workflow)
   - Safety guardrails present in Constraints
   - For multi-file: all companion file paths valid, no more than 6 files total, no empty placeholders
   - No unsafe instructions anywhere in the package

### Phase C — Validate & Deliver

9. Present the complete skill package to the user using the exact `=== FILE: <path> ===` delimiter format for multi-file, or a clean Markdown block for single-file.

10. After delivering the package, produce a quality summary:
    - **Description score**: X/10 (based on trigger clarity, specificity, boundary definition — see `./references/quality-criteria.md` §2)
    - **Workflow completeness**: X/10 (all required steps present, agent actions clear)
    - **Safety status**: PASS / FLAG (list any flagged patterns from `./references/quality-criteria.md` §5)
    - **Compatibility hint**: Install-ready for [target platform]; note any platform-specific concerns
    - **Suggestions**: 1–3 concrete improvements the user might consider (e.g., "Add a worked example in `examples/` for the most common use case", "The description could be more specific about trigger phrases")

### Phase D — Simulate (on user request)

11. If the user asks to test or simulate the skill, generate a test report using the simulation framework from `./references/quality-criteria.md` §8. Produce:
    - 3 "Should trigger" example prompts (including one paraphrased variant)
    - 3 "Should not trigger" example prompts (boundary cases that are close but outside scope)
    - 2 edge-case prompts that test the guardrails
    - Expected behavior for each
    - A brief assessment of whether the skill handles each correctly, with suggested fixes for any failures

### Phase E — Improve (on user request)

12. If the user asks to improve an existing skill (from conversation history or newly provided), apply the full QA suite from `./references/quality-criteria.md`, identify the top 3–5 gaps, and output a complete updated skill package with all improvements applied. Never output only the changed section — always the full updated package.

## Constraints

- **Scope**: This skill builds, validates, tests, and improves AI agent skill packages (SKILL.md files and companion files). It does NOT build general software, write general documentation, or serve as a general-purpose coding assistant outside the skill-creation context.
- **No unsafe instructions**: Generated skills must never instruct agents to exfiltrate secrets, bypass authentication, perform unauthorized access, exploit systems, hide behavior from users, or provide professional advice (legal, medical, financial) without appropriate disclaimers.
- **Escalation**: If the user requests a skill for malware, phishing, credential theft, surveillance, prompt injection, or any exploitation/abuse use case, refuse immediately with a clear explanation — do not generate any part of the skill.
- **Jurisdictional boundaries**: For legal, medical, financial, or compliance skills, always include appropriate disclaimers and escalation-to-human-expert rules in the generated Constraints section.
- **Single-file vs multi-file**: Do not default to multi-file for simple productivity or short conversational writing skills. Do default to multi-file for coding, design, devops, analysis, research, legal, business, security, and ai-ml skills where companion files materially improve agent quality.
- **Language matching**: Output the skill in the same language as the user's request, except the `name` field which must always be ASCII kebab-case.
- **Companion file quality**: Every companion file must satisfy the CONTAIN rule (`./references/quality-criteria.md` §6) — it must contain specific, actionable knowledge (actual code, actual values, actual patterns), not generic advice or descriptions of where to find information.