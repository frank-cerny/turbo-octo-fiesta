#!/bin/bash

# Perform pre-setup instructions (PGA/SGA memory requirements; 1600M is a guess based on installing the database manually)
echo "Updating PGA/SGA memory requirements before installing APEX"
sqlplus -s /nolog << EOF
CONNECT / as sysdba;

whenever sqlerror exit sql.sqlcode;
set echo off 
set heading off

ALTER SYSTEM SET MEMORY_TARGET = 1600M SCOPE = SPFILE;
ALTER SYSTEM SET MEMORY_MAX_TARGET = 1600M SCOPE = SPFILE;
SHUTDOWN IMMEDIATE;
EOF

echo "Sleeping for 5 seconds before attempting to start the database again"
sleep 5

sqlplus -s /nolog << EOF
CONNECT / as sysdba;
Startup
exit
EOF

# Create an APEX tablespace for install
echo "Creating APEX tablespace"
sqlplus -s /nolog << EOF
CONNECT / as sysdba;
alter session set container=XEPDB1;
create tablespace apextbsp212
datafile 'apextbsp212.dbf'
size 2G
autoextend on;
EOF
