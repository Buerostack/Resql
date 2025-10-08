# SQL Syntax Reference

Guide to writing SQL queries for Resql.

## Query File Structure

### Basic Format

```sql
-- datasource: primary
-- description: Brief description of what this query does
-- author: developer@example.com (optional)

SELECT column1, column2
FROM table_name
WHERE condition = :parameter;
```

### Metadata Headers

| Header | Required | Description | Example |
|--------|----------|-------------|---------|
| `datasource` | Yes | Target database | `-- datasource: primary` |
| `description` | No | Query purpose | `-- description: Find active users` |
| `author` | No | Query creator | `-- author: john@example.com` |
| `version` | No | Query version | `-- version: 1.0` |

## Named Parameters

### Basic Syntax

Use `:parameterName` for named parameters:

```sql
SELECT * FROM users WHERE id = :userId;
```

Call with:
```json
{"userId": 123}
```

### Multiple Parameters

```sql
SELECT * FROM products
WHERE category = :category
  AND price >= :minPrice
  AND price <= :maxPrice
  AND in_stock = :inStock;
```

Call with:
```json
{
  "category": "electronics",
  "minPrice": 100,
  "maxPrice": 1000,
  "inStock": true
}
```

### Parameter Types

Parameters are typed based on SQL context:

```sql
-- Integer
WHERE id = :id::INTEGER

-- String
WHERE name = :name::VARCHAR

-- Boolean
WHERE active = :active::BOOLEAN

-- Date
WHERE created_at > :startDate::DATE

-- Timestamp
WHERE updated_at > :timestamp::TIMESTAMP
```

## SELECT Queries

### Simple SELECT

```sql
-- datasource: primary
SELECT id, name, email
FROM users
WHERE status = :status;
```

### SELECT with JOIN

```sql
-- datasource: primary
SELECT
    u.id,
    u.name,
    u.email,
    r.role_name
FROM users u
INNER JOIN user_roles r ON u.role_id = r.id
WHERE u.status = :status;
```

### SELECT with Aggregation

```sql
-- datasource: primary
SELECT
    category,
    COUNT(*) as product_count,
    AVG(price) as avg_price
FROM products
WHERE created_at > :startDate
GROUP BY category
HAVING COUNT(*) > :minCount;
```

### SELECT with Subquery

```sql
-- datasource: primary
SELECT id, name
FROM users
WHERE department_id IN (
    SELECT id
    FROM departments
    WHERE region = :region
);
```

## INSERT Queries

### Single INSERT

```sql
-- datasource: primary
INSERT INTO users (name, email, status)
VALUES (:name, :email, :status)
RETURNING id, created_at;
```

Call with:
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "status": "active"
}
```

Response:
```json
[
  {
    "id": 123,
    "created_at": "2024-01-15T10:30:00Z"
  }
]
```

### INSERT with Default Values

```sql
-- datasource: primary
INSERT INTO audit_log (user_id, action, details)
VALUES (
    :userId,
    :action,
    COALESCE(:details::JSONB, '{}'::JSONB)
)
RETURNING id;
```

## UPDATE Queries

### Simple UPDATE

```sql
-- datasource: primary
UPDATE users
SET
    status = :status,
    updated_at = CURRENT_TIMESTAMP
WHERE id = :id
RETURNING id, status, updated_at;
```

### Conditional UPDATE

```sql
-- datasource: primary
UPDATE products
SET
    price = :newPrice,
    updated_by = :userId
WHERE id = :productId
  AND price <> :newPrice
RETURNING id, price;
```

### UPDATE with JOIN

```sql
-- datasource: primary
UPDATE orders o
SET status = :newStatus
FROM customers c
WHERE o.customer_id = c.id
  AND c.email = :customerEmail
RETURNING o.id, o.status;
```

## DELETE Queries

### Simple DELETE

```sql
-- datasource: primary
DELETE FROM sessions
WHERE user_id = :userId
RETURNING id;
```

### Soft DELETE

```sql
-- datasource: primary
UPDATE users
SET
    deleted_at = CURRENT_TIMESTAMP,
    deleted_by = :deletedBy
WHERE id = :id
  AND deleted_at IS NULL
