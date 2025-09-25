BEGIN;
CREATE SCHEMA IF NOT EXISTS usr;
COMMENT ON SCHEMA usr IS 'User/auth context. ADR: immutable + append-only tables. No joins/updates/deletes.';
COMMIT;