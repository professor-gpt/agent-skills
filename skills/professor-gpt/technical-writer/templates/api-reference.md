# API Reference Template

<!-- Instructions (delete before publishing):
     - Replace all [PLACEHOLDERS] with actual values
     - Delete any sections that don't apply
     - Each endpoint needs: description, HTTP method+path, auth requirement,
       request params, request body, response schema, errors, and one example
-->

# [Service Name] API Reference

**Base URL**: `https://api.example.com/v1`
**Version**: 1.0.0
**Authentication**: Bearer token (include `Authorization: Bearer <token>` header)

---

## Authentication

```http
GET /v1/me
Authorization: Bearer sk_live_abc123...
```

All endpoints require authentication unless marked **Public**.

Tokens are obtained via `POST /v1/auth/token`. Tokens expire after **1 hour**; use the refresh token to obtain a new one.

---

## Rate Limits

| Plan | Requests/minute | Burst |
|------|----------------|-------|
| Free | 60 | 10 |
| Pro | 600 | 100 |
| Enterprise | Custom | Custom |

Rate limit headers are included in every response:

```
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 45
X-RateLimit-Reset: 1719849600
```

When rate limited, the API returns `429 Too Many Requests`. Back off exponentially and retry after the `Retry-After` header value (in seconds).

---

## Errors

All errors use this shape:

```json
{
  "error": {
    "code": "VALIDATION_FAILED",
    "message": "Human-readable description",
    "details": [
      {
        "field": "email",
        "code": "INVALID_FORMAT",
        "message": "Must be a valid email address"
      }
    ],
    "request_id": "req_abc123"
  }
}
```

### Error Codes

| HTTP Status | Code | Description |
|-------------|------|-------------|
| 400 | `VALIDATION_FAILED` | One or more request fields are invalid |
| 401 | `UNAUTHORIZED` | Missing or invalid authentication token |
| 403 | `FORBIDDEN` | Authenticated but not authorized |
| 404 | `NOT_FOUND` | Resource does not exist |
| 409 | `CONFLICT` | Resource already exists or state conflict |
| 422 | `UNPROCESSABLE` | Request is valid but business logic rejects it |
| 429 | `RATE_LIMITED` | Too many requests |
| 500 | `INTERNAL_ERROR` | Unexpected server error |
| 503 | `SERVICE_UNAVAILABLE` | Temporary outage |

---

## Endpoints

---

### Users

#### Get Current User

```
GET /v1/me
```

Returns the authenticated user's profile.

**Authentication**: Required

**Response 200**

```json
{
  "data": {
    "id": "usr_01hx4j9kt2g9abcdef",
    "email": "alice@example.com",
    "name": "Alice Smith",
    "plan": "pro",
    "created_at": "2026-01-15T09:30:00Z",
    "updated_at": "2026-06-01T14:22:00Z"
  }
}
```

| Field | Type | Description |
|-------|------|-------------|
| `id` | `string` | User ID (Prefixed: `usr_`) |
| `email` | `string` | Verified email address |
| `name` | `string \| null` | Display name |
| `plan` | `"free" \| "pro" \| "enterprise"` | Current subscription plan |
| `created_at` | `string (ISO 8601)` | Account creation timestamp |
| `updated_at` | `string (ISO 8601)` | Last update timestamp |

**Errors**

| Status | Code | When |
|--------|------|------|
| 401 | `UNAUTHORIZED` | Token missing or expired |

---

#### Update User

```
PATCH /v1/me
```

Update the authenticated user's profile. All fields are optional.

**Authentication**: Required

**Request Body**

