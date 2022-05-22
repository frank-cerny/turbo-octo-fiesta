
  CREATE OR REPLACE EDITIONABLE TRIGGER "DEV_WS"."BSA_TRIGGER_AFTER_DELETE_TOOL" 
    after DELETE on bsa_project_tool
    FOR EACH ROW
    DECLARE
        toolName varchar2(100);
    BEGIN 
        
        SELECT t.name 
        INTO toolName 
        FROM bsa_tool t
        WHERE id = :old.tool_id;
        
        INSERT INTO bsa_audit_log (logDate, logTable, project_id, operation, description)
        VALUES (CURRENT_DATE, 'Tool Mapping', :old.project_id, 'Delete', 'Name=' || toolName);
    END;
ALTER TRIGGER "DEV_WS"."BSA_TRIGGER_AFTER_DELETE_TOOL" ENABLE