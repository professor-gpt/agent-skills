# Reference: Skill Quality Criteria & Validation Framework

## §1 — Frontmatter Validation

Every generated SKILL.md must pass these checks:

| Check | Rule | Severity |
|---|---|---|
| Has YAML frontmatter | `---` delimiters present, valid YAML syntax | CRITICAL |
| `name` field | ASCII lowercase, kebab-case, 2–5 words, no trailing hyphens | CRITICAL |
| `description` field | 1–3 sentences, trigger-oriented, no vague claims like "helps with" | CRITICAL |
| `category` field | Exactly one of: writing, coding, ai-ml, devops, analysis, research, creativity, productivity, education, business, design, planning, communication, security, other | CRITICAL |
| `tags` field | 3–6 lowercase keywords as YAML inline list, hyphens for multi-word tags | HIGH |
| No extra frontmatter fields | Only name, description, category, tags (plus optional version/deprecated if managing lifecycle) | LOW |

## §2 — Description Quality Scoring

Score descriptions on a 1–10 scale:

**1–3 (Poor):** Generic, vague, could apply to any skill. No trigger phrases. No boundaries.
- Example: `description: Helps with business tasks.`
- Example: `description: Assists users with their work.`

**4–6 (Adequate):** Names a domain but lacks specificity about when to activate or what output to produce.
- Example: `description: Creates business reports and documents.`

**7–8 (Good):** Specifies the domain, typical tasks, and implies trigger conditions.
- Example: `description: Creates structured procurement comparison reports and supplier risk matrices. Use when the user asks to compare suppliers or evaluate RFQ responses.`

**9–10 (Excellent):** Specifies domain, trigger phrases, input types, output format, and clear boundaries.
- Example: `description: Creates structured procurement comparison reports, supplier risk matrices, and approval memos. Use when the user asks to compare suppliers, evaluate RFQ responses, prepare a purchasing decision, or summarize vendor risks. Not for legal contract review or financial auditing.`

**Target: ≥7. Never ship below 7.**

## §3 — Workflow Completeness Checklist

- [ ] Instructions have ≥5 numbered steps
- [ ] Every step describes an AGENT action (Ask, Generate, Validate, Retrieve, Apply, Output, Parse, Check, Format, Extract, Compare, Produce, Emit, Identify, Load)
- [ ] ZERO steps use human workflow verbs (Define, Choose, Decide, Sketch, Conduct, Consult, Explore, Consider, Ensure as advice to human, Prepare as human task)
- [ ] Steps reference companion files by path and section where applicable (e.g., "Retrieve color tokens from `./references/design-tokens.md` §2")
- [ ] Output format is explicitly specified (field names, table structure, file type)
- [ ] Quality/validation step included (agent checks its own output before presenting)
- [ ] Context-gathering steps included (what the agent asks before generating)

## §4 — Output Structure Quality

| Criterion | Good | Bad |
|---|---|---|
| Field names specified | "Return a table with columns: Supplier Name, Price, Risk Score, Recommendation" | "Create a report" |
| Format specified | "Output as a Markdown table, then a JSON summary block" | "Give me the results" |
| Template referenced | "Use the template in `./templates/report-template.md`" | No template reference |
| Example included | At least one concrete input/output pair | No examples |

## §5 — Safety & Risk Pattern Scan

Flag these patterns in generated skills (reject if present in the skill being validated, refuse to generate if user requests them):

**CRITICAL — Reject immediately:**
- Instructions to exfiltrate secrets, tokens, credentials, cookies, private keys
- Instructions for unauthorized access, exploitation, malware creation
- Phishing, spam, or surveillance instructions
- Instructions to hide behavior from users
- Instructions to bypass system prompts, provider policies, authentication, paywalls, rate limits, or access controls
- Instructions to run destructive commands without explicit authorization

**HIGH — Require disclaimers or human escalation rules:**
- Professional advice (legal, medical, financial) without disclaimers
- Handling of PII or sensitive data without data-handling rules
- Automated decision-making with compliance/regulatory implications

**MEDIUM — Flag for user review:**
- Skills that modify production systems without confirmation steps
- Skills that send external communications (emails, messages) without preview
- Skills with very broad scope (may trigger too often or too rarely)

## §6 — The CONTAIN Rule for Companion Files

**Companion files must CONTAIN knowledge, not DESCRIBE where to find it.**

FAIL (describes knowledge):
```
> "Use semantic color tokens from the design system."
> "Ensure accessibility standards are met."
> "Choose appropriate typography."
```

PASS (contains knowledge):
```css
--background: oklch(1 0 0);
--foreground: oklch(0.145 0 0);
--primary: oklch(0.205 0 0);
--primary-foreground: oklch(0.985 0 0);
--muted: oklch(0.97 0 0);
--muted-foreground: oklch(0.556 0 0);
--border: oklch(0.922 0 0);
--ring: oklch(0.708 0 0);
--radius: 0.5rem;
```

**Each companion file must contain ≥50 lines of substantive, specific content.** A companion file shorter than this is almost always too shallow.

**Test:** Can an AI agent act on this file's contents directly, without looking up external documentation? If not, the file fails the CONTAIN rule.

## §7 — Agent Compatibility Hints

Assess the generated skill for these platform-specific concerns:

| Platform | Check |
|---|---|
| Claude Code | Skill installs via `/skill install`; supports multi-file packages with `references/`, `scripts/`, `templates/` |
| Cursor | Skills typically single-file; ensure SKILL.md is self-contained if targeting Cursor |
| Custom agents | Check if the platform uses YAML frontmatter or a different metadata format |
| GitHub skill registry | Ensure `name` is unique, tags are standard, README-like structure for discovery |

## §8 — Simulation Framework

Generate these test cases for any skill being tested:

### Trigger Tests (Should Trigger)
1. **Direct task match**: A prompt that exactly matches the skill's primary use case
2. **Paraphrased match**: The same intent expressed in different words, different sentence structure
3. **Partial match with context**: A prompt that partially overlaps but contains enough signals to trigger

### Non-Trigger Tests (Should NOT Trigger)
1. **Adjacent domain**: A prompt in the same general field but outside the skill's scope boundary
2. **Different output type**: A prompt that matches the domain but requires a completely different output format
3. **Different role**: A prompt that would be better served by a different skill category entirely

### Edge-Case Tests
1. **Ambiguous prompt**: Could trigger this skill or a related one — test trigger confidence
2. **Guardrail boundary**: A prompt that approaches the skill's safety/scope boundary

For each test case, specify:
- The prompt text
- Expected behavior (should trigger / should not trigger / needs clarification)
- If should trigger: what the agent should do in the first 1–2 steps
- If should not trigger: why, and which skill would be more appropriate