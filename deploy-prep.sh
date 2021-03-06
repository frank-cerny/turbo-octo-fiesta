#!/bin/bash

# Performs commands related to exporting the current application state in preparation for build/deploy steps

ROOT_DIR="$PWD"
APP_EXPORT_DIR="$ROOT_DIR/app"
SCHEMA_EXPORT_DIR="$ROOT_DIR/database/current_schema/"
DB_IP="192.168.0.81"
DB_PORT="45001"
USER_DB_PASSWORD="dev_ws"

echo "Exporting Current Schema"
cd "$SCHEMA_EXPORT_DIR"
sql -s /nolog <<EOF
CONNECT dev_ws/$USER_DB_PASSWORD@$DB_IP:$DB_PORT/XEPDB1
lb genschema -sql -split -dir .
EOF

echo "Cleaning Current Schema (Remove *.xml files)"
rm -rf "$SCHEMA_EXPORT_DIR"/**/*.xml

# We use the single file export because I have yet to get the split version of the export to properly import into a new workspace
echo "Exporting Application (Single File) to f100.xml (Cleaning first)"
cd "$APP_EXPORT_DIR/deploy"
# We need to remove first to ensure "old" values are not kept in update (since updates don't remove, only append)
rm f100.xml
sql -s /nolog <<EOF
CONNECT dev_ws/$USER_DB_PASSWORD@$DB_IP:$DB_PORT/XEPDB1
lb genobject -type apex -applicationid 100 -skipExportDate -expOriginalIds -expACLAssignments -dir .
EOF

# We use the single file export because I have yet to get the split version of the export to properly import into a new workspace
echo "Exporting Application Source to Diffable Directory"
cd "$APP_EXPORT_DIR/src"
sql -s /nolog <<EOF
CONNECT dev_ws/$USER_DB_PASSWORD@$DB_IP:$DB_PORT/XEPDB1
lb genobject -type apex -applicationid 100 -skipExportDate -expOriginalIds -expACLAssignments -split -dir .
EOF