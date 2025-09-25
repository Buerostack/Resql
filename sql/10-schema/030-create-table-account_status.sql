BEGIN;
CREATE TABLE IF NOT EXISTS iam.account_status (
  id       BIGSERIAL PRIMARY KEY,
  ext_id   TEXT NOT NULL REFERENCES iam.account(ext_id) ON DELETE RESTRICT,
  status   TEXT NOT NULL CHECK (status IN ('active','inactive','deleted')),
  note     TEXT,
  set_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS ix_acc_status_extid_time ON iam.account_status (ext_id, set_at DESC);
COMMIT;