# How to Create Your First Query

This guide walks you through creating your first SQL-to-REST endpoint in Resql.

## Prerequisites

- Resql running locally or via Docker
- A configured datasource (see [Configure DataSource](configure-datasource.md))
- Basic SQL knowledge

## Step 1: Create SQL File

Create a new SQL file in the appropriate directory:

```bash
mkdir -p sql/api/POST/users
touch sql/api/POST/users/find-by-email.sql
```

## Step 2: Write Your Query

Edit `sql/api/POST/users/find-by-email.sql`:

```sql
-- datasource: primary
-- description: Find a user by their email address

SELECT
    id,
    name,
    email,
    created_at,
    status
FROM users
WHERE email = :email
  AND deleted_at IS NULL;
```

**Key Points:**
- First line specifies which datasource to use
- Named parameters use `:paramName` syntax
- Comments starting with `--` are metadata
- Standard SQL syntax

## Step 3: Test Your Endpoint

### Using cURL

```bash
curl -X POST http://localhost:8080/api/users/find-by-email \
  -H "Content-Type: application/json" \
  -H "Authorization: Basic YWRtaW46cGFzc3dvcmQ=" \
  -d '{
    "email": "john.doe@example.com"
  }'
```

### Using HTTPie

```bash
http POST :8080/api/users/find-by-email \
  email=john.doe@example.com \
  -a admin:password
```

### Using Swagger UI

1. Open http://localhost:8080/swagger-ui.html
2. Find `POST /api/users/find-by-email`
3. Click "Try it out"
4. Enter parameters
5. Click "Execute"

## Step 4: Verify Response

Expected response:

```json
[
  {
    "id": 123,
    "name": "John Doe",
    "email": "john.doe@example.com",
    "created_at": "2024-01-15T10:30:00",
    "status": "active"
  }
]
```

**Note:** Response is always an array, even for single results.

## Understanding the Mapping

**File Path:** `sql/api/POST/users/find-by-email.sql`

**Endpoint:** `POST /api/users/find-by-email`

**Breakdown:**
- `api` → Project/namespace
- `POST` → HTTP method
- `users/find-by-email` → Endpoint path

## Adding Parameters

### Single Parameter

```sql
SELECT * FROM products WHERE id = :id;
```

Call with:
```json
{"id": 42}
```

### Multiple Parameters

```sql
SELECT * FROM orders
WHERE customer_id = :customerId
  AND status = :status
  AND created_at > :startDate;
```

Call with:
```json
{
  "customerId": 123,
  "status": "pending",
  "startDate": "2024-01-01"
}
```

### Optional Parameters

Resql supports optional parameters using SQL conditionals. For details on this and other advanced patterns like pagination, full-text search, and array parameters, see the [SQL Syntax Reference](../reference/sql-syntax.md).

## Common Patterns

For comprehensive SQL patterns including:
- Optional parameters
- Pagination
- Search with LIKE
- Array and JSON parameters
- Upsert operations

See the [SQL Syntax Reference](../reference/sql-syntax.md).

### Basic Pagination Example

```sql
SELECT * FROM products
ORDER BY created_at DESC
LIMIT :limit OFFSET :offset;
```

```json
{
  "limit": 20,
  "offset": 0
}
```


## GET vs POST Queries

### GET Query

File: `sql/api/GET/products/get-by-id.sql`

```sql
SELECT * FROM products WHERE id = :id;
```

Call:
```bash
curl "http://localhost:8080/api/products/get-by-id?id=42"
```

### POST Query

File: `sql/api/POST/products/search.sql`

```sql
SELECT * FROM products
WHERE category = :category
  AND price BETWEEN :minPrice AND :maxPrice;
```

Call:
```bash
curl -X POST http://localhost:8080/api/products/search \
  -H "Content-Type: application/json" \
  -d '{"category": "books", "minPrice": 10, "maxPrice": 50}'
```

**Best Practice:** Use GET for simple lookups, POST for complex queries.

## Next Steps

- [Configure DataSource](configure-datasource.md) - Add more databases
- [Deploy with Docker](deploy-docker.md) - Production deployment
- [SQL Syntax Reference](../reference/sql-syntax.md) - Complete SQL patterns and examples
- [REST API Reference](../reference/rest-api.md) - API endpoint documentation
- [Basic CRUD Example](../../examples/basic-crud/) - Working example with test script
