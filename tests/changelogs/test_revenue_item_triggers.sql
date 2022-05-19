--liquibase formatted sql

--changeset fcerny:1 runOnChange:true endDelimiter:"/" stripComments:false
create or replace package test_revenue_item_triggers
as
    -- %suite(Test Revenue Item Triggers)

    --%test(Test Revenue Item Insert Trigger With Logs)
    procedure test_revenue_item_insert_trigger_with_logs;
    --%test(Test Revenue Item Update Trigger With Logs)
    procedure test_revenue_item_update_trigger_with_logs;
    --%test(Test Revenue Item Delete Trigger With Logs)
    procedure test_revenue_item_delete_trigger_with_logs;
end test_revenue_item_triggers;
/

-- All revenue items are pass through, but the important part is that everything is logged in the audit table

--changeset fcerny:2 runOnChange:true endDelimiter:"/" stripComments:false
create or replace package body test_revenue_item_triggers
as
    procedure test_revenue_item_insert_trigger_with_logs is
    projectId int;
    id number;
    name varchar2 (50);
    description varchar2 (50);
    salePrice number;
    platformSoldOn varchar2 (50);
    isPending varchar2 (1);
    dateSold date;
    logId number;
    logDate date;
    logTable varchar2 (20);
    logOperation varchar2 (20);
    logDescription varchar2 (100);
    begin
        -- Setup
        -- Create a project and a tool
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 112233', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM dev_ws.bsa_project p where p.title = 'Test Project 112233';
        -- Act 
        INSERT INTO dev_ws.bsa_revenue_item (project_id, name, description, saleprice, platformsoldon, ispending, datesold)
        VALUES (projectId, 'temp 12345', 'description', 5.50, 'Ebay', 'N', CURRENT_DATE);
        -- Assert
        -- First check all fields on the revenue item
        SELECT id, name, description, saleprice, platformsoldon, ispending, datesold INTO id, name, description, salePrice, platformSoldOn. isPending, dateSold from BSA_REVENUE_ITEM where name = 'temp 12345' and project_id = projectId;
        ut.expect( id ).not_to( be_null() );
        ut.expect( description ).to_( equal('description') );
        ut.expect( salePrice ).to_( equal(5.50) );
        ut.expect( platformSoldOn ).to_( equal('Ebay') );
        ut.expect( isPending ).to_( equal('N') );
        ut.expect( dateSold ).to_( equal(CURRENT_DATE) );
        -- Then validate logs were created
        SELECT id, date, table, operation, description INTO logId, logDate, logTable, logOperation, logDescription FROM bsa_audit_log where project_id = projectId
        ut.expect( logId ).not_to( be_null() );
        ut.expect( logDate ).to_( equal(CURRENT_DATE) );
        ut.expect( logTable ).to_( equal('Revenue Item') );
        ut.expect( logOperation ).to_( equal('Create') );
        ut.expect( logDescription ).to_( equal('Name=temp 12345, Description=description, SalePrice=5.50, Platform=Ebay, IsPending=N') );
    end;

    procedure test_revenue_item_update_trigger_with_logs is
    projectId int;
    id number;
    name varchar2 (50);
    description varchar2 (50);
    salePrice number;
    platformSoldOn varchar2 (50);
    isPending varchar2 (1);
    dateSold date;
    logId number;
    logDate date;
    logTable varchar2 (20);
    logOperation varchar2 (20);
    logDescription varchar2 (100);
    begin
        -- Setup
        -- Create a project and a tool
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 112233', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM dev_ws.bsa_project p where p.title = 'Test Project 112233';
        -- Act 
        INSERT INTO dev_ws.bsa_revenue_item (project_id, name, description, saleprice, platformsoldon, ispending, datesold)
        VALUES (projectId, 'temp 12345', 'description', 5.50, 'Ebay', 'N', CURRENT_DATE);
        -- Then update
        UPDATE BSA_REVENUE_ITEM 
        SET name = 'temp 22222', description = 'new', saleprice = 10
        WHERE project_id = projectId and name = 'temp 12345'
        -- Assert
        -- First check all fields on the revenue item
        SELECT id, name, description, saleprice, platformsoldon, ispending, datesold INTO id, name, description, salePrice, platformSoldOn. isPending, dateSold from BSA_REVENUE_ITEM where name = 'temp 22222' and project_id = projectId;
        ut.expect( id ).not_to( be_null() );
        ut.expect( description ).to_( equal('new') );
        ut.expect( salePrice ).to_( equal(10) );
        ut.expect( platformSoldOn ).to_( equal('Ebay') );
        ut.expect( isPending ).to_( equal('N') );
        ut.expect( dateSold ).to_( equal(CURRENT_DATE) );
        -- Then validate logs were created
        SELECT id, date, table, operation, description INTO logId, logDate, logTable, logOperation, logDescription FROM bsa_audit_log where project_id = projectId and operation = 'Update'
        ut.expect( logId ).not_to( be_null() );
        ut.expect( logDate ).to_( equal(CURRENT_DATE) );
        ut.expect( logTable ).to_( equal('Revenue Item') );
        ut.expect( logDescription ).to_( equal('Name=temp 22222, Description=new, SalePrice=10, Platform=Ebay, IsPending=N') );
    end;

    procedure test_revenue_item_delete_trigger_with_logs is
    projectId int;
    id number;
    name varchar2 (50);
    description varchar2 (50);
    salePrice number;
    platformSoldOn varchar2 (50);
    isPending varchar2 (1);
    dateSold date;
    logId number;
    logDate date;
    logTable varchar2 (20);
    logOperation varchar2 (20);
    logDescription varchar2 (100);
    begin
        -- Setup
        -- Create a project and a tool
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 112233', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM dev_ws.bsa_project p where p.title = 'Test Project 112233';
        -- Act 
        INSERT INTO dev_ws.bsa_revenue_item (project_id, name, description, saleprice, platformsoldon, ispending, datesold)
        VALUES (projectId, 'temp 12345', 'description', 5.50, 'Ebay', 'N', CURRENT_DATE);
        -- Assert
        ut.expect( id ).to( be_null() );
        -- Then validate logs were created
        SELECT id, date, table, operation, description INTO logId, logDate, logTable, logOperation, logDescription FROM bsa_audit_log where project_id = projectId and operation = 'Delete'
        ut.expect( logId ).not_to( be_null() );
        ut.expect( logDate ).to_( equal(CURRENT_DATE) );
        ut.expect( logTable ).to_( equal('Revenue Item') );
        ut.expect( logDescription ).to_( equal('Name=temp 12345') );
    end;
end test_revenue_item_triggers;
/
