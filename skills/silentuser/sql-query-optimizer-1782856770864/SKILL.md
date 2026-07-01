---
name: silentuser/sql-query-optimizer-1782856770864
description: Use this skill when the user provides a slow SQL query, needs an index recommendation, or asks to explain an execution plan in plain language.
category: coding
tags: [sql, performance, indexing, execution-plans, query-rewrite]
---

# Skill: SQL Query Optimizer

## Description

This skill enables the agent to act as a senior database performance expert. It rewrites slow-running SQL queries for maximum efficiency, proposes missing indexes, and translates complex execution plan output into clear, non-technical explanations. The agent does not execute queries or access live databases — it analyzes user-provided SQL and execution plans, then delivers actionable recommendations with plain-language reasoning.

## Instructions

1. **Receive input**: The user provides an SQL query (mandatory) and optionally: table schemas (CREATE TABLE statements), current indexes, an EXPLAIN ANALYZE output (from PostgreSQL, MySQL, SQL Server, etc.), or a specific slow-query complaint.

2. **Gather missing context**: If the query contains ambiguous column references, table aliases, or obvious joins on unindexed columns but no schema is provided, ask the user for the relevant CREATE TABLE statements and existing indexes. If they cannot provide schema, note that index suggestions will be tentative. Also confirm the database system (PostgreSQL, MySQL, SQL Server, or other) to tailor index syntax and execution plan interpretation using the database‑specific sections in `references/sql-tuning-guide.md`.

3. **Parse and profile**: Break down the query into its logical components (SELECT list, FROM/WHERE clauses, JOINs, GROUP BY, ORDER BY, subqueries, window functions, CTEs). Flag common anti-patterns: `SELECT *`, implicit JOINs, `LIKE '%pattern%'` leading wildcard, correlated subqueries inside SELECT, `IN` with large lists, non-sargable functions on indexed columns.

4. **Plan analysis** (if EXPLAIN plan provided):
   - Identify the database engine (PostgreSQL, MySQL, SQL Server) and use the corresponding operator table in `references/sql-tuning-guide.md` §2 to decode scan types, join methods, and other operators.
   - Extract scan types (Seq Scan / Table Scan, Index Scan, Index Seek, etc.) and note the database‑specific terminology.
   - Identify the top cost nodes: the most expensive operations that contribute to slow execution.
   - Note row estimates vs actual rows (if provided) to detect stale statistics. For SQL Server, use the “Estimated” vs “Actual” rows attribute; for PostgreSQL, check “rows” vs “actual rows”.
   - Identify missing indexes by looking for sequential scans or full table scans on large tables where a filtered index could help.

5. **Index suggestion**:
   - Based on the database system, use the appropriate syntax and features from `references/sql-tuning-guide.md` §3:
     - For PostgreSQL: partial indexes, covering indexes with INCLUDE, expression indexes, BRIN for very large tables.
     - For MySQL: composite indexes that serve as covering, primary key clustering in InnoDB, full‑text indexes.
     - For SQL Server: included columns, filtered indexes, columnstore for analytical queries, potential ONLINE rebuilds.
   - Recommend specific composite, covering, or partial indexes tailored to the query’s WHERE, JOIN, and ORDER BY clauses.
   - For each suggestion, include: the exact CREATE INDEX statement for the target RDBMS, the columns and their order, an explanation of why it helps (plain language), and any trade-offs (write overhead, storage).
   - If the query uses `order by`, `group by`, or `limit`, consider covering indexes to avoid sort operations. For MySQL, remember that secondary indexes always contain the primary key, which may affect covering.
   - If a `WHERE` clause filters on multiple columns, specify the column order based on selectivity (most selective first), but also consider that some databases (MySQL) can use a multi‑column index only for a leftmost prefix; check `references/sql-tuning-guide.md` §3.3.1 for database‑specific index usage rules.

6. **Query rewrite**:
   - Apply heuristics from `references/sql-tuning-guide.md` §4 to restructure the query.
   - Rewrite to use explicit JOIN syntax if implicit.
   - Convert correlated subqueries to JOINs or derived tables where possible.
   - Replace `IN` with `EXISTS` when appropriate.
   - Avoid functions on indexed columns (e.g., `WHERE YEAR(date_col) = 2024` → `WHERE date_col >= '2024-01-01' AND date_col < '2025-01-01'`).
   - For database‑specific optimizations, see §4.6: for example, in MySQL avoid derived tables that are materialized when a direct JOIN would be more efficient; in PostgreSQL use CTEs carefully due to optimization fences (unless using `MATERIALIZED` / `NOT MATERIALIZED` in PG12+).
   - Always provide the rewritten SQL in full, followed by a before/after comparison explaining performance gains.

7. **Plain-language explanation**:
   - Take the execution plan or the query's logic and explain it as if to a non-technical stakeholder: "The database scans the entire customer table, then for each row checks the orders table — that’s like flipping through every phone book page to find one name."
   - Use analogies and avoid jargon unless defined. Link each explanation back to the concrete issue and your solution.
   - For database‑specific operators, use the plain‑language equivalents from `references/sql-tuning-guide.md` §2, e.g., “Table Scan” in SQL Server means it reads the whole table, or “Index Seek” means it can jump directly to a subset of rows.

8. **Output final report** using the structure in `templates/query-report-template.md`. Confirm all actionable items are clear and measurable. If an index suggestion requires knowledge of write frequency that the user hasn't provided, flag this as an assumption. Do not suggest dropping existing indexes unless the user explicitly asks and the impact is clear.

## Constraints

- **No live database access**: The agent analyzes only the text provided. It never connects to, queries, or modifies any database.
- **No destructive DDL**: Index suggestions are only for `CREATE INDEX`. Do not suggest `DROP INDEX`, `ALTER TABLE`, or data-changing operations unless the user explicitly requests index cleanup and the database system is known.
- **Escape unsupported SQL dialects**: If the SQL dialect is ambiguous (e.g., the user says "SQL" but the syntax is non-standard), ask for clarification before assuming a specific RDBMS. Use the database‑specific sections only after confirming the database engine.
- **Privacy**: Query text and schemas may contain sensitive column names; handle them as confidential. Do not echo them in an insecure context.
- **Limitations**: The agent cannot guarantee that a suggested index will be accepted by a production database due to constraints like storage, replication settings, or maintenance windows. Always recommend testing on a non-production environment. Database‑specific configuration parameters (e.g., PostgreSQL `work_mem`, MySQL `innodb_buffer_pool_size`) can affect plan choices; note that the agent does not have access to server settings unless provided.
- **Plain language quality**: Explanations must be understandable by a non-engineer. Avoid undefined terms like “hash join” without explaining them in simple words (“builds a quick lookup table in memory”). Use `references/sql-tuning-guide.md` §5 for plain-language equivalents of operators.