RETURNING id;
```

### DELETE with Condition

```sql
-- datasource: primary
DELETE FROM temp_data
WHERE created_at < :expiryDate
RETURNING id;
```

## Advanced Patterns

### Optional Parameters

Handle optional/nullable parameters:

```sql
-- datasource: primary
SELECT * FROM products
WHERE 1=1
  AND (:category IS NULL OR category = :category)
  AND (:minPrice IS NULL OR price >= :minPrice)
  AND (:maxPrice IS NULL OR price <= :maxPrice);
```

Call with:
```json
{
  "category": "electronics",
  "minPrice": null,
  "maxPrice": 1000
}
```

### Dynamic Filtering

```sql
-- datasource: primary
SELECT * FROM users
WHERE
    CASE
        WHEN :searchType = 'email' THEN email = :searchValue
        WHEN :searchType = 'name' THEN name ILIKE '%' || :searchValue || '%'
        WHEN :searchType = 'id' THEN id = :searchValue::INTEGER
        ELSE false
    END;
```

### Array Parameters

PostgreSQL array handling:

```sql
-- datasource: primary
SELECT * FROM users
WHERE id = ANY(CAST(:ids AS INTEGER[]));
```

Call with:
```json
{
  "ids": "{1,2,3,4,5}"
}
```

### JSON Parameters

```sql
-- datasource: primary
INSERT INTO events (event_type, metadata)
VALUES (
    :eventType,
    :metadata::JSONB
)
RETURNING id;
```

Call with:
```json
{
  "eventType": "user_login",
  "metadata": "{\"ip\": \"192.168.1.1\", \"browser\": \"Chrome\"}"
}
```

### Full-Text Search

```sql
-- datasource: primary
SELECT * FROM articles
WHERE to_tsvector('english', title || ' ' || content)
      @@ plainto_tsquery('english', :searchTerm)
ORDER BY ts_rank(
    to_tsvector('english', title || ' ' || content),
    plainto_tsquery('english', :searchTerm)
) DESC
LIMIT :limit;
```

### Pagination

```sql
-- datasource: primary
SELECT
    id,
    name,
    email,
    COUNT(*) OVER() as total_count
FROM users
WHERE status = :status
ORDER BY created_at DESC
LIMIT :limit OFFSET :offset;
```

Call with:
```json
{
  "status": "active",
  "limit": 20,
  "offset": 0
}
```

### Window Functions

```sql
-- datasource: primary
SELECT
    id,
    name,
    salary,
    department,
    AVG(salary) OVER (PARTITION BY department) as dept_avg_salary,
    RANK() OVER (PARTITION BY department ORDER BY salary DESC) as dept_rank
FROM employees
WHERE hire_date > :startDate;
```

### Common Table Expressions (CTE)

```sql
-- datasource: primary
WITH active_users AS (
    SELECT id, name, email
    FROM users
    WHERE status = 'active'
      AND created_at > :startDate
),
user_orders AS (
    SELECT
        user_id,
        COUNT(*) as order_count,
        SUM(total) as total_spent
    FROM orders
    WHERE user_id IN (SELECT id FROM active_users)
    GROUP BY user_id
)
SELECT
    u.id,
    u.name,
    u.email,
    COALESCE(o.order_count, 0) as order_count,
    COALESCE(o.total_spent, 0) as total_spent
FROM active_users u
LEFT JOIN user_orders o ON u.id = o.user_id;
```

## Data Type Handling

### String Operations

```sql
-- datasource: primary
SELECT * FROM users
WHERE
    -- Case-insensitive search
    LOWER(name) LIKE LOWER('%' || :searchTerm || '%')
    -- Exact match
    OR email = :email
    -- Pattern matching
    OR phone SIMILAR TO :phonePattern;
```

### Date Operations

```sql
-- datasource: primary
SELECT * FROM orders
WHERE
    -- Date range
    created_at BETWEEN :startDate AND :endDate
    -- Relative dates
    AND created_at > CURRENT_DATE - INTERVAL '30 days'
    -- Date parts
    AND EXTRACT(YEAR FROM created_at) = :year;
```

### Numeric Operations

```sql
-- datasource: primary
SELECT
    id,
    price,
    ROUND(price * :taxRate, 2) as tax,
    ROUND(price * (1 + :taxRate), 2) as total
