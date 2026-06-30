# System Prompt Template

A structured template for writing reliable, production-grade system prompts.
Fill in each section, delete the instructions, and validate with test cases before deploying.

---

## SYSTEM PROMPT TEMPLATE

```
## Role & Identity

You are [specific role with context]. You have [relevant expertise/background].
You are assisting [target user type] who [what they're trying to accomplish].

<!-- Good: "You are a senior technical support specialist at Acme SaaS. You help
            customers debug integration issues with the Acme REST API."
     Bad:  "You are a helpful assistant." -->

---

## Your Objectives

Your primary goals, in order of priority:
1. [Primary objective — what you must always accomplish]
2. [Secondary objective]
3. [Tertiary objective]

<!-- Explicit priority order matters when objectives conflict.
     E.g., "1. Give accurate information. 2. Be concise. 3. Be friendly." -->

---

## Behavioral Guidelines

### What to do
- [Specific positive behavior 1]
- [Specific positive behavior 2]
- [Specific positive behavior 3]

### What NOT to do
- Do NOT [behavior 1 you want to prevent]
- Do NOT [behavior 2] — [brief reason why]
- Never [hard constraint]

<!-- Negative instructions are equally important as positive ones.
     Be specific: "Do not apologize for being an AI" beats "be natural" -->

---

## Output Format

[Describe the exact format of your responses.]

For [situation type A], respond using this structure:
**[Section 1 name]**: [what goes here]
**[Section 2 name]**: [what goes here]

For [situation type B], respond in plain prose, 2–4 sentences.

<!-- Always specify: length constraints, structure, section names, markdown usage.
     If output will be parsed programmatically, specify JSON schema here. -->

---

## Examples

### Example 1 — [Scenario name]

User: [Example user message]