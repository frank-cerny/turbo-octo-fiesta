#!bin/bash

# References: 
# https://docs.oracle.com/en/database/oracle/application-express/21.2/htmig/downloading-installing-apex.html#GUID-B8ACA78B-8483-4786-863C-912659880604
# https://stackoverflow.com/questions/10277983/connect-to-sqlplus-in-a-shell-script-and-run-sql-scripts

# Helper script to install APEX given the path to a zip file directory containing the download

# TODO take directory as CMD argument

# TODO take helper script directory as input param as well

# TODO ensure this is being run by the oracle user, else exit with an error

# Perform pre-setup instructions (PGA/SGA memory requirements; 1600M is a guess based on installing the database manually)
sqlplus -S /nolog << EOF
CONNECT / as sysdba;

whenever sqlerror exit sql.sqlcode;
set echo off 
set heading off

ALTER SYSTEM SET MEMORY_TARGET = 1600M SCOPE = SPFILE;
ALTER SYSTEM SET MEMORY_MAX_TARGET = 1600M SCOPE = SPFILE;
SHUTDOWN IMMEDIATE;
EOF

echo "Sleeping for 5 seconds before attempting to start the database again"
sleep(5)

sqlplus -s /nolog << EOF
CONNECT / as sysdba;
Startup
exit
EOF

# Install APEX (workspace name matches that found in create_apex_tablespace.sql
@apexins.sql APEXTBSP21-2 APEXTBSP21-2 TEMP /i/

# Update Workspace Admin Password
@apxchpwd.sql <<EOF
INSADMIN
Pass0wrd1
INSADMIN@localhost.com
EOF

# Unlock the APEX_PUBLIC_USER account
ALTER USER APEX_PUBLIC_USER ACCOUNT UNLOCK
ALTER USER APEX_PUBLIC_USER IDENTIFIED BY new_password

# Create a default APEX workspace
# TODO

# Print out information to use
# TODO
