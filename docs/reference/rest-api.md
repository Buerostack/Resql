# REST API Reference

Complete reference for Resql REST API endpoints.

## Base URL

```
http://localhost:8080
```

## Authentication

All endpoints require authentication by default.

### Basic Auth

```bash
curl -u admin:password http://localhost:8080/api/...
```

### Header

```bash
curl -H "Authorization: Basic YWRtaW46cGFzc3dvcmQ=" http://localhost:8080/api/...
```

## Core Endpoints

### Execute Query (POST)

Execute a saved SQL query using POST method.

**Endpoint:** `POST /{project}/**`

**Example:** `POST /api/users/find-by-email`

**Request Headers:**
```
Content-Type: application/json
Authorization: Basic <credentials>
X-Datasource: <datasource-name> (optional)
```

**Request Body:**
```json
{
  "param1": "value1",
  "param2": "value2"
}
```

**Response:**
```json
[
  {
    "column1": "value1",
    "column2": "value2"
  }
]
```

**Status Codes:**
- `200 OK` - Query executed successfully
- `400 Bad Request` - Invalid parameters
- `401 Unauthorized` - Authentication required
- `404 Not Found` - Query file not found
- `500 Internal Server Error` - SQL execution error

**cURL Example:**
```bash
curl -X POST http://localhost:8080/api/users/find-by-email \
  -H "Content-Type: application/json" \
  -H "Authorization: Basic YWRtaW46cGFzc3dvcmQ=" \
  -d '{
    "email": "user@example.com"
  }'
```

---

### Execute Query (GET)

Execute a saved SQL query using GET method.

**Endpoint:** `GET /{project}/**`

**Example:** `GET /api/products/get-by-id`

**Request Headers:**
```
Authorization: Basic <credentials>
X-Datasource: <datasource-name> (optional)
```

**Query Parameters:**
```
?param1=value1&param2=value2
```

**Response:**
```json
[
  {
    "id": 123,
    "name": "Product Name"
  }
]
```

**cURL Example:**
```bash
curl "http://localhost:8080/api/products/get-by-id?id=123" \
  -H "Authorization: Basic YWRtaW46cGFzc3dvcmQ="
```

---

### Batch Execute

Execute the same query multiple times with different parameters.

**Endpoint:** `POST /{project}/{query-name}/batch`

**Example:** `POST /api/users/batch`

**Request Body:**
```json
{
  "queries": [
    {"email": "user1@example.com"},
    {"email": "user2@example.com"},
    {"email": "user3@example.com"}
  ]
}
```

**Response:**
```json
[
  [{"id": 1, "name": "User One"}],
  [{"id": 2, "name": "User Two"}],
  [{"id": 3, "name": "User Three"}]
]
```

**cURL Example:**
```bash
curl -X POST http://localhost:8080/api/users/find-by-email/batch \
  -H "Content-Type: application/json" \
  -H "Authorization: Basic YWRtaW46cGFzc3dvcmQ=" \
  -d '{
    "queries": [
      {"email": "user1@example.com"},
      {"email": "user2@example.com"}
    ]
  }'
```

---

### Health Check

Check application health and status.

**Endpoint:** `GET /heartbeat`

**Request Headers:** None required

**Response:**
```json
{
  "status": "UP",
  "version": "0.0.1-SNAPSHOT",
  "timestamp": "2024-01-15T10:30:00Z",
  "uptime": "2h 15m 30s"
}
```

**cURL Example:**
```bash
curl http://localhost:8080/heartbeat
```

---

### List DataSources

List all configured datasources and their status.

**Endpoint:** `GET /datasources`

**Request Headers:**
```
Authorization: Basic <credentials>
```

**Response:**
```json
[
  {
    "name": "primary",
    "status": "UP",
    "url": "jdbc:postgresql://localhost:5432/mydb",
    "driverClass": "org.postgresql.Driver",
    "activeConnections": 3,
    "idleConnections": 7,
    "totalConnections": 10
  }
]
```

**cURL Example:**
```bash
curl http://localhost:8080/datasources \
  -H "Authorization: Basic YWRtaW46cGFzc3dvcmQ="
```

---

## Response Format

### Success Response

All successful query executions return an array of objects:

```json
[
  {
    "column1": "value1",
    "column2": 123,
    "column3": true
  }
]
```

**Even single-row results return an array:**
```json
[
  {"count": 42}
]
```

### Empty Result

When no rows match:

```json
[]
```

### Error Response

```json
{
  "timestamp": "2024-01-15T10:30:00Z",
  "status": 500,
  "error": "Internal Server Error",
  "message": "Query execution failed",
  "path": "/api/users/find-by-email"
}
```

## Data Types

### Type Mapping

| SQL Type | JSON Type | Example |
|----------|-----------|---------|
| INTEGER, BIGINT | number | `123` |
| DECIMAL, NUMERIC | number | `123.45` |
| VARCHAR, TEXT | string | `"text"` |
| BOOLEAN | boolean | `true` |
| DATE | string | `"2024-01-15"` |
| TIMESTAMP | string | `"2024-01-15T10:30:00Z"` |
| JSON, JSONB | object/array | `{"key": "value"}` |
| ARRAY | array | `[1, 2, 3]` |
| NULL | null | `null` |

