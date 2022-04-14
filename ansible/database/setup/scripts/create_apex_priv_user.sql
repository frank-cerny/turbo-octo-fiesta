-- Create an admin to manage the APEX instance (a bit overkill for now)
CREATE USER apex_priv_user IDENTIFIED BY apex_priv_user QUOTA UNLIMITED ON users;
GRANT DBA, APEX_ADMINISTRATOR_ROLE TO apex_priv_user;
