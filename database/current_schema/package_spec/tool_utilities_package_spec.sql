
  CREATE OR REPLACE EDITIONABLE PACKAGE "FRANKCERNY"."TOOL_UTILITIES" 
as 
    function bsa_func_get_tool_total_usage (toolId IN int)
    return number;
end tool_utilities;