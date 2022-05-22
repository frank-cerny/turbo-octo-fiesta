--liquibase formatted sql

--changeset fcerny:1 runOnChange:true endDelimiter:"/"
create or replace trigger bsa_trigger_insert_project_non_fixed_supply
    instead of INSERT on bsa_view_project_non_fixed_supply
    FOR EACH ROW
    DECLARE
        quantity number;
    BEGIN 
        -- Using a nested exception as I could not get not-nested to work: https://stackoverflow.com/questions/1256112/pl-sql-block-problem-no-data-found-error
        BEGIN
        -- SELECT INTO cannot handle empty result sets, so we can catch the exception it throws
        -- Reference: https://stackoverflow.com/questions/12080428/unable-to-select-into-when-value-doesnt-exist
        SELECT pj.quantity into quantity FROM bsa_project_non_fixed_quantity_supply pj WHERE project_id = :new.project_id AND supply_id = :new.supply_id;
        EXCEPTION
            WHEN no_data_found
            THEN
                quantity := 0;
        END;
        IF quantity > 0 THEN
            UPDATE bsa_project_non_fixed_quantity_supply pj
            SET pj.quantity = quantity + 1
            WHERE project_id = :new.project_id AND supply_id = :new.supply_id;
        ELSE
            -- Insert into the join table (project/tool already exist!) (update quantity if it exists)
            insert into bsa_project_non_fixed_quantity_supply (project_id, supply_id, quantity)
            values(:new.project_id, :new.supply_id, 1);
        END IF;
    END;
/

--changeset fcerny:2 runOnChange:true endDelimiter:"/"
create or replace trigger bsa_trigger_delete_project_non_fixed_supply
    instead of DELETE on bsa_view_project_non_fixed_supply
    FOR EACH ROW
    BEGIN 
        DELETE 
        FROM bsa_project_non_fixed_quantity_supply
        WHERE project_id = :old.project_id AND supply_id = :old.supply_id;
    END;
/

--changeset fcerny:3 runOnChange:true endDelimiter:"/"
create or replace trigger bsa_trigger_update_project_non_fixed_supply
    instead of UPDATE on bsa_view_project_non_fixed_supply
    FOR EACH ROW
    BEGIN 
        UPDATE bsa_project_non_fixed_quantity_supply
        SET quantity = :new.quantity
        WHERE project_id = :new.project_id AND supply_id = :new.supply_id;
    END;
/

-- Note: We put these triggers on the underlying tables, NOT the view (the view doesn't support after triggers)
--changeset fcerny:4 runOnChange:true endDelimiter:"/"
create or replace trigger bsa_trigger_after_insert_non_fixed_use_supply
    after INSERT on bsa_project_non_fixed_quantity_supply
    FOR EACH ROW
    DECLARE
        supplyName varchar2(100);
    BEGIN 
        -- We are only given the supply id, project id, and quantity on insert/update/delete, so we need to get the supply name
        SELECT nfus.name 
        INTO supplyName 
        FROM bsa_non_fixed_quantity_supply nfus
        WHERE id = :new.supply_id;
        -- Now insert in the logs
        INSERT INTO bsa_audit_log (logDate, logTable, project_id, operation, description)
        VALUES (CURRENT_DATE, 'Non-Fixed Use Supply Mapping', :new.project_id, 'Create', 'Name=' || supplyName || ', Quantity=' || :new.quantity);
    END;
/

--changeset fcerny:5 runOnChange:true endDelimiter:"/"
create or replace trigger bsa_trigger_after_delete_non_fixed_use_supply
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
/

--changeset fcerny:6 runOnChange:true endDelimiter:"/"
create or replace trigger bsa_trigger_after_update_non_fixed_use_supply
    after UPDATE on bsa_project_non_fixed_quantity_supply
    FOR EACH ROW
    DECLARE
        supplyName varchar2(100);
    BEGIN 
        -- We are only given the supply id, project id, and quantity on insert/update/delete, so we need to get the supply name
        SELECT nfus.name 
        INTO supplyName 
        FROM bsa_non_fixed_quantity_supply nfus
        WHERE id = :new.supply_id;
        -- Now insert in the logs
        INSERT INTO bsa_audit_log (logDate, logTable, project_id, operation, description)
        VALUES (CURRENT_DATE, 'Non-Fixed Use Supply Mapping', :new.project_id, 'Update', 'Name=' || supplyName || ', Quantity=' || :new.quantity);
    END;
/