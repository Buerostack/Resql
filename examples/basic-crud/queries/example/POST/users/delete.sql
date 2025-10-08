-- datasource: primary
-- description: Delete user by ID

DELETE FROM users
WHERE id = :id
RETURNING id, name, email;
