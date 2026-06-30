---
name: silentuser/sql-performance-optimizer
description: Use this skill to rewrite slow SQL queries, suggest indexing improvements, and explain execution plans in plain language.
category: coding
tags: [sql, performance, optimization, database, indexing]
---

# Skill: SQL Performance Optimizer

## Description
This skill helps users optimize SQL query performance by rewriting slow queries, suggesting appropriate indexes, and providing clear explanations of execution plans.

## Instructions

1. **Trigger**: Activate this skill when presented with a slow-performing SQL query or execution plan.
2. **Context Gathering**:
   - Obtain the SQL query needing optimization.
   - Request the current database schema related to the query.
   - Ask for the existing execution plan if available.
3. **Optimization Workflow**:
   1. Analyze the SQL query structure for inefficiencies.
   2. Rewrite the query to improve performance, focusing on reducing complexity and improving execution.
   3. Suggest indexes that could enhance performance based on the query filtering conditions and joins.
   4. Interpret the execution plan into plain language, highlighting bottlenecks and areas for improvement.
   5. Validate the optimized query against the database to ensure improved performance.
4. **Output Format**:
   - Show the original query and its execution plan.
   - Present the optimized query with suggested indexes.
   - Provide a detailed explanation of the execution plan in accessible language.
5. **Quality Checks**:
   - Ensure the optimized query returns the same results as the original.
   - Verify that suggested indexes do not conflict with existing schema constraints.

## Constraints

- **Scope**: The skill does not execute queries directly on databases. Users must execute changes in their environments.
- **Safety**: Avoid suggestions that may lead to data loss or integrity issues.
- **Ethics**: Ensure recommendations comply with best practices and security standards.
- **Escalation**: Defer to a database administrator for complex rewrites or when significant schema changes are recommended.
- **Limitations**: This skill covers general SQL optimization techniques but may not address all vendor-specific database features or nuances.