FROM products
WHERE
    price BETWEEN :minPrice AND :maxPrice
    AND MOD(id, :batchSize) = :batchNumber;
```

### Boolean Logic

```sql
-- datasource: primary
SELECT * FROM users
WHERE
    (is_verified = :isVerified OR :isVerified IS NULL)
    AND (is_active = true OR :includeInactive = true)
    AND NOT is_deleted;
```

## Best Practices

### Use Explicit Column Names

**Good:**
```sql
SELECT id, name, email FROM users;
```

**Avoid:**
```sql
SELECT * FROM users;
```

### Type Cast Parameters

```sql
-- Explicit type casting
WHERE id = :id::INTEGER
AND price = :price::DECIMAL(10,2)
AND created_at = :date::TIMESTAMP
```

### Avoid SQL Injection

**Never concatenate strings:**
```sql
-- WRONG - vulnerable to injection
WHERE name = '" + :name + "'

-- RIGHT - use parameters
WHERE name = :name
```

### Index-Friendly Queries

```sql
-- Good - uses index on email
WHERE email = :email

-- Bad - can't use index
WHERE LOWER(email) = LOWER(:email)

-- Better - use functional index or parameter preparation
WHERE email = LOWER(:email)
```

### Limit Result Sets

Always use LIMIT for potentially large results:

```sql
SELECT * FROM logs
WHERE created_at > :startDate
ORDER BY created_at DESC
LIMIT :limit;
```

### Use RETURNING Clause

Get inserted/updated values without additional query:

```sql
INSERT INTO users (name, email)
VALUES (:name, :email)
RETURNING id, created_at;

UPDATE users
SET status = :status
WHERE id = :id
RETURNING id, status, updated_at;
```

## Common Patterns

### Upsert (INSERT or UPDATE)

```sql
-- datasource: primary
INSERT INTO user_preferences (user_id, key, value)
VALUES (:userId, :key, :value)
ON CONFLICT (user_id, key)
DO UPDATE SET
    value = EXCLUDED.value,
    updated_at = CURRENT_TIMESTAMP
RETURNING id, user_id, key, value;
```

### Bulk Insert

```sql
-- datasource: primary
INSERT INTO log_entries (level, message, timestamp)
VALUES
    (:level1, :message1, :timestamp1),
    (:level2, :message2, :timestamp2),
    (:level3, :message3, :timestamp3)
RETURNING id;
```

### Recursive Query

```sql
-- datasource: primary
WITH RECURSIVE category_tree AS (
    SELECT id, name, parent_id, 0 as level
    FROM categories
    WHERE id = :rootId

    UNION ALL

    SELECT c.id, c.name, c.parent_id, ct.level + 1
    FROM categories c
    INNER JOIN category_tree ct ON c.parent_id = ct.id
)
SELECT * FROM category_tree
ORDER BY level, name;
```

## PostgreSQL-Specific Features

### JSONB Operations

```sql
-- datasource: primary
SELECT
    id,
    metadata->>'name' as name,
    metadata->'tags' as tags
FROM products
WHERE metadata @> :filter::JSONB
  AND metadata ? :key;
```

### Array Operations

```sql
-- datasource: primary
SELECT * FROM users
WHERE :tag = ANY(tags)
   OR tags && CAST(:tags AS TEXT[]);
```

### Generate Series

```sql
-- datasource: primary
SELECT
    generate_series(:startDate::DATE, :endDate::DATE, '1 day'::INTERVAL)::DATE as date;
```

## Testing Queries

### Use Default Values

For development/testing:

```sql
-- datasource: primary
SELECT * FROM users
WHERE status = COALESCE(:status, 'active')
LIMIT COALESCE(:limit, 10);
```

### Add Comments

Document complex logic:

```sql
-- datasource: primary
-- This query calculates user engagement scores
-- based on login frequency and activity metrics
SELECT
    user_id,
    -- Login score: more logins = higher score
    COUNT(DISTINCT login_date) * 10 as login_score,
    -- Activity score: based on actions
    SUM(action_weight) as activity_score
FROM user_activity
WHERE created_at > :startDate
GROUP BY user_id;
```
