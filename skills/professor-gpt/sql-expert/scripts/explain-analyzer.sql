-- =============================================================================
-- EXPLAIN ANALYZER TOOLKIT
-- Diagnostic queries to understand query performance across databases
-- =============================================================================


-- =============================================================================
-- POSTGRESQL — Query Performance Diagnostics
-- =============================================================================

-- 1. Top 20 slowest queries (requires pg_stat_statements extension)
--    Enable with: CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
SELECT
    LEFT(query, 120)              AS query_preview,
    calls,
    ROUND(mean_exec_time::numeric, 2) AS avg_ms,
    ROUND(total_exec_time::numeric / 1000, 2) AS total_seconds,
    ROUND(stddev_exec_time::numeric, 2) AS stddev_ms,
    rows / NULLIF(calls, 0)       AS avg_rows_returned,
    shared_blks_hit + shared_blks_read AS total_blocks,
    ROUND(100.0 * shared_blks_hit / NULLIF(shared_blks_hit + shared_blks_read, 0), 1) AS cache_hit_pct
FROM pg_stat_statements
WHERE calls > 10                  -- ignore one-off queries
ORDER BY total_exec_time DESC
LIMIT 20;

-- 2. Tables with most sequential scans (missing index candidates)
SELECT
    schemaname,
    relname AS table_name,
    seq_scan,
    seq_tup_read,
    idx_scan,
    n_live_tup AS live_rows,
    ROUND(seq_tup_read::numeric / NULLIF(seq_scan, 0)) AS avg_rows_per_seq_scan
FROM pg_stat_user_tables
WHERE seq_scan > 100
  AND n_live_tup > 10000          -- only large tables matter
ORDER BY seq_tup_read DESC
LIMIT 20;

-- 3. Unused indexes (candidates for removal)
SELECT
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(indexrelid)) AS index_size,
    idx_scan AS times_used
FROM pg_stat_user_indexes
JOIN pg_index USING (indexrelid)
WHERE idx_scan = 0
  AND NOT indisprimary
  AND NOT indisunique
ORDER BY pg_relation_size(indexrelid) DESC;

-- 4. Table bloat — dead tuples (run VACUUM if high)
SELECT
    schemaname,
    relname AS table_name,
    n_live_tup,
    n_dead_tup,
    ROUND(100.0 * n_dead_tup / NULLIF(n_live_tup + n_dead_tup, 0), 1) AS dead_pct,
    last_autovacuum,
    last_autoanalyze
FROM pg_stat_user_tables
WHERE n_dead_tup > 1000
ORDER BY n_dead_tup DESC
LIMIT 20;

-- 5. Long-running active queries (run in separate session)
SELECT
    pid,
    now() - pg_stat_activity.query_start AS duration,
    query,
    state,
    wait_event_type,
    wait_event
FROM pg_stat_activity
WHERE state != 'idle'
  AND query_start < now() - INTERVAL '30 seconds'
ORDER BY duration DESC;

-- 6. Lock contention — blocked queries
SELECT
    blocked.pid                                    AS blocked_pid,
    blocked.query                                  AS blocked_query,
    blocking.pid                                   AS blocking_pid,
    blocking.query                                 AS blocking_query,
    now() - blocked.query_start                    AS blocked_duration
FROM pg_stat_activity blocked
JOIN pg_stat_activity blocking
    ON blocking.pid = ANY(pg_blocking_pids(blocked.pid))
WHERE cardinality(pg_blocking_pids(blocked.pid)) > 0;

-- 7. Index size vs table size
SELECT
    t.tablename,
    pg_size_pretty(pg_total_relation_size(quote_ident(t.tablename))) AS total_size,
    pg_size_pretty(pg_relation_size(quote_ident(t.tablename)))       AS table_size,
    pg_size_pretty(
        pg_total_relation_size(quote_ident(t.tablename))
        - pg_relation_size(quote_ident(t.tablename))
    )                                                                 AS index_size,
    COUNT(i.indexname)                                                AS num_indexes
FROM pg_tables t
LEFT JOIN pg_indexes i ON t.tablename = i.tablename AND t.schemaname = i.schemaname
WHERE t.schemaname = 'public'
GROUP BY t.tablename
ORDER BY pg_total_relation_size(quote_ident(t.tablename)) DESC
LIMIT 20;


-- =============================================================================
-- MYSQL — Query Performance Diagnostics
-- =============================================================================

-- 8. Top slow queries (requires performance_schema)
SELECT
    digest_text                                     AS query_pattern,
    count_star                                      AS calls,
    ROUND(avg_timer_wait / 1e9, 2)                  AS avg_ms,
    ROUND(sum_timer_wait / 1e12, 2)                 AS total_seconds,
    ROUND(sum_rows_examined / NULLIF(count_star,0)) AS avg_rows_examined,
    ROUND(sum_rows_sent / NULLIF(count_star,0))     AS avg_rows_returned
FROM performance_schema.events_statements_summary_by_digest
WHERE count_star > 10
ORDER BY sum_timer_wait DESC
LIMIT 20;

-- 9. Tables without a primary key (MySQL 8 replication issue)
SELECT TABLE_SCHEMA, TABLE_NAME
FROM information_schema.TABLES t
WHERE TABLE_TYPE = 'BASE TABLE'
  AND TABLE_SCHEMA NOT IN ('mysql','information_schema','performance_schema','sys')
  AND NOT EXISTS (
      SELECT 1
      FROM information_schema.TABLE_CONSTRAINTS tc
      WHERE tc.TABLE_SCHEMA = t.TABLE_SCHEMA
        AND tc.TABLE_NAME = t.TABLE_NAME
        AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
  );

-- 10. Index cardinality overview
SELECT
    TABLE_NAME,
    INDEX_NAME,
    GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX) AS columns,
    CARDINALITY,
    NON_UNIQUE
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = DATABASE()
ORDER BY TABLE_NAME, INDEX_NAME;


-- =============================================================================
-- TEMPLATE — Instrument a specific query
-- Replace <YOUR QUERY> with the query to analyze
-- =============================================================================

-- PostgreSQL: full diagnostic run
EXPLAIN (
    ANALYZE,        -- actually execute and measure
    BUFFERS,        -- show buffer hits vs disk reads
    VERBOSE,        -- show output columns per node
    FORMAT TEXT     -- human readable (use JSON for tooling)
)
/* <YOUR QUERY> */;

-- After EXPLAIN: key things to fix
-- Seq Scan on large table  → add index on filter column
-- high "rows=X actual=Y" mismatch → run ANALYZE on the table
-- high "Buffers: read=N" → data not cached, check shared_buffers
-- Sort on unindexed column → add index or use covering index
