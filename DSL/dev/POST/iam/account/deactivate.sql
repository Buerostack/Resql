-- param1: ext_id, param2: note
INSERT INTO iam.account_status (ext_id, status, note)
VALUES (:ext_id, 'inactive', COALESCE(:note, 'manual'))
RETURNING ext_id, status, note, set_at;