#!/bin/bash
# update-app.sh
# Based on the directroy structure of the application, deploy all changes by using the liquibase change logs

ROOT_DIR="$PWD"
SECURITY_ID_SCRIPT_DIRECTORY="$ROOT_DIR/etc/"
LOGIC_CHANGELOG_DIRECTORY="$ROOT_DIR/database/logic/"
SCHEMA_CHANGELOG_DIRECTORY="$ROOT_DIR/database/schema_updates/"
TEST_CHANGELOG_DIRECTORY="$ROOT_DIR/tests/"
APP_INSTALL_CHANGELOG_DIRECTORY="$ROOT_DIR/app/deploy/"
DB_IP="192.168.0.81"
DB_PORT="45001"
DB_PASSWORD="Passw0rd1"

printf "/etc Path: $SECURITY_ID_SCRIPT_DIRECTORY\n"
printf "Logic Changelog Dir: $LOGIC_CHANGELOG_DIRECTORY\n"
printf "Schema Changelog Dir: $SCHEMA_CHANGELOG_DIRECTORY\n"
printf "Test Changelog Dir: $TEST_CHANGELOG_DIRECTORY\n"
printf "App Install Dir: $APP_INSTALL_CHANGELOG_DIRECTORY\n"

# Run pre-step which sets the security id of the instance based on the workspace id (not sure why this is needed)
echo "Updating Security Flow ID (Pre-Req)"
cd $SECURITY_ID_SCRIPT_DIRECTORY
sql -s /nolog <<EOF
CONNECT sys@$DB_IP:$DB_PORT/XEPDB1 as sysdba
$DB_PASSWORD
@pre-deploy.sql
EOF

# Run the logic changelog
echo "Updating Logic"
cd $LOGIC_CHANGELOG_DIRECTORY
sql -s /nolog <<EOF
CONNECT sys@$DB_IP:$DB_PORT/XEPDB1 as sysdba
$DB_PASSWORD
liquibase update -changelog controller.xml
EOF

# Run the schema changelog
echo "Updating Schema"
cd $SCHEMA_CHANGELOG_DIRECTORY
sql -s /nolog <<EOF
CONNECT sys@$DB_IP:$DB_PORT/XEPDB1 as sysdba
$DB_PASSWORD
liquibase update -changelog controller.xml
EOF

# Run the test changelog
echo "Updating Tests"
cd $TEST_CHANGELOG_DIRECTORY
sql -s /nolog <<EOF
CONNECT sys@$DB_IP:$DB_PORT/XEPDB1 as sysdba
$DB_PASSWORD
liquibase update -changelog controller.xml
EOF

# Give permission to ut3 to dev_ws schema
echo "Giving Schema Permissiont to UT3 and Adding Sample Data"
cd $SECURITY_ID_SCRIPT_DIRECTORY
sql -s /nolog <<EOF
CONNECT sys@$DB_IP:$DB_PORT/XEPDB1 as sysdba
$DB_PASSWORD
@ut3_permission_grants.sql
@sample_data.sql
EOF

# Run the application install
echo "Installing Application"
cd $TEST_CHANGELOG_DIRECTORY
sql -s /nolog <<EOF
CONNECT sys@$DB_IP:$DB_PORT/XEPDB1 as sysdba
$DB_PASSWORD
liquibase update -changelog f100.xml
EOF