BEGIN;
-- user_001 primary -> alice@example.com
INSERT INTO usr.user_primary_email (user_id, email)
SELECT id, 'alice@example.com'
FROM usr.user_account
WHERE ext_id = 'user_001'
  AND NOT EXISTS (
    SELECT 1 FROM usr.user_primary_email
    WHERE user_id = (SELECT id FROM usr.user_account WHERE ext_id = 'user_001')
      AND lower(email) = lower('alice@example.com')
  );

-- user_002 primary -> bob@example.com
INSERT INTO usr.user_primary_email (user_id, email)
SELECT id, 'bob@example.com'
FROM usr.user_account
WHERE ext_id = 'user_002'
  AND NOT EXISTS (
    SELECT 1 FROM usr.user_primary_email
    WHERE user_id = (SELECT id FROM usr.user_account WHERE ext_id = 'user_002')
      AND lower(email) = lower('bob@example.com')
  );
COMMIT;