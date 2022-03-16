-- Create a tablespace for the APEX installation (doesn't need much space)
create tablespace apextbsp212
datafile 'apextbsp212.dbf'
size 2G
autoextend on;