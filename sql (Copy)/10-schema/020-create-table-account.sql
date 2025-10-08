BEGIN;
CREATE TABLE IF NOT EXISTS iam.account (
  ext_id        TEXT PRIMARY KEY,               -- natural key for simple inserts
  email         TEXT NOT NULL UNIQUE,           -- simple value, no JSON
  display_name  TEXT,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMIT;