
  CREATE OR REPLACE EDITIONABLE TRIGGER "DEV_WS"."BSA_TRIGGER_UPDATE_SINGLE_USE_SUPPLY" 
    after UPDATE on bsa_single_use_supply
    FOR EACH ROW
    BEGIN 
        -- The log is the same as create
        INSERT INTO bsa_audit_log (logDate, logTable, project_id, operation, description)
        VALUES (CURRENT_DATE, 'Single Use Supply', :new.project_id, 'Update', 'Name=' || :new.name || ', Description=' || :new.description || ', UnitCost=' || :new.unitcost ||
            ', UnitsPurchased=' || :new.unitspurchased || ', IsPending=' || :new.ispending);
    END;

ALTER TRIGGER "DEV_WS"."BSA_TRIGGER_UPDATE_SINGLE_USE_SUPPLY" ENABLE