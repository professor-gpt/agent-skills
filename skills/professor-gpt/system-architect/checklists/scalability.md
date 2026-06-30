# Scalability & Reliability Review Checklist

Review this before architecting a new system or scaling an existing one.
Mark: ✅ Good · ⚠️ Risk · ❌ Missing · N/A

---

## A. Load & Capacity

- [ ] Peak traffic estimated with concrete numbers (RPS, concurrent users, data volume)
- [ ] Load tests run at 2× expected peak (not just steady-state)
- [ ] Auto-scaling configured with scale-out threshold ≤ 70% CPU/memory
- [ ] Scale-out time acceptable (how long from trigger to new instance serving traffic?)
- [ ] Stateless application tier (no local session state — sessions in Redis/DB)
- [ ] Single points of failure identified and eliminated or mitigated

## B. Database

- [ ] Read/write traffic split: reads go to replicas, writes go to primary
- [ ] Database connection pool sized correctly (not unlimited — avoids PostgreSQL connection exhaustion)
- [ ] Slow query log enabled; queries > 100ms reviewed
- [ ] Indexes on all foreign keys and commonly filtered columns
- [ ] Partitioning or archival strategy for tables > 100M rows
- [ ] DB backups tested (restore, not just backup, is what matters)
- [ ] Point-in-time recovery (PITR) available

## C. Caching Strategy

- [ ] Cache hit rate measured and > 80% for hot paths
- [ ] Cache invalidation strategy defined for each cached resource
- [ ] Cache stampede (thundering herd) mitigated (probabilistic expiry, locks, or background refresh)
- [ ] Cache eviction policy appropriate (LRU for most; LFU for frequency-biased access)
- [ ] Cold cache startup handled (pre-warming strategy exists)

## D. Async Processing

- [ ] All non-real-time operations (email, webhooks, PDF generation) moved to background queue
- [ ] Job queue has visibility timeout > longest expected job duration
- [ ] Dead letter queue configured for failed jobs
- [ ] Jobs are idempotent (safe to retry without duplicate side effects)
- [ ] Job retry policy: exponential backoff with jitter, max retry count
- [ ] Queue depth monitored and alerts set for abnormal growth

## E. Resilience & Fault Tolerance

- [ ] Circuit breaker on all external service calls (open after N failures, half-open probe)
- [ ] Timeouts set on every outbound HTTP call (connect + read timeout)
- [ ] Retry logic with exponential backoff and max attempts
- [ ] Bulkhead pattern: failures in one service don't exhaust resources for all
- [ ] Graceful degradation: what does the system do when service X is unavailable?
- [ ] Health check endpoints (`/healthz`, `/readyz`) implemented and used by load balancer
- [ ] Chaos engineering: failure modes tested in staging (kill a pod, saturate DB, etc.)

## F. Observability

- [ ] Structured logging (JSON) with request ID, user ID, trace ID on every log line
- [ ] Distributed tracing (OpenTelemetry / Datadog APM) across all services
- [ ] Key business metrics tracked (order rate, checkout success rate, payment failure rate)
- [ ] SLOs defined: availability %, p99 latency, error rate
- [ ] Dashboards for each tier: frontend, API, worker, DB, cache
- [ ] Alerts on SLO breach, not just infrastructure metrics
- [ ] On-call runbooks for each alert

## G. Data Consistency

- [ ] Data consistency model chosen and documented (strong vs eventual)
- [ ] Saga or 2PC pattern for distributed transactions
- [ ] Idempotency keys on all payment / order creation endpoints
- [ ] Event sourcing or audit log for critical state changes
- [ ] Backup strategy: RPO (max data loss) and RTO (max downtime) defined

## H. Security at Scale

- [ ] API rate limiting per user/IP (not just global)
- [ ] DDoS protection at CDN/edge layer
- [ ] Secrets rotated regularly and rotation process is automated
- [ ] Principle of least privilege: services only access what they need
- [ ] VPC / network segmentation: data tier not directly reachable from internet

## I. Deployment & Operations

- [ ] Zero-downtime deployments (rolling or blue/green)
- [ ] Feature flags for gradual rollout (not all-or-nothing deploys)
- [ ] Database migrations are backward-compatible (old code runs against new schema)
- [ ] Rollback procedure tested and takes < 10 minutes
- [ ] Environment parity: staging ≈ production in data shape and scale

---

## Capacity Planning Template

Fill out before any major launch or scaling event:

| Metric | Today | 3-month target | 12-month target | Current headroom |
|--------|-------|---------------|----------------|-----------------|
| Daily active users | | | | |
| Peak RPS (API) | | | | |
| DB connections | | | | |
| DB size (GB) | | | | |
| Cache memory (GB) | | | | |
| Queue depth (avg) | | | | |
| Storage (GB) | | | | |

**Headroom formula**: `(capacity - current) / current × 100%`
Alert when headroom drops below 30%.
