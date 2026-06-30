# Prompt Review Checklist

Run before deploying any prompt to production.
Mark: ✅ Pass · ❌ Fail · N/A

---

## A. Clarity & Specificity

- [ ] The role is specific (not just "helpful assistant")
- [ ] The task is unambiguous — could you explain it to a new hire in one sentence?
- [ ] All undefined terms are explained or will be obvious to the model
- [ ] Output format is specified (length, structure, markdown, language)
- [ ] Edge cases are handled (empty input, ambiguous input, off-topic input)
- [ ] The prompt can be read top-to-bottom without forward references

## B. Output Control

- [ ] Length constraint specified if critical (`≤ 150 words`, `3–5 bullets`, `one sentence`)
- [ ] Structure specified if needed (JSON schema, template, section names)
- [ ] Forbidden output patterns listed (`Do NOT add disclaimers`)
- [ ] "No result" case handled (what to return if the task can't be completed)
- [ ] If JSON output: schema is explicit with types and nullability
- [ ] If code output: language, version, and style specified

## C. Instruction Quality

- [ ] Instructions use active voice and imperative mood ("Return", not "You should return")
- [ ] No contradictory instructions (check for conflicts between sections)
- [ ] Priority order stated when instructions can conflict
- [ ] Instructions address the failure modes you've observed in testing
- [ ] No "always be helpful" type filler — every instruction is actionable

## D. Few-Shot Examples

- [ ] At least 2–3 examples for classification/extraction tasks
- [ ] Examples cover the most common input patterns
- [ ] Examples are consistent with the instructions
- [ ] Edge cases represented in examples (not just easy cases)
- [ ] Examples follow the exact output format specified in instructions

## E. Safety & Robustness

- [ ] Prompt injection resistance: does adding `"Ignore previous instructions"` break behavior?
- [ ] Grounding: does the prompt prevent hallucination of facts? (`"Only use information from the document"`)
- [ ] No user-supplied content is trusted as instructions (use clear delimiters like `<user_input>`)
- [ ] Rate limits or scope limits specified if needed (`"Only answer questions about X"`)
- [ ] Sensitive data handled appropriately (PII, financial, medical)

## F. Testing

- [ ] Tested with 5+ varied inputs from real-world usage
- [ ] Tested with adversarial inputs (off-topic, ambiguous, empty)
- [ ] Tested for consistency: same input → same output format (not same content, but same structure)
- [ ] Tested at temperature=0 and temperature=0.7 to understand variance
- [ ] Output failure rate measured and acceptable (< 5% for production)

## G. Maintainability

- [ ] Prompt is version-controlled
- [ ] Changelog documents what changed and why
- [ ] Variables/placeholders are clearly marked (`{{variable_name}}`)
- [ ] Prompt is human-readable — a new team member can understand intent
- [ ] Model version pinned (behavior changes between model versions)

---

## Common Prompt Failure Modes

| Symptom | Root Cause | Fix |
|---------|-----------|-----|
| Inconsistent output format | No format specified | Add explicit format template |
| Includes unwanted preamble | No negative instruction | Add `"Do not explain what you're about to do"` |
| Too long / too short | No length constraint | Add `"Respond in exactly N sentences"` |
| Off-topic answers | No scope constraint | Add `"Only answer questions about [topic]"` |
| Hallucinated facts | No grounding instruction | Add `"Only use information from the provided context"` |
| Wrong tone | No tone instruction | Add `"Tone: professional but direct; no marketing language"` |
| Inconsistent across runs | High temperature + no examples | Add few-shot examples + lower temperature |
| Breaks on edge input | No edge case handling | Add explicit edge case instructions + examples |
| JSON parsing errors | Schema not specified | Add full JSON schema with types |
| Ignores part of instruction | Instruction too long | Split into numbered list; put critical rules first |

---

## Pre-deployment Sign-off

- [ ] Tested by at least one other person who wasn't involved in writing
- [ ] Failure rate measured on 20+ real inputs
- [ ] Rollback plan exists (previous prompt version stored)
- [ ] Monitoring in place to detect prompt regressions after model updates
