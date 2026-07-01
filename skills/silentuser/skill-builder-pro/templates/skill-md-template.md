# Template: SKILL.md Output Structure

Use this template as the structural skeleton for every generated SKILL.md.

```markdown
---
name: <ascii-kebab-case-2-to-5-words>
description: <1-3 sentences, trigger-oriented. What the skill does, when to use it, trigger phrases, relevant tasks, clear boundaries. Score target: ≥7/10>
category: <exactly one of: writing | coding | ai-ml | devops | analysis | research | creativity | productivity | education | business | design | planning | communication | security | other>
tags: [tag1, tag2, tag3, tag4, tag5]
---

# Skill: <Human-Readable Title>

## Description

<Expanded description — 2–4 sentences covering purpose, scope, typical inputs, typical outputs, and when the agent should activate this skill.>

## Instructions

<Numbered list, minimum 5 steps. Every step describes an AGENT action.>

1. <Agent action step>
2. <Agent action step>
3. ...
N. <Final validation/output step>

## Constraints

- <Scope boundary: what this skill does NOT do>
- <Safety boundary>
- <Escalation rule: when to defer to a human expert>
- <Domain-specific restriction, if applicable>
- <Data-handling rule, if applicable>

## <Optional: Examples>

### Example 1: <Scenario Name>

**Input:**
> "<User prompt>"

**Output:**
<Expected agent output>

### Example 2: <Scenario Name>

**Input:**
> "<User prompt>"

**Output:**
<Expected agent output>

## <Optional: Output Format>

<Detailed output schema or template, if not covered by a companion template file>
```

## Frontmatter Field Specifications

### name
- ASCII lowercase only (a-z, 0-9, hyphens)
- 2–5 words separated by hyphens
- Starts and ends with a letter or number
- No spaces, underscores, or special characters
- Examples: `contract-risk-analyzer`, `sales-call-coach`, `react-component-builder`

### description
- 1–3 complete sentences
- Must include: what the skill does, when to use it
- Should include: trigger phrases, relevant task types, clear boundaries
- Must NOT include: vague claims ("helps with", "assists in"), marketing language ("best", "amazing")
- Target quality score: ≥7/10 per `./references/quality-criteria.md` §2

### category
- Exactly one lowercase value from the allowed enum
- Choose the most specific fit; use "other" only as a last resort
- The category drives discovery and filtering — be precise

### tags
- 3–6 lowercase keywords
- Use hyphens for multi-word tags (e.g., `risk-analysis`, `code-review`)
- No spaces inside individual tags
- YAML inline list format: `[tag1, tag2, tag3]`

## Instruction Step Quality Rules

Each instruction step must pass this test:
1. Does the step describe what the AGENT does when activated? → Keep
2. Does the step describe what a HUMAN should do (decide, sketch, choose, conduct, consult)? → REWRITE as agent action
3. Could a human follow these instructions without an AI agent? → If yes, the step describes human work — rewrite

**Agent action verbs (use these):** Ask, Analyze, Retrieve, Generate, Validate, Return, Apply, Reference, Check, Format, Parse, Extract, Compare, Produce, Emit, Identify, Load, Output

**Human workflow verbs (never use in Instructions):** Define, Choose, Decide, Sketch, Conduct, Consult, Explore, Consider, Ensure (as advice to human), Prepare (as human task)

## Companion File References in Instructions

When the skill is a multi-file package, Instruction steps must reference companion files by exact path and section:

- GOOD: "Retrieve the color tokens from `./references/design-tokens.md` §2 and apply only the documented Tailwind CSS custom property classes"
- GOOD: "Load the risk taxonomy from `./references/risk-taxonomy.md` §1–§3 and classify each finding"
- BAD: "Reference the design system"
- BAD: "Use the companion files"