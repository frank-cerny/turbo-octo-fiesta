
  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "DEV_WS"."TEST_SINGLE_USE_SUPPLY_VALIDATION" 
as
    procedure test_single_use_supply_insert_same_name_into_single_project is
    projectId int;
    platformSoldOnId int;
    begin
        -- Setup
        -- Create a project
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 112233', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM dev_ws.bsa_project p where p.title = 'Test Project 112233';

        -- Get a platform sold on id for testing purposes
        -- Reference: https://stackoverflow.com/questions/3451534/how-do-i-do-top-1-in-oracle
        SELECT ID INTO platformSoldOnId from dev_ws.bsa_location where rownum = 1;

        -- Act 
        -- Attempt to insert a single use supply with the same name twice (should throw DUP_VAL_ON_INDEX)
        INSERT INTO dev_ws.bsa_single_use_supply (name, description, datepurchased, project_id, ispending, unitcost, unitspurchased, revenueitem_id)
        VALUES ('temp supply 12345', 'description', CURRENT_DATE, projectId, 'Y', 1.50, 10, null);
        INSERT INTO dev_ws.bsa_single_use_supply (name, description, datepurchased, project_id, ispending, unitcost, unitspurchased, revenueitem_id)
        VALUES ('temp supply 12345', 'description', CURRENT_DATE, projectId, 'Y', 1.50, 10, null);
    end;

    procedure test_single_use_supply_insert_same_name_into_multi_project is
    projectId int;
    projectId1 int;
    platformSoldOnId int;
    begin
        -- Setup
        -- Create two projects 
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 112233', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM dev_ws.bsa_project p where p.title = 'Test Project 112233';

        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('Project2 1122334', 'Project2 11223344', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId1 FROM dev_ws.bsa_project p where p.title = 'Project2 11223344';

        -- Get a platform sold on id for testing purposes
        SELECT ID INTO platformSoldOnId from dev_ws.bsa_location where rownum = 1;

        -- Act 
        -- Attempt to insert a revenue item with the same name into multiple projects (no error should be thrown)
        INSERT INTO dev_ws.bsa_single_use_supply (name, description, datepurchased, project_id, ispending, unitcost, unitspurchased, revenueitem_id)
        VALUES ('temp supply 12345', 'description', CURRENT_DATE, projectId, 'Y', 1.50, 10, null);
        INSERT INTO dev_ws.bsa_single_use_supply (name, description, datepurchased, project_id, ispending, unitcost, unitspurchased, revenueitem_id)
        VALUES ('temp supply 12345', 'description', CURRENT_DATE, projectId1, 'Y', 1.50, 10, null);
    end;
end test_single_use_supply_validation;
