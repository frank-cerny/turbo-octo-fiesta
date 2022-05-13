
  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "DEV_WS"."TEST_NON_FIXED_SUPP_UTITLITIES" 
as
    procedure test_get_nf_supp_0 is
    projectId int;
    supplyId int;
    usages int;
    begin
        -- Setup
        -- Create project, non-fixed-supply (don't add to the join table to simulate it not being used)
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 112233', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM dev_ws.bsa_project p where p.title = 'Test Project 112233';
        INSERT INTO bsa_non_fixed_quantity_supply(name, description, datepurchased, cost)
        VALUES ('EvapoRust 112233', '', CURRENT_DATE, 15.67);
        SELECT nfqs.id INTO supplyId FROM bsa_non_fixed_quantity_supply nfqs WHERE name = 'EvapoRust 112233';
        -- Act
        usages := dev_ws.nfsu.bsa_func_get_non_fixed_supply_usages(supplyId);
        -- Assert
        ut.expect(usages).to_( equal(0) );
    end;

    procedure test_get_nf_supp_not_0_single_project is
    projectId int;
    supplyId int;
    usages int;
    begin
        -- Setup
        -- Create project, non-fixed-supply 
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 112233', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM dev_ws.bsa_project p where p.title = 'Test Project 112233';
        INSERT INTO bsa_non_fixed_quantity_supply(name, description, datepurchased, cost)
        VALUES ('EvapoRust 112233', '', CURRENT_DATE, 15.67);
        SELECT nfqs.id INTO supplyId FROM bsa_non_fixed_quantity_supply nfqs WHERE name = 'EvapoRust 112233';
        -- Insert a record into the join table to simulate a supply being attached to a product
        INSERT INTO dev_ws.bsa_project_non_fixed_quantity_supply (project_id, supply_id, quantity)
        VALUES (projectId, supplyId, 72);
        -- Act
        usages := dev_ws.nfsu.bsa_func_get_non_fixed_supply_usages(supplyId);
        -- Assert
        ut.expect(usages).to_( equal(72) );
    end;

    procedure test_get_nf_supp_not_0_multi_project is
    projectId int;
    projectId1 int;
    supplyId int;
    usages int;
    begin
        -- Setup
        -- Create multiple projects, and a single non-fixed-supply 
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 112233', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM dev_ws.bsa_project p where p.title = 'Test Project 112233';

        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('Project 2', 'Project 2', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId1 FROM dev_ws.bsa_project p where p.title = 'Project 2';

        INSERT INTO bsa_non_fixed_quantity_supply(name, description, datepurchased, cost)
        VALUES ('EvapoRust 112233', '', CURRENT_DATE, 15.67);
        SELECT nfqs.id INTO supplyId FROM bsa_non_fixed_quantity_supply nfqs WHERE name = 'EvapoRust 112233';
        -- Insert a record into the join table to simulate a supply being attached to a product
        INSERT INTO dev_ws.bsa_project_non_fixed_quantity_supply (project_id, supply_id, quantity)
        VALUES (projectId, supplyId, 72);
        INSERT INTO dev_ws.bsa_project_non_fixed_quantity_supply (project_id, supply_id, quantity)
        VALUES (projectId1, supplyId, 28);
        -- Act
        usages := dev_ws.nfsu.bsa_func_get_non_fixed_supply_usages(supplyId);
        -- Assert
        ut.expect(usages).to_( equal(100) );
    end;

    -- Unit Cost Tests
    procedure test_nf_supp_unit_cost_0 is
    projectId int;
    supplyId int;
    unitCost number;
    begin
        -- Setup
        -- Create project, non-fixed-supply (don't add to the join table to simulate it not being used)
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 112233', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM dev_ws.bsa_project p where p.title = 'Test Project 112233';

        INSERT INTO bsa_non_fixed_quantity_supply(name, description, datepurchased, cost)
        VALUES ('EvapoRust 112233', '', CURRENT_DATE, 15.00);
        SELECT nfqs.id INTO supplyId FROM bsa_non_fixed_quantity_supply nfqs WHERE name = 'EvapoRust 112233';
        -- Act
        unitCost := dev_ws.nfsu.bsa_func_get_non_fixed_supply_unit_cost(supplyId);
        -- Assert
        ut.expect(unitCost).to_( be_null() );
    end;

    procedure test_nf_supp_unit_cost_non_zero_single_project is
    projectId int;
    supplyId int;
    unitCost number;
    begin
        -- Setup
        -- Create project, non-fixed-supply (don't add to the join table to simulate it not being used)
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 112233', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM dev_ws.bsa_project p where p.title = 'Test Project 112233';

        INSERT INTO bsa_non_fixed_quantity_supply(name, description, datepurchased, cost)
        VALUES ('EvapoRust 112233', '', CURRENT_DATE, 15.00);
        SELECT nfqs.id INTO supplyId FROM bsa_non_fixed_quantity_supply nfqs WHERE name = 'EvapoRust 112233';
        -- Map the non-fixed supply and project
        INSERT INTO dev_ws.bsa_project_non_fixed_quantity_supply (project_id, supply_id, quantity)
        VALUES (projectId, supplyId, 14);
        -- Act
        unitCost := dev_ws.nfsu.bsa_func_get_non_fixed_supply_unit_cost(supplyId);
        -- Assert
        -- 15/14 = 1.07 (rounded)
        ut.expect(unitCost).to_( equal(1.07) );
    end;

    procedure test_nf_supp_unit_cost_non_zero_multi_project is
    projectId int;
    projectId1 int;
    supplyId int;
    unitCost number;
    begin
        -- Setup
        -- Create project, non-fixed-supply (don't add to the join table to simulate it not being used)
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 112233', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM dev_ws.bsa_project p where p.title = 'Test Project 112233';

        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('Project 2', 'Project 2', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId1 FROM dev_ws.bsa_project p where p.title = 'Project 2';

        INSERT INTO bsa_non_fixed_quantity_supply(name, description, datepurchased, cost)
        VALUES ('EvapoRust 112233', '', CURRENT_DATE, 15.00);
        SELECT nfqs.id INTO supplyId FROM bsa_non_fixed_quantity_supply nfqs WHERE name = 'EvapoRust 112233';
        -- Map the non-fixed supply and project
        INSERT INTO dev_ws.bsa_project_non_fixed_quantity_supply (project_id, supply_id, quantity)
        VALUES (projectId, supplyId, 14);
        INSERT INTO dev_ws.bsa_project_non_fixed_quantity_supply (project_id, supply_id, quantity)
        VALUES (projectId1, supplyId, 14);
        -- Act
        unitCost := dev_ws.nfsu.bsa_func_get_non_fixed_supply_unit_cost(supplyId);
        -- Assert
        -- 15/28 = .54 (rounded)
        ut.expect(unitCost).to_( equal(.54) );
    end;

    procedure test_non_fixed_supply_split_none is
    projectId NUMBER;
    supplyId NUMBER;
    id number;
    quantity number;
    begin
        -- Setup
        -- Create a project
        INSERT INTO BSA_PROJECT (description, title, datestarted, dateended) VALUES ('Non-Fixed Supply Test', 'NFS Test 22222', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM BSA_PROJECT p WHERE p.title = 'NFS Test 22222';
        -- Create a non-fixed use supply
        INSERT INTO bsa_non_fixed_quantity_supply(name, description, datepurchased, cost)
        VALUES ('EvapoRust 11111', '', CURRENT_DATE, 15.67);
        SELECT nfqs.id INTO supplyId FROM bsa_non_fixed_quantity_supply nfqs WHERE name = 'EvapoRust 11111';
        -- Act
        -- Pass empty strings to show they are handled correctly
        nfsu.bsa_func_split_non_fixed_supplies_over_projects('', '');
        -- Assert
        -- The non-fixed supply should not have been added to the project, so this should throw a no_data_found exception
        SELECT nfqs.id, nfqs.quantity INTO id, quantity from bsa_project_non_fixed_quantity_supply nfqs WHERE project_id = projectId AND supply_id = supplyId;
    end;

    procedure test_non_fixed_supply_split_among_single_project_first_insert is
    projectId NUMBER;
    supplyId NUMBER;
    id number;
    quantity number;
    begin
        -- Setup
        -- Create a project
        INSERT INTO BSA_PROJECT (description, title, datestarted, dateended) VALUES ('Non-Fixed Supply Test', 'NFS Test 22222', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM BSA_PROJECT p WHERE p.title = 'NFS Test 22222';
        -- Create a non-fixed use supply
        INSERT INTO bsa_non_fixed_quantity_supply(name, description, datepurchased, cost)
        VALUES ('EvapoRust 11111', '', CURRENT_DATE, 15.67);
        SELECT nfqs.id INTO supplyId FROM bsa_non_fixed_quantity_supply nfqs WHERE name = 'EvapoRust 11111';
        -- Act
        nfsu.bsa_func_split_non_fixed_supplies_over_projects('' || supplyId, '' || projectId);
        -- Assert
        SELECT nfqs.id, nfqs.quantity INTO id, quantity from bsa_project_non_fixed_quantity_supply nfqs WHERE project_id = projectId AND supply_id = supplyId;
        ut.expect(id).not_to( be_null() );
        ut.expect(quantity).to_( equal(1) );
    end;

    procedure test_non_fixed_supply_split_among_single_project_upsert is
    projectId NUMBER;
    supplyId NUMBER;
    id number;
    quantity number;
    begin
        -- Setup
        -- Create a project
        INSERT INTO BSA_PROJECT (description, title, datestarted, dateended) VALUES ('Non-Fixed Supply Test', 'NFS Test 22222', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM BSA_PROJECT p WHERE p.title = 'NFS Test 22222';
        -- Create a non-fixed use supply
        INSERT INTO bsa_non_fixed_quantity_supply(name, description, datepurchased, cost)
        VALUES ('EvapoRust 11111', '', CURRENT_DATE, 15.67);
        SELECT nfqs.id INTO supplyId FROM bsa_non_fixed_quantity_supply nfqs WHERE name = 'EvapoRust 11111';
        -- Add mappings of fixed use supply to project
        INSERT INTO BSA_PROJECT_NON_FIXED_QUANTITY_SUPPLY(project_id, supply_id, quantity) VALUES (projectId, supplyId, 7);
        -- Act
        nfsu.bsa_func_split_non_fixed_supplies_over_projects('' || supplyId, '' || projectId);
        -- Assert
        SELECT nfqs.id, nfqs.quantity INTO id, quantity from bsa_project_non_fixed_quantity_supply nfqs WHERE project_id = projectId AND supply_id = supplyId;
        ut.expect(id).not_to( be_null() );
        ut.expect(quantity).to_( equal(8) );
    end;

    procedure test_non_fixed_supply_split_among_multiple_projects_first_insert is
    projectId NUMBER;
    projectId1 NUMBER;
    supplyId NUMBER;
    id number;
    quantity number;
    begin
        -- Setup
        -- Create two projects
        INSERT INTO BSA_PROJECT (description, title, datestarted, dateended) VALUES ('Non-Fixed Supply Test', 'NFS Test 22222', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM BSA_PROJECT p WHERE p.title = 'NFS Test 22222';
        INSERT INTO BSA_PROJECT (description, title, datestarted, dateended) VALUES ('Non-Fixed Supply Test', 'NFS Test 33333', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId1 FROM BSA_PROJECT p WHERE p.title = 'NFS Test 33333';
        -- Create a non-fixed use supply
        INSERT INTO bsa_non_fixed_quantity_supply(name, description, datepurchased, cost)
        VALUES ('EvapoRust 11111', '', CURRENT_DATE, 15.67);
        SELECT nfqs.id INTO supplyId FROM bsa_non_fixed_quantity_supply nfqs WHERE name = 'EvapoRust 11111';
        -- Act
        nfsu.bsa_func_split_non_fixed_supplies_over_projects('' || supplyId, '' || projectId || ':' || projectId1);
        -- Assert
        -- Look for the tool to be added to the join table for both projects
        SELECT nfqs.id, nfqs.quantity INTO id, quantity from bsa_project_non_fixed_quantity_supply nfqs WHERE project_id = projectId AND supply_id = supplyId;
        ut.expect(id).not_to( be_null() );
        ut.expect(quantity).to_( equal(1) );
        SELECT nfqs.id, nfqs.quantity INTO id, quantity from bsa_project_non_fixed_quantity_supply nfqs WHERE project_id = projectId1 AND supply_id = supplyId;
        ut.expect(id).not_to( be_null() );
        ut.expect(quantity).to_( equal(1) );
    end;

    procedure test_multi_non_fixed_supply_split_among_multiple_projects_first_insert is
    projectId NUMBER;
    projectId1 NUMBER;
    supplyId NUMBER;
    supplyId1 NUMBER;
    id number;
    quantity number;
    begin
        -- Setup
        -- Create two projects
        INSERT INTO BSA_PROJECT (description, title, datestarted, dateended) VALUES ('Non-Fixed Supply Test', 'NFS Test 22222', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM BSA_PROJECT p WHERE p.title = 'NFS Test 22222';
        INSERT INTO BSA_PROJECT (description, title, datestarted, dateended) VALUES ('Non-Fixed Supply Test', 'NFS Test 33333', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId1 FROM BSA_PROJECT p WHERE p.title = 'NFS Test 33333';
        -- Create two non-fixed use supplies
        INSERT INTO bsa_non_fixed_quantity_supply(name, description, datepurchased, cost)
        VALUES ('EvapoRust 11111', '', CURRENT_DATE, 15.67);
        SELECT nfqs.id INTO supplyId FROM bsa_non_fixed_quantity_supply nfqs WHERE name = 'EvapoRust 11111';
        INSERT INTO bsa_non_fixed_quantity_supply(name, description, datepurchased, cost)
        VALUES ('EvapoRust 22222', '', CURRENT_DATE, 5);
        SELECT nfqs.id INTO supplyId1 FROM bsa_non_fixed_quantity_supply nfqs WHERE name = 'EvapoRust 22222';
        -- Act (create a colon separated string to mirror a shuttle list output)
        nfsu.bsa_func_split_non_fixed_supplies_over_projects('' || supplyId || ':' || supplyId1 , '' || projectId || ':' || projectId1);
        -- Assert
        -- Look for both tools to be added to the join table for both projects
        SELECT nfqs.id, nfqs.quantity INTO id, quantity from bsa_project_non_fixed_quantity_supply nfqs WHERE project_id = projectId AND supply_id = supplyId;
        ut.expect(id).not_to( be_null() );
        ut.expect(quantity).to_( equal(1) );
        SELECT nfqs.id, nfqs.quantity INTO id, quantity from bsa_project_non_fixed_quantity_supply nfqs WHERE project_id = projectId AND supply_id = supplyId1;
        ut.expect(id).not_to( be_null() );
        ut.expect(quantity).to_( equal(1) );
        SELECT nfqs.id, nfqs.quantity INTO id, quantity from bsa_project_non_fixed_quantity_supply nfqs WHERE project_id = projectId1 AND supply_id = supplyId;
        ut.expect(id).not_to( be_null() );
        ut.expect(quantity).to_( equal(1) );
        SELECT nfqs.id, nfqs.quantity INTO id, quantity from bsa_project_non_fixed_quantity_supply nfqs WHERE project_id = projectId1 AND supply_id = supplyId1;
        ut.expect(id).not_to( be_null() );
        ut.expect(quantity).to_( equal(1) );
    end;
end test_non_fixed_supp_utitlities;