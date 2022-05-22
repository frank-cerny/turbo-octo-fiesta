
  CREATE OR REPLACE EDITIONABLE TRIGGER "DEV_WS"."BSA_TRIGGER_AFTER_INSERT_TOOL" 
    after INSERT on bsa_project_tool
    FOR EACH ROW
    DECLARE
        toolName varchar2(100);
    BEGIN 
        
        SELECT t.name 
        INTO toolName 
        FROM bsa_tool t
        WHERE id = :new.tool_id;
        
        INSERT INTO bsa_audit_log (logDate, logTable, project_id, operation, description)
        VALUES (CURRENT_DATE, 'Tool Mapping', :new.project_id, 'Create', 'Name=' || toolName || ', Quantity=' || :new.quantity);
    END;
ALTER TRIGGER "DEV_WS"."BSA_TRIGGER_AFTER_INSERT_TOOL" ENABLE