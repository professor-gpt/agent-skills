# RICE Scoring Example — Feature Prioritization

**RICE Formula**: `(Reach × Impact × Confidence) / Effort = RICE Score`

| Variable | What it measures | Unit |
|----------|-----------------|------|
| **Reach** | Users affected per quarter | # users |
| **Impact** | Effect on goal per user | 0.25 / 0.5 / 1 / 2 / 3 |
| **Confidence** | How certain are you about estimates | 50% / 80% / 100% |
| **Effort** | Total person-weeks to ship | person-weeks |

---

## Example: Q3 Prioritization for Growth Team

**Goal**: Increase trial-to-paid conversion rate (currently 4.2%)

### Feature Backlog

| # | Feature | Reach | Impact | Confidence | Effort (pw) | RICE Score |
|---|---------|-------|--------|-----------|------------|------------|
| 1 | Upgrade prompt in editor sidebar | 8,400 | 2 | 80% | 2 | **6,720** |
| 2 | Email drip campaign (trials day 3+7) | 6,200 | 2 | 80% | 3 | **3,307** |
| 3 | Feature comparison table on pricing page | 12,000 | 1 | 100% | 1 | **12,000** |
| 4 | Onboarding checklist for new users | 4,100 | 3 | 50% | 6 | **1,025** |
| 5 | Annual billing discount offer | 2,800 | 3 | 100% | 1 | **8,400** |
| 6 | Referral program | 5,000 | 2 | 50% | 8 | **625** |
| 7 | Live chat for trial users | 3,200 | 1 | 80% | 4 | **640** |
| 8 | Mobile app push notifications | 1,800 | 1 | 50% | 12 | **75** |

---

### Calculation Walk-throughs

#### Feature 3: Feature Comparison Table on Pricing Page

```
Reach:      12,000   (all trial users hit pricing page per quarter)
Impact:     1        (medium — helps conversion but not the bottleneck)
Confidence: 100%     (we've A/B tested comparison tables at previous company; they work)
Effort:     1 pw     (design already done; just needs implementation)

RICE = (12,000 × 1 × 1.0) / 1 = 12,000
```

**Why high RICE despite medium impact?** Minimal effort + confirmed by external evidence + touches all trials.

---

#### Feature 4: Onboarding Checklist

```
Reach:      4,100    (new signups per quarter who don't complete setup)
Impact:     3        (massive — users who complete setup convert at 3× rate in our data)
Confidence: 50%      (we're assuming a checklist drives completion; untested)
Effort:     6 pw     (design + backend + analytics instrumentation)

RICE = (4,100 × 3 × 0.5) / 6 = 1,025
```

**Why low despite massive impact?** Low confidence kills it. Run a 2-week spike to validate first.

---

### Prioritized Roadmap (by RICE)

```
Priority 1 (RICE > 5,000):
  ① Feature comparison table    RICE: 12,000  → Ship in Sprint 1
  ② Annual billing discount      RICE: 8,400   → Ship in Sprint 1

Priority 2 (RICE 1,000–5,000):
  ③ Upgrade prompt in sidebar    RICE: 6,720   → Ship in Sprint 2
  ④ Email drip campaign          RICE: 3,307   → Ship in Sprint 2–3

Priority 3 (RICE < 1,000 — deprioritized this quarter):
  ⑤ Onboarding checklist         RICE: 1,025   → Spike first (2 days to validate)
  ⑥ Live chat for trials         RICE: 640     → Q4
  ⑦ Referral program             RICE: 625     → Q4
  ⑧ Mobile push notifications    RICE: 75      → Backlog
```

---

### Decision Rationale

**Why Feature Comparison Table first?** Near-zero effort, touches all trials, and we have external evidence it works. This is the classic "highest ROI, lowest risk" pick.

**Why Annual Billing Discount second?** 1 person-week for $X in incremental ARR. The discount pays for itself in < 2 weeks from users who would have churned anyway.

**Why deprioritize Onboarding Checklist despite 3× conversion rate?** The 3× rate is a correlation (users who complete setup were already more motivated). We need to test whether *the checklist* causes completion, or just attracts motivated users who would have converted anyway. Spike: add a simple progress indicator (0.5 pw) to one cohort and measure completion delta before committing to the full 6 pw build.

---

## RICE Calibration Tips

| Impact Level | When to use |
|-------------|-------------|
| 3 — Massive | You have data showing 2–3× improvement on the primary metric |
| 2 — High | Directly removes a confirmed friction point |
| 1 — Medium | Positive but indirect effect on the goal |
| 0.5 — Low | Affects a small segment or indirectly |
| 0.25 — Minimal | Nice-to-have; some users will notice |

| Confidence Level | When to use |
|----------------|-------------|
| 100% | You've shipped this before and have results |
| 80% | Strong analogous evidence or clear user research |
| 50% | Hypothesis based on intuition or indirect signals |

**Warning signs in RICE scoring:**
- Everyone uses Impact = 3 and Confidence = 100% → calibration is broken
- Features with identical RICE scores should be compared qualitatively on risk
- RICE is an input to the conversation, not a substitute for judgment