### Dates and Timestamps

Returned as ISO 8601 strings:

```json
{
  "created_at": "2024-01-15T10:30:00Z",
  "birth_date": "1990-05-20"
}
```

### JSON Columns

PostgreSQL JSON/JSONB columns parsed automatically:

```json
{
  "id": 123,
  "metadata": {
    "key": "value",
    "nested": {
      "data": true
    }
  }
}
```

## Request Headers

### Standard Headers

| Header | Required | Description |
|--------|----------|-------------|
| `Content-Type` | Yes (POST) | Must be `application/json` |
| `Authorization` | Yes | Basic auth credentials |
| `Accept` | No | Response format (default: `application/json`) |

### Custom Headers

| Header | Required | Description |
|--------|----------|-------------|
| `X-Datasource` | No | Override default datasource |
| `X-Request-ID` | No | Client-provided request ID for tracing |

## Query Parameters

### URL Encoding

Special characters must be URL-encoded:

```bash
# Space
curl "http://localhost:8080/api/search?name=John%20Doe"

# Plus
curl "http://localhost:8080/api/search?phone=%2B1234567890"
```

### Arrays

Multiple values for same parameter:

```bash
curl "http://localhost:8080/api/filter?id=1&id=2&id=3"
```

Received as:
```json
{
  "id": ["1", "2", "3"]
}
```

## Error Handling

### Common Error Codes

| Status | Error | Cause |
|--------|-------|-------|
| 400 | Bad Request | Invalid parameters or JSON |
| 401 | Unauthorized | Missing/invalid credentials |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | Query file not found |
| 500 | Internal Server Error | SQL execution error |
| 503 | Service Unavailable | Database connection failed |

### Error Details

```json
{
  "timestamp": "2024-01-15T10:30:00Z",
  "status": 400,
  "error": "Bad Request",
  "message": "Required parameter 'email' is missing",
  "path": "/api/users/find-by-email",
  "details": {
    "missingParameters": ["email"]
  }
}
```

## Rate Limiting

Currently not implemented. Consider adding reverse proxy rate limiting:

```nginx
limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;

location / {
    limit_req zone=api burst=20 nodelay;
    proxy_pass http://resql:8080;
}
```

## CORS

Configure CORS in `application.yml`:

```yaml
spring:
  web:
    cors:
      allowed-origins: "https://example.com"
      allowed-methods: GET,POST
      allowed-headers: "*"
      allow-credentials: true
```

## Compression

Enable gzip compression:

```yaml
server:
  compression:
    enabled: true
    mime-types: application/json,application/xml,text/html,text/xml,text/plain
    min-response-size: 1024
```

## OpenAPI / Swagger

### Swagger UI

Interactive API documentation:

```
http://localhost:8080/swagger-ui.html
```

### OpenAPI Specification

JSON specification:

```
http://localhost:8080/v3/api-docs
```

YAML specification:

```
http://localhost:8080/v3/api-docs.yaml
```

## Examples

### Create User

```bash
curl -X POST http://localhost:8080/api/users/create \
  -H "Content-Type: application/json" \
  -H "Authorization: Basic YWRtaW46cGFzc3dvcmQ=" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "role": "user"
  }'
```

### Search Products

```bash
curl "http://localhost:8080/api/products/search?category=electronics&minPrice=100" \
  -H "Authorization: Basic YWRtaW46cGFzc3dvcmQ="
```

### Update Record

```bash
curl -X POST http://localhost:8080/api/users/update \
  -H "Content-Type: application/json" \
  -H "Authorization: Basic YWRtaW46cGFzc3dvcmQ=" \
  -d '{
    "id": 123,
    "status": "active"
  }'
```

### Delete Record

```bash
curl -X POST http://localhost:8080/api/users/delete \
  -H "Content-Type: application/json" \
  -H "Authorization: Basic YWRtaW46cGFzc3dvcmQ=" \
  -d '{
    "id": 123
  }'
```

## Best Practices

### Use POST for Complex Queries

GET for simple lookups, POST for:
- Multiple parameters
- Complex search criteria
- Parameters with special characters
- Sensitive data

### Parameter Validation

Always validate parameters in SQL:

```sql
SELECT * FROM users
WHERE id = :id::INTEGER
  AND status = :status;
```

### Handle Empty Results

Check for empty array:

```javascript
const response = await fetch('/api/users/find', {
  method: 'POST',
  body: JSON.stringify({email: 'test@example.com'})
});
const data = await response.json();

if (data.length === 0) {
  console.log('No results found');
}
```

### Error Handling

```javascript
try {
  const response = await fetch('/api/query', options);
  if (!response.ok) {
    const error = await response.json();
    console.error('Query failed:', error.message);
  }
  const data = await response.json();
} catch (error) {
  console.error('Request failed:', error);
}
```
