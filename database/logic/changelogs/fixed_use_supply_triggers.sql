--liquibase formatted sql

--changeset fcerny:1 runOnChange:true endDelimiter:"/"
create or replace trigger bsa_trigger_insert_project_fixed_supply
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
/

--changeset fcerny:2 runOnChange:true endDelimiter:"/"
create or replace trigger bsa_trigger_delete_project_fixed_supply
    instead of DELETE on bsa_view_project_fixed_supply
    FOR EACH ROW
    BEGIN 
        DELETE 
        FROM bsa_project_fixed_quantity_supply
        WHERE project_id = :old.project_id AND supply_id = :old.supply_id;
    END;
/

--changeset fcerny:3 runOnChange:true endDelimiter:"/"
create or replace trigger bsa_trigger_update_project_fixed_supply
    instead of UPDATE on bsa_view_project_fixed_supply
    FOR EACH ROW
    DECLARE
        unitsRemaining number;
        BSA_NEGATIVE_FUS EXCEPTION;
        PRAGMA EXCEPTION_INIT(BSA_NEGATIVE_FUS, -20001);
    BEGIN 
        -- First determine if the quantity of the fixed use supply is going to be negative after update (if so, we cannot insert and an exception should be thrown)
        unitsremaining := fsu.bsa_func_get_fixed_supply_units_remaining(:new.supply_id);
        IF (unitsRemaining - :new.quantity) < 0 THEN
            raise_application_error(-20001, 'Fixed Use Supply Units Remaining Would be Non-Zero After Operation');
        END IF;
        -- Otherwise we can safely update the quantity
        UPDATE bsa_project_fixed_quantity_supply
        SET quantity = :new.quantity
        WHERE project_id = :new.project_id AND supply_id = :new.supply_id;
    END;
/

-- Note: We put these triggers on the underlying tables, NOT the view (the view doesn't support after triggers)
--changeset fcerny:4 runOnChange:true endDelimiter:"/"
create or replace trigger bsa_trigger_after_insert_fixed_use_supply
    after INSERT on bsa_project_fixed_quantity_supply
    FOR EACH ROW
    DECLARE
        supplyName varchar2(100);
    BEGIN 
        -- We are only given the supply id, project id, and quantity on insert/update/delete, so we need to get the supply name
        SELECT fus.name 
        INTO supplyName 
        FROM bsa_fixed_quantity_supply fus
        WHERE id = :new.supply_id;
        -- Now insert in the logs
        INSERT INTO bsa_audit_log (logDate, logTable, project_id, operation, description)
        VALUES (CURRENT_DATE, 'Fixed Use Supply Mapping', :new.project_id, 'Create', 'Name=' || supplyName || ', Quantity=' || :new.quantity);
    END;
/

--changeset fcerny:5 runOnChange:true endDelimiter:"/"
create or replace trigger bsa_trigger_after_delete_fixed_use_supply
    after DELETE on bsa_project_fixed_quantity_supply
    FOR EACH ROW
    DECLARE
        supplyName varchar2(100);
    BEGIN 
        -- We are only given the supply id, project id, and quantity on insert/update/delete, so we need to get the supply name
        SELECT fus.name 
        INTO supplyName 
        FROM bsa_fixed_quantity_supply fus
        WHERE id = :old.supply_id;
        -- Now insert in the logs
        INSERT INTO bsa_audit_log (logDate, logTable, project_id, operation, description)
        VALUES (CURRENT_DATE, 'Fixed Use Supply Mapping', :old.project_id, 'Delete', 'Name=' || supplyName);
    END;
/

--changeset fcerny:6 runOnChange:true endDelimiter:"/"
create or replace trigger bsa_trigger_after_update_fixed_use_supply
    after UPDATE on bsa_project_fixed_quantity_supply
    FOR EACH ROW
    DECLARE
        supplyName varchar2(100);
    BEGIN 
        -- We are only given the supply id, project id, and quantity on insert/update/delete, so we need to get the supply name
        SELECT fus.name 
        INTO supplyName 
        FROM bsa_fixed_quantity_supply fus
        WHERE id = :new.supply_id;
        -- Now insert in the logs
        INSERT INTO bsa_audit_log (logDate, logTable, project_id, operation, description)
        VALUES (CURRENT_DATE, 'Fixed Use Supply Mapping', :new.project_id, 'Update', 'Name=' || supplyName || ', Quantity=' || :new.quantity);
    END;
/