# Before / After: Prompt Engineering Examples

Real prompt transformations showing the difference between vague and precise instructions.
Each example includes the failure mode and what the improvement targets.

---

## Example 1 — Classification Task

### ❌ Before

```
You are a helpful assistant. Classify the following customer support ticket.
```

**Failure modes:**
- Output format is unpredictable (sometimes "Billing", sometimes "BILLING", sometimes "billing question")
- No defined category list — model invents categories each time
- No confidence or reasoning provided
- No instruction for ambiguous tickets

### ✅ After

```
Classify the following customer support ticket into exactly one category.

Categories (use these exact labels):
- BILLING — payment failures, invoices, refunds, pricing questions
- TECHNICAL — bugs, crashes, performance issues, error messages
- ACCOUNT — login, password, email change, account deletion
- FEATURE_REQUEST — asking for new functionality or changes
- GENERAL — questions that don't fit the above categories

Instructions:
- Think step by step before classifying
- Choose the SINGLE best-fitting category
- If unclear, choose the category that best matches the PRIMARY complaint
- Return only the category label, nothing else

Ticket: {{ticket_text}}
Category:
```

**Improvements:**
- ✅ Fixed output vocabulary (5 specific labels)
- ✅ Added definitions for each category
- ✅ "Think step by step" enables chain-of-thought
- ✅ Handles ambiguity ("primary complaint")
- ✅ "nothing else" prevents preamble

---

## Example 2 — Summarization

### ❌ Before

```
Summarize this article.

{{article}}
```

**Failure modes:**
- Length is unpredictable (1 sentence to 5 paragraphs)
- Sometimes includes opinions not in the original
- Doesn't specify the audience or purpose
- No format requirement

### ✅ After

```
Summarize the following article for a busy executive who needs to decide whether to read the full piece.

Output format (use exactly this structure):
**TL;DR** (1 sentence, ≤ 25 words):
[One sentence that captures the most important point]

**Key Facts** (3–5 bullet points):
- [Specific, verifiable fact from the article]
- [...]

**Why It Matters** (1 sentence):
[Business or strategic implication]

Rules:
- Do NOT add opinions or information not in the article
- Do NOT start any bullet with "The article says" or "According to"
- If the article lacks enough content for 3 facts, note it explicitly

Article:
{{article}}
```

**Improvements:**
- ✅ Audience defined ("busy executive")
- ✅ Purpose defined ("decide whether to read")
- ✅ Exact output structure specified
- ✅ Length constraints ("≤ 25 words", "3–5 bullets")
- ✅ Rules prevent hallucination and filler phrases

---

## Example 3 — Code Generation

### ❌ Before

```
Write a function to validate email addresses.
```

**Failure modes:**
- Unknown language (will guess JavaScript or Python arbitrarily)
- Unknown validation standard (RFC 5322? Simple regex? MX lookup?)
- No error handling
- No tests
- May add features that weren't asked for

### ✅ After

```
Write a TypeScript function to validate email addresses.

Requirements:
- Language: TypeScript (strict mode)
- Validation: Format only (no DNS/MX lookup required)
- Accepts: standard email format per HTML5 spec (e.g., user@domain.tld)
- Rejects: strings without @, domains without TLD, leading/trailing whitespace

Function signature:
function isValidEmail(email: string): boolean

Rules:
- Return true only if the format is valid
- Return false for all invalid inputs (including null/undefined passed as any)
- No external dependencies — pure TypeScript
- No comments inside the function body

After the function, write 6 test cases using plain console.assert():
- 2 valid emails
- 2 invalid emails (different failure reasons)
- 1 edge case (empty string)
- 1 edge case (whitespace)
```

**Improvements:**
- ✅ Language + type system specified
- ✅ Exact validation scope defined (format only, no DNS)
- ✅ Function signature provided (no guessing)
- ✅ Dependency constraint (no libraries)
- ✅ Test cases requested with explicit categories

---

## Example 4 — Role Prompting

### ❌ Before

```
You are a senior software engineer. Review this code and tell me if there are any issues.
```

**Failure modes:**
- "Senior software engineer" is too generic — could mean frontend, ML, DevOps
- "Issues" is vague — bugs? style? performance? security?
- No output format — will vary per run
- No severity indication

### ✅ After

```
You are a senior backend engineer with expertise in Node.js, security, and distributed systems.
You have reviewed thousands of PRs and know how to identify both obvious bugs and subtle issues that cause production incidents.

Review the following code across four dimensions:
1. CORRECTNESS — logic errors, wrong assumptions, missing edge cases
2. SECURITY — injection risks, auth bypasses, data exposure, insecure crypto
3. PERFORMANCE — N+1 queries, unbounded loops, memory leaks, missing indices
4. MAINTAINABILITY — unclear naming, missing error handling, hidden side effects

For each issue found, use this format:
**[SEVERITY: CRITICAL|HIGH|MEDIUM|LOW]** [Dimension] — [One-line description]
```[language]
// Specific line or block that's problematic
```
Fix: [Concrete recommendation — code snippet if needed]

If no issues in a dimension, write: "✅ [Dimension]: No issues found."

Code to review:
```[language]
{{code}}
```
```

**Improvements:**
- ✅ Specific expertise domain (backend, Node.js, security)
- ✅ Four review dimensions explicitly defined
- ✅ Severity level required (CRITICAL/HIGH/MEDIUM/LOW)
- ✅ Exact output format with code blocks
- ✅ Handles "no issues" case explicitly

---

## Example 5 — Extraction with JSON Output

### ❌ Before

```
Extract the person's name, company, and contact information from this email.

{{email_text}}
```

**Failure modes:**
- Output format varies (JSON? prose? CSV?)
- Field names are inconsistent
- Missing fields are unclear (null? empty string? omitted?)
- No handling for multiple contacts in one email

### ✅ After

```
Extract contact information from the following email.

Return ONLY valid JSON. No explanation, no markdown code fences, just the raw JSON.

Schema:
{
  "contacts": [
    {
      "full_name": string | null,
      "first_name": string | null,
      "last_name": string | null,
      "email": string | null,
      "phone": string | null,
      "company": string | null,
      "title": string | null
    }
  ]
}

Rules:
- Include ALL people mentioned in the email, not just the sender
- Use null (not "" or "N/A") for fields not found in the text
- Phone numbers: include country code if present, otherwise local format as written
- If you find no contact information, return {"contacts": []}
- Do not infer or guess — only extract explicitly stated information

Email:
{{email_text}}
```

**Improvements:**
- ✅ Output format locked to JSON (no prose)
- ✅ Schema with explicit types and nullability
- ✅ Multiple contacts handled ("ALL people mentioned")
- ✅ Null handling standardized (null vs "")
- ✅ "Do not infer" prevents hallucination
- ✅ Empty-result case defined

---

## Quick Improvement Patterns

| Vague | Precise |
|-------|---------|
| "summarize this" | "summarize in 3 bullets, each ≤ 20 words" |
| "be concise" | "respond in at most 150 words" |
| "explain clearly" | "explain as if to a software engineer who hasn't used React before" |
| "fix the bug" | "fix only the bug in lines 23–31; don't refactor anything else" |
| "classify this" | "classify into exactly one of: [A, B, C]; return only the label" |
| "you're an expert" | "you're a senior DBA who has optimized PostgreSQL at 10M rows/table" |
| "be helpful" | "respond with the answer directly; no preamble like 'Great question!'" |