```json
{
  "name": "Alice Johnson",
  "notification_email": "alerts@example.com"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | `string` | ❌ | Display name (max 100 chars) |
| `notification_email` | `string` | ❌ | Separate email for notifications |

**Response 200** — Returns updated user object (same shape as GET /v1/me).

**Errors**

| Status | Code | When |
|--------|------|------|
| 400 | `VALIDATION_FAILED` | Invalid field value |
| 401 | `UNAUTHORIZED` | Token missing or expired |

---

### Resources

#### List [Resources]

```
GET /v1/[resources]
```

Returns a paginated list of [resources] owned by the authenticated user.

**Authentication**: Required

**Query Parameters**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `page` | `integer` | ❌ | `1` | Page number (1-indexed) |
| `per_page` | `integer` | ❌ | `20` | Items per page (max: 100) |
| `sort` | `string` | ❌ | `created_at` | Sort field |
| `order` | `"asc" \| "desc"` | ❌ | `"desc"` | Sort direction |
| `status` | `string` | ❌ | — | Filter by status |

**Response 200**

```json
{
  "data": [
    {
      "id": "res_01hx4j9kt2g9abcdef",
      "name": "My Resource",
      "status": "active",
      "created_at": "2026-06-01T10:00:00Z"
    }
  ],
  "meta": {
    "total": 47,
    "page": 1,
    "per_page": 20,
    "pages": 3
  },
  "links": {
    "self": "/v1/resources?page=1",
    "next": "/v1/resources?page=2",
    "prev": null,
    "last": "/v1/resources?page=3"
  }
}
```

---

#### Create [Resource]

```
POST /v1/[resources]
```

Creates a new [resource].

**Authentication**: Required

**Request Body** (`application/json`)

```json
{
  "name": "My New Resource",
  "description": "Optional description",
  "config": {
    "setting_a": true,
    "setting_b": "value"
  }
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | `string` | ✅ | Resource name (1–255 chars) |
| `description` | `string` | ❌ | Optional description (max 1000 chars) |
| `config.setting_a` | `boolean` | ❌ | Enable feature A. Default: `false` |
| `config.setting_b` | `string` | ❌ | Configuration value |

**Response 201**

```json
{
  "data": {
    "id": "res_01hx4j9kt2g9abcdef",
    "name": "My New Resource",
    "status": "pending",
    "created_at": "2026-06-22T12:00:00Z"
  }
}
```

**Errors**

| Status | Code | When |
|--------|------|------|
| 400 | `VALIDATION_FAILED` | Missing required field or invalid value |
| 409 | `CONFLICT` | Resource with this name already exists |

---

#### Get [Resource]

```
GET /v1/[resources]/:id
```

**Path Parameters**

| Parameter | Description |
|-----------|-------------|
| `id` | Resource ID |

**Response 200** — Returns full resource object.

**Errors**

| Status | Code | When |
|--------|------|------|
| 404 | `NOT_FOUND` | Resource does not exist or not owned by caller |

---

#### Delete [Resource]

```
DELETE /v1/[resources]/:id
```

Permanently deletes a resource. This action is irreversible.

**Response 204** — No content.

---

## Code Examples

### cURL

```bash
# Get current user
curl -X GET https://api.example.com/v1/me \
  -H "Authorization: Bearer $API_KEY"

# Create a resource
curl -X POST https://api.example.com/v1/resources \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"name": "My Resource"}'
```

### TypeScript

```typescript
const response = await fetch('https://api.example.com/v1/resources', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${process.env.API_KEY}`,
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({ name: 'My Resource' }),
})

if (!response.ok) {
  const { error } = await response.json()
  throw new Error(`${error.code}: ${error.message}`)
}

const { data } = await response.json()
console.log('Created:', data.id)
```

### Python

```python
import httpx

client = httpx.Client(
    base_url="https://api.example.com/v1",
    headers={"Authorization": f"Bearer {API_KEY}"},
)

response = client.post("/resources", json={"name": "My Resource"})
response.raise_for_status()
print("Created:", response.json()["data"]["id"])
```

---

## Changelog

### v1.1.0 — 2026-06-01
- Added `notification_email` field to User object
- `GET /v1/resources` now supports `sort` and `order` parameters

### v1.0.0 — 2026-01-15
- Initial release
