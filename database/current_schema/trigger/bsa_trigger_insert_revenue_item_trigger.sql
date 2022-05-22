
  CREATE OR REPLACE EDITIONABLE TRIGGER "DEV_WS"."BSA_TRIGGER_INSERT_REVENUE_ITEM" 
    after INSERT on bsa_revenue_item
    FOR EACH ROW
    BEGIN 
        
        INSERT INTO bsa_audit_log (logDate, logTable, project_id, operation, description)
        VALUES (CURRENT_DATE, 'Revenue Item', :new.project_id, 'Create', 'Name=' || :new.name || ', Description=' || :new.description || ', SalePrice=' || :new.saleprice ||
            ', Platform=' || :new.platformsoldon || ', IsPending=' || :new.ispending);
    END;
ALTER TRIGGER "DEV_WS"."BSA_TRIGGER_INSERT_REVENUE_ITEM" ENABLE