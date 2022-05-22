--liquibase formatted sql

--changeset fcerny:1 runOnChange:true endDelimiter:"/" stripComments:false
create or replace package test_non_fixed_use_supply_triggers
as
    -- %suite(Test Non-Fixed Use Supply Triggers)

    --%test(Test Trigger Insert Non-Fixed Use Supply Single Project)
    procedure test_trigger_insert_non_fixed_use_supply_single_project;
    --%test(Test Trigger Insert Non-Fixed Use Supply Multi-Project)
    procedure test_trigger_insert_non_fixed_use_supply_multi_project;
    --%test(Test Trigger Upsert Non-Fixed Use Supply)
    procedure test_trigger_upsert_non_fixed_use_supply;
    --%test(Test Trigger Delete Non-Fixed Supply)
    --%throws(-01403)
    procedure test_trigger_delete_non_fixed_supply;
    --%test(Test Trigger Update Non-Fixed Supply)
    procedure test_trigger_update_non_fixed_supply;
    --%test(Test Non-Fixed Use Supply Insert Trigger With Logs)
    procedure test_trigger_insert_non_fixed_use_supplies_with_logs;
    --%test(Test Non-Fixed Use Supply Update Trigger With Logs)
    procedure test_trigger_update_non_fixed_use_supplies_with_logs;
    --%test(Test Non-Fixed Use Supply Delete Trigger With Logs)
    procedure test_trigger_delete_non_fixed_use_supplies_with_logs;
end test_non_fixed_use_supply_triggers;
/

