# Code Review Output Examples

Reference examples showing the expected format for reviews at each severity level.

---

## Example 1 — Full Review Output (TypeScript API endpoint)

**Code submitted for review:**

```typescript
app.post('/api/login', async (req, res) => {
  const { email, password } = req.body
  const user = await db.query(`SELECT * FROM users WHERE email = '${email}'`)
  if (user && user.password === password) {
    const token = Math.random().toString(36)
    res.json({ token, userId: user.id, role: user.role })
  } else {
    res.status(401).json({ error: 'Invalid credentials', attempted_email: email })
  }
})
```

---

### Review Output

**Overall Risk: 🔴 CRITICAL — Do not merge**

---

#### [CRITICAL] SQL Injection — Line 3

```typescript
// ❌ Current
const user = await db.query(`SELECT * FROM users WHERE email = '${email}'`)

// ✅ Fixed
const user = await db.query('SELECT * FROM users WHERE email = $1', [email])
```

**Impact**: Attacker sends `email = ' OR 1=1--` → dumps entire users table. Full database compromise.
**Effort to fix**: 5 min

---

#### [CRITICAL] Plaintext Password Comparison — Line 4

```typescript
// ❌ Current
if (user && user.password === password)

// ✅ Fixed
import bcrypt from 'bcrypt'
if (user && await bcrypt.compare(password, user.password))
```

**Impact**: Passwords stored/compared as plaintext. Any DB read (SQL injection above, backup leak) exposes all passwords.
**Effort to fix**: 30 min (requires migration to hash existing passwords)

---

#### [HIGH] Weak Token Generation — Line 5

```typescript
// ❌ Current
const token = Math.random().toString(36)
// Math.random() is predictable — not cryptographically secure.
// Also no expiry, no storage for revocation.

// ✅ Fixed
import { randomBytes } from 'crypto'
import jwt from 'jsonwebtoken'

const token = jwt.sign(
  { userId: user.id, role: user.role },
  process.env.JWT_SECRET!,
  { expiresIn: '1h' }
)
```

**Impact**: Attacker can brute-force or predict session tokens.

---

#### [MEDIUM] Information Disclosure in Error Response — Lines 7–8

```typescript
// ❌ Current
res.status(401).json({ error: 'Invalid credentials', attempted_email: email })
// Echoes user input back — could leak PII in logs, reveal email validation.

// ✅ Fixed
res.status(401).json({ error: 'Invalid email or password' })
```

**Impact**: Echoed input can be used to enumerate valid emails. Logs may contain user-supplied data.

---

#### [LOW] Missing Rate Limiting

No rate limiting on login endpoint. An attacker can try unlimited passwords.

```typescript
// Add before route:
import rateLimit from 'express-rate-limit'

const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 10,
  message: { error: 'Too many login attempts, try again later' }
})

app.post('/api/login', loginLimiter, async (req, res) => { ... })
```

---

#### Summary Table

| # | Severity | Issue                     | Line | Fix Time |
|---|----------|---------------------------|------|----------|
| 1 | CRITICAL | SQL Injection             | 3    | 5 min    |
| 2 | CRITICAL | Plaintext passwords       | 4    | 30 min   |
| 3 | HIGH     | Weak token generation     | 5    | 15 min   |
| 4 | MEDIUM   | Info disclosure in error  | 7    | 2 min    |
| 5 | LOW      | No rate limiting          | —    | 10 min   |

**Decision**: Block merge. Fix items 1–3 before any further review.

---

## Example 2 — Clean Review (No Issues)

```python
def get_user_orders(user_id: int, db: Session) -> list[Order]:
    """Fetch all orders for a user, ordered by creation date desc."""
    return (
        db.query(Order)
        .filter(Order.user_id == user_id)
        .order_by(Order.created_at.desc())
        .limit(100)
        .all()
    )
```

### Review Output

**Overall Risk: 🟢 PASS — Approved**

- ✅ Parameterized query via ORM (no injection risk)
- ✅ Filters by `user_id` — proper authorization scope
- ✅ `LIMIT 100` prevents unbounded result sets
- ✅ Ordered by indexed column (`created_at`)
- ✅ Return type annotated

**Suggestion (non-blocking)**: If this is called from a paginated endpoint, consider adding `offset` parameter for cursor-based pagination at scale.

---

## Example 3 — Performance-Only Review

```javascript
async function getUsersWithOrders(userIds) {
  const result = []
  for (const id of userIds) {
    const user = await db.users.findById(id)
    const orders = await db.orders.find({ userId: id })
    result.push({ ...user, orders })
  }
  return result
}
```

### Review Output

**Overall Risk: 🟡 HIGH Performance Risk**

#### [HIGH] N+1 Query Pattern — Lines 3–5

**Problem**: For 100 users, this executes 200 sequential DB round trips.
At 5ms/query = 1000ms total. At scale this causes timeouts.

```javascript
// ✅ Batch fetch in 2 queries instead of 2×N
async function getUsersWithOrders(userIds) {
  const [users, orders] = await Promise.all([
    db.users.findMany({ where: { id: { in: userIds } } }),
    db.orders.findMany({ where: { userId: { in: userIds } } }),
  ])

  const ordersByUser = orders.reduce((map, order) => {
    ;(map[order.userId] ??= []).push(order)
    return map
  }, {})

  return users.map(user => ({ ...user, orders: ordersByUser[user.id] ?? [] }))
}
```

**Impact**: O(n) queries → O(1) queries. 200× faster at n=100.
