# Reference: SQL Performance Tuning Guide

This guide expands upon generic SQL tuning with database‑specific details for PostgreSQL, MySQL, and SQL Server. Use it during plan analysis, index suggestions, and query rewrites.

## 1. Quick Reference for Consultant Use
This document condenses common execution plan operators, index types, anti-patterns, and rewriting heuristics with database‑specific nuances.

## 2. Execution Plan Operators & Plain-Language Equivalents

### 2.1 Common Operators Across Databases

| Operator                     | PostgreSQL            | MySQL (EXPLAIN)        | SQL Server              | Meaning (Plain Language)                                   | Performance Impact                           |
|------------------------------|------------------------|------------------------|-------------------------|-------------------------------------------------------------|----------------------------------------------|
| Full Table Scan              | Seq Scan              | ALL (no index used)    | Table Scan              | Reads every row in the table one by one.                   | Slow on large tables; missing index.         |
| Index Scan (access rows)     | Index Scan            | Index (type)           | Index Seek + Key Lookup | Uses an index to find rows, then accesses the table.        | Fast with selective filter; lookout for high key lookups. |
| Index Only / Covering Scan   | Index Only Scan       | Using index (covering) | Index Seek (covering)   | Reads the index only, no table access needed.              | Very fast; covering index effective.        |
| Index Seek (direct locate)   | Index Scan / Bitmap   | Range (or ref)         | Index Seek              | Jumps directly to a range of rows via index.               | Efficient for selective range predicates.   |
| Bitmap Index Scan            | Bitmap Index Scan     | (multiple indexes)      | Index Union/Intersection| Combines multiple index lookups and sorts results.          | Good for many OR conditions.                |
| Nested Loop Join             | Nested Loop           | Nested Loop            | Nested Loop             | For each row in outer table, look up matching rows in inner. | Fast if one side tiny; slow on large–large. |
| Hash Join                    | Hash Join             | Hash Join (8.0.18+)    | Hash Match              | Builds in-memory lookup from one side, then matches.       | Efficient for two large tables without indexes. |
| Merge Join                   | Merge Join            | (not directly shown)   | Merge Join              | Sorts both sides on join key and scans together.            | Good if both sides pre‑sorted.              |
| Sort                         | Sort                  | Using filesort         | Sort                    | Orders rows, often for ORDER BY or GROUP BY.               | Expensive on large sets; indexes can avoid.   |
| Aggregation                  | HashAgg / GroupAgg    | Using temporary; Using filesort | Hash Match (Aggregate) / Stream Aggregate | Performs GROUP BY.                            | HashAgg efficient for large groups; indexes can avoid. |

### 2.2 Database‑Specific Plan Interpretation Details

**PostgreSQL**
- Look at `(cost=... ... ... rows=... width=...)`. The first cost is start-up (return first row), second is total. High total cost often points to the bottleneck.
- `actual time=... rows=...` gives the real execution stats when using `EXPLAIN ANALYZE`. Large difference between estimated and actual rows indicates stale statistics.
- Flags like `Materialize`, `CTE Scan` indicate materialization of subqueries that may be avoided.

**MySQL**
- `type` column: `ALL` (full table scan), `index` (full index scan), `range` (index range scan), `ref`/`eq_ref` (index lookup), `const` (primary key constant lookup). Aim for `range` or better.
- `Extra`: `Using index` (covering index), `Using filesort` (manual sort), `Using temporary` (temp table for GROUP BY / DISTINCT). Avoid `Using filesort` and `Using temporary` on large sets.
- `rows` column is an estimate; large mismatch with reality indicates `ANALYZE TABLE` needed.

**SQL Server**
- Icons in graphical plan: “Table Scan”, “Index Seek”, “Key Lookup”, “Nested Loops”, “Hash Match”, “Merge Join”. Reading the XML or properties pane shows “Estimated Number of Rows” vs “Actual Number of Rows”.
- Look for thick lines (high data flow) and high “Estimated Subtree Cost”.
- Warnings like “Missing Index” hint in the plan give explicit CREATE INDEX recommendations; incorporate these but evaluate based on overall query pattern.
- “Key Lookup” high percentage is a prime target for covering indexes with INCLUDE columns.

## 3. Index Types & Database‑Specific Syntax

### 3.1 Single-Column Index
**Use:** when a `WHERE` clause filters on a single column with high selectivity.

