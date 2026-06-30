# Data Quality Checklist

Run before any analysis. Bad data → bad conclusions. This checklist takes 15–30 minutes but prevents hours of wasted work.

---

## 1. Source Verification

- [ ] Data source is documented (system name, table/endpoint, extract method)
- [ ] Data freshness confirmed — when was it last updated?
- [ ] Data owner identified — who to contact for questions?
- [ ] Data dictionary / schema documentation reviewed
- [ ] Any known data quality issues flagged by the source team?

---

## 2. Row Counts & Completeness

```python
# Quick checks
print(f"Shape: {df.shape}")
print(f"Duplicates: {df.duplicated().sum()} ({df.duplicated().mean():.1%})")
print(f"Missing cells: {df.isnull().sum().sum()} ({df.isnull().mean().mean():.1%})")
```

- [ ] Row count matches expected volume (cross-check with source system)
- [ ] No unexpected row count drops in date ranges (could indicate failed ETL)
- [ ] Duplicate rows handled (dropped, or intentional — documented)
- [ ] Missing value rate per column acceptable for analysis:
  - < 5%: fine to proceed
  - 5–20%: document and use appropriate imputation/exclusion
  - > 20%: investigate root cause before proceeding

---

## 3. Key Column Checks

For each critical column:

```python
for col in critical_columns:
    print(f"\n{col}:")
    print(f"  Nulls:  {df[col].isnull().sum():,} ({df[col].isnull().mean():.1%})")
    print(f"  Unique: {df[col].nunique():,}")
    print(f"  Sample: {df[col].dropna().sample(min(5, len(df))).tolist()}")
```

- [ ] **Primary key** / unique identifier: zero duplicates, zero nulls
- [ ] **Timestamps**: valid date format, no future dates, no dates before system launch
- [ ] **Categorical columns**: unexpected values not in known enum set?
- [ ] **Numeric columns**: values in expected range (no -999 sentinel values, no nulls encoded as 0)
- [ ] **Foreign keys**: all IDs reference existing records in the parent table

---

## 4. Value Range Checks

```python
# Check numeric bounds
for col in df.select_dtypes(include='number').columns:
    print(f"{col}: min={df[col].min()}, max={df[col].max()}, zeros={( df[col]==0).sum()}")
```

- [ ] No impossible values (negative ages, > 100% rates, negative revenue)
- [ ] Outliers investigated — are they real or data errors?
  - IQR method: values outside Q1 - 1.5×IQR or Q3 + 1.5×IQR
  - Z-score method: |z| > 3 for roughly normal distributions
- [ ] Sentinel/placeholder values identified (`-1`, `999`, `9999-12-31`, `"N/A"`)
- [ ] Numeric fields stored as strings? (e.g., `"$1,234"` needs parsing)
- [ ] Percentage fields: stored as 0.032 or 3.2 or 3.2%? Consistent?

---

## 5. Temporal Checks

```python
# Check date distribution
df['date_col'] = pd.to_datetime(df['date_col'])
print(df['date_col'].describe())
print(f"Date range: {df['date_col'].min()} to {df['date_col'].max()}")

# Check for gaps
date_range = pd.date_range(df['date_col'].min(), df['date_col'].max(), freq='D')
missing_dates = date_range[~date_range.isin(df['date_col'])]
print(f"Missing dates: {len(missing_dates)}")
```

- [ ] Date range covers the expected analysis period
- [ ] No gaps in daily/weekly time series (could indicate missing data)
- [ ] Weekend/holiday patterns are expected, not anomalies
- [ ] Timezone documented and consistent (all UTC, or clearly specified)
- [ ] No data from after a cutoff date (leakage risk in ML)

---

## 6. Distribution Sanity Checks

```python
import matplotlib.pyplot as plt
df.hist(bins=30, figsize=(15, 10))
plt.tight_layout()
plt.show()
```

- [ ] Distribution shape matches expectations (orders are right-skewed, click rates are beta-distributed)
- [ ] No suspicious spikes at round numbers (could indicate imputation or rounding errors)
- [ ] No bimodal distributions that shouldn't be bimodal (could indicate two populations mixed)
- [ ] Seasonal patterns present where expected

---

## 7. Cross-Column Consistency

- [ ] Totals add up (sum of sub-categories equals total)
- [ ] Date ordering makes sense (created_at < updated_at < deleted_at)
- [ ] Logical relationships hold (if cancelled = true, then cancelled_at is not null)
- [ ] Referential integrity: foreign key values exist in the referenced table

```python
# Example: orders with status=cancelled must have cancelled_at set
invalid = df[(df['status'] == 'cancelled') & df['cancelled_at'].isnull()]
print(f"Inconsistent rows: {len(invalid)}")
```

---

## 8. Bias & Sampling Checks

- [ ] Sample is representative of the population you're analyzing
- [ ] Survivorship bias: does the data only include active users/records (missing churned/deleted)?
- [ ] Selection bias: was data collected uniformly, or only for certain segments?
- [ ] Time period bias: does the selected period include unusual events (COVID, holidays, outages)?
- [ ] Reporting lag: are recent records complete, or still accumulating?

---

## 9. Documentation

Before proceeding with analysis, document:

| Item | Value |
|------|-------|
| Data source | [table/endpoint] |
| Date range | [start] to [end] |
| Row count (raw) | |
| Row count (after cleaning) | |
| Key exclusions | [e.g., "removed 234 rows with null user_id"] |
| Known issues | [e.g., "revenue missing for EU region before 2025-01-01"] |
| Analyst | |
| Analysis date | |

---

## Quick Issue Classification

| Issue | Severity | Action |
|-------|----------|--------|
| Primary key duplicates | CRITICAL | Fix before proceeding |
| > 30% nulls in key column | CRITICAL | Investigate source |
| Future dates | HIGH | Flag to data team |
| > 5% duplicates | HIGH | Understand reason |
| Values outside valid range | HIGH | Investigate or exclude |
| 5–30% nulls | MEDIUM | Impute or exclude with documentation |
| Minor encoding issues | LOW | Fix and document |
| Expected outliers | INFO | Document but don't remove |
