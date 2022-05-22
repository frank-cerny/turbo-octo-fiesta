
  CREATE OR REPLACE EDITIONABLE TRIGGER "DEV_WS"."BSA_TRIGGER_AFTER_UPDATE_TOOL" 
    after UPDATE on bsa_project_tool
    FOR EACH ROW
    DECLARE
        toolName varchar2(100);
    BEGIN 
        -- We are only given the supply id, project id, and quantity on insert/update/delete, so we need to get the supply name
        SELECT t.name 
        INTO toolName 
        FROM bsa_tool t
        WHERE id = :new.tool_id;
        -- Now insert in the logs
        INSERT INTO bsa_audit_log (logDate, logTable, project_id, operation, description)
        VALUES (CURRENT_DATE, 'Tool Mapping', :new.project_id, 'Update', 'Name=' || toolName || ', Quantity=' || :new.quantity);
    END;

ALTER TRIGGER "DEV_WS"."BSA_TRIGGER_AFTER_UPDATE_TOOL" ENABLE