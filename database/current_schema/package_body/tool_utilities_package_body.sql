
  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "DEV_WS"."TOOL_UTILITIES" 
as
    
    
    function bsa_func_get_tool_total_usage (toolId IN int)
    RETURN number
    AS
        totalUsages number;
        BEGIN
            
            select COALESCE(sum(quantity), 0) into totalUsages 
            from bsa_project_tool
            where tool_id = toolId;
            return totalUsages;
        END;

    function bsa_func_get_tool_unit_cost (toolId IN int)
    RETURN number
    AS
        totalUsages number;
        totalCost number;
        
        unitCost number(10,2);
        BEGIN
            
            totalUsages := bsa_func_get_tool_total_usage(toolId);
            if totalUsages = 0 THEN
                return null;
            END IF;
            
            select totalCost into totalCost from bsa_tool where Id = toolId;
            unitCost := totalCost/totalUsages;
            return unitCost;
        END;
end tool_utilities;