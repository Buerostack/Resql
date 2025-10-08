BEGIN;
INSERT INTO iam.account (ext_id, email, display_name)
SELECT 'user_001', 'alice@example.com', 'Alice' WHERE NOT EXISTS (SELECT 1 FROM iam.account WHERE ext_id='user_001');
INSERT INTO iam.account (ext_id, email, display_name)
SELECT 'user_002', 'bob@example.com',   'Bob'   WHERE NOT EXISTS (SELECT 1 FROM iam.account WHERE ext_id='user_002');
COMMIT;