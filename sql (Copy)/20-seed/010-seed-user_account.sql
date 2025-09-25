BEGIN;
-- Idempotent inserts using INSERT ... SELECT ... WHERE NOT EXISTS (only INSERT + SELECT)
INSERT INTO usr.user_account (ext_id, metadata)
SELECT 'user_001', '{"note":"Seed user 1"}'::jsonb
WHERE NOT EXISTS (SELECT 1 FROM usr.user_account WHERE ext_id = 'user_001');

INSERT INTO usr.user_account (ext_id, metadata)
SELECT 'user_002', '{"note":"Seed user 2"}'::jsonb
WHERE NOT EXISTS (SELECT 1 FROM usr.user_account WHERE ext_id = 'user_002');

INSERT INTO usr.user_account (ext_id, metadata)
SELECT 'user_003', '{"note":"Seed user 3"}'::jsonb
WHERE NOT EXISTS (SELECT 1 FROM usr.user_account WHERE ext_id = 'user_003');
COMMIT;