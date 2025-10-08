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
