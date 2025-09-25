BEGIN;
CREATE TABLE IF NOT EXISTS usr.user_account (
  id          BIGSERIAL PRIMARY KEY,
  ext_id      TEXT NOT NULL UNIQUE,          -- stable external/user subject
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  metadata    JSONB NOT NULL DEFAULT '{}'::jsonb
);
COMMENT ON TABLE usr.user_account IS 'Immutable identity anchor. One row per user.';
COMMIT;