
  CREATE OR REPLACE EDITIONABLE TRIGGER "DEV_WS"."BSA_TRIGGER_DELETE_REVENUE_ITEM" 
    after DELETE on bsa_revenue_item
    FOR EACH ROW
    BEGIN 
        INSERT INTO bsa_audit_log (logDate, logTable, project_id, operation, description)
        VALUES (CURRENT_DATE, 'Revenue Item', :old.project_id, 'Delete', 'Name=' || :old.name);
    END;
ALTER TRIGGER "DEV_WS"."BSA_TRIGGER_DELETE_REVENUE_ITEM" ENABLE