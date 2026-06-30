# Debugging Checklist

Work through these steps in order. The most common mistake is jumping to step 3 before completing steps 1–2.

---

## Phase 1 — Reproduce (Never skip this)

- [ ] **Can you reproduce it locally?** If no, list what's different about the environment where it fails
- [ ] **Reproduce rate**: Always / Sometimes / Rarely (affects diagnosis strategy)
- [ ] **Minimum reproduction case**: What's the simplest input/state that triggers the bug?
- [ ] **Is it deterministic?** If not, is it:
  - [ ] Timing-dependent (race condition)
  - [ ] Data-dependent (specific input values)
  - [ ] Load-dependent (only under concurrency)
  - [ ] Environment-dependent (only in prod, not staging)
- [ ] **When did it start?** Find the first commit/deploy that introduced it:
  ```bash
  git bisect start
  git bisect bad HEAD
  git bisect good <last-known-good-commit>
  # Test each commit git bisect suggests
  git bisect good/bad
  ```

---

## Phase 2 — Gather Evidence (Before forming hypotheses)

- [ ] **Full error message**: Exact text, not paraphrased. Stack trace copy-pasted.
- [ ] **Logs**: What appears in logs before, during, and after the error?
- [ ] **Recent changes**: What changed in the last deploy? (git log, migration list, config changes)
- [ ] **Affected scope**: All users / specific users / specific inputs / specific time windows?
- [ ] **Metrics**: Did any metric spike or drop when the bug started? (error rate, latency, DB connections)
- [ ] **Network**: For web apps — capture the failing request/response in browser DevTools or curl

---

## Phase 3 — Form Hypotheses (Max 3, ranked by likelihood)

For each hypothesis:
- [ ] State the specific root cause (not "something is wrong with the DB")
- [ ] List 1–2 pieces of evidence that support it
- [ ] Identify a test that would prove or disprove it in < 15 minutes
- [ ] Identify what would contradict it

**Template:**
```
Hypothesis 1 (most likely): [Specific cause]
  Evidence for: [What points to this]
  Evidence against: [What contradicts this]
  Test: [How to verify in < 15 min]
  
Hypothesis 2: [...]
Hypothesis 3: [...]
```

---

## Phase 4 — Test Systematically

- [ ] **Change one thing at a time** — never test two hypotheses simultaneously
- [ ] **Add logging before guessing** — instrument the code to observe actual state
- [ ] **Use binary search** — if the cause is unknown, cut the search space in half each step
- [ ] **Test the hypothesis, not the fix** — confirm root cause before patching
- [ ] **Document results** — record what you tried and what happened (saves time on similar bugs)

---

## Phase 5 — Fix and Verify

- [ ] Implement the smallest possible fix (don't refactor while fixing)
- [ ] The fix directly addresses the root cause (not a symptom)
- [ ] Test the original reproduction case — bug is gone
- [ ] Test adjacent cases — no regression in related functionality
- [ ] Add a test that would have caught this bug before it reached production:
  - Unit test for the specific case
  - Integration test for the flow
  - Add an assertion to catch the invalid state earlier

---

## Language-Specific Checks

### JavaScript / TypeScript

- [ ] Missing `await` before async call? (`const user = getUser()` → `user` is a Promise)
- [ ] `undefined` vs `null` — which does the code expect?
- [ ] Event listener leak — is `removeEventListener` called when component unmounts?
- [ ] Closure capturing stale variable in loop?
- [ ] `this` binding lost in callback? (use arrow function or `.bind()`)
- [ ] JSON.parse without try/catch on untrusted input?
- [ ] Optional chaining needed? (`obj.a.b` → `obj.a?.b`)

### Python

- [ ] Mutable default argument? (`def fn(items=[]):` — same list shared across calls)
- [ ] Encoding issue? (`bytes.decode('utf-8')` failing on non-UTF-8 content)
- [ ] Exception swallowed by bare `except:` or `except Exception:`?
- [ ] Generator exhausted and iterated twice?
- [ ] `None` returned implicitly from function that should return a value?

### Databases

- [ ] Transaction not committed? (changes visible in same connection but not others)
- [ ] N+1 query pattern inside a loop?
- [ ] Index missing on query filter column?
- [ ] Deadlock between two transactions modifying same rows in different order?
- [ ] Connection pool exhausted? (check pool size vs concurrent requests)
- [ ] Timezone mismatch between app and DB?

### Async / Concurrent

- [ ] Shared mutable state accessed from multiple goroutines/threads without lock?
- [ ] Fire-and-forget async call — errors are silently swallowed?
- [ ] Race condition in cache: read-then-write without atomic operation?
- [ ] Missing `await` causes function to return before async work completes?

---

## Anti-patterns That Waste Time

| Anti-pattern | Why it's bad | Do this instead |
|---|---|---|
| "Try random things and see" | Creates more bugs, wastes hours | Form a specific hypothesis first |
| Guessing before reproducing | Fixes the wrong thing | Always reproduce first |
| Changing multiple things at once | Hides what actually worked | One change, one test |
| "It works on my machine" | Ignores environment differences | List every difference, test each |
| Ignoring the stack trace | Misses the direct cause | Read it top to bottom |
| Commenting out code to see if it matters | Leaves broken code in repo | Use feature flags or proper tests |
