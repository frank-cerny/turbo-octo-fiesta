
  CREATE OR REPLACE EDITIONABLE PACKAGE "DEV_WS"."TOOL_UTILITIES" 
as 
    function bsa_func_get_tool_total_usage (toolId IN int)
    return number;
    function bsa_func_get_tool_unit_cost (toolId IN int)
    return number;
    procedure bsa_func_split_tools_over_projects(toolIdString IN varchar2, projectIdString IN varchar2);
end tool_utilities;
