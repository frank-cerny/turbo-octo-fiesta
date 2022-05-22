
  CREATE OR REPLACE EDITIONABLE TRIGGER "DEV_WS"."BSA_TRIGGER_DELETE_SINGLE_USE_SUPPLY" 
    after DELETE on bsa_single_use_supply
    FOR EACH ROW
    BEGIN 
        INSERT INTO bsa_audit_log (logDate, logTable, project_id, operation, description)
        VALUES (CURRENT_DATE, 'Single Use Supply', :old.project_id, 'Delete', 'Name=' || :old.name);
    END;
ALTER TRIGGER "DEV_WS"."BSA_TRIGGER_DELETE_SINGLE_USE_SUPPLY" ENABLE