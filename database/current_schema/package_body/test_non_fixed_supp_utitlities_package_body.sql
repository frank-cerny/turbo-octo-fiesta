
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
end test_non_fixed_supp_utitlities;