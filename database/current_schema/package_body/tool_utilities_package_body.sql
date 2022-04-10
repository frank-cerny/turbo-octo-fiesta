
  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "DEV_WS"."TOOL_UTILITIES" 
as
    
    
    function bsa_func_get_tool_total_usage (toolId IN int)
    RETURN number
    AS
        totalUsages number;
        BEGIN
            
            select COALESCE(sum(quantity), 0) into totalUsages 
            from bsa_project_tool
            where toolId = tool_id;
            return totalUsages;
        END;
end tool_utilities;