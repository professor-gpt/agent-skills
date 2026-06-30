# Security Review Checklist

Use this checklist for every PR touching authentication, data handling, or external I/O.
Mark each item ✅ PASS · ⚠️ WARN · ❌ FAIL · N/A.

---

## A. Input Validation & Injection

- [ ] All user-controlled inputs are validated (type, length, format, range)
- [ ] SQL queries use parameterized statements / ORM — no string concatenation
- [ ] HTML/template output is escaped to prevent XSS (`dangerouslySetInnerHTML` justified?)
- [ ] Command execution (`exec`, `spawn`, `eval`) never includes user input directly
- [ ] File paths are sanitized — no `../` traversal possible
- [ ] XML/JSON parsing uses safe parsers with size limits
- [ ] Regular expressions are tested against ReDoS inputs (exponential backtracking)
- [ ] GraphQL queries have depth and complexity limits

## B. Authentication & Authorization

- [ ] Every protected route/function checks authentication before acting
- [ ] Authorization checks use server-side data, not client-supplied role/id claims
- [ ] JWT tokens: `alg` is verified (not `alg: none`), expiry is checked
- [ ] Session tokens are rotated after privilege escalation (login, 2FA)
- [ ] Password hashing uses bcrypt/argon2 with adequate work factor (not MD5/SHA1)
- [ ] Password reset tokens are single-use and expire in ≤ 1 hour
- [ ] Admin/privileged endpoints require additional authorization, not just auth
- [ ] Horizontal privilege check: user can only access **their own** resources

## C. Secrets & Configuration

- [ ] No secrets, API keys, or credentials hardcoded in source
- [ ] `.env` files are in `.gitignore` and not committed
- [ ] Secrets accessed only from env vars or secret manager (not config files)
- [ ] Error messages don't leak stack traces, DB schema, or file paths to end users
- [ ] Debug mode / verbose logging disabled in production config

## D. Cryptography

- [ ] TLS used for all external communication (no plain HTTP for sensitive data)
- [ ] Cryptographic keys are at least 2048-bit RSA or 256-bit AES/ECC
- [ ] IV/nonce is unique per encryption operation (not reused, not hardcoded)
- [ ] Random values for security use `crypto.randomBytes()` / `os.urandom()` (not `Math.random()`)
- [ ] Hashed passwords use a salt (bcrypt/argon2 include it automatically)

## E. Dependency & Supply Chain

- [ ] New dependencies checked for known CVEs (`npm audit` / `pip-audit` / `trivy`)
- [ ] Package version is pinned (lockfile committed)
- [ ] No dependency with publish date < 6 months old used for critical functionality
- [ ] `package.json` / `requirements.txt` — no wildcard versions (`*`, `>=`) for prod

## F. Error Handling & Logging

- [ ] Exceptions caught and logged server-side (not swallowed silently)
- [ ] Log lines don't contain PII (email, phone, SSN, passwords)
- [ ] Rate limiting applied to auth endpoints (login, register, reset)
- [ ] Sensitive operations (delete account, change email) require re-authentication

## G. Frontend-Specific

- [ ] CSP (Content-Security-Policy) header present and restrictive
- [ ] `X-Frame-Options: DENY` or `frame-ancestors 'none'` (clickjacking)
- [ ] Cookies have `HttpOnly`, `Secure`, `SameSite=Strict` flags
- [ ] CORS policy is explicit, not `*` for authenticated endpoints
- [ ] `localStorage` / `sessionStorage` not used for tokens (XSS exfiltration)

---

## Severity Rating Guide

| Level    | Description                                              | SLA     |
|----------|----------------------------------------------------------|---------|
| CRITICAL | Remote code execution, auth bypass, mass data exposure   | Fix now |
| HIGH     | Privilege escalation, stored XSS, SQL injection          | < 24h   |
| MEDIUM   | CSRF, insecure direct object reference, info disclosure  | < 1 wk  |
| LOW      | Missing headers, verbose errors, weak but unexploitable  | Sprint  |
| INFO     | Defense-in-depth improvements                            | Backlog |
