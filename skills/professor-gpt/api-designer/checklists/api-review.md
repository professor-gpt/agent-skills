# API Design Review Checklist

Use before publishing any new API or adding endpoints to an existing one.
Mark: ✅ Pass · ❌ Fail · N/A

---

## A. URL Design

- [ ] Resources are **plural nouns**: `/users`, `/orders`, `/products`
- [ ] Paths use **kebab-case**: `/blog-posts`, not `/blogPosts` or `/blog_posts`
- [ ] No verbs in URLs (except for actions): `/orders/:id/cancel` (acceptable), `/cancelOrder` (not acceptable)
- [ ] URL hierarchy matches resource nesting (max 2 levels deep): `/users/:id/orders` ✅, `/users/:id/orders/:id/items/:id/details` ❌
- [ ] Version prefix present: `/v1/`, `/v2/`
- [ ] IDs are opaque (UUIDs or prefixed strings), not sequential integers that expose count

## B. HTTP Methods

- [ ] `GET` is safe (no side effects) and idempotent
- [ ] `POST` used for creation and non-idempotent actions
- [ ] `PUT` replaces the full resource (client sends complete representation)
- [ ] `PATCH` updates partial resource (only changed fields required)
- [ ] `DELETE` is idempotent (deleting a non-existent resource returns 204 or 404, not 500)
- [ ] No `GET` endpoints that create or modify data

## C. HTTP Status Codes

- [ ] `200 OK` for successful GET, PATCH, PUT
- [ ] `201 Created` for successful POST (with `Location` header)
- [ ] `204 No Content` for successful DELETE
- [ ] `400 Bad Request` for malformed JSON or wrong parameter type
- [ ] `401 Unauthorized` for missing/invalid token
- [ ] `403 Forbidden` for valid auth but insufficient permission
- [ ] `404 Not Found` for missing resources (not `400`)
- [ ] `409 Conflict` for duplicate resources or state conflicts
- [ ] `422 Unprocessable Entity` for failed business validation (field-level errors)
- [ ] `429 Too Many Requests` for rate limiting (with `Retry-After` header)
- [ ] `500 Internal Server Error` never exposes stack traces to clients

## D. Request Design

- [ ] Required fields validated and 422 returned if missing
- [ ] Optional fields have documented defaults
- [ ] No undocumented required headers
- [ ] Content-Type validated: reject `415 Unsupported Media Type` for wrong type
- [ ] Request body size limit enforced (prevent large payload DoS)
- [ ] Idempotency keys supported for POST endpoints that create resources

## E. Response Design

- [ ] Response shape is consistent: `{ "data": {...} }` or `{ "data": [...], "meta": {...} }`
- [ ] Error responses use consistent error schema (see error checklist)
- [ ] List endpoints are paginated (never return unlimited results)
- [ ] Timestamps use ISO 8601 UTC: `2026-06-22T10:00:00Z`
- [ ] Monetary values are integers (cents), not floats (avoid floating-point errors)
- [ ] Null fields are explicit (`"field": null`), not omitted
- [ ] Boolean fields are true/false, not 0/1 or "yes"/"no"

## F. Error Design

- [ ] Every error includes: `code` (machine-readable string), `message` (human-readable)
- [ ] Validation errors include `details[]` with per-field breakdown
- [ ] Error `code` values are documented in API reference
- [ ] Error codes use SCREAMING_SNAKE_CASE: `VALIDATION_FAILED`, `NOT_FOUND`
- [ ] `message` is useful for debugging but safe for display (no PII, no stack traces)
- [ ] `request_id` included for support/debugging

## G. Pagination

- [ ] All list endpoints support `page` + `per_page` parameters (or cursor-based)
- [ ] Response includes `meta.total`, `meta.pages`, `meta.page`, `meta.per_page`
- [ ] Response includes `links.next`, `links.prev` (null if not applicable)
- [ ] `per_page` has a maximum limit (e.g., 100) to prevent abuse
- [ ] Default `per_page` is reasonable (20–50)
- [ ] Sorting documented: which fields, which directions, what's the default

## H. Authentication & Authorization

- [ ] Auth scheme documented (Bearer token, API key, OAuth 2.0)
- [ ] Token expiry documented
- [ ] `401` vs `403` used correctly (missing auth vs insufficient permission)
- [ ] Each endpoint lists required permission/scope
- [ ] Admin-only endpoints are clearly marked and separately protected

## I. Versioning

- [ ] Version in URL prefix (`/v1/`)
- [ ] Deprecation policy documented (how long old versions are maintained)
- [ ] `Deprecation` and `Sunset` headers set on deprecated endpoints
- [ ] Breaking vs non-breaking changes defined:
  - Non-breaking (no version bump): adding optional fields, new endpoints, new enum values
  - Breaking (version bump): removing fields, changing field types, removing endpoints

## J. Developer Experience

- [ ] OpenAPI 3.x spec is valid (run `npx @redocly/cli lint openapi.yaml`)
- [ ] All examples are valid (match the schema)
- [ ] Every parameter has a description
- [ ] Common operations have a code example (curl, TypeScript, Python)
- [ ] Changelog documents every breaking change and new endpoint

## K. Security

- [ ] Rate limiting on all public endpoints
- [ ] Rate limit headers in response (`X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`)
- [ ] Input sanitized (prevent injection via API parameters)
- [ ] CORS policy is explicit (not `*` for authenticated endpoints)
- [ ] API keys not logged in plaintext in server logs

---

## Quick Reference: Common Mistakes

| Mistake | ❌ Wrong | ✅ Right |
|---------|----------|---------|
| Verbs in URLs | `POST /createUser` | `POST /users` |
| Wrong status code for validation | `400` with field errors | `422` with `details[]` |
| Inconsistent envelope | sometimes `{data}`, sometimes `{result}` | always `{data}` |
| Float for money | `{"price": 9.99}` | `{"price_cents": 999}` |
| Omitting nulls | `{}` for empty fields | `{"field": null}` |
| Exposing DB ids | `{"id": 42}` | `{"id": "usr_01hx..."}` |
| Mutable GET | `GET /users/:id/activate` | `POST /users/:id/activate` |
| 500 on bad input | returns 500 | returns 400/422 with reason |
