
  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "FRANKCERNY"."TOOL_UTILITIES" 
as
    
    
    function bsa_func_get_tool_total_usage (toolId IN int)
    RETURN number
    AS
        totalUsages number := 0;
        BEGIN
            select sum(quantity) into totalUsages 
            from bsa_project_tool bpt
            where toolId = tool_id;
            return totalUsages;
        END;
end tool_utilities;