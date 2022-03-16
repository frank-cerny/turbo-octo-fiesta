#!/bin/bash

# References: 
# https://docs.oracle.com/en/database/oracle/application-express/21.2/htmig/downloading-installing-apex.html#GUID-B8ACA78B-8483-4786-863C-912659880604
# https://stackoverflow.com/questions/10277983/connect-to-sqlplus-in-a-shell-script-and-run-sql-scripts

# Install APEX (workspace name matches that found in create_apex_tablespace.sql
# The non-interactive version did not work, so we opted for the interactive version instead
echo "Installing APEX into XEPDB1"
sqlplus -s /nolog << EOF
CONNECT /XEPDB1 as sysdba;
alter session set container=XEPDB1;
@../../apex/apexins.sql 
apextbsp212 
apextbsp212 
TEMP 
/i/
EOF