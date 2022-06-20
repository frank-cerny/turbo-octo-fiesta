
  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "DEV_WS"."TEST_REVENUE_ITEM_TRIGGERS" 
as
    procedure test_revenue_item_insert_trigger_with_logs is
    projectId int;
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
        -- Validate logs were created
        SELECT l.id, l.logDate, l.logTable, l.operation, l.description INTO logId, logDate, logTable, logOperation, logDescription FROM bsa_audit_log l where project_id = projectId;
        ut.expect( logId ).not_to( be_null() );
        ut.expect( logDate ).to_( equal(CURRENT_DATE) );
        ut.expect( logTable ).to_( equal('Revenue Item') );
        ut.expect( logOperation ).to_( equal('Create') );
        ut.expect( logDescription ).to_( equal('Name=temp 12345, Description=description, SalePrice=5.5, Platform=Ebay, IsPending=N') );
    end;

    procedure test_revenue_item_update_trigger_with_logs is
    projectId int;
    logId number;
    logDate date;
    logTable varchar2 (20);
    logOperation varchar2 (20);
    logDescription varchar2 (100);
    numLogs number;
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
        WHERE project_id = projectId and name = 'temp 12345';
        -- Assert
        -- Validate logs were created
        SELECT count(id) INTO numLogs FROM bsa_audit_log where project_id = projectId;
        ut.expect( numLogs ).to_( equal(2) );
        SELECT l.id, l.logDate, l.logTable, l.operation, l.description INTO logId, logDate, logTable, logOperation, logDescription FROM bsa_audit_log l where project_id = projectId and operation = 'Update';
        ut.expect( logId ).not_to( be_null() );
        ut.expect( logDate ).to_( equal(CURRENT_DATE) );
        ut.expect( logTable ).to_( equal('Revenue Item') );
        ut.expect( logDescription ).to_( equal('Name=temp 22222, Description=new, SalePrice=10, Platform=Ebay, IsPending=N') );
    end;

    procedure test_revenue_item_delete_trigger_with_logs is
    revenueItemId int;
    projectId int;
    logId number;
    logDate date;
    logTable varchar2 (20);
    logOperation varchar2 (20);
    logDescription varchar2 (100);
    numLogs number;
    begin
        -- Setup
        -- Create a project and a tool
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 112233', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM dev_ws.bsa_project p where p.title = 'Test Project 112233';
        -- Act 
        INSERT INTO dev_ws.bsa_revenue_item (project_id, name, description, saleprice, platformsoldon, ispending, datesold)
        VALUES (projectId, 'temp 12345', 'description', 5.50, 'Ebay', 'N', CURRENT_DATE);
        SELECT r.id INTO revenueItemId FROM bsa_revenue_item r WHERE name = 'temp 12345';
        -- Now delete the revenue item
        DELETE
        FROM bsa_revenue_item
        WHERE id = revenueItemId;
        -- Assert
        SELECT count(id) INTO numLogs FROM bsa_audit_log where project_id = projectId;
        ut.expect( numLogs ).to_( equal(2) );
        -- Then validate logs were created
        SELECT l.id, l.logDate, l.logTable, l.operation, l.description INTO logId, logDate, logTable, logOperation, logDescription FROM bsa_audit_log l where project_id = projectId and operation = 'Delete';
        ut.expect( logId ).not_to( be_null() );
        ut.expect( logDate ).to_( equal(CURRENT_DATE) );
        ut.expect( logTable ).to_( equal('Revenue Item') );
        ut.expect( logDescription ).to_( equal('Name=temp 12345') );
    end;
end test_revenue_item_triggers;
