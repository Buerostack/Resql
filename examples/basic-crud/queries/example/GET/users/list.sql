-- datasource: primary
-- description: List all users with optional filtering

SELECT id, name, email, status, created_at, updated_at
FROM users
WHERE (:status IS NULL OR status = :status)
ORDER BY created_at DESC
LIMIT COALESCE(:limit, 100)
OFFSET COALESCE(:offset, 0);
