# Architecture Decision Record (ADR) Template

ADRs capture the context, decision, and consequences of significant architectural choices.
One file per decision. Store in `/docs/adr/` with sequential numbering: `0001-use-postgresql.md`.

---

# ADR-[NUMBER]: [Short Title of Decision]

**Status**: Proposed | Accepted | Deprecated | Superseded by ADR-[N]
**Date**: YYYY-MM-DD
**Deciders**: [List of people who made or ratified this decision]
**Tags**: `database` `api` `security` `infrastructure` (pick relevant tags)

---

## Context and Problem Statement

<!-- 2–4 sentences describing the situation that forced this decision.
     Include: current pain, scale numbers, constraints, and deadline if relevant.
     Be specific. "We need to handle more traffic" is bad.
     "At 50K DAU, our PostgreSQL replica hits 80% CPU at peak" is good. -->

[Describe the situation and problem here.]

### Driving Forces

- [Force 1: a constraint, concern, or goal — e.g., "read latency must be < 50ms at p99"]
- [Force 2]
- [Force 3]
- [Force 4]

---

## Decision Drivers

Ranked by importance for this specific decision:

1. **[Driver 1]** — e.g., "Operational simplicity: team has no DBA"
2. **[Driver 2]** — e.g., "Consistency: strong ACID guarantees needed"
3. **[Driver 3]** — e.g., "Cost: < $500/month in year 1"
4. **[Driver 4]** — e.g., "Migration path: must be reversible in < 1 week"

---

## Considered Options

### Option A: [Name]

**Description**: [1–3 sentences]

**Pros:**
- [Advantage 1]
- [Advantage 2]

**Cons:**
- [Disadvantage 1]
- [Disadvantage 2]

**Effort**: [days/weeks] · **Cost**: [$X/month]

---

### Option B: [Name]

**Description**: [1–3 sentences]

**Pros:**
- [Advantage 1]
- [Advantage 2]

**Cons:**
- [Disadvantage 1]
- [Disadvantage 2]

**Effort**: [days/weeks] · **Cost**: [$X/month]

---

### Option C: [Name — include "do nothing" if applicable]

...

---

## Decision Outcome

**Chosen Option**: Option [X] — [Name]

**Rationale**: [2–3 sentences explaining why this option best satisfies the decision drivers.
Reference specific drivers by name. Acknowledge the key trade-off you're accepting.]

### Positive Consequences

- [Expected benefit 1]
- [Expected benefit 2]

### Negative Consequences / Accepted Trade-offs

- [Accepted downside 1] — [mitigation plan if any]
- [Accepted downside 2]

### Conditions for Re-evaluation

Revisit this decision if:
- [Condition 1: e.g., "Monthly active users exceed 500K"]
- [Condition 2: e.g., "Operational incidents from this choice exceed 2 per quarter"]

---

## Implementation Notes

<!-- Key technical details that engineers need to implement this decision correctly.
     This is NOT the full implementation spec — just the things that would be
     missed or done wrong without explicit guidance. -->

### Migration Plan

1. [Step 1]
2. [Step 2]
3. [Step 3 — rollback trigger]

### Configuration / Code Conventions

```yaml
# Example config if relevant
option_name: value
```

### Rollback Plan

[How to reverse this decision in an emergency. Be specific: which command, which flag.]

---

## Links

- [Related ADR-000N: Title](./000N-title.md) — [relationship: supersedes / related to / motivated by]
- [RFC / Design Doc](https://link-to-doc)
- [Spike / Proof of Concept](https://link-to-branch-or-pr)
- [Relevant ticket](https://jira.example.com/browse/PROJ-123)

---

## Appendix

### Evaluation Matrix

Weight each driver 1–5. Score each option 1–5 per driver. Multiply, sum, compare.

| Driver | Weight | Option A | Option B | Option C |
|--------|--------|----------|----------|----------|
| [Driver 1] | 5 | 3 (15) | 4 (20) | 2 (10) |
| [Driver 2] | 4 | 4 (16) | 3 (12) | 5 (20) |
| [Driver 3] | 3 | 5 (15) | 2 (6)  | 4 (12) |
| **Total** | | **46** | **38** | **42** |

### Load / Capacity Assumptions

| Metric | Current | 6-month target | 2-year target |
|--------|---------|---------------|---------------|
| DAU | [N] | [N] | [N] |
| Peak RPS | [N] | [N] | [N] |
| Data size | [N GB] | [N GB] | [N TB] |

---

*Template version 2.0 — inspired by [Michael Nygard's ADR format](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)*
