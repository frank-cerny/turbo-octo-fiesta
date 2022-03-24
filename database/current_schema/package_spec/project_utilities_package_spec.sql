
  CREATE OR REPLACE EDITIONABLE PACKAGE "DEV_WS"."PROJECT_UTILITIES" 
as 
    function bsa_func_calculate_net_project_value(projectId IN int)
    return number;
end project_utilities;