# Template: Generation Brief (Internal)

Use this schema to assemble a structured brief before generating the skill package. Do not display to the user unless they explicitly request it.

```json
{
  "categoryId": "string — from references/skill-categories.md §1",
  "specialization": "string — specific role or focus area",
  "orientation": "problem-first | tool-first | hybrid",
  "useCases": [
    "string — concrete use case 1",
    "string — concrete use case 2",
    "string — concrete use case 3"
  ],
  "inputTypes": ["string — document", "string — code", "string — URL", "string — structured data", "string — voice transcript", "string — other"],
  "toolsAndSystems": [
    {
      "name": "string — tool/framework/API name",
      "version": "string — version or 'latest'",
      "purpose": "string — how the skill uses this tool"
    }
  ],
  "workflowSteps": [
    "string — step 1: what the agent does",
    "string — step 2: what the agent does",
    "string — step N: what the agent does"
  ],
  "outputFormats": [
    {
      "format": "markdown | json | code | table | email | report | other",
      "description": "string — what the output contains",
      "templatePath": "string or null — path to template file if applicable"
    }
  ],
  "qualityCriteria": [
    "string — criterion 1: what makes output good",
    "string — criterion 2"
  ],
  "guardrails": [
    "string — safety boundary 1",
    "string — scope boundary 2",
    "string — escalation rule 3"
  ],
  "language": "string — output language",
  "tone": "formal | semi-formal | casual | technical | conversational",
  "installTarget": "claude-code | cursor | custom | github-registry",
  "packageComplexity": "single-file | multi-file",
  "companionFiles": [
    {
      "path": "string — relative path",
      "type": "references | examples | templates | scripts",
      "purpose": "string — what knowledge this file contains"
    }
  ]
}
```

## Field Guidance

**categoryId**: Must match a valid category ID from `./references/skill-categories.md` §1. This drives category-specific wizard questions.

**orientation**: 
- `problem-first`: User describes desired outcome (e.g., "I need to compare suppliers"). Skill guides the workflow.
- `tool-first`: User names a specific tool/API/platform (e.g., "I need my agent to use the Stripe API"). Skill teaches the agent how to use that tool well.
- `hybrid`: Both modes supported, one designated primary.

**workflowSteps**: Must describe AGENT actions, not human actions. Use verbs: Ask, Generate, Validate, Retrieve, Apply, Output, Parse, Check, Format, Extract, Compare, Produce, Emit, Identify, Load. Never use: Define, Choose, Decide, Sketch, Conduct, Consult, Explore, Consider, Prepare (as human task).

**guardrails**: Must include at minimum one scope boundary (what the skill does NOT do), one safety boundary, and one escalation rule (when to defer to a human expert).

**packageComplexity**: Default to `multi-file` for: coding, design, devops, analysis, research, legal, business, security, ai-ml. Default to `single-file` for: simple productivity, short-form writing, single-task skills that are fully self-contained.

**companionFiles**: For multi-file packages, plan 1–5 companion files. Each must satisfy the CONTAIN rule from `./references/quality-criteria.md` §6 — it must contain specific, actionable knowledge, not generic advice.