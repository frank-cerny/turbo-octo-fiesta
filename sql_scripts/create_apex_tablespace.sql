-- Create a tablespace for the APEX installation (doesn't need much space)
create tablespace apextbsp
datafile ‘apextbsp.dbf’
size 5G
autoextend on;