declare
l_workspace_id number;
begin
l_workspace_id := apex_util.find_security_group_id (p_workspace => '<strong>DEV_WS</strong>');
apex_util.set_security_group_id (p_security_group_id => l_workspace_id);
APEX_UTIL.PAUSE(2);
end;
/