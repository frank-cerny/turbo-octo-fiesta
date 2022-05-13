
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

    
    
    procedure bsa_func_split_tools_over_projects (toolIdString IN varchar2, projectIdString IN varchar2)
    IS
        projectIdList apex_t_varchar2;
        toolIdList apex_t_varchar2;
    BEGIN
        
        projectIdList := apex_string.split(projectIdString, ':');
        toolIdList := apex_string.split(toolIdString, ':');
        
        if projectIdList.count = 0 or toolIdList.count = 0 then
            return;
        end if;
        
        for i in 1 .. projectIdList.count loop
            for j in 1 .. toolIdList.count loop
                
                INSERT INTO bsa_view_project_tool (tool_id, name, ToolDescription, datepurchased, totalcost, unitcost, project_id)
                        VALUES (TO_NUMBER(toolIdList(j)), NULL, NULL, NULL, NULL, NULL, TO_NUMBER(projectIdList(i)));
            end loop;
        end loop;
    END;
end tool_utilities;