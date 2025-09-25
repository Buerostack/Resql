-- Only SELECTs; quick sanity checks
SELECT 'user_account' AS table_name, COUNT(*) AS rows FROM usr.user_account;
SELECT 'user_status'  AS table_name, COUNT(*) AS rows FROM usr.user_status;
SELECT 'email_registry' AS table_name, COUNT(*) AS rows FROM usr.email_registry;
SELECT 'user_primary_email' AS table_name, COUNT(*) AS rows FROM usr.user_primary_email;
SELECT 'user_session' AS table_name, COUNT(*) AS rows FROM usr.user_session;

-- Peek data (no joins)
SELECT * FROM usr.user_account ORDER BY id;
SELECT * FROM usr.user_status ORDER BY user_id, valid_from DESC;
SELECT * FROM usr.email_registry ORDER BY id;
SELECT * FROM usr.user_primary_email ORDER BY user_id, set_at DESC;
SELECT * FROM usr.user_session ORDER BY user_id, issued_at DESC;