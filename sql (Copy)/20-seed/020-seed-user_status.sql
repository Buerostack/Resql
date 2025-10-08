BEGIN;
-- user_001 -> active
INSERT INTO usr.user_status (user_id, status, note)
SELECT id, 'active', 'initial'
FROM usr.user_account
WHERE ext_id = 'user_001'
  AND NOT EXISTS (
    SELECT 1 FROM usr.user_status
    WHERE user_id = (SELECT id FROM usr.user_account WHERE ext_id = 'user_001')
      AND status = 'active' AND note = 'initial'
  );

-- user_002 -> inactive
INSERT INTO usr.user_status (user_id, status, note)
SELECT id, 'inactive', 'seeded'
FROM usr.user_account
WHERE ext_id = 'user_002'
  AND NOT EXISTS (
    SELECT 1 FROM usr.user_status
    WHERE user_id = (SELECT id FROM usr.user_account WHERE ext_id = 'user_002')
      AND status = 'inactive' AND note = 'seeded'
  );

-- user_003 -> banned
INSERT INTO usr.user_status (user_id, status, note)
SELECT id, 'banned', 'seeded'
FROM usr.user_account
WHERE ext_id = 'user_003'
  AND NOT EXISTS (
    SELECT 1 FROM usr.user_status
    WHERE user_id = (SELECT id FROM usr.user_account WHERE ext_id = 'user_003')
      AND status = 'banned' AND note = 'seeded'
  );
COMMIT;