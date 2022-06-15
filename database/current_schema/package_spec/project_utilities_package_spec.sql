
  CREATE OR REPLACE EDITIONABLE PACKAGE "DEV_WS"."PROJECT_UTILITIES" 
as 
    function bsa_func_calculate_net_project_value(projectId IN int)
    return number;
    function bsa_func_return_project_name_string_from_ids (projectIdString IN varchar2)
    return varchar2;
end project_utilities;