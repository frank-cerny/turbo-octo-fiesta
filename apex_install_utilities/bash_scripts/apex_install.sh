#!/bin/bash

# References: 
# https://docs.oracle.com/en/database/oracle/application-express/21.2/htmig/downloading-installing-apex.html#GUID-B8ACA78B-8483-4786-863C-912659880604
# https://stackoverflow.com/questions/10277983/connect-to-sqlplus-in-a-shell-script-and-run-sql-scripts

# Install APEX (workspace name matches that found in create_apex_tablespace.sql
# In order we must pass 
# 1. APEX User tablespace
# 2. APEX Files user tablespace
# 3. Temp tablespace
# 4. images directory (/i/)
# 5. APEX public user password
# 6. APEX listener password
# 7. APEX Rest public user password
# 8. APEX internal admin password
# This will install APEX, add an instance admin, configure the public user, enable network services, and configure static file support
echo "Installing APEX into XEPDB1"
sqlplus -s /nolog << EOF
CONNECT / as sysdba;
alter session set container=XEPDB1;
@apxsilentins.sql 
apextbsp212 
apextbsp212 
TEMP
/i/
Passw0rd!
Passw0rd!
Passw0rd!
Passw0rd!
EOF