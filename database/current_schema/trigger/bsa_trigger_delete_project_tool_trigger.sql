
  CREATE OR REPLACE EDITIONABLE TRIGGER "FRANKCERNY"."BSA_TRIGGER_DELETE_PROJECT_TOOL" 
    instead of DELETE on bsa_view_project_tool
    FOR EACH ROW
    BEGIN 
        DELETE 
        FROM bsa_project_tool
        WHERE project_id = :old.project_id AND tool_id = :old.tool_id;
    END;
ALTER TRIGGER "FRANKCERNY"."BSA_TRIGGER_DELETE_PROJECT_TOOL" ENABLE