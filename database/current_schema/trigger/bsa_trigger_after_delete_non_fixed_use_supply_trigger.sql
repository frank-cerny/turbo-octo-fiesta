
  CREATE OR REPLACE EDITIONABLE TRIGGER "DEV_WS"."BSA_TRIGGER_AFTER_DELETE_NON_FIXED_USE_SUPPLY" 
    after DELETE on bsa_project_non_fixed_quantity_supply
    FOR EACH ROW
    DECLARE
        supplyName varchar2(100);
    BEGIN 
        
        SELECT nfus.name 
        INTO supplyName 
        FROM bsa_non_fixed_quantity_supply nfus
        WHERE id = :old.supply_id;
        
        INSERT INTO bsa_audit_log (logDate, logTable, project_id, operation, description)
        VALUES (CURRENT_DATE, 'Non-Fixed Use Supply Mapping', :old.project_id, 'Delete', 'Name=' || supplyName);
    END;
ALTER TRIGGER "DEV_WS"."BSA_TRIGGER_AFTER_DELETE_NON_FIXED_USE_SUPPLY" ENABLE