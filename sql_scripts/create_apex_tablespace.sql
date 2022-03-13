-- Create a tablespace for the APEX installation (doesn't need much space)
create tablespace apextbsp21-2
datafile ‘apextbsp21-2.dbf’
size 5G
autoextend on;