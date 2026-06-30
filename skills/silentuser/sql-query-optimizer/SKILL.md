---
name: silentuser/sql-query-optimizer
description: Use this skill when you need to rewrite slow SQL queries, suggest indexes, and explain execution plans in plain language.
category: coding
tags: [sql, performance, optimization, database, indexing]
---

# Skill: SQL Query Optimizer

## Description
This skill assists users in optimizing SQL queries by rewriting slow queries, suggesting appropriate indexing strategies, and explaining execution plans in an understandable manner. It is designed for database administrators and developers who need to enhance the performance of their SQL queries.

## Instructions

1. **Trigger**: Activate this skill whenever you need to improve the execution speed of SQL queries.
2. **Gather Context**:
   - Request the original SQL query and information about the database schema.
   - Ask for any specific performance issues or execution time expectations.
   - Obtain the current execution plan for the query, if available.
3. **Analyze the Query**:
   - Identify common performance bottlenecks, such as missing WHERE clauses or inefficient JOIN operations.
   - Check for opportunities to improve query structure or logic.
4. **Suggest Indexes**:
   - Analyze the query and schema to propose indexes that could improve performance.
   - Explain how each suggested index would affect query execution.
5. **Explain Execution Plan**:
   - Translate the execution plan elements into plain language.
   - Highlight key steps and potential performance issues.
6. **Output Recommendations**:
   - Provide a rewritten version of the query with optimized changes.
   - List the suggested indexes and explain their impact.
   - Offer a plain-language explanation of the execution plan for user understanding.
7. **Quality Check**:
   - Ensure the rewritten query maintains accuracy and intended results.
   - Verify index suggestions align with best practices for the provided database system.
   - Confirm the explanation is clear and accessible to non-experts.

## Constraints

- **Scope**: Do not modify database configurations or perform database maintenance. Focus only on query and index optimization.
- **Safety**: Ensure that all suggestions are reversible and do not pose risks of data loss or corruption.
- **Escalation**: If the provided SQL query involves complex business logic or custom functions, suggest consulting a database specialist.
- **Limitations**: Index suggestions are based on standard practices and may need adjustment based on specific database implementations and workloads.