#!/bin/bash
# update-app.sh
# Based on the directroy structure of the application, deploy all changes by using the liquibase change logs
# References:
# 1. How to run SQLcl in non-interactive mode: https://stackoverflow.com/questions/64350609/how-to-make-oracle-sqlplus-command-line-utility-non-interactive

ROOT_DIR="$PWD"
SECURITY_ID_SCRIPT_DIRECTORY="$ROOT_DIR/etc/"
LOGIC_CHANGELOG_DIRECTORY=""
SCHEMA_CHANGELOG_DIRECTORY=""
TEST_CHANGELOG_DIRECTORY=""
APP_INSTALL_CHANGELOG_DIRECTORY=""
DB_IP="192.168.0.81"
DB_PORT="45001"
DB_PASSWORD="Passw0rd!"

printf "/etc Path: $SECURITY_ID_SCRIPT_DIRECTORY\n"
printf "Logic Changelog Dir: $LOGIC_CHANGELOG_DIRECTORY\n"
printf "Schema Changelog Dir: $SCHEMA_CHANGELOG_DIRECTORY\n"
printf "Test Changelog Dir: $TEST_CHANGELOG_DIRECTORY\n"
printf "App Install Dir: $APP_INSTALL_CHANGELOG_DIRECTORY\n"

# Run pre-step which sets the security id of the instance based on the workspace id (not sure why this is needed)
cd $SECURITY_ID_SCRIPT_DIRECTORY
sql -s /nolog <<EOF
whenever sqlerror exit sql.sqlcode
CONNECT sys/$DB_PASSWORD@$DB_IP:$DB_PORT/XEPDB1 as sysdba
@pre-deploy.sql
EOF

# Run the logic changelog

# Run the schema changelog

# Run the test changelog

# Run the application install