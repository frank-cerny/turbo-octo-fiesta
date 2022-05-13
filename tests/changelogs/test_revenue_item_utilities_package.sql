--liquibase formatted sql

--changeset fcerny:1 runOnChange:true endDelimiter:"/" stripComments:false
create or replace package test_revenue_item_utilities
as
    -- %suite(Test Revenue Item Utilities)

    --%test(Test Revenue Item Split With Empty Project String)
    --%throws(-01403)
    procedure test_revenue_item_split_with_empty_project_string;
    --%test(Test Revenue Item Split With Single Project String)
    procedure test_revenue_item_split_with_single_project_string;
    --%test(Test Revenue Item Split With Two Project String)
    procedure test_revenue_item_split_with_two_project_string;
    --%test(Test Revenue Item Split With Rounded Value)
    procedure test_revenue_item_split_with_rounded_value;
end test_revenue_item_utilities;
/

--changeset fcerny:2 runOnChange:true endDelimiter:"/" stripComments:false
create or replace package body test_revenue_item_utilities
as
    procedure test_revenue_item_split_with_empty_project_string is
    projectId int;
    revenueItemId int;
    begin
        -- Setup
        -- Create a project
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 11111', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM dev_ws.bsa_project p where p.title = 'Test Project 11111';

        -- Act (use an empty projects)
        ru.bsa_proc_split_revenue_item_among_projects('', 'item name 22222', 'item description', '5.00', 'Facebook', 'N', CURRENT_DATE);

        -- Assert (should throw an exception since no data exists)
        SELECT id INTO revenueItemId from BSA_REVENUE_ITEM where name = 'item name 22222';
    end;

    procedure test_revenue_item_split_with_single_project_string is
    projectId int;
    revenueItemId int;
    rowCount int;
    salePrice number;
    description varchar2(200);
    platformSoldOn varchar2(200); 
    isPending varchar2(200);
    dateSold Date;
    begin
        -- Setup
        -- Create a project
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 11111', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM dev_ws.bsa_project p where p.title = 'Test Project 11111';

        -- Act (use an empty projects)
        ru.bsa_proc_split_revenue_item_among_projects('' || projectId, 'item name 22222', 'item description', '5.00', 'Facebook', 'N', CURRENT_DATE);

        -- Assert (Full assert here, no need to repeat in other tests though)
        SELECT id, salePrice, description, platformSoldOn, isPending, dateSold INTO revenueItemId, salePrice, description, platformSoldOn, isPending, dateSold from BSA_REVENUE_ITEM where name = 'item name 22222' and project_id = projectId;
        ut.expect(revenueItemId).not_to( be_null() );
        ut.expect(salePrice).to_( equal(5.00) );
        ut.expect(description).to_( equal('item description (Split Among Projects: Test Project 11111)') );
        ut.expect(platformSoldOn).to_( equal('Facebook') );
        ut.expect(isPending).to_( equal('N') );
        ut.expect(dateSold).to_( equal(CURRENT_DATE) );
        -- Also assert that this item doesn't exist anywhere else
        SELECT count(id) INTO rowCount from BSA_REVENUE_ITEM where name = 'item name 22222' and project_id = projectId;
        ut.expect(rowCount).to_( equal(1) );
    end;

    procedure test_revenue_item_split_with_two_project_string is
    projectId int;
    projectId1 int;
    revenueItemId int;
    rowCount int;
    salePrice number;
    description varchar2(200);
    begin
        -- Setup
        -- Create two projects
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 11111', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM dev_ws.bsa_project p where p.title = 'Test Project 11111';

        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 33333', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId1 FROM dev_ws.bsa_project p where p.title = 'Test Project 33333';
        -- Act (use an empty projects)
        ru.bsa_proc_split_revenue_item_among_projects('' || projectId || ':' || projectId1, 'item name 22222', 'item description', '5.00', 'Facebook', 'N', CURRENT_DATE);

        -- Assert
        SELECT id, salePrice, description INTO revenueItemId, salePrice, description from BSA_REVENUE_ITEM where name = 'item name 22222' and project_id = projectId1;
        ut.expect(revenueItemId).not_to( be_null() );
        ut.expect(salePrice).to_( equal(2.50) );
        ut.expect(description).to_( equal('item description (Split Among Projects: Test Project 11111, Test Project 33333)') );
        -- Repeat for second project
        SELECT id, salePrice, description INTO revenueItemId, salePrice, description from BSA_REVENUE_ITEM where name = 'item name 22222' and project_id = projectId1;
        ut.expect(revenueItemId).not_to( be_null() );
        ut.expect(salePrice).to_( equal(2.50) );
        ut.expect(description).to_( equal('item description (Split Among Projects: Test Project 11111, Test Project 33333)') );
        -- Also assert that this item doesn't exist in any other projects
        SELECT count(id) INTO rowCount from BSA_REVENUE_ITEM where name = 'item name 22222';
        ut.expect(rowCount).to_( equal(2) );
    end;

    -- Same as above, except using an uneven sale price to show how rounding works
    procedure test_revenue_item_split_with_rounded_value is
    projectId int;
    projectId1 int;
    revenueItemId int;
    rowCount int;
    salePrice number;
    description varchar2(200);
    begin
        -- Setup
        -- Create two projects
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 11111', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM dev_ws.bsa_project p where p.title = 'Test Project 11111';

        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 33333', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId1 FROM dev_ws.bsa_project p where p.title = 'Test Project 33333';
        -- Act (use an empty projects)
        ru.bsa_proc_split_revenue_item_among_projects('' || projectId || ':' || projectId1, 'item name 22222', 'item description', '5.01', 'Facebook', 'N', CURRENT_DATE);

        -- Assert (5.01 / 2 = 2.505, but will be rounded to 2.51)
        SELECT id, salePrice, description INTO revenueItemId, salePrice, description from BSA_REVENUE_ITEM where name = 'item name 22222' and project_id = projectId1;
        ut.expect(revenueItemId).not_to( be_null() );
        ut.expect(salePrice).to_( equal(2.51) );
        ut.expect(description).to_( equal('item description (Split Among Projects: Test Project 11111, Test Project 33333)') );
        -- Repeat for second project
        SELECT id, salePrice, description INTO revenueItemId, salePrice, description from BSA_REVENUE_ITEM where name = 'item name 22222' and project_id = projectId1;
        ut.expect(revenueItemId).not_to( be_null() );
        ut.expect(salePrice).to_( equal(2.51) );
        ut.expect(description).to_( equal('item description (Split Among Projects: Test Project 11111, Test Project 33333)') );
        -- Also assert that this item doesn't exist in any other projects
        SELECT count(id) INTO rowCount from BSA_REVENUE_ITEM where name = 'item name 22222';
        ut.expect(rowCount).to_( equal(2) );
    end;
end test_revenue_item_utilities;
/
