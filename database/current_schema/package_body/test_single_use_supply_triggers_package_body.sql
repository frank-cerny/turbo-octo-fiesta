
  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "DEV_WS"."TEST_SINGLE_USE_SUPPLY_TRIGGERS" 
as
    procedure test_single_use_supply_insert_trigger_with_logs is
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
        INSERT INTO dev_ws.bsa_single_use_supply (name, description, datepurchased, project_id, ispending, unitcost, unitspurchased, revenueitem_id)
        VALUES ('temp supply 12345', 'description', CURRENT_DATE, projectId, 'Y', 1.50, 10, null);
        -- Assert
        -- Validate logs were created
        SELECT l.id, l.logDate, l.logTable, l.operation, l.description INTO logId, logDate, logTable, logOperation, logDescription FROM bsa_audit_log l where project_id = projectId;
        ut.expect( logId ).not_to( be_null() );
        ut.expect( logDate ).to_( equal(CURRENT_DATE) );
        ut.expect( logTable ).to_( equal('Single Use Supply') );
        ut.expect( logOperation ).to_( equal('Create') );
        ut.expect( logDescription ).to_( equal('Name=temp supply 12345, Description=description, UnitCost=1.5, UnitsPurchased=10, IsPending=Y') );
    end;

    procedure test_single_use_supply_update_trigger_with_logs is
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
        INSERT INTO dev_ws.bsa_single_use_supply (name, description, datepurchased, project_id, ispending, unitcost, unitspurchased, revenueitem_id)
        VALUES ('temp supply 12345', 'description', CURRENT_DATE, projectId, 'Y', 1.50, 10, null);
        -- Then update
        UPDATE bsa_single_use_supply 
        SET name = 'temp 22222', description = 'new', unitspurchased = 50
        WHERE project_id = projectId and name = 'temp supply 12345';
        -- Assert
        -- Validate logs were created
        SELECT count(id) INTO numLogs FROM bsa_audit_log where project_id = projectId;
        ut.expect( numLogs ).to_( equal(2) );
        SELECT l.id, l.logDate, l.logTable, l.operation, l.description INTO logId, logDate, logTable, logOperation, logDescription FROM bsa_audit_log l where project_id = projectId and operation = 'Update';
        ut.expect( logId ).not_to( be_null() );
        ut.expect( logDate ).to_( equal(CURRENT_DATE) );
        ut.expect( logTable ).to_( equal('Single Use Supply') );
        ut.expect( logDescription ).to_( equal('Name=temp 22222, Description=new, UnitCost=1.5, UnitsPurchased=50, IsPending=Y') );
    end;

    procedure test_single_use_supply_delete_trigger_with_logs is
    supplyId int;
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
        INSERT INTO dev_ws.bsa_single_use_supply (name, description, datepurchased, project_id, ispending, unitcost, unitspurchased, revenueitem_id)
        VALUES ('temp supply 12345', 'description', CURRENT_DATE, projectId, 'Y', 1.50, 10, null);
        SELECT sus.id INTO supplyId FROM bsa_single_use_supply sus WHERE name = 'temp supply 12345';
        -- Now delete the revenue item
        DELETE
        FROM bsa_single_use_supply
        WHERE id = supplyId;
        -- Assert
        SELECT count(id) INTO numLogs FROM bsa_audit_log where project_id = projectId;
        ut.expect( numLogs ).to_( equal(2) );
        -- Then validate logs were created
        SELECT l.id, l.logDate, l.logTable, l.operation, l.description INTO logId, logDate, logTable, logOperation, logDescription FROM bsa_audit_log l where project_id = projectId and operation = 'Delete';
        ut.expect( logId ).not_to( be_null() );
        ut.expect( logDate ).to_( equal(CURRENT_DATE) );
        ut.expect( logTable ).to_( equal('Single Use Supply') );
        ut.expect( logDescription ).to_( equal('Name=temp supply 12345') );
    end;
end test_single_use_supply_triggers;
