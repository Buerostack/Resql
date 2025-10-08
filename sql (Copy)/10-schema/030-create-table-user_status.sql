BEGIN;
CREATE TABLE IF NOT EXISTS usr.user_status (
  id          BIGSERIAL PRIMARY KEY,
  user_id     BIGINT NOT NULL REFERENCES usr.user_account(id) ON DELETE RESTRICT,
  status      TEXT   NOT NULL CHECK (status IN ('active','inactive','banned')),
  valid_from  TIMESTAMPTZ NOT NULL DEFAULT now(),
  note        TEXT
);
CREATE INDEX IF NOT EXISTS ix_user_status_user_time ON usr.user_status (user_id, valid_from DESC);
COMMENT ON TABLE usr.user_status IS 'Append-only status history.';
COMMIT;