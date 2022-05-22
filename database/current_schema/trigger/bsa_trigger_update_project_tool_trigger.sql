
  CREATE OR REPLACE EDITIONABLE TRIGGER "DEV_WS"."BSA_TRIGGER_UPDATE_PROJECT_TOOL" 
    instead of UPDATE on bsa_view_project_tool
    FOR EACH ROW
    BEGIN 
        UPDATE bsa_project_tool
        SET quantity = :new.quantity
        WHERE project_id = :new.project_id AND tool_id = :new.tool_id;
    END;
ALTER TRIGGER "DEV_WS"."BSA_TRIGGER_UPDATE_PROJECT_TOOL" ENABLE