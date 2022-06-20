
  CREATE OR REPLACE EDITIONABLE PACKAGE "DEV_WS"."PROJECT_UTILITIES" 
as 
    function bsa_func_calculate_net_project_value(projectId IN int)
    return number;
    function bsa_func_return_project_name_string_from_ids (projectIdString IN varchar2)
    return varchar2;
    function bsa_func_return_bike_cost_for_project(projectId IN int)
    return number;
    function bsa_func_return_single_use_supply_cost_for_project(projectId IN int)
    return number;
    function bsa_func_return_tool_cost_for_project(projectId IN int)
    return number;
    function bsa_func_return_revenue_for_project(projectId IN int)
    return number;
    function bsa_func_return_fixed_supply_cost_for_project(projectId IN int)
    return number;
    function bsa_func_return_non_fixed_supply_cost_for_project(projectId IN int)
    return number;
end project_utilities;
