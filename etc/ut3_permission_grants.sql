-- test_permission_handerl.sql
-- Gives the proper permissions to a testing user to access schema for performing unit tests

set serveroutput on size unlimited
declare
	l_priv varchar2(30);
begin
	for r_object in
	(
		select object_name, object_type
		from dba_objects
		where owner = 'DEV_WS'
		and object_type in ('PACKAGE', 'PROCEDURE', 'SEQUENCE', 'TABLE', 'VIEW', 'FUNCTION')
	)
	loop
		l_priv :=
		case r_object.object_type
			when 'PACKAGE' then 'EXECUTE'
			when 'PROCEDURE' then 'EXECUTE'
            when 'FUNCTION' then 'EXECUTE'
			when 'TABLE' then 'ALL'
			else 'SELECT'
		end;
		dbms_output.put_line('Granting '||l_priv||' on '||r_object.object_name);
		execute immediate 'grant '||l_priv||' on DEV_WS.'||r_object.object_name||' to UT3';
	end loop;
end;
/