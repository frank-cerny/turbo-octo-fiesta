#!/bin/bash
# Adds credentials to a workspace (credential must already exit)

# TODO (need to take a LOT of command line params)

BEGIN 
 apex_session.create_session(
  p_app_id    => 100
  ,p_page_id  => 1
  ,p_username => 'dev'
 );

 apex_credential.set_persistent_credentials(
   p_credential_static_id => 'Okta'
  ,p_client_id     => '123456'
  ,p_client_secret => 'heythere'
 );
END;
/