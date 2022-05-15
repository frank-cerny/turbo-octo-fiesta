
  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "DEV_WS"."TEST_FIXED_SUPP_UTITLITIES" 
as
    procedure test_get_f_supp_remaining_0 is
    fixedSupplyId int;
    unitsRemaining int;
    begin
        -- Setup
        -- Insert a single fixed supply into the table
        INSERT INTO dev_ws.bsa_fixed_quantity_supply(name, description, datepurchased, unitspurchased, totalcost)
        VALUES ('Bubble Wrap 112233', '', CURRENT_DATE, 165, 23.45);
        SELECT fqs.id INTO fixedSupplyId FROM dev_ws.bsa_fixed_quantity_supply fqs WHERE name = 'Bubble Wrap 112233';
        -- Act 
        -- fsu is a public synomym for the fixed supply package
        unitsRemaining := dev_ws.fsu.bsa_func_get_fixed_supply_units_remaining(fixedSupplyId);
        -- Assert
        -- We haven't used any of the fixed use supplies yet, so this should equal the original supply
        ut.expect(unitsRemaining).to_( equal(165) );
    end;

    procedure test_get_f_supp_remaining_not_0_single_project is
    projectId int;
    fixedSupplyId int;
    unitsRemaining int;
    begin
        -- Setup
        -- Create a project
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 112233', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM dev_ws.bsa_project p where p.title = 'Test Project 112233';
        -- Insert a single fixed supply into the table
        INSERT INTO dev_ws.bsa_fixed_quantity_supply(name, description, datepurchased, unitspurchased, totalcost)
        VALUES ('Bubble Wrap 112233', '', CURRENT_DATE, 165, 23.45);
        SELECT fqs.id INTO fixedSupplyId FROM dev_ws.bsa_fixed_quantity_supply fqs WHERE name = 'Bubble Wrap 112233';
        -- Add records to the project fixed use supply table directly (do not use the trigger here)
        INSERT INTO dev_ws.bsa_project_fixed_quantity_supply (project_id, supply_id, quantity)
        VALUES (projectId, fixedSupplyId, 65);
        -- Act 
        -- fsu is a public synomym for the fixed supply package
        unitsRemaining := dev_ws.fsu.bsa_func_get_fixed_supply_units_remaining(fixedSupplyId);
        -- Assert
        ut.expect(unitsRemaining).to_( equal(100) );
    end;

    procedure test_get_f_supp_remaining_not_0_multi_project is
    projectId1 int;
    projectId2 int;
    fixedSupplyId int;
    unitsRemaining int;
    begin
        -- Setup
        -- Create two projects
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 112233', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId1 FROM dev_ws.bsa_project p where p.title = 'Test Project 112233';
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 332211', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId2 FROM dev_ws.bsa_project p where p.title = 'Test Project 332211';
        -- Insert a single fixed supply into the table
        INSERT INTO dev_ws.bsa_fixed_quantity_supply(name, description, datepurchased, unitspurchased, totalcost)
        VALUES ('Bubble Wrap 112233', '', CURRENT_DATE, 165, 23.45);
        SELECT fqs.id INTO fixedSupplyId FROM dev_ws.bsa_fixed_quantity_supply fqs WHERE name = 'Bubble Wrap 112233';
        -- Add records to the project fixed use supply table directly (do not use the trigger here)
        INSERT INTO dev_ws.bsa_project_fixed_quantity_supply (project_id, supply_id, quantity)
        VALUES (projectId1, fixedSupplyId, 65);
        INSERT INTO dev_ws.bsa_project_fixed_quantity_supply (project_id, supply_id, quantity)
        VALUES (projectId2, fixedSupplyId, 50);
        -- Act 
        -- fsu is a public synomym for the fixed supply package
        unitsRemaining := dev_ws.fsu.bsa_func_get_fixed_supply_units_remaining(fixedSupplyId);
        -- Assert
        ut.expect(unitsRemaining).to_( equal(50) );
    end;

    -- Not sure this can happen, but it doesn't hurt to check and tighten the conditions on the function
    procedure test_get_f_supp_remaining_handle_negative is
    projectId int;
    fixedSupplyId int;
    unitsRemaining int;
    begin
        -- Setup
        -- Create a project
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 112233', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM dev_ws.bsa_project p where p.title = 'Test Project 112233';
        -- Insert a single fixed supply into the table
        INSERT INTO dev_ws.bsa_fixed_quantity_supply(name, description, datepurchased, unitspurchased, totalcost)
        VALUES ('Bubble Wrap 112233', '', CURRENT_DATE, 165, 23.45);
        SELECT fqs.id INTO fixedSupplyId FROM dev_ws.bsa_fixed_quantity_supply fqs WHERE name = 'Bubble Wrap 112233';
        -- Add records to the project fixed use supply table directly (do not use the trigger here)
        -- For this specific test we want to "use" more than we have to ensure the function does NOT return a negatvie number
        INSERT INTO dev_ws.bsa_project_fixed_quantity_supply (project_id, supply_id, quantity)
        VALUES (projectId, fixedSupplyId, 166);
        -- Act 
        -- fsu is a public synomym for the fixed supply package
        unitsRemaining := dev_ws.fsu.bsa_func_get_fixed_supply_units_remaining(fixedSupplyId);
        -- Assert
        ut.expect(unitsRemaining).to_( equal(0) );
    end;

    -- This case should not happen, but in case of user error it should be covered
    procedure test_fixed_supply_unit_cost_0 is
    fixedSupplyId int;
    unitCost number;
    begin
        -- Setup
        -- Insert a single fixed supply into the table
        INSERT INTO dev_ws.bsa_fixed_quantity_supply(name, description, datepurchased, unitspurchased, totalcost)
        VALUES ('Bubble Wrap 112233', '', CURRENT_DATE, 0, 100);
        SELECT fqs.id INTO fixedSupplyId FROM dev_ws.bsa_fixed_quantity_supply fqs WHERE name = 'Bubble Wrap 112233';
        -- Act 
        -- fsu is a public synomym for the fixed supply package
        unitCost := dev_ws.fsu.bsa_func_get_fixed_supply_unit_cost(fixedSupplyId);
        -- Assert
        ut.expect(unitCost).to_( be_null() );
    end;

    -- This case should not happen, but in case of user error it should be covered
    procedure test_fixed_supply_unit_cost_non_zero is
    fixedSupplyId int;
    unitCost number;
    begin
        -- Setup
        -- Insert a single fixed supply into the table
        INSERT INTO dev_ws.bsa_fixed_quantity_supply(name, description, datepurchased, unitspurchased, totalcost)
        VALUES ('Bubble Wrap 112233', '', CURRENT_DATE, 165, 100);
        SELECT fqs.id INTO fixedSupplyId FROM dev_ws.bsa_fixed_quantity_supply fqs WHERE name = 'Bubble Wrap 112233';
        -- Act 
        -- fsu is a public synomym for the fixed supply package
        unitCost := dev_ws.fsu.bsa_func_get_fixed_supply_unit_cost(fixedSupplyId);
        -- Assert
        ut.expect(unitCost).to_( equal(.61) );
    end;

    procedure test_fixed_supply_split_none is
    projectId NUMBER;
    supplyId NUMBER;
    id number;
    quantity number;
    begin
        -- Setup
        -- Create a project
        INSERT INTO BSA_PROJECT (description, title, datestarted, dateended) VALUES ('Fixed Supply Test', 'FS Test 22222', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM BSA_PROJECT p WHERE p.title = 'FS Test 22222';
        -- Create a fixed use supply
        INSERT INTO bsa_fixed_quantity_supply(name, description, datepurchased, unitspurchased, totalcost)
        VALUES ('Bubble Wrap 11111', '', CURRENT_DATE, 165, 23.45);
        SELECT fqs.id INTO supplyId FROM bsa_fixed_quantity_supply fqs WHERE name = 'Bubble Wrap 11111';
        -- Act
        -- Pass empty strings to show they are handled correctly
        fsu.bsa_func_split_fixed_supplies_over_projects('', '');
        -- Assert
        -- The tool should not have been added to the project, so this should throw a no_data_found exception
        SELECT fqs.id, fqs.quantity INTO id, quantity from bsa_project_fixed_quantity_supply fqs WHERE project_id = projectId AND supply_id = supplyId;
    end;

    procedure test_fixed_supply_split_among_single_project_first_insert is
    projectId NUMBER;
    supplyId NUMBER;
    id number;
    quantity number;
    begin
        -- Setup
        -- Create a project
        INSERT INTO BSA_PROJECT (description, title, datestarted, dateended) VALUES ('Fixed Supply Test', 'FS Test 22222', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM BSA_PROJECT p WHERE p.title = 'FS Test 22222';
        -- Create a fixed use supply
        INSERT INTO bsa_fixed_quantity_supply(name, description, datepurchased, unitspurchased, totalcost)
        VALUES ('Bubble Wrap 11111', '', CURRENT_DATE, 165, 23.45);
        SELECT fqs.id INTO supplyId FROM bsa_fixed_quantity_supply fqs WHERE name = 'Bubble Wrap 11111';
        -- Act
        fsu.bsa_func_split_fixed_supplies_over_projects('' || supplyId, '' || projectId);
        -- Assert
        -- Look for the tool to be added to the join table
        SELECT fqs.id, fqs.quantity INTO id, quantity from bsa_project_fixed_quantity_supply fqs WHERE project_id = projectId AND supply_id = supplyId;
        ut.expect(id).not_to( be_null() );
        ut.expect(quantity).to_( equal(1) );
    end;

    procedure test_fixed_supply_split_among_single_project_upsert is
    projectId NUMBER;
    supplyId NUMBER;
    id number;
    quantity number;
    begin
        -- Setup
        -- Create a project
        INSERT INTO BSA_PROJECT (description, title, datestarted, dateended) VALUES ('Fixed Supply Test', 'FS Test 22222', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM BSA_PROJECT p WHERE p.title = 'FS Test 22222';
        -- Create a fixed use supply
        INSERT INTO bsa_fixed_quantity_supply(name, description, datepurchased, unitspurchased, totalcost)
        VALUES ('Bubble Wrap 11111', '', CURRENT_DATE, 165, 23.45);
        SELECT fqs.id INTO supplyId FROM bsa_fixed_quantity_supply fqs WHERE name = 'Bubble Wrap 11111';
        -- Add mappings of fixed use supply to project
        INSERT INTO BSA_PROJECT_FIXED_QUANTITY_SUPPLY(project_id, supply_id, quantity) VALUES (projectId, supplyId, 50);
        -- Act
        fsu.bsa_func_split_fixed_supplies_over_projects('' || supplyId, '' || projectId);
        -- Assert
        -- Look for the tool to be added to the join table
        SELECT fqs.id, fqs.quantity INTO id, quantity from bsa_project_fixed_quantity_supply fqs WHERE project_id = projectId AND supply_id = supplyId;
        ut.expect(id).not_to( be_null() );
        ut.expect(quantity).to_( equal(51) );
    end;

    procedure test_fixed_supply_split_among_multiple_projects_first_insert is
    projectId NUMBER;
    projectId1 NUMBER;
    supplyId NUMBER;
    id number;
    quantity number;
    begin
        -- Setup
        -- Create two projects
        INSERT INTO BSA_PROJECT (description, title, datestarted, dateended) VALUES ('Fixed Use Supply Test 1', 'FSU Test 11111', CURRENT_DATE, NULL);
        INSERT INTO BSA_PROJECT (description, title, datestarted, dateended) VALUES ('Fixed Use Supply Test 2', 'FSU Test 22222', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM BSA_PROJECT p WHERE p.title = 'FSU Test 11111';
        SELECT p.id INTO projectId1 FROM BSA_PROJECT p WHERE p.title = 'FSU Test 22222';
        -- Create a fixed use supply
        INSERT INTO bsa_fixed_quantity_supply(name, description, datepurchased, unitspurchased, totalcost)
        VALUES ('Bubble Wrap 11111', '', CURRENT_DATE, 165, 23.45);
        SELECT fqs.id INTO supplyId FROM bsa_fixed_quantity_supply fqs WHERE name = 'Bubble Wrap 11111';
        -- Act
        fsu.bsa_func_split_fixed_supplies_over_projects('' || supplyId, '' || projectId || ':' || projectId1);
        -- Assert
        -- Look for the tool to be added to the join table for both projects
        SELECT fqs.id, fqs.quantity INTO id, quantity from bsa_project_fixed_quantity_supply fqs WHERE project_id = projectId AND supply_id = supplyId;
        ut.expect(id).not_to( be_null() );
        ut.expect(quantity).to_( equal(1) );
        SELECT fqs.id, fqs.quantity INTO id, quantity from bsa_project_fixed_quantity_supply fqs WHERE project_id = projectId1 AND supply_id = supplyId;
        ut.expect(id).not_to( be_null() );
        ut.expect(quantity).to_( equal(1) );
    end;

    procedure test_multi_fixed_supply_split_among_multiple_projects_first_insert is
    projectId NUMBER;
    projectId1 NUMBER;
    supplyId NUMBER;
    supplyId1 NUMBER;
    id number;
    quantity number;
    begin
        -- Setup
        -- Create two projects
        INSERT INTO BSA_PROJECT (description, title, datestarted, dateended) VALUES ('Fixed Use Supply Test 1', 'FSU Test 11111', CURRENT_DATE, NULL);
        INSERT INTO BSA_PROJECT (description, title, datestarted, dateended) VALUES ('Fixed Use Supply Test 2', 'FSU Test 22222', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM BSA_PROJECT p WHERE p.title = 'FSU Test 11111';
        SELECT p.id INTO projectId1 FROM BSA_PROJECT p WHERE p.title = 'FSU Test 22222';
        -- Create a fixed use supply
        INSERT INTO bsa_fixed_quantity_supply(name, description, datepurchased, unitspurchased, totalcost)
        VALUES ('Bubble Wrap 11111', '', CURRENT_DATE, 165, 23.45);
        SELECT fqs.id INTO supplyId FROM bsa_fixed_quantity_supply fqs WHERE name = 'Bubble Wrap 11111';
        INSERT INTO bsa_fixed_quantity_supply(name, description, datepurchased, unitspurchased, totalcost)
        VALUES ('Bubble Wrap 22222', '', CURRENT_DATE, 50, 100);
        SELECT fqs.id INTO supplyId1 FROM bsa_fixed_quantity_supply fqs WHERE name = 'Bubble Wrap 22222';
        -- Act (create a colon separated string to mirror a shuttle list output)
        fsu.bsa_func_split_fixed_supplies_over_projects('' || supplyId || ':' || supplyId1 , '' || projectId || ':' || projectId1);
        -- Assert
        -- Look for both tools to be added to the join table for both projects
        SELECT fqs.id, fqs.quantity INTO id, quantity from bsa_project_fixed_quantity_supply fqs WHERE project_id = projectId AND supply_id = supplyId;
        ut.expect(id).not_to( be_null() );
        ut.expect(quantity).to_( equal(1) );
        SELECT fqs.id, fqs.quantity INTO id, quantity from bsa_project_fixed_quantity_supply fqs WHERE project_id = projectId AND supply_id = supplyId1;
        ut.expect(id).not_to( be_null() );
        ut.expect(quantity).to_( equal(1) );
        SELECT fqs.id, fqs.quantity INTO id, quantity from bsa_project_fixed_quantity_supply fqs WHERE project_id = projectId1 AND supply_id = supplyId;
        ut.expect(id).not_to( be_null() );
        ut.expect(quantity).to_( equal(1) );
        SELECT fqs.id, fqs.quantity INTO id, quantity from bsa_project_fixed_quantity_supply fqs WHERE project_id = projectId1 AND supply_id = supplyId1;
        ut.expect(id).not_to( be_null() );
        ut.expect(quantity).to_( equal(1) );
    end;
end test_fixed_supp_utitlities;