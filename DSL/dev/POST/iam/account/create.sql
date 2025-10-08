-- ext_id: ext_id, email: email, display_name: display_name
WITH ins_acc AS (
  INSERT INTO iam.account (ext_id, email, display_name)
  VALUES (:ext_id, :email, :display_name)
  ON CONFLICT (ext_id) DO NOTHING
  RETURNING ext_id
), ins_status AS (
  INSERT INTO iam.account_status (ext_id, status, note)
  SELECT :ext_id, 'active', 'created'
  WHERE NOT EXISTS (
    SELECT 1 FROM iam.account_status
    WHERE ext_id = :ext_id AND status = 'active' AND note = 'created'
  )
  RETURNING 1
)
SELECT ext_id, email, display_name, created_at
FROM iam.account
WHERE ext_id = :ext_id
LIMIT 1;