| Database    | Syntax |
|-------------|--------|
| PostgreSQL  | `CREATE INDEX idx ON table (col);` |
| MySQL       | `CREATE INDEX idx ON table (col);` |
| SQL Server  | `CREATE INDEX idx ON table (col);` |

### 3.2 Composite Index
**Use:** when queries filter on multiple columns together, or filter + order by. Column order: most selective first, then join columns, then ORDER BY columns.

All three databases support composite indexes with identical basic syntax:
```sql
CREATE INDEX idx ON table (col1, col2, col3);
```

**Database‑specific notes:**
- **PostgreSQL**: Can also specify sort order per column (`ASC`, `DESC`), crucial for indexes that support `ORDER BY DESC`. Example: `(col1 ASC, col2 DESC)`.
- **MySQL**: InnoDB secondary indexes automatically append the primary key columns, making them potentially covering. Column order in the index declaration is critical because MySQL can only use a leftmost prefix of the index unless index condition pushdown (ICP) is active.
- **SQL Server**: `CREATE INDEX idx ON table (col1, col2) INCLUDE (col3)` to add non‑key columns for covering purposes.

### 3.3 Covering Index (Index Only Scan)

**PostgreSQL**
```sql
CREATE INDEX idx ON table (col1, col2) INCLUDE (col3, col4);
```
- Columns after INCLUDE are not part of the index tree but stored in the leaf, allowing index‑only scans.

**MySQL**
- InnoDB: All columns of a composite index are part of the index; if you include extra columns after the search prefix, they are stored in the index and can serve as a covering index. Example: `CREATE INDEX idx ON orders (cust_id, order_date, order_total);` – this index can cover a query that filters by `cust_id` and returns `order_date` and `order_total`.
- For primary key lookups, the entire row is already in the primary key (clustered index).

**SQL Server**
```sql
CREATE INDEX idx ON table (col1, col2) INCLUDE (col3, col4, col5);
```
- Key columns used for searching, included columns avoid Key Lookups.

### 3.4 Partial / Filtered Index

- **PostgreSQL**: `CREATE INDEX idx ON table (col) WHERE status = 'active';`
- **SQL Server**: `CREATE INDEX idx ON table (col) WHERE status = 'active';` (Filtered Index)
- **MySQL**: No direct partial index feature, but can emulate with a very wide composite index if the subset is small and always filtered; otherwise, workarounds are limited.

### 3.5 Expression / Functional Index

- **PostgreSQL**: `CREATE INDEX idx ON table ((LOWER(email)));`
- **MySQL**: From 8.0.13, functional indexes: `CREATE INDEX idx ON table ((LOWER(email)));` (or using generated columns in older versions).
- **SQL Server**: Use a computed column: `ALTER TABLE table ADD email_lower AS LOWER(email) PERSISTED; CREATE INDEX idx ON table (email_lower);`

### 3.6 Full-Text Index
- **PostgreSQL**: `CREATE INDEX idx ON table USING GIN (to_tsvector('english', body));`
- **MySQL**: `CREATE FULLTEXT INDEX idx ON table (col1, col2);`
- **SQL Server**: `CREATE FULLTEXT CATALOG ft; CREATE FULLTEXT INDEX ON table (col LANGUAGE ...) ...;` (more complex setup).

### 3.7 Additional PostgreSQL-Specific Indexes
- **BRIN (Block Range Index)**: For very large tables with physically correlated data (e.g., timestamps). `CREATE INDEX idx ON orders USING BRIN (order_date) WITH (pages_per_range = 32);` Much smaller than B‑tree, good for range scans.
- **GIN**: For array or JSONB queries.
- **GiST**: For geometric or full-text.

### 3.8 Additional SQL Server-Specific Indexes
- **Columnstore Index**: For large analytical queries (aggregation over many rows). `CREATE CLUSTERED COLUMNSTORE INDEX idx ON fact_table;` or non‑clustered columnstore with included columns.
- **Online rebuild**: `CREATE INDEX ... WITH (ONLINE = ON)` – avoids blocking during creation; relevant for production but not required for suggestion.

## 4. Query Rewrite Heuristics

