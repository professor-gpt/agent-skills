# SQL Query Optimization Checklist

Before shipping a query that runs against more than ~10,000 rows or more than 10 times per minute,
work through this checklist. Each item includes what to look for in `EXPLAIN ANALYZE` output.

---

## Step 1 — Run EXPLAIN ANALYZE First

```sql
-- PostgreSQL
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT) <your query>;

-- MySQL
EXPLAIN ANALYZE <your query>;

-- SQL Server
SET STATISTICS IO ON; SET STATISTICS TIME ON;
<your query>;

-- SQLite
EXPLAIN QUERY PLAN <your query>;
```

**What to look for:**
- `Seq Scan` on large tables (missing index)
- `Hash Join` vs `Nested Loop` — nested loop is fine for small sets, bad for large
- High `rows=N (actual rows=M)` discrepancy (stale statistics → `ANALYZE table`)
- `cost=X..Y` — X is startup cost, Y is total cost; high Y needs attention
- `Buffers: shared hit=N read=M` — high `read` means disk I/O (add index or increase cache)

---

## A. Index Strategy

- [ ] WHERE clause columns are indexed (check with `EXPLAIN`, look for `Index Scan`)
- [ ] Composite index column order matches query: most selective + equality columns first
- [ ] Range conditions (`BETWEEN`, `>`, `<`) are the last column in composite index
- [ ] Columns used in `JOIN ON` conditions are indexed on both sides
- [ ] `ORDER BY` columns are covered by the index to avoid file sort
- [ ] `LIKE 'prefix%'` can use a B-tree index — `LIKE '%suffix'` cannot (use full-text)
- [ ] Function calls on indexed columns prevent index use: `WHERE LOWER(email) = ?` → use functional index
- [ ] Covering index includes all SELECT columns (no heap fetch needed)
- [ ] Unused indexes identified and dropped (each index slows writes)

```sql
-- Check index usage (PostgreSQL)
SELECT schemaname, tablename, indexname, idx_scan, idx_tup_read, idx_tup_fetch
FROM pg_stat_user_indexes
WHERE idx_scan = 0
ORDER BY schemaname, tablename;
```

## B. Query Structure

- [ ] `SELECT *` replaced with specific column list (avoid fetching unused data)
- [ ] `WHERE` conditions use SARGable expressions:
  - ✅ `WHERE created_at >= '2024-01-01'`
  - ❌ `WHERE YEAR(created_at) = 2024` (function on column = no index)
- [ ] `OR` conditions on different columns rewritten as `UNION ALL` if large tables
- [ ] `NOT IN (subquery)` replaced with `NOT EXISTS` (handles NULLs correctly, often faster)
- [ ] `DISTINCT` removed if not logically required (hides duplicate bug, always slow)
- [ ] `HAVING` used only for aggregate filters; row filters moved to `WHERE`
- [ ] Subqueries in `SELECT` list (correlated) replaced with `LEFT JOIN`
- [ ] `COUNT(*)` used instead of `COUNT(column)` when NULLs don't matter

## C. JOIN Optimization

- [ ] JOIN columns have matching data types (implicit cast disables index)
- [ ] Join order: filter most selective table first in FROM clause (optimizer may reorder, but be explicit)
- [ ] `CROSS JOIN` / unintentional cartesian product checked (missing ON clause)
- [ ] `LEFT JOIN` result filtered with `WHERE right_table.id IS NULL` → change to `NOT EXISTS` or `EXCEPT`

## D. Pagination

- [ ] `OFFSET N` avoided for large N — use keyset pagination instead:

```sql
-- ❌ Slow at large offsets (scans N+limit rows every time)
SELECT * FROM orders ORDER BY id LIMIT 20 OFFSET 10000;

-- ✅ Keyset pagination (O(1) per page after index lookup)
SELECT * FROM orders
WHERE id > :last_seen_id
ORDER BY id
LIMIT 20;
```

## E. Aggregation & Grouping

- [ ] `GROUP BY` columns are indexed
- [ ] Filtering with `WHERE` before aggregation, not after with `HAVING`
- [ ] Partial aggregation in subquery before joining to reduce row count
- [ ] Window functions used instead of self-joins for running totals / rankings

## F. Data Volume Controls

- [ ] All queries have a `LIMIT` (even internal queries in application code)
- [ ] Result set size estimated and acceptable for application memory
- [ ] Long-running reports use async execution (job queue) not synchronous HTTP
- [ ] Batch updates use `WHERE id BETWEEN a AND b` chunks, not single transaction for millions of rows

## G. Statistics & Maintenance

```sql
-- PostgreSQL: refresh statistics
ANALYZE orders;
ANALYZE VERBOSE orders;  -- shows what was sampled

-- PostgreSQL: check table bloat
SELECT relname, n_live_tup, n_dead_tup, last_autovacuum
FROM pg_stat_user_tables
WHERE n_dead_tup > 1000
ORDER BY n_dead_tup DESC;

-- MySQL: update statistics
ANALYZE TABLE orders;

-- Check slow query log
-- PostgreSQL: pg_stat_statements
SELECT query, calls, mean_exec_time, total_exec_time
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 20;
```

---

## Common Anti-Patterns Quick Reference

| Anti-Pattern | Problem | Fix |
|---|---|---|
| `SELECT *` | Over-fetches, breaks with schema changes | List explicit columns |
| Function on indexed column in WHERE | Disables index | Use functional index or rewrite |
| `OFFSET` pagination | O(n) scan per page | Keyset pagination |
| N+1 queries in app code | N round trips | JOIN or batch IN |
| `NOT IN (subquery with NULLs)` | Returns 0 rows if any NULL in subquery | Use `NOT EXISTS` |
| Implicit type cast in JOIN | Disables index | Ensure matching types |
| `OR` across columns | Full table scan | `UNION ALL` of indexed queries |
| `DISTINCT` as a bug fix | Hides duplicate-producing JOIN | Fix the JOIN |
