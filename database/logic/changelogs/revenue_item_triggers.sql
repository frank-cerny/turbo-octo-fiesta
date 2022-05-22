--liquibase formatted sql

--changeset fcerny:1 runOnChange:true endDelimiter:"/"
create or replace trigger bsa_trigger_insert_revenue_item
    after INSERT on bsa_revenue_item
    FOR EACH ROW
    BEGIN 
        -- Name=temp 12345, Description=description, SalePrice=5.50, Platform=Ebay, IsPending=N
        INSERT INTO bsa_audit_log (logDate, logTable, project_id, operation, description)
        VALUES (CURRENT_DATE, 'Revenue Item', :new.project_id, 'Create', 'Name=' || :new.name || ', Description=' || :new.description || ', SalePrice=' || :new.saleprice ||
            ', Platform=' || :new.platformsoldon || ', IsPending=' || :new.ispending);
    END;
/

--changeset fcerny:2 runOnChange:true endDelimiter:"/"
create or replace trigger bsa_trigger_delete_revenue_item
    after DELETE on bsa_revenue_item
    FOR EACH ROW
    BEGIN 
        INSERT INTO bsa_audit_log (logDate, logTable, project_id, operation, description)
        VALUES (CURRENT_DATE, 'Revenue Item', :old.project_id, 'Delete', 'Name=' || :old.name);
    END;
/

--changeset fcerny:3 runOnChange:true endDelimiter:"/"
create or replace trigger bsa_trigger_update_revenue_item 
    after UPDATE on bsa_revenue_item
    FOR EACH ROW
    BEGIN 
        -- The log is the same as create
        INSERT INTO bsa_audit_log (logDate, logTable, project_id, operation, description)
        VALUES (CURRENT_DATE, 'Revenue Item', :new.project_id, 'Update', 'Name=' || :new.name || ', Description=' || :new.description || ', SalePrice=' || :new.saleprice ||
            ', Platform=' || :new.platformsoldon || ', IsPending=' || :new.ispending);
    END;
/