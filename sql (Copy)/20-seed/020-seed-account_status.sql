BEGIN;
INSERT INTO iam.account_status (ext_id, status, note)
SELECT 'user_001', 'active', 'seed' WHERE NOT EXISTS (
  SELECT 1 FROM iam.account_status WHERE ext_id='user_001' AND status='active' AND note='seed'
);
INSERT INTO iam.account_status (ext_id, status, note)
SELECT 'user_002', 'inactive', 'seed' WHERE NOT EXISTS (
  SELECT 1 FROM iam.account_status WHERE ext_id='user_002' AND status='inactive' AND note='seed'
);
COMMIT;