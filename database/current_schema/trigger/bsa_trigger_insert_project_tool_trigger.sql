
  CREATE OR REPLACE EDITIONABLE TRIGGER "DEV_WS"."BSA_TRIGGER_INSERT_PROJECT_TOOL" 
    instead of INSERT on bsa_view_project_tool
    FOR EACH ROW
    DECLARE
        quantity number;
        totalUsages number;
    BEGIN 
        
        BEGIN
        
        
        SELECT pj.quantity into quantity FROM BSA_PROJECT_TOOL pj WHERE project_id = :new.project_id AND tool_id = :new.tool_id;
        EXCEPTION
            WHEN no_data_found
            THEN
                quantity := 0;
        END;
        IF quantity > 0 THEN
            UPDATE BSA_PROJECT_TOOL pj
            SET pj.quantity = quantity + 1
            WHERE project_id = :new.project_id AND tool_id = :new.tool_id;
        ELSE
            
            insert into bsa_project_tool (project_id, tool_id, quantity)
            values(:new.project_id, :new.tool_id, 1);
        END IF;
    END;
ALTER TRIGGER "DEV_WS"."BSA_TRIGGER_INSERT_PROJECT_TOOL" ENABLE