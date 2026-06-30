# Stack Trace Analysis Examples

How to read and diagnose stack traces from common environments.
Each example shows: the trace → what it means → what to investigate.

---

## Example 1 — Node.js / TypeScript: Cannot read properties of undefined

```
TypeError: Cannot read properties of undefined (reading 'email')
    at UserService.getEmail (src/services/user.ts:47:23)
    at OrderService.createOrder (src/services/order.ts:89:31)
    at async POST /api/orders (src/routes/orders.ts:23:18)
    at Layer.handle [as handle_request] (node_modules/express/lib/router/layer.js:95:5)
```

### Reading Strategy

1. **Error type + message**: `TypeError: Cannot read properties of undefined (reading 'email')`
   → Something is `undefined` where an object with `.email` is expected
2. **Your code** (ignore node_modules): lines 1–3 in the trace
3. **Direct cause** (top of your code): `user.ts:47` — `UserService.getEmail`
4. **Caller** (one level down): `order.ts:89` — this is what passed `undefined` in

### Investigation

```typescript
// order.ts line 89 — what is it passing?
const email = userService.getEmail(userId)

// user.ts line 47 — what does getEmail do?
getEmail(userId: string): string {
  const user = this.users.get(userId)  // ← returns undefined if not found
  return user.email  // ← CRASH: user is undefined
}
```

**Root cause**: `UserService.getEmail` does not handle the case where `userId` doesn't exist in the map.

**Fix**:
```typescript
getEmail(userId: string): string | null {
  const user = this.users.get(userId)
  if (!user) {
    logger.warn('getEmail: user not found', { userId })
    return null
  }
  return user.email
}
// Callers must handle null return
```

**Prevention**: TypeScript strict null checks (`"strict": true` in tsconfig) would have caught this at compile time if return type was `string | null`.

---

## Example 2 — Python: Traceback with chained exceptions

```
Traceback (most recent call last):
  File "src/api/orders.py", line 45, in create_order
    user = user_service.get_user(user_id)
  File "src/services/user.py", line 23, in get_user
    return self.db.query(User).filter_by(id=user_id).one()
  File "sqlalchemy/orm/query.py", line 3287, in one
    raise NoResultFound("No row was found when one was required")
sqlalchemy.exc.NoResultFound: No row was found when one was required

During handling of the above exception, another exception occurred:

Traceback (most recent call last):
  File "src/api/orders.py", line 47, in create_order
    raise OrderCreationError(f"User {user_id} not found") from exc
src.exceptions.OrderCreationError: User abc123 not found
```

### Reading Strategy

1. **Two exceptions**: The second (`OrderCreationError`) was raised while handling the first (`NoResultFound`)
2. **Root cause**: `NoResultFound` from SQLAlchemy — no user row in DB for `user_id = "abc123"`
3. **Where it propagated**: `user.py:23` → `orders.py:45` → re-raised at `orders.py:47`
4. **"during handling of"**: The `OrderCreationError` is a deliberate re-raise (`raise ... from exc`), which is correct

### Investigation

- The user_id `abc123` doesn't exist in the database
- Check: was the user deleted? Was the request using a stale/wrong ID?
- Check: is this the right database (dev vs prod mixup)?

```python
# Quick diagnostic
from sqlalchemy import text
result = db.execute(text("SELECT id FROM users WHERE id = :id"), {"id": "abc123"})
print(result.fetchone())  # Should be None if user doesn't exist
```

---

## Example 3 — Java: NullPointerException with helpful Java 14+ message

```
Exception in thread "main" java.lang.NullPointerException:
    Cannot invoke "String.toLowerCase()" because "user.name" is null
    at com.example.UserService.normalizeUser(UserService.java:34)
    at com.example.UserService.processUsers(UserService.java:18)
    at com.example.Main.main(Main.java:12)
```

### Reading Strategy

Java 14+ NPEs tell you exactly what's null. `"user.name" is null` → `user.name` field is `null`.

