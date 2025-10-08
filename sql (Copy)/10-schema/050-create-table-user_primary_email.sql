BEGIN;
CREATE TABLE IF NOT EXISTS usr.user_primary_email (
  id       BIGSERIAL PRIMARY KEY,
  user_id  BIGINT NOT NULL REFERENCES usr.user_account(id) ON DELETE RESTRICT,
  email    TEXT   NOT NULL,
  set_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS ix_user_primary_email_user_time ON usr.user_primary_email (user_id, set_at DESC);
COMMENT ON TABLE usr.user_primary_email IS 'Append-only log of primary-email changes.';
COMMIT;