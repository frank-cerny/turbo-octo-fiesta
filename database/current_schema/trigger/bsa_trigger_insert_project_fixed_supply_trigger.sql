
  CREATE OR REPLACE EDITIONABLE TRIGGER "DEV_WS"."BSA_TRIGGER_INSERT_PROJECT_FIXED_SUPPLY" 
    instead of INSERT on bsa_view_project_fixed_supply
    FOR EACH ROW
    DECLARE
        quantity number;
    BEGIN 
        
        BEGIN
        
        
        SELECT pj.quantity into quantity FROM bsa_project_fixed_quantity_supply pj WHERE project_id = :new.project_id AND supply_id = :new.supply_id;
        EXCEPTION
            WHEN no_data_found
            THEN
                quantity := 0;
        END;
        IF quantity > 0 THEN
            UPDATE bsa_project_fixed_quantity_supply pj
            SET pj.quantity = quantity + 1
            WHERE project_id = :new.project_id AND supply_id = :new.supply_id;
        ELSE
            
            insert into bsa_project_fixed_quantity_supply (project_id, supply_id, quantity)
            values(:new.project_id, :new.supply_id, 1);
        END IF;
    END;
ALTER TRIGGER "DEV_WS"."BSA_TRIGGER_INSERT_PROJECT_FIXED_SUPPLY" ENABLE