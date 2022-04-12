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
    end;

    procedure test_trigger_update_project_fixed_use_supply is
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
    end;
end test_fixed_use_supply_triggers;
/
