# Performance Review Checklist

Red flags that cause slow code, memory leaks, and scale failures.
Mark each item ✅ PASS · ⚠️ WARN · ❌ FAIL · N/A.

---

## A. Database & Query Performance

- [ ] **N+1 queries eliminated**: loops that call the DB per iteration use batch fetch / JOIN instead
- [ ] Queries on large tables filter by indexed columns in the WHERE clause
- [ ] `SELECT *` avoided — only required columns fetched
- [ ] `LIMIT` applied to all list queries (no unbounded result sets)
- [ ] Pagination uses keyset (cursor) pagination, not `OFFSET N` for large N
- [ ] Aggregations (`COUNT`, `SUM`) on large tables have covering indexes
- [ ] Transactions wrap multi-step writes (no partial-commit state possible)
- [ ] Long-running queries (> 1s) use `EXPLAIN ANALYZE` and are reviewed
- [ ] ORM lazy loading disabled in hot paths (explicit `.select_related()` / `.include()`)
- [ ] DB connection pool size appropriate for expected concurrency

## B. Caching

- [ ] Expensive computations (DB lookups, API calls) are cached where safe
- [ ] Cache keys include all input dimensions (no stale cross-user data)
- [ ] Cache TTL set — nothing cached indefinitely unless explicitly invalidated
- [ ] Cache stampede prevented (lock / probabilistic early expiry) for high-traffic keys
- [ ] Cached data serialization is efficient (not naive JSON for large objects)

## C. Memory Management

- [ ] No unbounded in-memory collections (growing arrays/maps never pruned)
- [ ] Large datasets streamed, not loaded entirely into memory
- [ ] Event listeners removed when no longer needed (no memory leak pattern)
- [ ] File/stream handles closed after use (in `finally` / `using`)
- [ ] Recursive functions have a documented depth bound (stack overflow risk?)
- [ ] Object pools used for frequently allocated/freed large objects

## D. Concurrency & I/O

- [ ] Blocking I/O (file read, network call) is async in event-loop languages (Node, Python async)
- [ ] Independent async operations run in parallel (`Promise.all` / `asyncio.gather`)
- [ ] Shared mutable state protected against race conditions (locks, atomic ops, immutable patterns)
- [ ] Background jobs don't block the main request thread
- [ ] Retry logic has exponential backoff + jitter (no retry storms)

## E. Algorithm Complexity

- [ ] Hot-path loops are O(n) or better — no accidental O(n²) nested iteration
- [ ] Large dataset operations use appropriate data structures (Set for O(1) lookup, not Array.includes)
- [ ] String concatenation in loops uses `join()` / `StringBuilder` (not `+=`)
- [ ] Sorting unnecessary data avoided — filter first, sort after
- [ ] JSON.parse / serialize avoided inside tight loops

## F. Frontend Performance

- [ ] Bundle size checked — no accidental import of entire library (lodash, moment)
- [ ] Images have explicit `width`/`height`, lazy loading for below-fold
- [ ] Expensive renders memoized (`useMemo`, `React.memo`) where profiler confirms benefit
- [ ] No unnecessary re-renders from object/array literals created inline in JSX
- [ ] API calls are deduplicated (React Query / SWR / cache layer)
- [ ] Long lists use virtualization (react-virtual, tanstack-virtual)

## G. Observability

- [ ] Slow operations emit duration metrics / spans (OpenTelemetry / Datadog)
- [ ] Error rates tracked separately from latency (p50/p95/p99 on key endpoints)
- [ ] Alerting threshold defined for API response time degradation

---

## Complexity Quick Reference

| Code Pattern                            | Complexity | Red Flag? |
|-----------------------------------------|-----------|-----------|
| `arr.includes()` inside a loop          | O(n²)     | ✅ Yes    |
| `.find()` on sorted array (use bisect)  | O(n)      | ⚠️ Large n |
| Object key lookup `obj[key]`            | O(1)      | No        |
| `Set.has()` / `Map.get()`              | O(1)      | No        |
| Regex with catastrophic backtracking    | O(2ⁿ)    | ✅ Yes    |
| DB query per loop iteration (N+1)       | O(n×RTT)  | ✅ Yes    |
