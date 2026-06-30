# OWASP Top 10 Audit Checklist (2021)

Use this checklist to systematically audit a web application.
For each item, record: Status · Evidence · CVSS Score (if applicable) · Remediation

---

## A01 — Broken Access Control

**Risk**: Users act outside intended permissions (horizontal/vertical privilege escalation).

### Test Cases

- [ ] **Horizontal access**: Log in as User A. Access `/api/users/USER_B_ID/orders`. Do you see User B's data?
- [ ] **Vertical access**: Log in as regular user. Try admin endpoints (`/api/admin/*`). Are they blocked?
- [ ] **IDOR (Insecure Direct Object Reference)**: Change IDs in requests/URLs. Can you access other users' records?
- [ ] **Mass assignment**: POST/PATCH with extra fields (`"role": "admin"`). Are unexpected fields accepted?
- [ ] **JWT manipulation**: Decode JWT, change `userId` or `role` claim, re-encode. Does the server accept it?
- [ ] **Force browsing**: Access `/admin`, `/dashboard`, `/internal` without authentication. Are they blocked?
- [ ] **CORS**: Does the API accept requests from any origin? Test with `Origin: https://evil.com`.

**Evidence to collect**: HTTP request/response pairs, JWT contents, response codes.

---

## A02 — Cryptographic Failures

**Risk**: Sensitive data exposed due to weak or missing encryption.

### Test Cases

- [ ] **Transport**: All pages and APIs use HTTPS. No HTTP fallback for sensitive operations.
- [ ] **HSTS**: `Strict-Transport-Security` header present with `max-age ≥ 31536000`.
- [ ] **Password storage**: Are passwords hashed with bcrypt/argon2? Test: dump a user row and check format (`$2b$` = bcrypt).
- [ ] **Sensitive data in logs**: Search logs for `password`, `token`, `ssn`, `credit`. Are any present?
- [ ] **Sensitive data in URLs**: Are tokens/API keys passed as query parameters (end up in logs)?
- [ ] **Cookie flags**: Session cookies have `HttpOnly`, `Secure`, `SameSite=Strict`.
- [ ] **Old TLS**: Does server accept TLS 1.0 or 1.1? Use `nmap --script ssl-enum-ciphers` or SSL Labs.
- [ ] **Weak cipher suites**: Are DES/RC4/MD5 cipher suites offered?

**Tools**: SSL Labs (ssllabs.com/ssltest), `nmap`, `curl -I`, log search.

---

## A03 — Injection

**Risk**: Untrusted data sent as part of a command or query.

### Test Cases

- [ ] **SQL injection**: Insert `' OR 1=1--` into text fields, URL params, headers. Do errors reveal DB info?
- [ ] **Blind SQLi**: Use time-based payloads: `'; WAITFOR DELAY '0:0:5'--`. Does response delay?
- [ ] **NoSQL injection**: MongoDB: `{"$gt":""}` as username. Does it bypass auth?
- [ ] **LDAP injection**: `*)(uid=*` in login fields.
- [ ] **Command injection**: If app accepts filenames/paths: `; ls -la` or `| whoami`.
- [ ] **Template injection**: `{{7*7}}` or `${7*7}` in any user input. Does response contain `49`?
- [ ] **XPath injection**: In XML-based queries.
- [ ] **Header injection**: `User-Agent: foo\r\nX-Injected: true`. Does server reflect injected header?

**Tools**: sqlmap (for automated SQLi), Burp Suite Intruder, manual payloads.

---

## A04 — Insecure Design

**Risk**: Missing security controls at design time (not a coding bug — a design flaw).

### Test Cases

- [ ] **Rate limiting**: Submit login form 100× rapidly. Is there a lockout or CAPTCHA?
- [ ] **Password reset**: Is the reset token single-use? Does it expire? Can you enumerate valid emails?
- [ ] **Account enumeration**: Does "Email not found" vs "Wrong password" reveal account existence?
- [ ] **Brute force**: Is there lockout on PIN/OTP entry?
- [ ] **Business logic**: Can you apply a discount coupon twice? Set item quantity to -1?
- [ ] **Multi-step process**: Can you jump directly to step 3 of a 5-step flow (skip validation steps)?

---

## A05 — Security Misconfiguration

**Risk**: Default credentials, unnecessary features, overly permissive settings.

### Test Cases

- [ ] **Default credentials**: Try `admin/admin`, `admin/password`, `root/root` on all admin panels.
- [ ] **Error messages**: Trigger a 500 error. Does the response include stack trace, DB queries, or file paths?
- [ ] **Directory listing**: Does `https://example.com/uploads/` list files?
- [ ] **Debug endpoints**: Does `/debug`, `/actuator`, `/metrics`, `/__graphql` expose sensitive data?
- [ ] **HTTP security headers**: Check with securityheaders.com or manually:
  - `X-Content-Type-Options: nosniff`
  - `X-Frame-Options: DENY` or `Content-Security-Policy: frame-ancestors 'none'`
  - `Content-Security-Policy` present and restrictive
  - `Referrer-Policy: no-referrer-when-downgrade`
