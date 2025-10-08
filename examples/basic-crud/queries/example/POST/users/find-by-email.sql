-- datasource: primary
-- description: Find user by email

SELECT id, name, email, status, created_at, updated_at
FROM users
WHERE email = :email;
