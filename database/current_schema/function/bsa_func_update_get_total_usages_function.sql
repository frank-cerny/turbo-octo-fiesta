
  CREATE OR REPLACE EDITIONABLE FUNCTION "FCERNY"."BSA_FUNC_UPDATE_GET_TOTAL_USAGES" (toolId IN int) 
RETURN number 
AS 
    totalUsages number := 0; 
    BEGIN 
        select sum(quantity) into totalUsages  
        from bsa_project_tool bpt 
        where toolId = tool_id; 
        return totalUsages; 
    END; 
/