BEGIN;
-- user_001 claims alice@example.com
INSERT INTO usr.email_registry (user_id, email)
SELECT id, 'alice@example.com'
FROM usr.user_account
WHERE ext_id = 'user_001'
  AND NOT EXISTS (
    SELECT 1 FROM usr.email_registry WHERE lower(email) = lower('alice@example.com')
  );

-- user_002 claims bob@example.com
INSERT INTO usr.email_registry (user_id, email)
SELECT id, 'bob@example.com'
FROM usr.user_account
WHERE ext_id = 'user_002'
  AND NOT EXISTS (
    SELECT 1 FROM usr.email_registry WHERE lower(email) = lower('bob@example.com')
  );

-- Attempt to claim ALICE@EXAMPLE.COM again (will no-op due to NOT EXISTS)
INSERT INTO usr.email_registry (user_id, email)
SELECT id, 'ALICE@EXAMPLE.COM'
FROM usr.user_account
WHERE ext_id = 'user_003'
  AND NOT EXISTS (
    SELECT 1 FROM usr.email_registry WHERE lower(email) = lower('ALICE@EXAMPLE.COM')
  );
COMMIT;