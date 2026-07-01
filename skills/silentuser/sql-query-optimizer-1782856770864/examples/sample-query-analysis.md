# Example: Sample Query Analysis

## User Input
**Query:**
```sql
SELECT *
FROM orders o, customers c
WHERE o.cust_id = c.id
  AND YEAR(o.order_date) = 2024
  AND c.status = 'active'
ORDER BY o.order_total DESC
LIMIT 10;
```

**Schema Provided:**
- `customers` table: id (int, PK), name, status (varchar), country, signup_date.
- `orders` table: order_id (int, PK), cust_id (int), order_date (datetime), order_total (decimal), status (varchar).
- Existing indexes: `customers.id` (PK), `orders.order_id` (PK), `orders.cust_id` (single column index).
- Database system: PostgreSQL.

## Agent Analysis Steps

### 1. Parse & Profile
- Anti-patterns: `SELECT *` (waste bandwidth, prevents covering index), implicit JOIN syntax, `YEAR(order_date)` (non-sargable), no index on `order_date` or `c.status`.

### 2. Index Suggestions (from reference §3, PostgreSQL specific)
- **Composite index on orders(order_date, cust_id, order_total DESC)**: covers the WHERE date filter, the JOIN column, and the ORDER BY/LIMIT. The `order_total DESC` allows the index to satisfy sorting without an extra sort step.
- **Partial index on customers(status, id) WHERE status = 'active'**: reduces index size and targets only active customers.
SQL:
```sql
CREATE INDEX idx_orders_date_cust_total ON orders (order_date, cust_id, order_total DESC);
CREATE INDEX idx_customers_active_status_id ON customers (status, id) WHERE status = 'active';
```

### 3. Query Rewrite (applying §4 heuristics)
```sql
SELECT o.order_id, o.order_total, o.order_date, c.name
FROM orders o
INNER JOIN customers c ON o.cust_id = c.id
WHERE o.order_date >= '2024-01-01' AND o.order_date < '2025-01-01'
  AND c.status = 'active'
ORDER BY o.order_total DESC
LIMIT 10;
```
- Replaced `YEAR()` with range to allow index seek.
- Used explicit JOIN.
- Selected only necessary columns for covering index effectiveness.
- Without a rewrite, the old query would force a full scan of orders or a full index scan.

### 4. Execution Plan Explanation (plain language)
If an EXPLAIN showed a Seq Scan on orders, the agent would say:
> "Think of the orders table as a huge stack of paper receipts. The database is reading the entire stack just to find orders from 2024. Our date filter with `YEAR()` forces it to read every receipt because it can’t use a quick lookup by date. After rewriting, it can jump directly to January 1st and stop at December 31st, reading only a tiny section. The new index is like a pre-sorted binder where each month is tabbed."

## Output (Report Format)
The final report would follow `templates/query-report-template.md`, with sections filled accordingly. The agent would flag that the `SELECT *` replacement depends on the required columns; if the user really needs all columns, a covering index might still be efficient but wider.