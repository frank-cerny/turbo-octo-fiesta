#!/bin/bash

# Update test code within the database

ROOT_DIR="$PWD"
DB_IP="192.168.0.81"
DB_PORT="45001"
SYS_DB_PASSWORD="Passw0rd1"
USER_DB_PASSWORD="dev_ws"
SECURITY_ID_SCRIPT_DIRECTORY="$ROOT_DIR/etc/"
TEST_CHANGELOG_DIRECTORY="$ROOT_DIR/tests/"

# Run the test changelog
echo "Updating Tests"
cd $TEST_CHANGELOG_DIRECTORY
sql -s /nolog <<EOF
CONNECT dev_ws/$USER_DB_PASSWORD@$DB_IP:$DB_PORT/XEPDB1
liquibase update -changelog controller.xml
EOF

# Give permission to ut3 to dev_ws schema (in case something has changed)
echo "Giving Schema Permission to UT3"
cd $SECURITY_ID_SCRIPT_DIRECTORY
sql -s /nolog <<EOF
CONNECT sys/$SYS_DB_PASSWORD@$DB_IP:$DB_PORT/XEPDB1 as sysdba
@ut3_permission_grants.sql
EOF