### 4.1 Sargability (Same Across All)
- Avoid functions on indexed columns: `WHERE YEAR(date_col) = 2024` → `WHERE date_col >= '2024-01-01' AND date_col < '2025-01-01'`.
- Avoid arithmetic: `WHERE col + 1 = 5` → `WHERE col = 4`.
- Leading wildcard `LIKE '%pattern'` disables B‑tree; full‑text required.

### 4.2 Join Syntax & Type
- Use explicit `JOIN ... ON`.
- Replace correlated subqueries with derived tables or `WITH` when the subquery executes per outer row.
- `NOT IN` with NULLs can produce unexpected results; use `NOT EXISTS`.

### 4.3 Aggregation & Sorting
- `ORDER BY` columns should be in an index as the last column(s) after filtering columns.
- In PostgreSQL, `ORDER BY` using the same column order as an index can avoid a sort, provided the index includes all the columns and has no unmatched conditions.
- MySQL’s `ORDER BY` can be optimized if the index exactly matches the `ORDER BY` expression and all previous tables are constant; otherwise it will `Using filesort`.
- SQL Server: an index with sorted columns can provide query output order without an explicit sort.

### 4.4 LIMIT / TOP
- Always use `ORDER BY` for deterministic results.
- An index on the `ORDER BY` expression can avoid a full sort; for `LIMIT` with an index, the database can scan the index in sorted order and stop early.

### 4.5 CTE vs. Subquery (Database‑Specific)
- **PostgreSQL**: Prior to v12, CTEs were always materialized (optimization fence); from v12 `WITH ... AS [NOT] MATERIALIZED` gives control. Without that, a CTE may prevent predicate pushdown, leading to performance hits. Prefer derived tables if unsure.
- **MySQL**: Derived tables (subqueries in FROM) are materialized in <8.0 without `derived_merge`. In MySQL 8.0+, the optimizer may merge them, but a CTE may block merging? Usually similar to derived tables.
- **SQL Server**: CTEs are not materialized by default; they act like views and the optimizer can push predicates. They are mainly syntactic.

### 4.6 Additional Database‑Specific Optimizations
- **PostgreSQL**: `SELECT DISTINCT` can be ineffective with many columns; consider `GROUP BY`. Window functions may require ordered sets; `ROWS BETWEEN` can reduce memory.
- **MySQL**: Avoid `SELECT ... FOR UPDATE` on large ranges due to locking. Use `SQL_NO_CACHE` or modern `SELECT /*+ NO_QUERY_TRANSFORMATION */` hints for debugging.
- **SQL Server**: Use `OPTION (RECOMPILE)` for queries with parameter sniffing issues. Avoid scalar UDFs inside SELECT because they are executed per row and prohibit parallelism.

## 5. Plain-Language Glossary for Explaining Plans

- **Seq Scan / Full Table Scan**: “Reading the entire table from start to finish, like reading every page of a book to find a specific chapter.”
- **Index Scan with Key Lookup**: “The database quickly locates the rows in the index (the book’s index) but then has to flip to the actual page (the table) to get the rest of the data. In SQL Server, this is called a Key Lookup.”
- **Nested Loop Join**: “For each row in the first table, it searches for matches in the second table. Imagine checking every order and looking up the customer for each one individually.”
- **Hash Join / Hash Match**: “It creates a temporary in-memory dictionary from one table, then uses it to match rows from the other table instantly — like preparing a cheat sheet before the exam.”
- **Sort / Filesort**: “It takes all the result rows and rearranges them in order; this can be expensive if there are millions of rows. In MySQL, ‘filesort’ is a misleading name — it may happen in memory but still means a sorting operation.”
- **Table Scan (SQL Server) vs. Index Seek**: “Table Scan means the database reads every row; Index Seek means it can jump directly to the relevant rows using the index, like going to a page number using an index in the back of a book.”

## 6. Diagnostic Questions to Ask (when schema missing)
- “What is the approximate row count of the large tables involved?”
- “What columns are used in WHERE, JOIN, and ORDER BY?”
- “Are there existing indexes on those columns? Please share `SHOW INDEX FROM table;` (MySQL), `\d table` (PostgreSQL), or `sp_helpindex 'table'` (SQL Server).”
- “Is this query part of a batch process or an interactive user-facing page needing sub-second response?”
- “Which database system and version are you using (PostgreSQL 14+, MySQL 8.0+, SQL Server 2019+)? This helps me tailor index syntax and plan interpretation.”