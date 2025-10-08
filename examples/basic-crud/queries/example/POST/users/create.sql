-- datasource: primary
-- description: Create a new user

INSERT INTO users (name, email, status)
VALUES (:name, :email, COALESCE(:status, 'active'))
RETURNING id, name, email, status, created_at;