- [ ] **Unused ports**: `nmap -p- example.com` — are unexpected ports open?
- [ ] **Cloud storage**: Are S3/GCS buckets publicly listable? Try `aws s3 ls s3://bucketname`.

---

## A06 — Vulnerable and Outdated Components

**Risk**: Known CVEs in libraries, frameworks, or runtime.

### Test Cases

- [ ] **Dependency audit**: `npm audit --audit-level=high` / `pip-audit` / `trivy fs .`
- [ ] **CRITICAL/HIGH CVEs**: Any unpatched dependencies with CVSS ≥ 7.0?
- [ ] **Framework version**: Is the web framework on a supported/patched version?
- [ ] **OS and runtime**: Is the OS/Node/Python version still receiving security patches?
- [ ] **Docker base images**: `trivy image app:latest` — any CVEs in base image?

---

## A07 — Identification and Authentication Failures

**Risk**: Authentication bypass, weak credentials, session management flaws.

### Test Cases

- [ ] **Password strength**: Can you set password `1`, `a`, or `password123`?
- [ ] **Session fixation**: Set a known session ID before login. Does it change after login?
- [ ] **Session expiry**: Leave a session idle for 30 min. Is it still valid?
- [ ] **Concurrent sessions**: Log in on two devices. Are both sessions valid? Is there a limit?
- [ ] **Token in URL**: Is the session token passed in the URL (ends up in server logs)?
- [ ] **Multi-factor bypass**: Can you skip MFA by directly accessing post-MFA URL?
- [ ] **Remember me**: How long does "remember me" persist? Is the cookie secure?

---

## A08 — Software and Data Integrity Failures

**Risk**: Unsigned or unverified updates, insecure deserialization.

### Test Cases

- [ ] **Deserialization**: Does the app deserialize user-supplied data (Java serialized objects, pickle, YAML)?
- [ ] **CI/CD pipeline**: Are dependencies fetched without integrity checks (no lockfile, no hash verification)?
- [ ] **Auto-update**: Does the app auto-update without verifying the signature of the update?
- [ ] **JWT algorithm confusion**: Can you change `alg: RS256` to `alg: HS256` and sign with the public key?

---

## A09 — Security Logging and Monitoring Failures

**Risk**: Attacks not detected or investigated due to missing logs.

### Test Cases

- [ ] **Failed logins logged**: Trigger 10 failed logins. Is there a log entry per failure?
- [ ] **Access control failures logged**: Try accessing a forbidden resource. Is the 403 logged with user ID and IP?
- [ ] **PII in logs**: Do logs contain passwords, full card numbers, or unmasked tokens?
- [ ] **Log integrity**: Can application users delete or modify logs?
- [ ] **Alert on attack patterns**: Would 1000 failed logins in 1 minute trigger an alert?
- [ ] **Log retention**: Are logs kept for ≥ 90 days (legal minimum in many jurisdictions)?

---

## A10 — Server-Side Request Forgery (SSRF)

**Risk**: Server fetches attacker-controlled URLs, exposing internal services.

### Test Cases

- [ ] **URL parameters**: Find any parameter that accepts a URL (`imageUrl`, `webhookUrl`, `redirect`).
- [ ] **Internal metadata**: Replace with `http://169.254.169.254/latest/meta-data/` (AWS metadata). Does the server return cloud credentials?
- [ ] **Internal services**: Try `http://localhost:6379`, `http://10.0.0.1/admin`.
- [ ] **DNS rebinding**: Does the app validate the IP after DNS resolution (not just the hostname)?
- [ ] **Protocol schemes**: Does the app accept `file://`, `gopher://`, `dict://` URLs?

---

## Vulnerability Report Template

```markdown
## [VULN-001] [Vulnerability Title]

**Category**: OWASP A0X
**Severity**: CRITICAL / HIGH / MEDIUM / LOW
**CVSS Score**: X.X (Vector: AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H)

### Description
[2–3 sentences explaining the vulnerability]

### Steps to Reproduce
1. [Step 1]
2. [Step 2]
3. [Observe: ...]

### Impact
[What an attacker can do with this]

### Evidence
Request:
```http
POST /api/endpoint HTTP/1.1
...
```
Response:
```http
HTTP/1.1 200 OK
...
```

### Recommended Fix
[Specific code or configuration change]

### References
- CWE-XXX: [Name]
- OWASP: [Link]
```
