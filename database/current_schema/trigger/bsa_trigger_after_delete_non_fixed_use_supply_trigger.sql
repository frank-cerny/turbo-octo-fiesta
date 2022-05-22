
  CREATE OR REPLACE EDITIONABLE TRIGGER "DEV_WS"."BSA_TRIGGER_AFTER_DELETE_NON_FIXED_USE_SUPPLY" 
    after DELETE on bsa_project_non_fixed_quantity_supply
    FOR EACH ROW
    DECLARE
        supplyName varchar2(100);
    BEGIN 
        -- We are only given the supply id, project id, and quantity on insert/update/delete, so we need to get the supply name
        SELECT nfus.name 
        INTO supplyName 
        FROM bsa_non_fixed_quantity_supply nfus
        WHERE id = :old.supply_id;
        -- Now insert in the logs
        INSERT INTO bsa_audit_log (logDate, logTable, project_id, operation, description)
        VALUES (CURRENT_DATE, 'Non-Fixed Use Supply Mapping', :old.project_id, 'Delete', 'Name=' || supplyName);
    END;

ALTER TRIGGER "DEV_WS"."BSA_TRIGGER_AFTER_DELETE_NON_FIXED_USE_SUPPLY" ENABLE