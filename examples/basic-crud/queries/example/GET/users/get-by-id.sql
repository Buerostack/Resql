-- datasource: primary
-- description: Get user by ID

SELECT id, name, email, status, created_at, updated_at
FROM users
WHERE id = :id;
