-- Create a tablespace for the ORDS installation (doesn't need much space)
create tablespace ords
datafile ‘ordstbls.dbf’
size 2G
autoextend on;