
  CREATE OR REPLACE EDITIONABLE TRIGGER "DEV_WS"."BSA_TRIGGER_UPDATE_PROJECT_FIXED_SUPPLY" 
    instead of UPDATE on bsa_view_project_fixed_supply
    FOR EACH ROW
    DECLARE
        unitsRemaining number;
        BSA_NEGATIVE_FUS EXCEPTION;
        PRAGMA EXCEPTION_INIT(BSA_NEGATIVE_FUS, -20001);
    BEGIN 
        
        unitsremaining := fsu.bsa_func_get_fixed_supply_units_remaining(:new.supply_id);
        IF (unitsRemaining - :new.quantity) < 0 THEN
            raise_application_error(-20001, 'Fixed Use Supply Units Remaining Would be Non-Zero After Operation');
        END IF;
        
        UPDATE bsa_project_fixed_quantity_supply
        SET quantity = :new.quantity
        WHERE project_id = :new.project_id AND supply_id = :new.supply_id;
    END;

ALTER TRIGGER "DEV_WS"."BSA_TRIGGER_UPDATE_PROJECT_FIXED_SUPPLY" ENABLE