
  CREATE OR REPLACE EDITIONABLE TRIGGER "DEV_WS"."BSA_TRIGGER_INSERT_PROJECT_FIXED_SUPPLY" 
    instead of INSERT on bsa_view_project_fixed_supply
    FOR EACH ROW
    DECLARE
        quantity number;
        unitsRemaining number;
        -- Reference: https://www.oracletutorial.com/plsql-tutorial/plsql-raise/
        BSA_NEGATIVE_FUS EXCEPTION;
        PRAGMA EXCEPTION_INIT(BSA_NEGATIVE_FUS, -20001);
    BEGIN 
        BEGIN
        -- First determine if the quantity of the fixed use supply is 0 (if so, we cannot insert and an exception should be thrown)
        unitsRemaining := fsu.bsa_func_get_fixed_supply_units_remaining(:new.supply_id);
        IF unitsRemaining = 0 THEN
            raise_application_error(-20001, 'Fixed Use Supply Units Remaining Would be Non-Zero After Operation');
        END IF;
        -- SELECT INTO cannot handle empty result sets, so we can catch the exception it throws
        -- Reference: https://stackoverflow.com/questions/12080428/unable-to-select-into-when-value-doesnt-exist
        SELECT pj.quantity into quantity FROM bsa_project_fixed_quantity_supply pj WHERE project_id = :new.project_id AND supply_id = :new.supply_id;
        -- Using a nested exception as I could not get not-nested to work: https://stackoverflow.com/questions/1256112/pl-sql-block-problem-no-data-found-error
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
            -- Insert into the join table (project/tool already exist!) (update quantity if it exists)
            insert into bsa_project_fixed_quantity_supply (project_id, supply_id, quantity)
            values(:new.project_id, :new.supply_id, 1);
        END IF;
    END;

ALTER TRIGGER "DEV_WS"."BSA_TRIGGER_INSERT_PROJECT_FIXED_SUPPLY" ENABLE