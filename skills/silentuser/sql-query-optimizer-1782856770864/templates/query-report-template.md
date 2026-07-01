# Template: Query Optimization Report

Use this structure to present findings. Fill each section.

## 1. Input Summary
- **Original Query:**
  ```sql
  -- provided by user
  ```
- **Database System:** (PostgreSQL / MySQL / SQL Server)
- **Provided Schemas & Indexes:** (list or note “none”)

## 2. Anti-Patterns Found
- [ ] Implicit JOIN syntax
- [ ] Non-sargable conditions (functions on indexed columns)
- [ ] `SELECT *` (recommend explicit column list)
- [ ] Correlated subqueries that can be transformed
- [ ] Missing indexes causing scans
- [ ] Other: (explain)

## 3. Execution Plan Diagnosis (if plan provided)
- **Top-cost nodes:**
  - Node 1: (operator) — (rows estimated vs actual) — issue: (e.g., “Seq Scan on orders – 50,000 estimated vs 2 actual”)
  - ...
- **Interpretation:** (plain language summary, using database‑specific operator names and analogies)

## 4. Index Recommendations
### 4.1 Proposed Indexes
```sql
-- Index 1 (PostgreSQL example):
CREATE INDEX idx_... ON ... (...);
```
**Why:** (explain in simple terms, e.g., “This allows the database to jump directly to orders from 2024 without scanning all orders.”)
**Trade-offs:** (write overhead, storage increase, lock considerations)

### 4.2 Alternative Index Strategies (partial, covering, functional) [if applicable]

## 5. Query Rewrite
### 5.1 Rewritten Query
```sql
-- Optimized version
SELECT ...
FROM ...
WHERE ...
ORDER BY ...
LIMIT ...;
```
### 5.2 Explanation of Changes
- Changed `YEAR(order_date)` to range condition for index usage.
- Converted to explicit `INNER JOIN`.
- Selected only necessary columns.
- (If MySQL, note that derived table merging is assumed available in 8.0+.)
- (etc.)

### 5.3 Expected Performance Improvement
“Original query scanned entire orders table (500k rows). With the rewrite and new index, the database will read only ~1,200 rows for 2024 and sort efficiently via index — expecting sub-second response.”

## 6. Plain-Language Explanation
(Write a user-friendly summary, avoiding jargon: “Your report was slow because the system was reading all orders from all years, then sorting them, and finally picking the top 10. We changed it to first grab only this year’s orders using a quick date filter, then the index already has them sorted — the database only touches what it needs.”)

## 7. Assumptions & Next Steps
- Assumed write load is moderate (if not, consider index maintenance costs).
- Test index creation in a staging environment and compare EXPLAIN plans.
- For the specific database system, review server configuration parameters (e.g., PostgreSQL `work_mem`, MySQL `innodb_buffer_pool_size`, SQL Server MAXDOP) if performance is still suboptimal.
- If the database is heavily transactional, monitor index bloat and maintain regularly.