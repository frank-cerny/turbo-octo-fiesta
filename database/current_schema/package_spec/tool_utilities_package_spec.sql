
  CREATE OR REPLACE EDITIONABLE PACKAGE "DEV_WS"."TOOL_UTILITIES" 
as 
    function bsa_func_get_tool_total_usage (toolId IN int)
    return number;
    function bsa_func_get_tool_unit_cost (toolId IN int)
    return number;
end tool_utilities;
