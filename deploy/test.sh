#!/bin/bash

sqlplus -s /nolog <<EOF
CONNECT dev_ws/$USER_DB_PASSWORD@$DB_IP:$DB_PORT/XEPDB1
liquibase update -changelog controller.xml
EOF