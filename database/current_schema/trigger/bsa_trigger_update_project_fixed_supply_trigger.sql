
  CREATE OR REPLACE EDITIONABLE TRIGGER "DEV_WS"."BSA_TRIGGER_UPDATE_PROJECT_FIXED_SUPPLY" 
    instead of UPDATE on bsa_view_project_fixed_supply
    FOR EACH ROW
    BEGIN 
        UPDATE bsa_project_fixed_quantity_supply
        SET quantity = :new.quantity
        WHERE project_id = :new.project_id AND supply_id = :new.supply_id;
    END;
ALTER TRIGGER "DEV_WS"."BSA_TRIGGER_UPDATE_PROJECT_FIXED_SUPPLY" ENABLE