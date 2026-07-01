# Example: Complete Skill Generation Session

## Scenario

User: "I need an AI agent skill that helps me review SaaS vendor contracts. I get a lot of B2B SaaS agreements and I want the agent to flag risky clauses, suggest negotiation positions, and give me a summary I can take to my legal counsel."

## Step 1 — Classification (Agent asks)

Agent asks:
- **Category**: Legal & Compliance Assistant
- **Orientation**: Problem-first (user describes outcome — contract review)
- **Specialization**: B2B SaaS contract review

Agent then asks context-gathering questions:
- Use cases: (1) Review new vendor agreements for risk, (2) Compare renewal terms against original, (3) Prepare a negotiation brief
- Input types: PDF contracts, DOCX agreements, pasted clause text
- Output: Risk summary table, clause-by-clause analysis, negotiation brief
- Tools: None specific — pure document analysis
- Guardrails: Not legal advice — always escalate final decisions to counsel. US jurisdiction focus.
- Install target: Claude Code

## Step 2 — Agent Assembles Internal Brief

```json
{
  "categoryId": "legal-compliance",
  "specialization": "B2B SaaS contract review",
  "orientation": "problem-first",
  "useCases": [
    "Review new SaaS vendor agreements for risky clauses",
    "Compare renewal terms against original agreement",
    "Prepare a negotiation brief with recommended positions"
  ],
  "inputTypes": ["document"],
  "toolsAndSystems": [],
  "workflowSteps": [
    "Ask the user to provide the contract text (paste, upload reference, or describe key clauses)",
    "Parse the contract into logical sections: liability, IP, data privacy, payment terms, termination, SLAs",
    "Classify each clause against the risk taxonomy in ./references/saas-risk-taxonomy.md",
    "Generate a risk summary table with severity ratings, clause references, and plain-language explanations",
    "For HIGH and CRITICAL risks, generate specific fallback negotiation language",
    "Produce a negotiation brief structured for legal counsel review",
    "Validate: confirm all risks are classified, all HIGH/CRITICAL risks have fallback language, disclaimer is present"
  ],
  "outputFormats": [
    {
      "format": "markdown",
      "description": "Risk summary table + clause-by-clause analysis + negotiation brief",
      "templatePath": "./templates/contract-review-output.md"
    }
  ],
  "qualityCriteria": [
    "Every clause is classified with a severity rating",
    "HIGH and CRITICAL risks have negotiation fallback language",
    "Plain-language explanations for non-lawyers",
    "Legal disclaimer included"
  ],
  "guardrails": [
    "Not legal advice — output is for attorney review only",
    "US jurisdiction focus; flag non-US governing law clauses for special attention",
    "Escalate any clause involving criminal liability, fraud, or regulatory penalty to human counsel immediately"
  ],
  "language": "English",
  "tone": "professional",
  "installTarget": "claude-code",
  "packageComplexity": "multi-file",
  "companionFiles": [
    {
      "path": "references/saas-risk-taxonomy.md",
      "type": "references",
      "purpose": "Complete taxonomy of SaaS contract risks: severity levels, clause categories, standard fallback positions, and red-flag patterns"
    },
    {
      "path": "templates/contract-review-output.md",
      "type": "templates",
      "purpose": "Output template the agent fills in: risk summary table, clause analysis format, negotiation brief structure"
    },
    {
      "path": "examples/sample-contract-review.md",
      "type": "examples",
      "purpose": "Worked example showing a realistic SaaS agreement excerpt with the full analysis output"
    }
  ]
}
```

## Step 3 — Agent Generates Multi-File Package