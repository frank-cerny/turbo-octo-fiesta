#!/bin/bash

# Update Workspace Admin Password
echo "Updating Workspace Admin Account (INSADMIN)"

# Update working directory
cd "../../apex/"

sqlplus -s /nolog <<EOF
CONNECT / as sysdba;
alter session set container=XEPDB1;
@apxchpwd.sql 
INSADMIN
INSADMIN@localhost.com
Passw0rd1!
EOF

echo "Great start. Picking up after this..."
exit

# Unlock the APEX_PUBLIC_USER account
ALTER USER APEX_PUBLIC_USER ACCOUNT UNLOCK
ALTER USER APEX_PUBLIC_USER IDENTIFIED BY new_password

# Create a default APEX workspace
# TODO

# Print out information to use
# TODO
