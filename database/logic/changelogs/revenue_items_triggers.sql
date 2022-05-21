--liquibase formatted sql

--changeset fcerny:1 runOnChange:true endDelimiter:"/"
create or replace trigger bsa_trigger_insert_revenue_item
    after INSERT on bsa_view_project_tool
    FOR EACH ROW
    DECLARE

    BEGIN 

    END;
/

--changeset fcerny:2 runOnChange:true endDelimiter:"/"
create or replace trigger bsa_trigger_delete_revenue_item
    after DELETE on bsa_view_project_tool
    FOR EACH ROW
    BEGIN 

    END;
/

--changeset fcerny:3 runOnChange:true endDelimiter:"/"
create or replace trigger bsa_trigger_update_revenue_item 
    after UPDATE on bsa_view_project_tool
    FOR EACH ROW
    BEGIN 

    END;
/