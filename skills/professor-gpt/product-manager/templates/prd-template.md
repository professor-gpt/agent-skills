# PRD: [Feature Name]

> **Status**: Draft
> **Author**: [Your Name]
> **Last Updated**: YYYY-MM-DD
> **Target Release**: Q[N] YYYY / Sprint [N]
> **Stakeholders**: Engineering, Design, [other teams]

---

## 1. Problem Statement

<!-- THE MOST IMPORTANT SECTION. Write this first, before any solutions.
     Answer in 3–5 sentences:
     - What is happening today that is wrong/painful?
     - Who is affected and how many?
     - What evidence do you have? (data, user quotes, support tickets)
     - Why does solving this matter to the business now?
-->

[Replace with specific, evidence-backed problem statement]

**Supporting evidence:**
- [Data point 1: e.g., "23% of checkout starts don't reach payment step (Mixpanel, last 30d)"]
- [Data point 2: e.g., "Top 3 support complaint: 'I don't know what I get with Pro' (142 tickets in June)"]
- [User quote: "I tried to upgrade but gave up because I couldn't figure out the difference" — User interview, 2026-06-10]

---

## 2. Goals and Success Metrics

<!-- Be specific. "Improve conversion" is not a goal. "Increase trial-to-paid conversion from 4.2% to 6% by end of Q3" is. -->

| Goal | Metric | Baseline | Target | Measurement |
|------|--------|---------|--------|-------------|
| [Primary outcome] | [KPI] | [Current value] | [Target value] | [How/where to measure] |
| [Secondary outcome] | [KPI] | [Current value] | [Target value] | [How/where to measure] |
| [Guard metric — should NOT regress] | [KPI] | [Current value] | No regression | [How/where to measure] |

**Target date for metrics measurement**: [Date — give features time to show impact]

---

## 3. Non-Goals

<!-- Be explicit. "Not doing X in v1" prevents scope creep AND sets expectations.
     A good non-goal explains WHY you're deferring it. -->

- **[Feature X]**: Deferred to v2. Current data doesn't support the investment; we'll revisit after [condition].
- **[Use case Y]**: Affects < 2% of users. Will address via [workaround / future work].
- **[Technically possible but excluded thing Z]**: Engineering effort outweighs impact at current scale.

---

## 4. Background and Context

<!-- Why now? What research, experiments, or events led to this decision?
     Link to: user research reports, A/B test results, competitive analysis, support data. -->

### Research Summary

[Summarize 2–3 key insights from user research or data analysis]

### Competitive Landscape

| Competitor | Approach | Our Differentiator |
|------------|----------|-------------------|
| [Competitor A] | [How they solve it] | [Our advantage] |

### Previous Experiments

| Experiment | Result | Learning |
|------------|--------|---------|
| [A/B test name] | [Outcome] | [Insight that shapes this PRD] |

---

## 5. User Stories

<!-- Write stories for the 2–3 most important user types.
     Format: As a [user type], I want to [action] so that [outcome].
     Each story needs acceptance criteria in Given/When/Then format. -->

### Story 1: [Title]

**As a** [user type],
**I want to** [perform some action],
**So that** [I achieve some goal].

**Acceptance Criteria:**
- [ ] **Given** [context], **When** [action], **Then** [expected result]
- [ ] **Given** [edge case context], **When** [action], **Then** [expected result]
- [ ] [Error case: e.g., "If payment fails, user sees specific error message and is not charged"]

**Out of scope for this story**: [what explicitly doesn't need to work]

---

### Story 2: [Title]

**As a** [user type],
**I want to** [action],
**So that** [outcome].

**Acceptance Criteria:**
- [ ] **Given** [...], **When** [...], **Then** [...]

---

## 6. Solution Overview

<!-- High-level description of the solution. NOT implementation details.
     Describe the user experience, not the technical architecture.
     Include a rough wireframe description or link to Figma if available. -->

### User Experience Flow

1. [Step 1 — what the user sees/does]
2. [Step 2]
3. [Step 3 — happy path ends here]

**Error states:**
- [Error condition 1]: [User sees / system does]
- [Error condition 2]: [User sees / system does]

### Design Links

- Figma: [link]
- User research: [link]

---

## 7. Scope

### In Scope (v1)

- [Specific feature 1]
- [Specific feature 2]
- [Specific feature 3]

### Out of Scope (Future)

| Feature | Reason Deferred | Potential Release |
|---------|-----------------|-----------------|
| [Feature A] | [Reason] | Q[N] YYYY |
| [Feature B] | [Reason] | TBD |

---

## 8. Open Questions

| # | Question | Owner | Due | Decision |
|---|----------|-------|-----|---------|
| 1 | [Question that blocks design/engineering] | [Name] | [Date] | [Pending / Decision made] |
| 2 | [Legal/compliance question] | Legal | [Date] | Pending |

---

## 9. Dependencies

| Dependency | Team | What's Needed | ETA |
|------------|------|---------------|-----|
| [API endpoint X] | Backend | New endpoint for [purpose] | [Date] |
| [Design system component] | Design | [Component name] | [Date] |
| [Legal review] | Legal | Approval for [feature] | [Date] |
| [External vendor] | [Team] | [Integration requirement] | [Date] |

---

## 10. Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| [Engineering risk] | Medium | High | [Mitigation plan] |
| [User adoption risk] | Low | Medium | [Mitigation plan] |
| [Business risk] | Low | High | [Mitigation plan] |

---

## 11. Launch Plan

### Rollout Strategy

- [ ] **Week 1**: Internal team dogfooding
- [ ] **Week 2**: Beta with [N]% of users (Feature flag: `feature_xyz`)
- [ ] **Week 3**: Expand to [N]% if metrics look good
- [ ] **Week 4**: Full rollout

### Rollback Criteria

Roll back if any of the following are observed:
- [Guard metric] drops by > [threshold]
- [Error rate] exceeds [threshold]
- [Critical bug category] detected

### Communications Plan

| Channel | Message | Owner | Timing |
|---------|---------|-------|--------|
| In-app announcement | [Key user benefit] | Marketing | Launch day |
| Email to Pro users | [Feature highlight] | Marketing | Launch day |
| Blog post | [Detailed explanation] | Marketing | [Date] |
| Changelog | [Technical summary] | PM | Launch day |

---

## 12. Appendix

### Glossary

| Term | Definition |
|------|-----------|
| [Term] | [Definition] |

### Related Documents

- [Link to user research report]
- [Link to technical spec]
- [Link to design spec]
- [Link to competitive analysis]
