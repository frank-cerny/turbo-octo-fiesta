
  CREATE OR REPLACE EDITIONABLE TRIGGER "DEV_WS"."BSA_TRIGGER_AFTER_UPDATE_FIXED_USE_SUPPLY" 
    after UPDATE on bsa_project_fixed_quantity_supply
    FOR EACH ROW
    DECLARE
        supplyName varchar2(100);
    BEGIN 
        
        SELECT fus.name 
        INTO supplyName 
        FROM bsa_fixed_quantity_supply fus
        WHERE id = :new.supply_id;
        
        INSERT INTO bsa_audit_log (logDate, logTable, project_id, operation, description)
        VALUES (CURRENT_DATE, 'Fixed Use Supply Mapping', :new.project_id, 'Update', 'Name=' || supplyName || ', Quantity=' || :new.quantity);
    END;
ALTER TRIGGER "DEV_WS"."BSA_TRIGGER_AFTER_UPDATE_FIXED_USE_SUPPLY" ENABLE