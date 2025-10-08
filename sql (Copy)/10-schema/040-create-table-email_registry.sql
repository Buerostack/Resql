BEGIN;
CREATE TABLE IF NOT EXISTS usr.email_registry (
  id          BIGSERIAL PRIMARY KEY,
  user_id     BIGINT NOT NULL REFERENCES usr.user_account(id) ON DELETE RESTRICT,
  email       TEXT   NOT NULL,
  claimed_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
-- Case-insensitive global uniqueness
CREATE UNIQUE INDEX IF NOT EXISTS ux_email_registry_email_nocase
  ON usr.email_registry ((lower(email)));
CREATE INDEX IF NOT EXISTS ix_email_registry_user ON usr.email_registry (user_id, claimed_at DESC);
COMMENT ON TABLE usr.email_registry IS 'Immutable claims of emails (case-insensitive unique).';
COMMIT;