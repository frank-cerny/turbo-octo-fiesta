-- Adds credentials to a workspace (credential must already exit)
-- References
-- 1. Passing parameters from the command line: https://stackoverflow.com/questions/18620893/how-do-i-pass-arguments-to-a-pl-sql-script-on-command-line-with-sqlplus
-- 2. Using PLSQL to add web credentials: https://community.oracle.com/tech/developers/discussion/4496330/migrating-credentials

-- Params
-- &1: app id
-- &2: username
-- &3: credential static id
-- &4: client id
-- &5: client secret

BEGIN 
 apex_session.create_session(
  p_app_id    => &1
  ,p_page_id  => 1
  ,p_username => '&2'
 );

 apex_credential.set_persistent_credentials(
   p_credential_static_id => '&3'
  ,p_client_id     => '&4'
  ,p_client_secret => '&5'
 );
END;
/