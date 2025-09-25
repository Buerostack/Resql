BEGIN;
CREATE TABLE IF NOT EXISTS usr.user_session (
  id            BIGSERIAL PRIMARY KEY,
  user_id       BIGINT NOT NULL REFERENCES usr.user_account(id) ON DELETE RESTRICT,
  session_token TEXT   NOT NULL,
  issued_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  expires_at    TIMESTAMPTZ NOT NULL,
  ip            INET,
  user_agent    TEXT,
  revoked_at    TIMESTAMPTZ
);
CREATE UNIQUE INDEX IF NOT EXISTS ux_user_session_token ON usr.user_session (session_token);
CREATE INDEX IF NOT EXISTS ix_user_session_user ON usr.user_session (user_id, issued_at DESC);
CREATE INDEX IF NOT EXISTS ix_user_session_live ON usr.user_session (user_id) WHERE revoked_at IS NULL;
COMMENT ON TABLE usr.user_session IS 'Append-only sessions. Revocations are represented as rows with revoked_at set at insert-time.';
COMMIT;