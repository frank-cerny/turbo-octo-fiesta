--liquibase formatted sql

--changeset fcerny:1 runOnChange:true endDelimiter:"/" stripComments:false
create or replace package test_fixed_use_supply_triggers
as
    -- %suite(Test Fixed Use Supply Triggers)

    --%test(Test Trigger Insert Fixed Use Supply Single Project)
    procedure test_trigger_insert_fixed_use_supply_single_project;
    --%test(Test Trigger Insert Fixed Use Supply on multiple projects)
    procedure test_trigger_insert_fixed_use_supply_multi_project;
    --%test(Test Trigger Insert Project Fixed Use Supply with upsert)
    procedure test_trigger_insert_fixed_use_supply_upsert;
    --%test(Test Trigger Delete Project Fixed Use Supply)
    --%throws(-01403)
    procedure test_trigger_delete_project_fixed_use_supply;
    --%test(Test Trigger Update Fixed Use Supply)
    procedure test_trigger_update_project_fixed_use_supply;
    --%test(Test Trigger Update Fixed Use Supply Negative Single Project)
    --%throws(-20001)
    procedure test_trigger_update_project_fixed_use_supply_negative_single_project;
    --%test(Test Trigger Update Fixed Use Supply Negative Multi-Project)
    --%throws(-20001)
    procedure test_trigger_update_project_fixed_use_supply_negative_multi_project;
    --%test(Test Trigger Insert Project Fixed Use Supply Negative Single Project)
    --%throws(-20001)
    procedure test_trigger_insert_project_fixed_use_supply_negative_single_project;
    --%test(Test Trigger Insert Project Fixed Use Supply Negative Single Project)
    --%throws(-20001)
    procedure test_trigger_insert_project_fixed_use_supply_negative_multi_project;
end test_fixed_use_supply_triggers;
/

