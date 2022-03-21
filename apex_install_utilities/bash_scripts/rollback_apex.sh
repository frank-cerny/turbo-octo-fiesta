# Remove APEX
echo "Removing APEX from XEPDB1"
sqlplus -s /nolog << EOF
CONNECT / as sysdba;
alter session set container=XEPDB1;
@apxremov.sql 
EOF

# Delete the Apex tablespace
# Reference: https://docs.oracle.com/cd/B19306_01/server.102/b14200/statements_9004.htm
echo "Removing the APEX tablespace"
sqlplus -s /nolog << EOF
CONNECT / as sysdba;
alter session set container=XEPDB1;
DROP tablespace apextbsp212
INCLUDING contents and datafiles
CASCADE constraints;
EOF