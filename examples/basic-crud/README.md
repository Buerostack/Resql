# Basic CRUD Operations Example

This example demonstrates basic Create, Read, Update, Delete (CRUD) operations using Resql.

## Prerequisites

- Resql running (see main [README.md](../../README.md))
- PostgreSQL database (see [Configure DataSource](../../docs/how-to/configure-datasource.md))
- cURL or HTTPie installed

## Setup

### 1. Create Database Schema

```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    status VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 2. Create SQL Query Files

The query files are already in this directory under `queries/`. Copy them to your Resql instance:

```bash
# Copy to Resql sql directory
cp -r queries/* /path/to/resql/sql/
```

Or if using Docker:

```bash
docker cp queries/. resql:/app/sql/
```

## Query Files

### Create User

**File:** `queries/example/POST/users/create.sql`

```sql
-- datasource: primary
-- description: Create a new user

INSERT INTO users (name, email, status)
VALUES (:name, :email, COALESCE(:status, 'active'))
RETURNING id, name, email, status, created_at;
```

### Read User by ID

**File:** `queries/example/GET/users/get-by-id.sql`

```sql
-- datasource: primary
-- description: Get user by ID

SELECT id, name, email, status, created_at, updated_at
FROM users
WHERE id = :id;
```

### Read User by Email

**File:** `queries/example/POST/users/find-by-email.sql`

```sql
-- datasource: primary
-- description: Find user by email

SELECT id, name, email, status, created_at, updated_at
FROM users
WHERE email = :email;
```

### List All Users

**File:** `queries/example/GET/users/list.sql`

```sql
-- datasource: primary
-- description: List all users with optional filtering

SELECT id, name, email, status, created_at, updated_at
FROM users
WHERE (:status IS NULL OR status = :status)
ORDER BY created_at DESC
LIMIT COALESCE(:limit, 100)
OFFSET COALESCE(:offset, 0);
```

### Update User

**File:** `queries/example/POST/users/update.sql`

```sql
-- datasource: primary
-- description: Update user information

UPDATE users
SET
    name = COALESCE(:name, name),
    email = COALESCE(:email, email),
    status = COALESCE(:status, status),
    updated_at = CURRENT_TIMESTAMP
WHERE id = :id
RETURNING id, name, email, status, updated_at;
```

### Delete User

**File:** `queries/example/POST/users/delete.sql`

```sql
-- datasource: primary
-- description: Delete user by ID

DELETE FROM users
WHERE id = :id
RETURNING id, name, email;
```

## Running the Examples

### Create a User

```bash
curl -X POST http://localhost:8080/example/users/create \
  -H "Content-Type: application/json" \
  -H "Authorization: Basic YWRtaW46cGFzc3dvcmQ=" \
  -d '{
    "name": "John Doe",
    "email": "john.doe@example.com",
    "status": "active"
  }'
```

**Response:**
```json
[
  {
    "id": 1,
    "name": "John Doe",
    "email": "john.doe@example.com",
    "status": "active",
    "created_at": "2024-01-15T10:30:00Z"
  }
]
```

### Get User by ID

```bash
curl "http://localhost:8080/example/users/get-by-id?id=1" \
  -H "Authorization: Basic YWRtaW46cGFzc3dvcmQ="
```

**Response:**
```json
[
  {
    "id": 1,
    "name": "John Doe",
    "email": "john.doe@example.com",
    "status": "active",
    "created_at": "2024-01-15T10:30:00Z",
    "updated_at": "2024-01-15T10:30:00Z"
  }
]
```

### Find User by Email

```bash
curl -X POST http://localhost:8080/example/users/find-by-email \
  -H "Content-Type: application/json" \
  -H "Authorization: Basic YWRtaW46cGFzc3dvcmQ=" \
  -d '{
    "email": "john.doe@example.com"
  }'
```

### List All Users

```bash
# List all active users
curl "http://localhost:8080/example/users/list?status=active&limit=10&offset=0" \
  -H "Authorization: Basic YWRtaW46cGFzc3dvcmQ="

# List all users (no filter)
curl "http://localhost:8080/example/users/list" \
  -H "Authorization: Basic YWRtaW46cGFzc3dvcmQ="
```

### Update User

```bash
curl -X POST http://localhost:8080/example/users/update \
  -H "Content-Type: application/json" \
  -H "Authorization: Basic YWRtaW46cGFzc3dvcmQ=" \
  -d '{
    "id": 1,
    "name": "Jane Doe",
    "status": "inactive"
  }'
```

**Response:**
```json
[
  {
    "id": 1,
    "name": "Jane Doe",
    "email": "john.doe@example.com",
    "status": "inactive",
    "updated_at": "2024-01-15T11:00:00Z"
  }
]
```

### Delete User

```bash
curl -X POST http://localhost:8080/example/users/delete \
  -H "Content-Type: application/json" \
  -H "Authorization: Basic YWRtaW46cGFzc3dvcmQ=" \
  -d '{
    "id": 1
  }'
```

**Response:**
```json
[
  {
    "id": 1,
    "name": "Jane Doe",
    "email": "john.doe@example.com"
  }
]
```

## Automated Test Script

Run all operations:

```bash
chmod +x test.sh
./test.sh
```

The script will:
1. Create a new user
2. Retrieve the user by ID
3. Find the user by email
4. Update the user
5. List all users
6. Delete the user

## Using HTTPie

If you prefer HTTPie over cURL:

```bash
# Create user
http POST :8080/example/users/create \
  name="John Doe" \
  email=john@example.com \
  -a admin:password

# Get user
http :8080/example/users/get-by-id id==1 -a admin:password

# Update user
http POST :8080/example/users/update \
  id:=1 \
  name="Jane Doe" \
  -a admin:password

# Delete user
http POST :8080/example/users/delete id:=1 -a admin:password
```

## Error Handling

### User Not Found

```bash
curl "http://localhost:8080/example/users/get-by-id?id=999" \
  -H "Authorization: Basic YWRtaW46cGFzc3dvcmQ="
```

Response:
```json
[]
```

### Duplicate Email

```bash
curl -X POST http://localhost:8080/example/users/create \
  -H "Content-Type: application/json" \
  -H "Authorization: Basic YWRtaW46cGFzc3dvcmQ=" \
  -d '{
    "name": "Duplicate User",
    "email": "john.doe@example.com"
  }'
```

Response:
```json
{
  "timestamp": "2024-01-15T10:30:00Z",
  "status": 500,
  "error": "Internal Server Error",
  "message": "ERROR: duplicate key value violates unique constraint"
}
```

## Next Steps

- [Multi-DataSource Example](../multi-datasource/)
- [Batch Operations Example](../batch-operations/)
- [Advanced Queries](../../docs/reference/sql-syntax.md)
