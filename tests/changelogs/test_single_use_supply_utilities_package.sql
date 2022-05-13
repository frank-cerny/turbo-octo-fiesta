--liquibase formatted sql

--changeset fcerny:1 runOnChange:true endDelimiter:"/" stripComments:false
create or replace package test_single_use_supply_utilities
as
    -- %suite(Test Single Use Supply Utilities)

    --%test(Test Single Use Supply Split With Empty Project String)
    --%throws(-01403)
    procedure test_single_use_supply_split_with_empty_project_string;
    --%test(Test Single Use Supply Split With Single Project String)
    procedure test_single_use_supply_split_with_single_project_string;
    --%test(Test Single Use Supply Split With Two Project String)
    procedure test_single_use_supply_split_with_two_project_string;
    --%test(Test Single Use Supply With Rounded Value)
    procedure test_single_use_supply_split_with_rounded_value;
    -- TODO - Add one with multiple units purchased
end test_single_use_supply_utilities;
/

--changeset fcerny:2 runOnChange:true endDelimiter:"/" stripComments:false
create or replace package body test_single_use_supply_utilities
as
    procedure test_single_use_supply_split_with_empty_project_string is
    projectId int;
    supplyId int;
    begin
        -- Setup
        -- Create a project
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 11111', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM dev_ws.bsa_project p where p.title = 'Test Project 11111';

        -- Act (use an empty projects)
        sus.bsa_proc_split_single_use_supply_among_projects('', 'single use supply 22222', 'item description', CURRENT_DATE, 'N', 5.00, 1, NULL);

        -- Assert (should throw an exception since no data exists)
        SELECT id INTO supplyId from BSA_SINGLE_USE_SUPPLY where name = 'item name 22222';
    end;

    procedure test_single_use_supply_split_with_single_project_string is
    projectId int;
    supplyId int;
    rowCount int;
    description varchar2(200);
    isPending varchar2(200);
    datePurchased Date;
    unitCost number;
    unitsPurchased int;
    revenueItemId int;
    begin
        -- Setup
        -- Create a project
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 11111', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM dev_ws.bsa_project p where p.title = 'Test Project 11111';

        -- Act
        sus.bsa_proc_split_single_use_supply_among_projects('' || projectId, 'single use supply 22222', 'item description', CURRENT_DATE, 'N', 5.00, 1, NULL);

        -- Assert (Full assert here, no need to repeat in other tests though)
        SELECT id, description, datePurchased, isPending, unitCost, unitsPurchased, revenueItemId INTO supplyId, description, datePurchased, isPending, unitCost, unitsPurchased, revenueItemId from BSA_SINGLE_USE_SUPPLY where name = 'single use supply 22222' and project_id = projectId;
        ut.expect(supplyId).not_to( be_null() );
        ut.expect(description).to_( equal('item description (Split Among Projects: Test Project 11111)') );
        ut.expect(isPending).to_( equal('N') );
        ut.expect(datePurchased).to_( equal(CURRENT_DATE) );
        ut.expect(unitCost).to_( equal(5.00) );
        ut.expect(unitsPurchased).to_( equal(1) );
        ut.expect(revenueItemId).to_( be_null() );
        -- Also assert that this item doesn't exist anywhere else
        SELECT count(id) INTO rowCount from BSA_SINGLE_USE_SUPPLY where name = 'single use supply 22222' and project_id = projectId;
        ut.expect(rowCount).to_( equal(1) );
    end;

    procedure test_single_use_supply_split_with_two_project_string is
    projectId int;
    projectId1 int;
    supplyId int;
    rowCount int;
    unitCost number;
    description varchar2(200);
    begin
        -- Setup
        -- Create a project
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 11111', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM dev_ws.bsa_project p where p.title = 'Test Project 11111';

        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 33333', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId1 FROM dev_ws.bsa_project p where p.title = 'Test Project 33333';

        -- Act
        sus.bsa_proc_split_single_use_supply_among_projects('' || projectId, 'single use supply 22222', 'item description', CURRENT_DATE, 'N', 5.00, 1, NULL);

        -- Assert (Full assert here, no need to repeat in other tests though)
        SELECT id, description, unitCost INTO supplyId, description, unitCost from BSA_SINGLE_USE_SUPPLY where name = 'single use supply 22222' and project_id = projectId;
        ut.expect(supplyId).not_to( be_null() );
        ut.expect(description).to_( equal('item description (Split Among Projects: Test Project 11111, Test Project 33333)') );
        ut.expect(unitCost).to_( equal(5.1) );
        -- Assert for the second project
        SELECT id, description, unitCost INTO supplyId, description, unitCost from BSA_SINGLE_USE_SUPPLY where name = 'single use supply 22222' and project_id = projectId1;
        ut.expect(supplyId).not_to( be_null() );
        ut.expect(description).to_( equal('item description (Split Among Projects: Test Project 11111, Test Project 33332)') );
        ut.expect(unitCost).to_( equal(2.50) );
        -- Also assert that this item doesn't exist anywhere else
        SELECT count(id) INTO rowCount from BSA_SINGLE_USE_SUPPLY where name = 'single use supply 22222' and project_id = projectId;
        ut.expect(rowCount).to_( equal(2) );
    end;

    -- Same as above, except using an uneven sale price to show how rounding works
    procedure test_single_use_supply_split_with_rounded_value is
    projectId int;
    projectId1 int;
    supplyId int;
    rowCount int;
    unitCost number;
    description varchar2(200);
    begin
        -- Setup
        -- Create a project
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 11111', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM dev_ws.bsa_project p where p.title = 'Test Project 11111';

        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 33333', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId1 FROM dev_ws.bsa_project p where p.title = 'Test Project 33333';

        -- Act
        sus.bsa_proc_split_single_use_supply_among_projects('' || projectId, 'single use supply 22222', 'item description', CURRENT_DATE, 'N', 5.01, 1, NULL);

        -- Assert (Full assert here, no need to repeat in other tests though)
        SELECT id, description, unitCost INTO supplyId, description, unitCost from BSA_SINGLE_USE_SUPPLY where name = 'single use supply 22222' and project_id = projectId;
        ut.expect(supplyId).not_to( be_null() );
        ut.expect(description).to_( equal('item description (Split Among Projects: Test Project 11111, Test Project 33333)') );
        -- 5.01 / 2 should round to 2.51
        ut.expect(unitCost).to_( equal(2.51) );
        -- Assert for the second project
        SELECT id, description, unitCost INTO supplyId, description, unitCost from BSA_SINGLE_USE_SUPPLY where name = 'single use supply 22222' and project_id = projectId1;
        ut.expect(supplyId).not_to( be_null() );
        ut.expect(description).to_( equal('item description (Split Among Projects: Test Project 11111, Test Project 33332)') );
        ut.expect(unitCost).to_( equal(2.51) );
        -- Also assert that this item doesn't exist anywhere else
        SELECT count(id) INTO rowCount from BSA_SINGLE_USE_SUPPLY where name = 'single use supply 22222' and project_id = projectId;
        ut.expect(rowCount).to_( equal(2) );
    end;
end test_single_use_supply_utilities;
/
