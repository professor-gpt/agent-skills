-- =============================================================================
-- CTE & Window Function Examples
-- Tested on: PostgreSQL 15+, MySQL 8.0+, SQL Server 2019+, SQLite 3.35+
-- =============================================================================


-- =============================================================================
-- 1. RECURSIVE CTE — Organizational Hierarchy
-- =============================================================================
-- Find all reports under a given manager (any depth)

WITH RECURSIVE org_tree AS (
    -- Base case: start from the target manager
    SELECT
        id,
        name,
        manager_id,
        title,
        0 AS depth,
        ARRAY[id] AS path          -- PostgreSQL; use JSON_ARRAY() in MySQL 8
    FROM employees
    WHERE id = :manager_id          -- bind param: starting node

    UNION ALL

    -- Recursive case: add direct reports of current level
    SELECT
        e.id,
        e.name,
        e.manager_id,
        e.title,
        ot.depth + 1,
        ot.path || e.id
    FROM employees e
    INNER JOIN org_tree ot ON e.manager_id = ot.id
    WHERE ot.depth < 10             -- guard against cycles
)
SELECT
    REPEAT('  ', depth) || name AS indented_name,
    title,
    depth,
    path
FROM org_tree
ORDER BY path;


-- =============================================================================
-- 2. RUNNING TOTALS & MOVING AVERAGES
-- =============================================================================

SELECT
    order_date,
    daily_revenue,

    -- Running total (all rows from partition start to current)
    SUM(daily_revenue)
        OVER (ORDER BY order_date
              ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
        AS running_total,

    -- 7-day moving average (current + 6 preceding days)
    AVG(daily_revenue)
        OVER (ORDER BY order_date
              ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)
        AS moving_avg_7d,

    -- % of monthly total
    ROUND(
        100.0 * daily_revenue /
        SUM(daily_revenue) OVER (
            PARTITION BY DATE_TRUNC('month', order_date)
        ),
        2
    ) AS pct_of_month

FROM daily_sales
ORDER BY order_date;


-- =============================================================================
-- 3. RANK vs DENSE_RANK vs ROW_NUMBER
-- =============================================================================
-- Find top 3 products per category by revenue

WITH ranked AS (
    SELECT
        category,
        product_name,
        total_revenue,

        -- ROW_NUMBER: unique sequence, no ties (1,2,3,4,...)
        ROW_NUMBER()  OVER w AS row_num,

        -- RANK: ties share rank, gaps after (1,1,3,4,...)
        RANK()        OVER w AS rank,

        -- DENSE_RANK: ties share rank, no gaps (1,1,2,3,...)
        DENSE_RANK()  OVER w AS dense_rank

    FROM product_sales
    WINDOW w AS (PARTITION BY category ORDER BY total_revenue DESC)
)
SELECT *
FROM ranked
WHERE dense_rank <= 3              -- top 3 per category, ties included
ORDER BY category, dense_rank;


-- =============================================================================
-- 4. LAG / LEAD — Period-over-Period Comparison
-- =============================================================================

SELECT
    month,
    revenue,

    -- Previous month's revenue
    LAG(revenue, 1, 0) OVER (ORDER BY month) AS prev_month_revenue,

    -- Month-over-month change
    revenue - LAG(revenue, 1, 0) OVER (ORDER BY month) AS mom_delta,

    -- Month-over-month % growth
    ROUND(
        100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
               / NULLIF(LAG(revenue) OVER (ORDER BY month), 0),
        1
    ) AS mom_pct_growth,

    -- Same month last year (12 periods back)
    LAG(revenue, 12) OVER (ORDER BY month) AS same_month_last_year

FROM monthly_revenue
ORDER BY month;


-- =============================================================================
-- 5. FIRST_VALUE / LAST_VALUE — Baseline Comparisons
-- =============================================================================
-- Compare each day's stock price to the first price in the window

SELECT
    ticker,
    trade_date,
    close_price,

    FIRST_VALUE(close_price) OVER (
        PARTITION BY ticker
        ORDER BY trade_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS ipo_price,

    LAST_VALUE(close_price) OVER (
        PARTITION BY ticker
        ORDER BY trade_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS latest_price,

    ROUND(
        100.0 * (close_price - FIRST_VALUE(close_price) OVER (
            PARTITION BY ticker ORDER BY trade_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        )) / FIRST_VALUE(close_price) OVER (
            PARTITION BY ticker ORDER BY trade_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ),
        2
    ) AS pct_return_from_start

FROM stock_prices
ORDER BY ticker, trade_date;


-- =============================================================================
-- 6. GAPS AND ISLANDS — Find Consecutive Date Ranges
-- =============================================================================
-- Find continuous subscription periods per user

WITH numbered AS (
    SELECT
        user_id,
        active_date,
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY active_date) AS rn
    FROM user_active_days
),
grouped AS (
    SELECT
        user_id,
        active_date,
        -- If dates are consecutive, (date - rn) is constant → same group
        active_date - INTERVAL '1 day' * rn AS grp
    FROM numbered
)
SELECT
    user_id,
    MIN(active_date) AS period_start,
    MAX(active_date) AS period_end,
    COUNT(*) AS days_active
FROM grouped
GROUP BY user_id, grp
ORDER BY user_id, period_start;


-- =============================================================================
-- 7. PIVOT (Cross-Tab) — Without PIVOT syntax (works everywhere)
-- =============================================================================
-- Revenue by quarter, pivoted into columns

SELECT
    EXTRACT(YEAR FROM order_date) AS year,
    SUM(CASE WHEN EXTRACT(QUARTER FROM order_date) = 1 THEN revenue ELSE 0 END) AS q1,
    SUM(CASE WHEN EXTRACT(QUARTER FROM order_date) = 2 THEN revenue ELSE 0 END) AS q2,
    SUM(CASE WHEN EXTRACT(QUARTER FROM order_date) = 3 THEN revenue ELSE 0 END) AS q3,
    SUM(CASE WHEN EXTRACT(QUARTER FROM order_date) = 4 THEN revenue ELSE 0 END) AS q4,
    SUM(revenue) AS total
FROM orders
GROUP BY year
ORDER BY year;


-- =============================================================================
-- 8. UPSERT / MERGE — Insert or Update in one statement
-- =============================================================================

-- PostgreSQL
INSERT INTO product_inventory (product_id, quantity, updated_at)
VALUES (:product_id, :quantity, NOW())
ON CONFLICT (product_id) DO UPDATE
    SET quantity   = EXCLUDED.quantity,
        updated_at = EXCLUDED.updated_at
WHERE product_inventory.quantity != EXCLUDED.quantity;  -- skip no-op updates

-- MySQL 8
INSERT INTO product_inventory (product_id, quantity, updated_at)
VALUES (:product_id, :quantity, NOW())
ON DUPLICATE KEY UPDATE
    quantity   = VALUES(quantity),
    updated_at = NOW();
