--liquibase formatted sql

--changeset fcerny:1 runOnChange:true endDelimiter:"/"
create or replace trigger bsa_trigger_insert_single_use_supply
    after INSERT on bsa_single_use_supply
    FOR EACH ROW
    BEGIN 
        -- Name=temp 12345, Description=description, SalePrice=5.50, Platform=Ebay, IsPending=N
        INSERT INTO bsa_audit_log (logDate, logTable, project_id, operation, description)
        VALUES (CURRENT_DATE, 'Single Use Supply', :new.project_id, 'Create', 'Name=' || :new.name || ', Description=' || :new.description || ', UnitCost=' || :new.unitcost ||
            ', UnitsPurchased=' || :new.unitspurchased || ', IsPending=' || :new.ispending);
    END;
/

--changeset fcerny:2 runOnChange:true endDelimiter:"/"
create or replace trigger bsa_trigger_delete_single_use_supply
    after DELETE on bsa_single_use_supply
    FOR EACH ROW
    BEGIN 
        INSERT INTO bsa_audit_log (logDate, logTable, project_id, operation, description)
        VALUES (CURRENT_DATE, 'Single Use Supply', :old.project_id, 'Delete', 'Name=' || :old.name);
    END;
/

--changeset fcerny:3 runOnChange:true endDelimiter:"/"
create or replace trigger bsa_trigger_update_single_use_supply
    after UPDATE on bsa_single_use_supply
    FOR EACH ROW
    BEGIN 
        -- The log is the same as create
        INSERT INTO bsa_audit_log (logDate, logTable, project_id, operation, description)
        VALUES (CURRENT_DATE, 'Single Use Supply', :new.project_id, 'Update', 'Name=' || :new.name || ', Description=' || :new.description || ', UnitCost=' || :new.unitcost ||
            ', UnitsPurchased=' || :new.unitspurchased || ', IsPending=' || :new.ispending);
    END;
/