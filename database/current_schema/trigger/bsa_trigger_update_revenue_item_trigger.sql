
  CREATE OR REPLACE EDITIONABLE TRIGGER "DEV_WS"."BSA_TRIGGER_UPDATE_REVENUE_ITEM" 
    after UPDATE on bsa_revenue_item
    FOR EACH ROW
    BEGIN 
        -- The log is the same as create
        INSERT INTO bsa_audit_log (logDate, logTable, project_id, operation, description)
        VALUES (CURRENT_DATE, 'Revenue Item', :new.project_id, 'Update', 'Name=' || :new.name || ', Description=' || :new.description || ', SalePrice=' || :new.saleprice ||
            ', Platform=' || :new.platformsoldon || ', IsPending=' || :new.ispending);
    END;

ALTER TRIGGER "DEV_WS"."BSA_TRIGGER_UPDATE_REVENUE_ITEM" ENABLE