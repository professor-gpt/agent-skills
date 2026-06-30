# Before / After: Technical Writing Examples

Real rewrites showing what good technical writing looks like.
Each example includes the diagnosis of what was wrong.

---

## Example 1 — README Introduction

### ❌ Before

> "DataSync is a powerful and flexible data synchronization solution that leverages cutting-edge technology to seamlessly integrate your data across multiple platforms and systems with ease and efficiency."

**Problems:**
- Zero information about what it actually does
- "Powerful", "cutting-edge", "seamlessly" are meaningless adjectives
- "Integrate data across platforms" could describe anything
- Reader still doesn't know if this is for them

### ✅ After

> "DataSync copies PostgreSQL tables to your Redshift warehouse on a schedule you define. Point it at a source database, choose tables, and records sync every 5 minutes (or on a cron you specify)."

**Why it's better:**
- Specific: PostgreSQL → Redshift, not "platforms"
- Concrete: "every 5 minutes", "on a cron"
- Reader knows immediately if this solves their problem

---

## Example 2 — Installation Instructions

### ❌ Before

> "To get started, you'll need to make sure your environment is set up correctly. First, ensure you have all the necessary prerequisites installed. Then, follow the steps below to install the package and configure it for your needs."

**Problems:**
- No actual information (what are the prerequisites?)
- Explains what you're about to do instead of doing it
- Passive voice throughout

### ✅ After

```
Prerequisites:
- Node.js ≥ 18
- PostgreSQL 13+ running and accessible
- A Redshift cluster with write access

Install:
npm install @org/datasync

Configure (create datasync.config.ts):
export default {
  source: { url: process.env.PG_URL },
  dest:   { url: process.env.REDSHIFT_URL },
  tables: ['users', 'orders'],
}
```

**Why it's better:**
- Prerequisites are listed specifically
- Commands are copy-pasteable
- Configuration is shown, not described

---

## Example 3 — Error Message Documentation

### ❌ Before

> "SYNC_FAILED: An error occurred during the synchronization process. Please check your configuration and try again. If the problem persists, contact support."

**Problems:**
- Doesn't say what failed or why
- "Check your configuration" is vague — check what?
- Offers no actionable next step

### ✅ After

> "SYNC_FAILED: Cannot connect to source database. Connection to `db.prod.example.com:5432` timed out after 30 seconds."
>
> **Next steps:**
> 1. Verify the database is running: `pg_isready -h db.prod.example.com -p 5432`
> 2. Check that your firewall allows outbound connections on port 5432
> 3. If using a VPN, ensure it's connected and routing correctly
>
> **Config key**: `source.url` in `datasync.config.ts`

**Why it's better:**
- States exactly what failed (connection timeout, specific host/port)
- Links the error back to the config key that needs fixing
- Next steps are commands you can run immediately

---

## Example 4 — API Parameter Description

### ❌ Before

> `timeout` — The timeout value for the operation.

**Problems:**
- Doesn't say what unit (seconds? ms? minutes?)
- Doesn't say what happens when it's exceeded
- Doesn't say the default or valid range

### ✅ After

> `timeout` `integer` — Maximum time in milliseconds to wait for a response before aborting. When exceeded, throws `TimeoutError`. Default: `10000` (10 seconds). Range: `1000`–`120000`.

**Why it's better:**
- Type and unit are explicit
- Behavior on failure is documented
- Default and valid range included in one line

---

## Example 5 — Architecture Explanation

### ❌ Before

> "The system uses a microservices architecture with various components that communicate using modern protocols to ensure scalability and reliability."

**Problems:**
- "Various components" — which ones?
- "Modern protocols" — which protocols?
- No reader can act on this information

### ✅ After

> **Architecture overview**
>
> DataSync runs as three independent services:
>
> 1. **Scheduler** — A cron process that emits sync jobs to a Redis queue every 5 minutes
> 2. **Worker** — Pulls jobs from the queue, reads rows from PostgreSQL, and writes batches to Redshift using the Redshift Data API
> 3. **API** — An HTTP server that lets you configure tables, pause syncs, and view logs
>
> Workers scale horizontally — add more workers to increase sync throughput. The scheduler and API are single-instance (leader election via Redis `SET NX`).
>
> ```
> [Scheduler] → Redis Queue → [Workers ×N] → [Redshift]
>                                  ↑
>                             [PostgreSQL]
> ```

**Why it's better:**
- Named components (3, not "various")
- Specific technologies (Redis, Redshift Data API)
- Explains scaling model (horizontal workers, single-instance scheduler)
- Diagram makes the data flow clear at a glance

---

## Style Rules Summary

| Rule | ❌ Don't | ✅ Do |
|------|----------|-------|
| Be specific | "configure your settings" | "set `source.url` in `datasync.config.ts`" |
| Name the units | "a timeout value" | "timeout in milliseconds (default: 10000)" |
| Show, don't tell | "the system handles errors gracefully" | show the error message + recovery steps |
| Avoid filler | "In order to get started, you'll need to..." | "Install:" |
| Active voice | "The file is read by the worker" | "The worker reads the file" |
| Skip superlatives | "powerful", "seamless", "cutting-edge" | describe the actual behavior |
| Be prescriptive | "you may want to consider" | "do X" or "don't do Y" |