--changeset fcerny:2 runOnChange:true endDelimiter:"/" stripComments:false
create or replace package body test_non_fixed_use_supply_triggers
as
    -- Inserting a tool into a project for the first time should create a quantity of 1 for that tool for that project
    procedure test_trigger_insert_non_fixed_use_supply_single_project is
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

        INSERT INTO dev_ws.bsa_non_fixed_quantity_supply(name, description, datepurchased, cost)
        VALUES ('EvapoRust 123456', '', CURRENT_DATE, 15.67);

        SELECT nfqs.id INTO supplyId FROM bsa_non_fixed_quantity_supply nfqs WHERE name = 'EvapoRust 123456';

        -- Act 
        -- Insert into View (which should trigger the trigger)
        INSERT INTO dev_ws.bsa_view_project_non_fixed_supply(supply_id, name, description, datepurchased, cost, quantity, project_id)
        VALUES (supplyId, null, null, null, null, null, projectId);
        -- Assert
        -- If there is a record in the join table then we know that it worked
        SELECT pnfqs.id, pnfqs.quantity INTO joinId, quantity FROM dev_ws.bsa_project_non_fixed_quantity_supply pnfqs WHERE supply_id = supplyId and project_id = projectId;
        -- Quantity should be 1 since we added a single tool to a single project (this also proves there is an entry in the join table)
        ut.expect( joinId ).not_to( be_null() );
        ut.expect( quantity ).to_( equal(1) );
    end;

    procedure test_trigger_insert_non_fixed_use_supply_multi_project is
    supplyId int;
    projectId int;
    projectId1 int;
    joinId int;
    quantity int;
    begin
        -- Setup
        -- Create a project and a fixed use supply
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 112233', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM dev_ws.bsa_project p where p.title = 'Test Project 112233';

        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('Project2 112233', 'Project2 112233', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId1 FROM dev_ws.bsa_project p where p.title = 'Project2 112233';

        INSERT INTO dev_ws.bsa_non_fixed_quantity_supply(name, description, datepurchased, cost)
        VALUES ('EvapoRust 123456', '', CURRENT_DATE, 15.67);

        SELECT nfqs.id INTO supplyId FROM bsa_non_fixed_quantity_supply nfqs WHERE name = 'EvapoRust 123456';

        -- Act 
        -- Insert into View (which should trigger the trigger)
        INSERT INTO dev_ws.bsa_view_project_non_fixed_supply(supply_id, name, description, datepurchased, cost, quantity, project_id)
        VALUES (supplyId, null, null, null, null, null, projectId);
        INSERT INTO dev_ws.bsa_view_project_non_fixed_supply(supply_id, name, description, datepurchased, cost, quantity, project_id)
        VALUES (supplyId, null, null, null, null, null, projectId1);
        -- Assert
        -- If there is a record in the join table then we know that it worked
        SELECT pnfqs.id, pnfqs.quantity INTO joinId, quantity FROM dev_ws.bsa_project_non_fixed_quantity_supply pnfqs WHERE supply_id = supplyId and project_id = projectId;
        -- Quantity should be 1 since we added a single tool to a single project (this also proves there is an entry in the join table)
        ut.expect( joinId ).not_to( be_null() );
        ut.expect( quantity ).to_( equal(1) );
        -- Then check the other project as well
        SELECT pnfqs.id, pnfqs.quantity INTO joinId, quantity FROM dev_ws.bsa_project_non_fixed_quantity_supply pnfqs WHERE supply_id = supplyId and project_id = projectId1;
        -- Quantity should be 1 since we added a single tool to a single project (this also proves there is an entry in the join table)
        ut.expect( joinId ).not_to( be_null() );
        ut.expect( quantity ).to_( equal(1) );
    end;

    procedure test_trigger_upsert_non_fixed_use_supply is
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

        INSERT INTO dev_ws.bsa_non_fixed_quantity_supply(name, description, datepurchased, cost)
        VALUES ('EvapoRust 123456', '', CURRENT_DATE, 15.67);

        SELECT nfqs.id INTO supplyId FROM bsa_non_fixed_quantity_supply nfqs WHERE name = 'EvapoRust 123456';

        -- Act 
        -- Insert into View (which should trigger the trigger)
        INSERT INTO dev_ws.bsa_view_project_non_fixed_supply(supply_id, name, description, datepurchased, cost, quantity, project_id)
        VALUES (supplyId, null, null, null, null, null, projectId);
        -- Assert
        -- If there is a record in the join table then we know that it worked
        SELECT pnfqs.id, pnfqs.quantity INTO joinId, quantity FROM dev_ws.bsa_project_non_fixed_quantity_supply pnfqs WHERE supply_id = supplyId and project_id = projectId;
        -- Quantity should be 1 since we added a single tool to a single project (this also proves there is an entry in the join table)
        ut.expect( joinId ).not_to( be_null() );
        ut.expect( quantity ).to_( equal(1) );
        -- Insert the same item into the same project again twice
        INSERT INTO dev_ws.bsa_view_project_non_fixed_supply(supply_id, name, description, datepurchased, cost, quantity, project_id)
        VALUES (supplyId, null, null, null, null, null, projectId);
        -- Assert
        -- If there is a record in the join table then we know that it worked
        SELECT pnfqs.id, pnfqs.quantity INTO joinId, quantity FROM dev_ws.bsa_project_non_fixed_quantity_supply pnfqs WHERE supply_id = supplyId and project_id = projectId;
        -- Quantity should be 1 since we added a single tool to a single project (this also proves there is an entry in the join table)
        ut.expect( joinId ).not_to( be_null() );
        ut.expect( quantity ).to_( equal(2) );
        INSERT INTO dev_ws.bsa_view_project_non_fixed_supply(supply_id, name, description, datepurchased, cost, quantity, project_id)
        VALUES (supplyId, null, null, null, null, null, projectId);
        -- Assert
        -- If there is a record in the join table then we know that it worked
        SELECT pnfqs.id, pnfqs.quantity INTO joinId, quantity FROM dev_ws.bsa_project_non_fixed_quantity_supply pnfqs WHERE supply_id = supplyId and project_id = projectId;
        -- Quantity should be 1 since we added a single tool to a single project (this also proves there is an entry in the join table)
        ut.expect( joinId ).not_to( be_null() );
        ut.expect( quantity ).to_( equal(3) );
    end;

    procedure test_trigger_delete_non_fixed_supply is
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

        INSERT INTO dev_ws.bsa_non_fixed_quantity_supply(name, description, datepurchased, cost)
        VALUES ('EvapoRust 123456', '', CURRENT_DATE, 15.67);

        SELECT nfqs.id INTO supplyId FROM bsa_non_fixed_quantity_supply nfqs WHERE name = 'EvapoRust 123456';
        -- Act 
        -- Insert into View (which should trigger the trigger)
        INSERT INTO dev_ws.bsa_view_project_non_fixed_supply(supply_id, name, description, datepurchased, cost, quantity, project_id)
        VALUES (supplyId, null, null, null, null, null, projectId);
        -- Assert
        -- If there is a record in the join table then we know that it worked
        SELECT pnfqs.id, pnfqs.quantity INTO joinId, quantity FROM dev_ws.bsa_project_non_fixed_quantity_supply pnfqs WHERE supply_id = supplyId and project_id = projectId;
        -- Quantity should be 1 since we added a single tool to a single project (this also proves there is an entry in the join table)
        ut.expect( joinId ).not_to( be_null() );
        ut.expect( quantity ).to_( equal(1) );
        -- Now delete the mapping and ensure a no_data_found exception is thrown
        DELETE FROM dev_ws.bsa_view_project_non_fixed_supply WHERE project_id = projectId and supply_id = supplyId;
        SELECT pnfqs.id, pnfqs.quantity INTO joinId, quantity FROM dev_ws.bsa_project_non_fixed_quantity_supply pnfqs WHERE supply_id = supplyId and project_id = projectId;
    end;

    -- Inserting a tool into a project for the first time should create a quantity of 1 for that tool for that project
    procedure test_trigger_update_non_fixed_supply is
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

        INSERT INTO dev_ws.bsa_non_fixed_quantity_supply(name, description, datepurchased, cost)
        VALUES ('EvapoRust 123456', '', CURRENT_DATE, 15.67);

        SELECT nfqs.id INTO supplyId FROM bsa_non_fixed_quantity_supply nfqs WHERE name = 'EvapoRust 123456';

        -- Act 
        -- Insert into View (which should trigger the trigger)
        INSERT INTO dev_ws.bsa_view_project_non_fixed_supply(supply_id, name, description, datepurchased, cost, quantity, project_id)
        VALUES (supplyId, null, null, null, null, null, projectId);
        -- Assert
        -- If there is a record in the join table then we know that it worked
        SELECT pnfqs.id, pnfqs.quantity INTO joinId, quantity FROM dev_ws.bsa_project_non_fixed_quantity_supply pnfqs WHERE supply_id = supplyId and project_id = projectId;
        -- Quantity should be 1 since we added a single tool to a single project (this also proves there is an entry in the join table)
        ut.expect( joinId ).not_to( be_null() );
        ut.expect( quantity ).to_( equal(1) );
        -- Update the values
        UPDATE dev_ws.bsa_view_project_non_fixed_supply SET quantity = 107 WHERE project_id = projectId and supply_id = supplyId;
        SELECT pnfqs.id, pnfqs.quantity INTO joinId, quantity FROM dev_ws.bsa_project_non_fixed_quantity_supply pnfqs WHERE supply_id = supplyId and project_id = projectId;
        -- Quantity should be 1 since we added a single tool to a single project (this also proves there is an entry in the join table)
        ut.expect( joinId ).not_to( be_null() );
        ut.expect( quantity ).to_( equal(107) );
    end;

    procedure test_trigger_insert_non_fixed_use_supplies_with_logs is
    supplyId int;
    projectId int;
    joinId int;
    quantity int;
    logId number;
    logDate date;
    logTable varchar2 (50);
    logOperation varchar2 (20);
    logDescription varchar2 (100);
    numLogs number;
    begin
        -- Setup
        -- Create a project and a fixed use supply
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 112233', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM dev_ws.bsa_project p where p.title = 'Test Project 112233';

        INSERT INTO dev_ws.bsa_non_fixed_quantity_supply(name, description, datepurchased, cost)
        VALUES ('EvapoRust 123456', '', CURRENT_DATE, 15.67);
        SELECT nfqs.id INTO supplyId FROM bsa_non_fixed_quantity_supply nfqs WHERE name = 'EvapoRust 123456';
        -- Act 
        -- Insert into View (which should trigger the trigger)
        INSERT INTO dev_ws.bsa_view_project_non_fixed_supply(supply_id, name, description, datepurchased, cost, quantity, project_id)
        VALUES (supplyId, null, null, null, null, null, projectId);
        -- Assert
        SELECT count(id) INTO numLogs FROM bsa_audit_log where project_id = projectId;
        ut.expect( numLogs ).to_( equal(1) );
        -- Validate logs were created
        SELECT l.id, l.logDate, l.logTable, l.operation, l.description INTO logId, logDate, logTable, logOperation, logDescription FROM bsa_audit_log l where project_id = projectId;
        ut.expect( logId ).not_to( be_null() );
        ut.expect( logDate ).to_( equal(CURRENT_DATE) );
        ut.expect( logTable ).to_( equal('Non-Fixed Use Supply Mapping') );
        ut.expect( logOperation ).to_( equal('Create') );
        ut.expect( logDescription ).to_( equal('Name=EvapoRust 123456, Quantity=1') );
    end;

    procedure test_trigger_update_non_fixed_use_supplies_with_logs is
    supplyId int;
    projectId int;
    joinId int;
    quantity int;
    logId number;
    logDate date;
    logTable varchar2 (50);
    logOperation varchar2 (20);
    logDescription varchar2 (100);
    numLogs number;
    begin
        -- Setup
        -- Create a project and a fixed use supply
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 112233', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM dev_ws.bsa_project p where p.title = 'Test Project 112233';

        INSERT INTO dev_ws.bsa_non_fixed_quantity_supply(name, description, datepurchased, cost)
        VALUES ('EvapoRust 123456', '', CURRENT_DATE, 15.67);
        SELECT nfqs.id INTO supplyId FROM bsa_non_fixed_quantity_supply nfqs WHERE name = 'EvapoRust 123456';
        -- Act 
        -- Insert into View 
        INSERT INTO dev_ws.bsa_view_project_non_fixed_supply(supply_id, name, description, datepurchased, cost, quantity, project_id)
        VALUES (supplyId, null, null, null, null, null, projectId);
        -- Then update the value
        UPDATE dev_ws.bsa_view_project_non_fixed_supply
        SET quantity = 51
        WHERE supply_id = supplyId and project_id = projectId;
        -- Assert
        SELECT count(id) INTO numLogs FROM bsa_audit_log where project_id = projectId;
        ut.expect( numLogs ).to_( equal(2) );
        -- Validate logs were created
        SELECT l.id, l.logDate, l.logTable, l.operation, l.description INTO logId, logDate, logTable, logOperation, logDescription FROM bsa_audit_log l where project_id = projectId and operation = 'Update';
        ut.expect( logId ).not_to( be_null() );
        ut.expect( logDate ).to_( equal(CURRENT_DATE) );
        ut.expect( logTable ).to_( equal('Non-Fixed Use Supply Mapping') );
        ut.expect( logDescription ).to_( equal('Name=EvapoRust 123456, Quantity=51') );
    end;

    procedure test_trigger_delete_non_fixed_use_supplies_with_logs is
    supplyId int;
    projectId int;
    joinId int;
    quantity int;
    logId number;
    logDate date;
    logTable varchar2 (50);
    logOperation varchar2 (20);
    logDescription varchar2 (100);
    numLogs number;
    begin
        -- Setup
        -- Create a project and a fixed use supply
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 112233', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM dev_ws.bsa_project p where p.title = 'Test Project 112233';

        INSERT INTO dev_ws.bsa_non_fixed_quantity_supply(name, description, datepurchased, cost)
        VALUES ('EvapoRust 123456', '', CURRENT_DATE, 15.67);
        SELECT nfqs.id INTO supplyId FROM bsa_non_fixed_quantity_supply nfqs WHERE name = 'EvapoRust 123456';
        -- Act 
        -- Insert into View (which should trigger the trigger)
        INSERT INTO dev_ws.bsa_view_project_non_fixed_supply(supply_id, name, description, datepurchased, cost, quantity, project_id)
        VALUES (supplyId, null, null, null, null, null, projectId);
        -- Now Delete the mapping
        DELETE 
        FROM dev_ws.bsa_view_project_non_fixed_supply
        WHERE supply_id = supplyId and project_id = projectId;
        -- Assert
        SELECT count(id) INTO numLogs FROM bsa_audit_log where project_id = projectId;
        ut.expect( numLogs ).to_( equal(2) );
        -- Validate logs were created
        SELECT l.id, l.logDate, l.logTable, l.operation, l.description INTO logId, logDate, logTable, logOperation, logDescription FROM bsa_audit_log l where project_id = projectId and operation = 'Delete';
        ut.expect( logId ).not_to( be_null() );
        ut.expect( logDate ).to_( equal(CURRENT_DATE) );
        ut.expect( logTable ).to_( equal('Non-Fixed Use Supply Mapping') );
        ut.expect( logDescription ).to_( equal('Name=EvapoRust 123456') );
    end;
end test_non_fixed_use_supply_triggers;
/
