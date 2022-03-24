#!/bin/bash
# update-app.sh
# Based on the directroy structure of the application, deploy all changes by using the liquibase change logs
# References:
# 1. How to run SQLcl in non-interactive mode: https://stackoverflow.com/questions/64350609/how-to-make-oracle-sqlplus-command-line-utility-non-interactive

ROOT_DIR="$PWD"
SECURITY_ID_SCRIPT_DIRECTORY="$ROOT_DIR/etc/"
LOGIC_CHANGELOG_DIRECTORY="$ROOT_DIR/database/logic/"
SCHEMA_CHANGELOG_DIRECTORY="$ROOT_DIR/database/schema_updates/"
TEST_CHANGELOG_DIRECTORY="$ROOT_DIR/tests/"
APP_INSTALL_CHANGELOG_DIRECTORY="$ROOT_DIR/app/deploy/"
DB_IP="192.168.0.81"
DB_PORT="45001"
SYS_DB_PASSWORD="Passw0rd1"
USER_DB_PASSWORD="dev_ws"

printf "/etc Path: $SECURITY_ID_SCRIPT_DIRECTORY\n"
printf "Logic Changelog Dir: $LOGIC_CHANGELOG_DIRECTORY\n"
printf "Schema Changelog Dir: $SCHEMA_CHANGELOG_DIRECTORY\n"
printf "Test Changelog Dir: $TEST_CHANGELOG_DIRECTORY\n"
printf "App Install Dir: $APP_INSTALL_CHANGELOG_DIRECTORY\n"

# Run the schema changelog (must come before logic/test changelogs)
echo "Updating Schema"
cd $SCHEMA_CHANGELOG_DIRECTORY
sql -s /nolog <<EOF
CONNECT dev_ws/$USER_DB_PASSWORD@$DB_IP:$DB_PORT/XEPDB1
liquibase update -changelog controller.xml
EOF

# Run the logic changelog
echo "Updating Logic"
cd $LOGIC_CHANGELOG_DIRECTORY
sql -s /nolog <<EOF
CONNECT dev_ws/$USER_DB_PASSWORD@$DB_IP:$DB_PORT/XEPDB1
liquibase update -changelog controller.xml
EOF

# Run the test changelog
echo "Updating Tests"
cd $TEST_CHANGELOG_DIRECTORY
sql -s /nolog <<EOF
CONNECT dev_ws/$USER_DB_PASSWORD@$DB_IP:$DB_PORT/XEPDB1
liquibase update -changelog controller.xml
EOF

# Give permission to ut3 to dev_ws schema
echo "Giving Schema Permission to UT3"
cd $SECURITY_ID_SCRIPT_DIRECTORY
sql -s /nolog <<EOF
CONNECT sys/$SYS_DB_PASSWORD@$DB_IP:$DB_PORT/XEPDB1 as sysdba
@ut3_permission_grants.sql
EOF

# Add Sample Data to Application
echo "Adding Sample Data To Application"
cd $SECURITY_ID_SCRIPT_DIRECTORY
sql -s /nolog <<EOF
CONNECT dev_ws/$USER_DB_PASSWORD@$DB_IP:$DB_PORT/XEPDB1
@sample_data.sql
EOF

# # Run pre-step which sets the security id of the instance based on the workspace id (not sure why this is needed)
# echo "Updating Security Flow ID (Pre-Req)"
# cd $SECURITY_ID_SCRIPT_DIRECTORY
# sql -s /nolog <<EOF
# CONNECT sys/$SYS_DB_PASSWORD@$DB_IP:$DB_PORT/XEPDB1 as sysdba
# @pre-deploy.sql
# EOF

# Run the application install
echo "Installing Application"
cd $APP_INSTALL_CHANGELOG_DIRECTORY
sql -s /nolog <<EOF
CONNECT dev_ws/$USER_DB_PASSWORD@$DB_IP:$DB_PORT/XEPDB1
@pre-deploy.sql
liquibase update -changelog f100.xml
EOF