```java
// UserService.java:34
public User normalizeUser(User user) {
    return new User(
        user.id,
        user.name.toLowerCase(),  // ← NPE: user.name is null
        user.email
    );
}
```

**Fix**:
```java
// Option 1: Null guard
String normalizedName = user.name != null ? user.name.toLowerCase() : null;

// Option 2: Optional
String normalizedName = Optional.ofNullable(user.name)
    .map(String::toLowerCase)
    .orElse(null);

// Option 3: Annotate to enforce non-null at compile time
public User normalizeUser(@NonNull User user) { ... }
// And ensure callers pass non-null names
```

---

## Example 4 — Go: Panic with goroutine trace

```
goroutine 1 [running]:
panic: runtime error: index out of range [5] with length 5

goroutine 1 [running]:
main.processItems(...)
        /app/main.go:28 +0x1c4
main.main()
        /app/main.go:14 +0x64
exit status 2
```

### Reading Strategy

1. **Panic reason**: `index out of range [5] with length 5`
   → Trying to access index 5 of a slice with length 5 (valid indices: 0–4)
2. **Location**: `main.go:28` — the off-by-one error

```go
// main.go:28
func processItems(items []Item) {
    for i := 0; i <= len(items); i++ {  // ← Bug: should be i < len(items)
        process(items[i])
    }
}
```

**Fix**:
```go
for i := 0; i < len(items); i++ {  // strict less-than
    process(items[i])
}
// Or use range (idiomatic Go, no off-by-one possible):
for _, item := range items {
    process(item)
}
```

---

## Example 5 — React: Maximum update depth exceeded

```
Warning: Maximum update depth exceeded. This can happen when a component
calls setState inside useEffect, but useEffect either doesn't have a
dependency array, or one of the dependencies changes on every render.

    at Counter (http://localhost:3000/main.js:42:15)
```

### Reading Strategy

This is not a crash but a React infinite re-render loop. No traditional stack trace — look at the component name (`Counter`) and the render trigger.

**Common causes**:
```jsx
// ❌ Cause 1: No dependency array → runs after every render
useEffect(() => {
  setCount(count + 1)  // triggers re-render → effect runs again → ∞
})

// ❌ Cause 2: Object/array dependency created inline → new reference each render
useEffect(() => {
  fetchData()
}, [{ userId }])  // new object every render → infinite loop

// ❌ Cause 3: setState in render (not in effect or handler)
const [data, setData] = useState(null)
setData(computeData())  // called during render → re-render → ∞
```

**Fixes**:
```jsx
// ✅ Fix 1: Add proper dependency array
useEffect(() => {
  setCount(prev => prev + 1)
}, [])  // only on mount

// ✅ Fix 2: Stable primitive dependency
useEffect(() => {
  fetchData(userId)
}, [userId])  // primitive string — stable reference

// ✅ Fix 3: useMemo for object dependencies
const config = useMemo(() => ({ userId }), [userId])
useEffect(() => { fetchData(config) }, [config])
```

---

## General Pattern Recognition

| Stack Trace Pattern | Likely Root Cause |
|---|---|
| `Cannot read properties of undefined` | Null/undefined not handled; missing optional chain |
| `Maximum call stack size exceeded` | Infinite recursion; missing base case |
| `Maximum update depth exceeded` | React render-loop; unstable useEffect deps |
| `ECONNREFUSED 127.0.0.1:5432` | Database not running or wrong host/port |
| `JWT malformed` / `JsonWebTokenError` | Invalid/expired token; wrong secret |
| `No row was found` (SQLAlchemy) | `.one()` on empty result; use `.one_or_none()` |
| `index out of range` (Go/Python) | Off-by-one; accessing past end of slice/list |
| `deadlock detected` (PostgreSQL) | Two transactions locking rows in opposite order |
| `ENOENT: no such file or directory` | Wrong path; file not created before read |
| `heap out of memory` | Memory leak; loading too-large dataset |
