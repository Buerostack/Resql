BEGIN;
-- user_001 sessions
INSERT INTO usr.user_session (user_id, session_token, expires_at, ip, user_agent, revoked_at)
SELECT id, 'sess_user001_a', now() + interval '1 day', '192.168.1.10', 'CLI seed', NULL
FROM usr.user_account
WHERE ext_id = 'user_001'
  AND NOT EXISTS (SELECT 1 FROM usr.user_session WHERE session_token = 'sess_user001_a');

INSERT INTO usr.user_session (user_id, session_token, expires_at, ip, user_agent, revoked_at)
SELECT id, 'sess_user001_b', now() + interval '2 days', '192.168.1.11', 'CLI seed', NULL
FROM usr.user_account
WHERE ext_id = 'user_001'
  AND NOT EXISTS (SELECT 1 FROM usr.user_session WHERE session_token = 'sess_user001_b');

-- user_002 session (pre-revoked at insert-time to demonstrate append-only)
INSERT INTO usr.user_session (user_id, session_token, expires_at, ip, user_agent, revoked_at)
SELECT id, 'sess_user002_a', now() + interval '1 day', '192.168.1.12', 'CLI seed', now()
FROM usr.user_account
WHERE ext_id = 'user_002'
  AND NOT EXISTS (SELECT 1 FROM usr.user_session WHERE session_token = 'sess_user002_a');
COMMIT;