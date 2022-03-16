# TODO (apexremov.sql should do the trick)

# Remove APEX
echo "Removing APEX from XEPDB1"
sqlplus -s /nolog << EOF
CONNECT / as sysdba;
alter session set container=XEPDB1;
@../../apex/apexremov.sql 
EOF

# Delete the Apex tablespace