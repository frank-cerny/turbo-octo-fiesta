
  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "DEV_WS"."TEST_REVENUE_ITEM_VALIDATION" 
as
    procedure test_revenue_item_insert_same_name_into_single_project is
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
        -- Attempt to insert a revenue item with the same name twice (should throw DUP_VAL_ON_INDEX)
        INSERT INTO dev_ws.bsa_revenue_item (project_id, name, description, saleprice, platformsoldon, ispending, datesold)
        VALUES (projectId, 'temp 12345', 'description', 5.50, platformSoldOnId, 'N', CURRENT_DATE);
        INSERT INTO dev_ws.bsa_revenue_item (project_id, name, description, saleprice, platformsoldon, ispending, datesold)
        VALUES (projectId, 'temp 12345', 'description', 7.50, platformSoldOnId, 'Y', CURRENT_DATE);
    end;

    procedure test_revenue_item_insert_same_name_into_multi_project is
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
        INSERT INTO dev_ws.bsa_revenue_item (project_id, name, description, saleprice, platformsoldon, ispending, datesold)
        VALUES (projectId, 'temp 12345', 'description', 5.50, platformSoldOnId, 'N', CURRENT_DATE);
        INSERT INTO dev_ws.bsa_revenue_item (project_id, name, description, saleprice, platformsoldon, ispending, datesold)
        VALUES (projectId1, 'temp 12345', 'description', 7.50, platformSoldOnId, 'Y', CURRENT_DATE);
    end;
end test_revenue_item_validation;