--changeset fcerny:2 runOnChange:true endDelimiter:"/" stripComments:false
create or replace package body test_fixed_use_supply_triggers
as
    -- Inserting a tool into a project for the first time should create a quantity of 1 for that tool for that project
    procedure test_trigger_insert_fixed_use_supply_single_project is
    supplyId int;
    projectId int;
    joinId int;
    quantity int;
    logId number;
    logDate date;
    logTable varchar2 (20);
    logOperation varchar2 (20);
    logDescription varchar2 (100);
    begin
        -- Setup
        -- Create a project and a fixed use supply
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 112233', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM dev_ws.bsa_project p where p.title = 'Test Project 112233';

        INSERT INTO dev_ws.bsa_fixed_quantity_supply(name, description, datepurchased, unitspurchased, totalcost)
        VALUES ('Bubble Wrap 12345', '', CURRENT_DATE, 165, 23.45);
        SELECT fqs.id INTO supplyId FROM dev_ws.bsa_fixed_quantity_supply fqs WHERE name = 'Bubble Wrap 12345';
        -- Act 
        -- Insert into View (which should trigger the trigger)
        INSERT INTO dev_ws.bsa_view_project_fixed_supply (supply_id, name, description, datepurchased, unitspurchased, totalcost, quantity, project_id)
        VALUES (supplyId, null, null, null, null, null, null, projectId);
        -- Assert
        -- If there is a record in the join table then we know that it worked
        SELECT pfqs.id, pfqs.quantity INTO joinId, quantity FROM dev_ws.bsa_project_fixed_quantity_supply pfqs WHERE supply_id = supplyId and project_id = projectId;
        -- Quantity should be 1 since we added a single tool to a single project (this also proves there is an entry in the join table)
        ut.expect( joinId ).not_to( be_null() );
        ut.expect( quantity ).to_( equal(1) );
        -- Now validate that audit logs were created 
        SELECT id, date, table, operation, description INTO logId, logDate, logTable, logOperation, logDescription FROM bsa_audit_log where project_id = projectId
        ut.expect( logId ).not_to( be_null() );
        ut.expect( logDate ).to_( equal(CURRENT_DATE) );
        ut.expect( logTable ).to_( equal('Fixed Use Supply Mapping') );
        ut.expect( logOperation ).to_( equal('Create') );
        ut.expect( logDescription ).to_( equal('Name=Bubble Wrap 12345, Quantity=1') );
    end;

    procedure test_trigger_insert_fixed_use_supply_multi_project is
    supplyId int;
    projectId int;
    projectId1 int;
    joinId int;
    quantity int;
    begin
        -- Setup
        -- Create two projects and a fixed use supply
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 112233', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM dev_ws.bsa_project p where p.title = 'Test Project 112233';

        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('Project2 12345', 'Project2 12345', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId1 FROM dev_ws.bsa_project p where p.title = 'Project2 12345';

        INSERT INTO dev_ws.bsa_fixed_quantity_supply(name, description, datepurchased, unitspurchased, totalcost)
        VALUES ('Bubble Wrap 12345', '', CURRENT_DATE, 165, 23.45);
        SELECT fqs.id INTO supplyId FROM dev_ws.bsa_fixed_quantity_supply fqs WHERE name = 'Bubble Wrap 12345';
        -- Act 
        -- Insert into View for both the projects
        INSERT INTO dev_ws.bsa_view_project_fixed_supply (supply_id, name, description, datepurchased, unitspurchased, totalcost, quantity, project_id)
        VALUES (supplyId, null, null, null, null, null, null, projectId);
        INSERT INTO dev_ws.bsa_view_project_fixed_supply (supply_id, name, description, datepurchased, unitspurchased, totalcost, quantity, project_id)
        VALUES (supplyId, null, null, null, null, null, null, projectId1);
        -- Assert
        -- If there is a record in the join table then we know that it worked
        SELECT pfqs.id, pfqs.quantity INTO joinId, quantity FROM dev_ws.bsa_project_fixed_quantity_supply pfqs WHERE supply_id = supplyId and project_id = projectId;
        -- Quantity should be 1 since we added a single tool to a single project (this also proves there is an entry in the join table)
        ut.expect( joinId ).not_to( be_null() );
        ut.expect( quantity ).to_( equal(1) );
        -- Now check the second project
        SELECT pfqs.id, pfqs.quantity INTO joinId, quantity FROM dev_ws.bsa_project_fixed_quantity_supply pfqs WHERE supply_id = supplyId and project_id = projectId1;
        -- Quantity should be 1 since we added a single tool to a single project (this also proves there is an entry in the join table)
        ut.expect( joinId ).not_to( be_null() );
        ut.expect( quantity ).to_( equal(1) );
    end;

    procedure test_trigger_insert_fixed_use_supply_upsert is
    supplyId int;
    projectId int;
    joinId int;
    quantity int;
    begin
        -- Setup
        -- Create a project and a fixed use supply
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 112233', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM dev_ws.bsa_project p where p.title = 'Test Project 112233';

        INSERT INTO dev_ws.bsa_fixed_quantity_supply(name, description, datepurchased, unitspurchased, totalcost)
        VALUES ('Bubble Wrap 12345', '', CURRENT_DATE, 165, 23.45);
        SELECT fqs.id INTO supplyId FROM dev_ws.bsa_fixed_quantity_supply fqs WHERE name = 'Bubble Wrap 12345';
        -- Act 
        -- Insert into View (which should trigger the trigger)
        INSERT INTO dev_ws.bsa_view_project_fixed_supply (supply_id, name, description, datepurchased, unitspurchased, totalcost, quantity, project_id)
        VALUES (supplyId, null, null, null, null, null, null, projectId);
        -- Assert
        -- If there is a record in the join table then we know that it worked
        SELECT pfqs.id, pfqs.quantity INTO joinId, quantity FROM dev_ws.bsa_project_fixed_quantity_supply pfqs WHERE supply_id = supplyId and project_id = projectId;
        -- Quantity should be 1 since we added a single tool to a single project (this also proves there is an entry in the join table)
        ut.expect( joinId ).not_to( be_null() );
        ut.expect( quantity ).to_( equal(1) );
        -- Now insert again into the view (which should increment the quantity to 2)
        INSERT INTO dev_ws.bsa_view_project_fixed_supply (supply_id, name, description, datepurchased, unitspurchased, totalcost, quantity, project_id)
        VALUES (supplyId, null, null, null, null, null, null, projectId);
        SELECT pfqs.id, pfqs.quantity INTO joinId, quantity FROM dev_ws.bsa_project_fixed_quantity_supply pfqs WHERE supply_id = supplyId and project_id = projectId;
        ut.expect( joinId ).not_to( be_null() );
        ut.expect( quantity ).to_( equal(2) );
        -- And a 3rd time
        INSERT INTO dev_ws.bsa_view_project_fixed_supply (supply_id, name, description, datepurchased, unitspurchased, totalcost, quantity, project_id)
        VALUES (supplyId, null, null, null, null, null, null, projectId);
        SELECT pfqs.id, pfqs.quantity INTO joinId, quantity FROM dev_ws.bsa_project_fixed_quantity_supply pfqs WHERE supply_id = supplyId and project_id = projectId;
        ut.expect( joinId ).not_to( be_null() );
        ut.expect( quantity ).to_( equal(3) );
    end;

    procedure test_trigger_delete_project_fixed_use_supply is
    supplyId int;
    projectId int;
    joinId int;
    quantity int;
    logId number;
    logDate date;
    logTable varchar2 (20);
    logOperation varchar2 (20);
    logDescription varchar2 (100);
    begin
        -- Setup
        -- Create a project and a fixed use supply
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 112233', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM dev_ws.bsa_project p where p.title = 'Test Project 112233';

        INSERT INTO dev_ws.bsa_fixed_quantity_supply(name, description, datepurchased, unitspurchased, totalcost)
        VALUES ('Bubble Wrap 12345', '', CURRENT_DATE, 165, 23.45);
        SELECT fqs.id INTO supplyId FROM dev_ws.bsa_fixed_quantity_supply fqs WHERE name = 'Bubble Wrap 12345';
        -- Insert into View (which should trigger the trigger)
        INSERT INTO dev_ws.bsa_view_project_fixed_supply (supply_id, name, description, datepurchased, unitspurchased, totalcost, quantity, project_id)
        VALUES (supplyId, null, null, null, null, null, null, projectId);
        -- If there is a record in the join table then we know that it worked
        SELECT pfqs.id, pfqs.quantity INTO joinId, quantity FROM dev_ws.bsa_project_fixed_quantity_supply pfqs WHERE supply_id = supplyId and project_id = projectId;
        -- Quantity should be 1 since we added a single tool to a single project (this also proves there is an entry in the join table)
        ut.expect( joinId ).not_to( be_null() );
        ut.expect( quantity ).to_( equal(1) );
        -- Now delete and validate an exception is thrown
        DELETE FROM dev_ws.bsa_view_project_fixed_supply where supply_id = supplyId and project_id = projectId;
        -- This should throw a no_data_found exception
        SELECT pfqs.id, pfqs.quantity INTO joinId, quantity FROM dev_ws.bsa_project_fixed_quantity_supply pfqs WHERE supply_id = supplyId and project_id = projectId;
        -- Now validate that audit logs were created 
        SELECT id, date, table, operation, description INTO logId, logDate, logTable, logOperation, logDescription FROM bsa_audit_log where project_id = projectId and operation = 'Delete'
        ut.expect( logId ).not_to( be_null() );
        ut.expect( logDate ).to_( equal(CURRENT_DATE) );
        ut.expect( logTable ).to_( equal('Fixed Use Supply Mapping') );
        ut.expect( logDescription ).to_( equal('Name=Bubble Wrap 12345') );
    end;

    procedure test_trigger_update_project_fixed_use_supply is
    supplyId int;
    projectId int;
    joinId int;
    quantity int;
    logId number;
    logDate date;
    logTable varchar2 (20);
    logOperation varchar2 (20);
    logDescription varchar2 (100);
    begin
        -- Setup
        -- Create a project and a fixed use supply
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 112233', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM dev_ws.bsa_project p where p.title = 'Test Project 112233';

        INSERT INTO dev_ws.bsa_fixed_quantity_supply(name, description, datepurchased, unitspurchased, totalcost)
        VALUES ('Bubble Wrap 12345', '', CURRENT_DATE, 165, 23.45);
        SELECT fqs.id INTO supplyId FROM dev_ws.bsa_fixed_quantity_supply fqs WHERE name = 'Bubble Wrap 12345';
        -- Insert into View (which should trigger the trigger)
        INSERT INTO dev_ws.bsa_view_project_fixed_supply (supply_id, name, description, datepurchased, unitspurchased, totalcost, quantity, project_id)
        VALUES (supplyId, null, null, null, null, null, null, projectId);
        -- If there is a record in the join table then we know that it worked
        SELECT pfqs.id, pfqs.quantity INTO joinId, quantity FROM dev_ws.bsa_project_fixed_quantity_supply pfqs WHERE supply_id = supplyId and project_id = projectId;
        -- Quantity should be 1 since we added a single tool to a single project (this also proves there is an entry in the join table)
        ut.expect( joinId ).not_to( be_null() );
        ut.expect( quantity ).to_( equal(1) );
        -- Now update the quantity of the item
        UPDATE dev_ws.bsa_view_project_fixed_supply
        SET quantity = 50
        WHERE supply_id = supplyId and project_id = projectId;
        SELECT pfqs.id, pfqs.quantity INTO joinId, quantity FROM dev_ws.bsa_project_fixed_quantity_supply pfqs WHERE supply_id = supplyId and project_id = projectId;
        ut.expect( joinId ).not_to( be_null() );
        ut.expect( quantity ).to_( equal(50) );
        -- Then validate logs were created
        SELECT id, date, table, operation, description INTO logId, logDate, logTable, logOperation, logDescription FROM bsa_audit_log where project_id = projectId and operation = 'Update'
        ut.expect( logId ).not_to( be_null() );
        ut.expect( logDate ).to_( equal(CURRENT_DATE) );
        ut.expect( logTable ).to_( equal('Fixed Supply Mapping') );
        ut.expect( logDescription ).to_( equal('Name=Bubble Wrap 12345, Quantity=50') );
    end;

    -- If a client attempts to to add a fixed use supply that is "empty" the app should throw an exception
    procedure test_trigger_update_project_fixed_use_supply_negative_single_project is
    supplyId int;
    projectId int;
    joinId int;
    quantity int;
    begin
        -- Setup
        -- Create a project and a fixed use supply
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 112233', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM dev_ws.bsa_project p where p.title = 'Test Project 112233';

        INSERT INTO dev_ws.bsa_fixed_quantity_supply(name, description, datepurchased, unitspurchased, totalcost)
        VALUES ('Bubble Wrap 12345', '', CURRENT_DATE, 165, 23.45);
        SELECT fqs.id INTO supplyId FROM dev_ws.bsa_fixed_quantity_supply fqs WHERE name = 'Bubble Wrap 12345';
        -- Insert into View (which should trigger the trigger)
        INSERT INTO dev_ws.bsa_view_project_fixed_supply (supply_id, name, description, datepurchased, unitspurchased, totalcost, quantity, project_id)
        VALUES (supplyId, null, null, null, null, null, null, projectId);
        -- Now update the quantity of the item (but update the quantity to more than is available) (should throw an exception)
        UPDATE dev_ws.bsa_view_project_fixed_supply
        SET quantity = 166
        WHERE supply_id = supplyId and project_id = projectId;
    end;

    procedure test_trigger_update_project_fixed_use_supply_negative_multi_project is
    supplyId int;
    projectId int;
    projectId1 int;
    joinId int;
    quantity int;
    begin
        -- Setup
        -- Create two projects and a fixed use supply
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 112233', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM dev_ws.bsa_project p where p.title = 'Test Project 112233';

        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('Project2 12345', 'Project2 12345', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId1 FROM dev_ws.bsa_project p where p.title = 'Project2 12345';

        INSERT INTO dev_ws.bsa_fixed_quantity_supply(name, description, datepurchased, unitspurchased, totalcost)
        VALUES ('Bubble Wrap 12345', '', CURRENT_DATE, 165, 23.45);
        SELECT fqs.id INTO supplyId FROM dev_ws.bsa_fixed_quantity_supply fqs WHERE name = 'Bubble Wrap 12345';
        -- Act 
        -- Insert into View for both the projects
        INSERT INTO dev_ws.bsa_view_project_fixed_supply (supply_id, name, description, datepurchased, unitspurchased, totalcost, quantity, project_id)
        VALUES (supplyId, null, null, null, null, null, null, projectId);
        INSERT INTO dev_ws.bsa_view_project_fixed_supply (supply_id, name, description, datepurchased, unitspurchased, totalcost, quantity, project_id)
        VALUES (supplyId, null, null, null, null, null, null, projectId1);
        -- Now update the quantity of the item in both projects
        UPDATE dev_ws.bsa_view_project_fixed_supply
        SET quantity = 164
        WHERE supply_id = supplyId and project_id = projectId;
        -- At this point there should be 0 quantity left, and an exception should be thrown
        UPDATE dev_ws.bsa_view_project_fixed_supply
        SET quantity = 2
        WHERE supply_id = supplyId and project_id = projectId1;
    end;

    -- If a a client attempts to update to a quantity that is invalid or empty, the app should throw an exception
    procedure test_trigger_insert_project_fixed_use_supply_negative_single_project is
    supplyId int;
    projectId int;
    joinId int;
    quantity int;
    begin
        -- Setup
        -- Create a project and a fixed use supply
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 112233', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM dev_ws.bsa_project p where p.title = 'Test Project 112233';

        INSERT INTO dev_ws.bsa_fixed_quantity_supply(name, description, datepurchased, unitspurchased, totalcost)
        VALUES ('Bubble Wrap 12345', '', CURRENT_DATE, 1, 23.45);
        SELECT fqs.id INTO supplyId FROM dev_ws.bsa_fixed_quantity_supply fqs WHERE name = 'Bubble Wrap 12345';
        -- Act 
        -- Insert into View (which should trigger the trigger)
        INSERT INTO dev_ws.bsa_view_project_fixed_supply (supply_id, name, description, datepurchased, unitspurchased, totalcost, quantity, project_id)
        VALUES (supplyId, null, null, null, null, null, null, projectId);
        -- If we insert again, an exception should be raised because the quantity of the fixed supply is 0 at this point
        INSERT INTO dev_ws.bsa_view_project_fixed_supply (supply_id, name, description, datepurchased, unitspurchased, totalcost, quantity, project_id)
        VALUES (supplyId, null, null, null, null, null, null, projectId);
    end;

    procedure test_trigger_insert_project_fixed_use_supply_negative_multi_project is
    supplyId int;
    projectId int;
    projectId1 int;
    joinId int;
    quantity int;
    begin
        -- Setup
        -- Create two projects and a fixed use supply
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 112233', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM dev_ws.bsa_project p where p.title = 'Test Project 112233';

        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('Project2 12345', 'Project2 12345', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId1 FROM dev_ws.bsa_project p where p.title = 'Project2 12345';

        INSERT INTO dev_ws.bsa_fixed_quantity_supply(name, description, datepurchased, unitspurchased, totalcost)
        VALUES ('Bubble Wrap 12345', '', CURRENT_DATE, 2, 23.45);
        SELECT fqs.id INTO supplyId FROM dev_ws.bsa_fixed_quantity_supply fqs WHERE name = 'Bubble Wrap 12345';
        -- Act 
        -- Insert into View for both the projects
        INSERT INTO dev_ws.bsa_view_project_fixed_supply (supply_id, name, description, datepurchased, unitspurchased, totalcost, quantity, project_id)
        VALUES (supplyId, null, null, null, null, null, null, projectId);
        INSERT INTO dev_ws.bsa_view_project_fixed_supply (supply_id, name, description, datepurchased, unitspurchased, totalcost, quantity, project_id)
        VALUES (supplyId, null, null, null, null, null, null, projectId1);
        -- If we insert again into either project, an exception should be raised because the quantity of the fixed supply is 0 at this point
        INSERT INTO dev_ws.bsa_view_project_fixed_supply (supply_id, name, description, datepurchased, unitspurchased, totalcost, quantity, project_id)
        VALUES (supplyId, null, null, null, null, null, null, projectId1);
    end;
end test_fixed_use_supply_triggers;
/
