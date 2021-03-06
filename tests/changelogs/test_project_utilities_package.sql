--liquibase formatted sql

--changeset fcerny:1 runOnChange:true endDelimiter:"/" stripComments:false
create or replace package test_project_utilities_package
as
    -- %suite(Test Project Utility Package)

    --%test(Test Project Id String Conversion on Empty String)
    procedure test_project_id_string_conversion_empty;
    --%test(Test Project Id String Conversion on Single Project)
    procedure test_project_id_string_single_project;
    --%test(Test Project Id String Conversion on Multiple Project)
    procedure test_project_id_string_multi_project;
    --%test(Test Project Get Net Value)
    procedure test_project_get_net_value;
    --%test(Test Get Total Bike Cost For Project 0)
    procedure test_project_get_total_bike_cost_zero;
    --%test(Test Get Total Bike Cost For Project Non-Zero)
    procedure test_project_get_total_bike_cost_non_zero;
    --%test(Test Get Total Single Use Supply Cost For Project 0)
    procedure test_project_get_total_single_use_supply_cost_zero;
    --%test(Test Get Total Single Use Supply Cost For Project Non-Zero)
    procedure test_project_get_total_single_use_supply_cost_non_zero;
    --%test(Test Get Total Tool Cost For Project 0)
    procedure test_project_get_total_tool_cost_zero;
    --%test(Test Get Total Tool Cost For Project Non-Zero)
    procedure test_project_get_total_tool_cost_non_zero;
    --%test(Test Get Total Revenue For Project 0)
    procedure test_project_get_total_revenue_zero;
    --%test(Test Get Total Revenue For Project Non-Zero)
    procedure test_project_get_total_revenue_non_zero;
    --%test(Test Get Total Fixed Use Supply Cost For Project 0)
    procedure test_project_get_total_fixed_use_supply_cost_zero;
    --%test(Test Get Total Fixed Use Supply Cost For Project Non-Zero)
    procedure test_project_get_total_fixed_use_supply_cost_non_zero;
    --%test(Test Get Total Non Fixed Use Supply Cost For Project 0)
    procedure test_project_get_total_non_fixed_use_supply_cost_zero;
    --%test(Test Get Total Non Fixed Use Supply Cost For Project Non-Zero)
    procedure test_project_get_total_non_fixed_use_supply_cost_non_zero;
end test_project_utilities_package;
/

--changeset fcerny:2 runOnChange:true endDelimiter:"/" stripComments:false
create or replace package body test_project_utilities_package
as
    -- Inserting a tool into a project for the first time should create a quantity of 1 for that tool for that project
    procedure test_project_id_string_conversion_empty is
        inputString varchar2(50);
        result varchar2(500);
    begin
        inputString := '';
        result := pu.bsa_func_return_project_name_string_from_ids(inputString);
        ut.expect( result ).to_( equal('No Projects Selected') );
    end;

    procedure test_project_id_string_single_project is
        inputString varchar2(50);
        result varchar2(500);
        projectId1 number;
        projectId2 number;
        projectId3 number;
    begin
        -- First seed 3 projects (only one will be used)
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Project 11111', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId1 FROM dev_ws.bsa_project p where p.title = 'Project 11111';

        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Project 22222', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId2 FROM dev_ws.bsa_project p where p.title = 'Project 22222';

        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Project 33333', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId3 FROM dev_ws.bsa_project p where p.title = 'Project 33333';

        -- Craft an input string from the project ids created above
        inputString := ('' || projectId1);
        result := pu.bsa_func_return_project_name_string_from_ids(inputString);
        ut.expect( result ).to_( equal('Project 11111') );
    end;

    procedure test_project_id_string_multi_project is
        inputString varchar2(50);
        result varchar2(500);
        projectId1 number;
        projectId2 number;
        projectId3 number;
    begin
        -- First seed 3 projects (only one will be used)
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Project 11111', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId1 FROM dev_ws.bsa_project p where p.title = 'Project 11111';

        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Project 22222', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId2 FROM dev_ws.bsa_project p where p.title = 'Project 22222';

        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Project 33333', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId3 FROM dev_ws.bsa_project p where p.title = 'Project 33333';

        -- Craft an input string from the project ids created above
        inputString := ('' || projectId1 || ':' || projectId2 || '');
        result := pu.bsa_func_return_project_name_string_from_ids(inputString);
        ut.expect( result ).to_( equal('Project 11111, Project 22222') );
    end;

    procedure test_project_get_net_value is
        projectId1 int;
        projectId2 int;
        projectId3 int;
        toolId int;
        fixedSupplyId int;
        nonFixedSupplyId int;
        netIncome number(10,2);
    begin
        -- Setup
        -- Remove current year values if they exist in the DB
        DELETE 
        FROM dev_ws.bsa_tax_income
        WHERE year in ('2021', '2022');

        -- Add estimated/actual tax values for 2021 (all revenue items will be in 2021)
        INSERT INTO dev_ws.bsa_tax_income (year, income)
        VALUES ('2021', 67500);
        -- First seed 3 projects (only one will be used)
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Project 11111', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId1 FROM dev_ws.bsa_project p where p.title = 'Project 11111';

        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Project 22222', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId2 FROM dev_ws.bsa_project p where p.title = 'Project 22222';

        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Project 33333', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId3 FROM dev_ws.bsa_project p where p.title = 'Project 33333';

        -- Then create one bike for each project
        -- We will focus on project 2, so cost is -27.50 here
        INSERT INTO BSA_BIKE (serialNumber, make, model, year, purchaseprice, purchasedfrom, datepurchased, description, project_id)
        VALUES ('11111', 'Schwinn', 'Tempo', 1988, 35, 'Facebook Marketplace', CURRENT_DATE, 'A simple bike!', projectId1);
        INSERT INTO BSA_BIKE (serialNumber, make, model, year, purchaseprice, purchasedfrom, datepurchased, description, project_id)
        VALUES ('22222', 'Nishiki', 'International', 1988, 27.50, 'Facebook Marketplace', CURRENT_DATE, 'A simple bike!', projectId2);
        INSERT INTO BSA_BIKE (serialNumber, make, model, year, purchaseprice, purchasedfrom, datepurchased, description, project_id)
        VALUES ('33333', 'Cannondale', 'Topstone', 1988, 65, 'Facebook Marketplace', CURRENT_DATE, 'A simple bike!', projectId3);

        -- Then create a single tool and use in two of the projects
        -- Tool cost for project 2 = -3
        INSERT INTO BSA_TOOL (name, description, datepurchased, totalcost)
        VALUES ('Tool 11111', 'A new tool!', CURRENT_DATE, 6);
        SELECT t.id INTO toolId FROM BSA_TOOL t WHERE t.name = 'Tool 11111' and t.datepurchased = CURRENT_DATE;
        -- Insert the tool mapping (via a view for ease of use within the application)
        INSERT INTO bsa_view_project_tool (tool_id, name, ToolDescription, datepurchased, totalcost, project_id)
        VALUES (toolId, NULL, NULL, NULL, NULL, projectId1);
        INSERT INTO bsa_view_project_tool (tool_id, name, ToolDescription, datepurchased, totalcost, project_id)
        VALUES (toolId, NULL, NULL, NULL, NULL, projectId2);

        -- Then create a single use supply on the project
        -- Cost = -7.99
        INSERT INTO dev_ws.bsa_single_use_supply (name, description, datepurchased, project_id, ispending, unitcost, unitspurchased, revenueitem_id)
        VALUES ('postage (11111)', 'description', CURRENT_DATE, projectId2, 'N', 7.99, 1, null);

        -- Then create a fixed use supply and add it to the project
        -- Cost = -1
        INSERT INTO bsa_fixed_quantity_supply(name, description, datepurchased, unitspurchased, totalcost)
        VALUES ('Bubble Wrap 11111', '', CURRENT_DATE, 165, 165);

        SELECT fqs.id INTO fixedSupplyId FROM bsa_fixed_quantity_supply fqs WHERE name = 'Bubble Wrap 11111';

        INSERT INTO bsa_view_project_fixed_supply (supply_id, name, description, datepurchased, unitspurchased, totalcost, quantity, project_id)
        VALUES (fixedSupplyId, null, null, null, null, null, null, projectId2);

        -- Create a non-fixed use supply and add it to 3 projects
        -- Cost = -6
        INSERT INTO bsa_non_fixed_quantity_supply(name, description, datepurchased, cost)
        VALUES ('EvapoRust 11111', '', CURRENT_DATE, 18);

        SELECT nfqs.id INTO nonFixedSupplyId FROM bsa_non_fixed_quantity_supply nfqs WHERE name = 'EvapoRust 11111';

        INSERT INTO bsa_view_project_non_fixed_supply(supply_id, name, description, datepurchased, cost, quantity, project_id)
        VALUES (nonFixedSupplyId, null, null, null, null, null, projectId1);

        INSERT INTO bsa_view_project_non_fixed_supply(supply_id, name, description, datepurchased, cost, quantity, project_id)
        VALUES (nonFixedSupplyId, null, null, null, null, null, projectId2);

        INSERT INTO bsa_view_project_non_fixed_supply(supply_id, name, description, datepurchased, cost, quantity, project_id)
        VALUES (nonFixedSupplyId, null, null, null, null, null, projectId3);

        -- Add revenue item to the project
        -- 30
        INSERT INTO dev_ws.bsa_revenue_item (project_id, name, description, saleprice, platformsoldon, ispending, datesold)
        VALUES (projectId2, 'temp 44444A', 'description', 30, 'Ebay', 'N', Date '2021-04-20');

        -- Tax calculation (see test_tax_utilities_package) = -6.60

        -- Act
        netIncome := pu.bsa_func_calculate_net_project_value(projectId2);

        -- Assert
        ut.expect(netIncome).to_( equal(-22.09) );
    end;

    procedure test_project_get_total_bike_cost_zero is
        cost number(10,2);
        projectId1 int;
        projectId2 int;
    begin
        -- First, create a project
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Project 11111', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId1 FROM dev_ws.bsa_project p where p.title = 'Project 11111';

        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Project 22222', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId2 FROM dev_ws.bsa_project p where p.title = 'Project 22222';

        -- Add a bike to project 2
        INSERT INTO BSA_BIKE (serialNumber, make, model, year, purchaseprice, purchasedfrom, datepurchased, description, project_id)
        VALUES ('22222', 'Schwinn', 'Tempo', 1988, 45.50, 'FBM', CURRENT_DATE, 'A simple bike!', projectId2);

        -- Act
        cost := pu.bsa_func_return_bike_cost_for_project(projectId1);

        -- Assert
        ut.expect(cost).to_( equal(0) );
    end;

    procedure test_project_get_total_bike_cost_non_zero is
        cost number(10,2);
        projectId1 int;
        projectId2 int;
    begin
        -- First, create two projects
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Project 11111', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId1 FROM dev_ws.bsa_project p where p.title = 'Project 11111';

        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Project 22222', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId2 FROM dev_ws.bsa_project p where p.title = 'Project 22222';

        -- Then add bikes to each project
        INSERT INTO BSA_BIKE (serialNumber, make, model, year, purchaseprice, purchasedfrom, datepurchased, description, project_id)
        VALUES ('11111', 'Schwinn', 'Tempo', 1988, 20, 'FBM', CURRENT_DATE, 'A simple bike!', projectId1);

        INSERT INTO BSA_BIKE (serialNumber, make, model, year, purchaseprice, purchasedfrom, datepurchased, description, project_id)
        VALUES ('44444', 'Schwinn', 'Tempo', 1988, 20, 'FBM', CURRENT_DATE, 'A simple bike!', projectId2);

        -- Act
        cost := pu.bsa_func_return_bike_cost_for_project(projectId1);

        -- Assert
        ut.expect(cost).to_( equal(20) );

        -- Now add 2 more bikes and test again

        INSERT INTO BSA_BIKE (serialNumber, make, model, year, purchaseprice, purchasedfrom, datepurchased, description, project_id)
        VALUES ('22222', 'Schwinn', 'Tempo', 1988, 45.50, 'FBM', CURRENT_DATE, 'A simple bike!', projectId1);

        INSERT INTO BSA_BIKE (serialNumber, make, model, year, purchaseprice, purchasedfrom, datepurchased, description, project_id)
        VALUES ('33333', 'Schwinn', 'Tempo', 1988, 127.25, 'FBM', CURRENT_DATE, 'A simple bike!', projectId1);

        INSERT INTO BSA_BIKE (serialNumber, make, model, year, purchaseprice, purchasedfrom, datepurchased, description, project_id)
        VALUES ('55555', 'Schwinn', 'Tempo', 1988, 127.25, 'FBM', CURRENT_DATE, 'A simple bike!', projectId2);

        cost := pu.bsa_func_return_bike_cost_for_project(projectId1);
        ut.expect(cost).to_( equal(192.75) );
    end;

    procedure test_project_get_total_single_use_supply_cost_zero is
        cost number(10,2);
        projectId1 int;
        projectId2 int;
    begin
        -- First, create a project
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Project 11111', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId1 FROM dev_ws.bsa_project p where p.title = 'Project 11111';

        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Project 22222', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId2 FROM dev_ws.bsa_project p where p.title = 'Project 22222';

        -- Add a single use supply to project 2
        INSERT INTO dev_ws.bsa_single_use_supply (name, description, datepurchased, project_id, ispending, unitcost, unitspurchased, revenueitem_id)
        VALUES ('temp supply 11111', 'description', CURRENT_DATE, projectId2, 'Y', 1.50, 10, null);

        -- Act
        cost := pu.bsa_func_return_single_use_supply_cost_for_project(projectId1);

        -- Assert
        ut.expect(cost).to_( equal(0) );
    end;

    procedure test_project_get_total_single_use_supply_cost_non_zero is
        cost number(10,2);
        projectId1 int;
        projectId2 int;
    begin
        -- First, create two projects
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Project 11111', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId1 FROM dev_ws.bsa_project p where p.title = 'Project 11111';

        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Project 22222', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId2 FROM dev_ws.bsa_project p where p.title = 'Project 22222';

        -- Then add bikes to each project
        INSERT INTO dev_ws.bsa_single_use_supply (name, description, datepurchased, project_id, ispending, unitcost, unitspurchased, revenueitem_id)
        VALUES ('temp supply 11111', 'description', CURRENT_DATE, projectId1, 'Y', 1.50, 10, null);

        INSERT INTO dev_ws.bsa_single_use_supply (name, description, datepurchased, project_id, ispending, unitcost, unitspurchased, revenueitem_id)
        VALUES ('temp supply 22222', 'description', CURRENT_DATE, projectId2, 'Y', 1.50, 10, null);

        -- Act
        cost := pu.bsa_func_return_single_use_supply_cost_for_project(projectId1);

        -- Assert
        ut.expect(cost).to_( equal(15) );

        -- Now add 2 more bikes and test again

        INSERT INTO dev_ws.bsa_single_use_supply (name, description, datepurchased, project_id, ispending, unitcost, unitspurchased, revenueitem_id)
        VALUES ('temp supply 33333', 'description', CURRENT_DATE, projectId1, 'Y', 1, 25, null);

        INSERT INTO dev_ws.bsa_single_use_supply (name, description, datepurchased, project_id, ispending, unitcost, unitspurchased, revenueitem_id)
        VALUES ('temp supply 44444', 'description', CURRENT_DATE, projectId1, 'Y', 2, 15.50, null);

        INSERT INTO dev_ws.bsa_single_use_supply (name, description, datepurchased, project_id, ispending, unitcost, unitspurchased, revenueitem_id)
        VALUES ('temp supply 55555', 'description', CURRENT_DATE, projectId2, 'Y', 1.50, 10, null);

        cost := pu.bsa_func_return_single_use_supply_cost_for_project(projectId1);
        ut.expect(cost).to_( equal(71) );
    end;

    procedure test_project_get_total_tool_cost_zero is
        cost number(10,2);
        projectId1 int;
        projectId2 int;
        toolId1 int;
        toolId2 int;
    begin
        -- First, create two projects
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Project 11111', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId1 FROM dev_ws.bsa_project p where p.title = 'Project 11111';

        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Project 22222', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId2 FROM dev_ws.bsa_project p where p.title = 'Project 22222';

        -- Then create some tools
        INSERT INTO BSA_TOOL (name, description, datepurchased, totalcost)
        VALUES ('New Tool 11111', 'A new tool!', CURRENT_DATE, 5);
        SELECT t.id INTO toolId1 FROM BSA_TOOL t WHERE t.name = 'New Tool 11111' and t.datepurchased = CURRENT_DATE;

        INSERT INTO BSA_TOOL (name, description, datepurchased, totalcost)
        VALUES ('New Tool 22222', 'A new tool!', CURRENT_DATE, 25);
        SELECT t.id INTO toolId2 FROM BSA_TOOL t WHERE t.name = 'New Tool 22222' and t.datepurchased = CURRENT_DATE;
        -- Add tool mappings (only to project 2)
        INSERT INTO bsa_view_project_tool (tool_id, name, ToolDescription, datepurchased, totalcost, project_id)
        VALUES (toolId1, NULL, NULL, NULL, NULL, projectId2);
        INSERT INTO bsa_view_project_tool (tool_id, name, ToolDescription, datepurchased, totalcost, project_id)
        VALUES (toolId2, NULL, NULL, NULL, NULL, projectId2);

        -- Act
        cost := pu.bsa_func_return_tool_cost_for_project(projectId1);

        -- Assert
        ut.expect(cost).to_( equal(0) );
    end;

    procedure test_project_get_total_tool_cost_non_zero is
        cost number(10,2);
        projectId1 int;
        projectId2 int;
        toolId1 int;
        toolId2 int;
    begin
        -- First, create two projects
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Project 11111', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId1 FROM dev_ws.bsa_project p where p.title = 'Project 11111';

        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Project 22222', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId2 FROM dev_ws.bsa_project p where p.title = 'Project 22222';

        -- Create tools
        INSERT INTO BSA_TOOL (name, description, datepurchased, totalcost)
        VALUES ('New Tool 11111', 'A new tool!', CURRENT_DATE, 5);
        SELECT t.id INTO toolId1 FROM BSA_TOOL t WHERE t.name = 'New Tool 11111' and t.datepurchased = CURRENT_DATE;

        INSERT INTO BSA_TOOL (name, description, datepurchased, totalcost)
        VALUES ('New Tool 22222', 'A new tool!', CURRENT_DATE, 25);
        SELECT t.id INTO toolId2 FROM BSA_TOOL t WHERE t.name = 'New Tool 22222' and t.datepurchased = CURRENT_DATE;

        -- Add tool mappings
        INSERT INTO bsa_view_project_tool (tool_id, name, ToolDescription, datepurchased, totalcost, project_id)
        VALUES (toolId1, NULL, NULL, NULL, NULL, projectId2);
        INSERT INTO bsa_view_project_tool (tool_id, name, ToolDescription, datepurchased, totalcost, project_id)
        VALUES (toolId2, NULL, NULL, NULL, NULL, projectId2);
        INSERT INTO bsa_view_project_tool (tool_id, name, ToolDescription, datepurchased, totalcost, project_id)
        VALUES (toolId2, NULL, NULL, NULL, NULL, projectId2);

        INSERT INTO bsa_view_project_tool (tool_id, name, ToolDescription, datepurchased, totalcost, project_id)
        VALUES (toolId1, NULL, NULL, NULL, NULL, projectId1);
        INSERT INTO bsa_view_project_tool (tool_id, name, ToolDescription, datepurchased, totalcost, project_id)
        VALUES (toolId2, NULL, NULL, NULL, NULL, projectId1);

        -- Act
        cost := pu.bsa_func_return_tool_cost_for_project(projectId1);

        -- Assert
        -- Tool 1 has cost 5, number of uses = 2 (2.50 per use)
        -- Tool 2 has cost 25, number of uses = 3 (8.33)
        ut.expect(cost).to_( equal(10.83) );
    end;

    procedure test_project_get_total_revenue_zero is
        cost number(10,2);
        projectId1 int;
        projectId2 int;
    begin
        -- First, create two projects
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Project 11111', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId1 FROM dev_ws.bsa_project p where p.title = 'Project 11111';

        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Project 22222', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId2 FROM dev_ws.bsa_project p where p.title = 'Project 22222';

        -- Then create some revenue items
        INSERT INTO dev_ws.bsa_revenue_item (project_id, name, description, saleprice, platformsoldon, ispending, datesold)
        VALUES (projectId2, 'temp 11111', 'description', 5.50, 'Ebay', 'N', CURRENT_DATE);
        INSERT INTO dev_ws.bsa_revenue_item (project_id, name, description, saleprice, platformsoldon, ispending, datesold)
        VALUES (projectId2, 'temp 22222', 'description', 5.50, 'Ebay', 'N', CURRENT_DATE);

        -- Act
        cost := pu.bsa_func_return_revenue_for_project(projectId1);

        -- Assert
        ut.expect(cost).to_( equal(0) );
    end;

    procedure test_project_get_total_revenue_non_zero is
        cost number(10,2);
        projectId1 int;
        projectId2 int;
        toolId1 int;
        toolId2 int;
    begin
        -- First, create two projects
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Project 11111', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId1 FROM dev_ws.bsa_project p where p.title = 'Project 11111';

        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Project 22222', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId2 FROM dev_ws.bsa_project p where p.title = 'Project 22222';

        -- Create revenue items
        INSERT INTO dev_ws.bsa_revenue_item (project_id, name, description, saleprice, platformsoldon, ispending, datesold)
        VALUES (projectId2, 'temp 11111', 'description', 10, 'Ebay', 'N', CURRENT_DATE);
        INSERT INTO dev_ws.bsa_revenue_item (project_id, name, description, saleprice, platformsoldon, ispending, datesold)
        VALUES (projectId2, 'temp 22222', 'description', 5.50, 'Ebay', 'N', CURRENT_DATE);
        INSERT INTO dev_ws.bsa_revenue_item (project_id, name, description, saleprice, platformsoldon, ispending, datesold)
        VALUES (projectId1, 'temp 33333', 'description', 10, 'Ebay', 'N', CURRENT_DATE);
        INSERT INTO dev_ws.bsa_revenue_item (project_id, name, description, saleprice, platformsoldon, ispending, datesold)
        VALUES (projectId1, 'temp 44444', 'description', 5.50, 'Ebay', 'N', CURRENT_DATE);

        -- Act
        cost := pu.bsa_func_return_revenue_for_project(projectId1);

        -- Assert
        ut.expect(cost).to_( equal(15.50) );
    end;

    procedure test_project_get_total_fixed_use_supply_cost_zero is
        cost number(10,2);
        projectId1 int;
        projectId2 int;
        supplyId1 int;
        supplyId2 int;
    begin
        -- First, create two projects
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Project 11111', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId1 FROM dev_ws.bsa_project p where p.title = 'Project 11111';

        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Project 22222', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId2 FROM dev_ws.bsa_project p where p.title = 'Project 22222';

        -- Add fixed use supplies and mappings
        INSERT INTO bsa_fixed_quantity_supply(name, description, datepurchased, unitspurchased, totalcost)
        VALUES ('Bubble Wrap 11111', '', CURRENT_DATE, 165, 165);
        SELECT fqs.id INTO supplyId1 FROM bsa_fixed_quantity_supply fqs WHERE name = 'Bubble Wrap 11111';

        INSERT INTO bsa_fixed_quantity_supply(name, description, datepurchased, unitspurchased, totalcost)
        VALUES ('Bubble Wrap 22222', '', CURRENT_DATE, 10, 150);
        SELECT fqs.id INTO supplyId2 FROM bsa_fixed_quantity_supply fqs WHERE name = 'Bubble Wrap 22222';
        -- Mappings
        INSERT INTO bsa_view_project_fixed_supply (supply_id, name, description, datepurchased, unitspurchased, totalcost, quantity, project_id)
        VALUES (supplyId1, null, null, null, null, null, null, projectId2);
        INSERT INTO bsa_view_project_fixed_supply (supply_id, name, description, datepurchased, unitspurchased, totalcost, quantity, project_id)
        VALUES (supplyId2, null, null, null, null, null, null, projectId2);

        -- Act
        cost := pu.bsa_func_return_fixed_supply_cost_for_project(projectId1);

        -- Assert
        ut.expect(cost).to_( equal(0) );
    end;

    procedure test_project_get_total_fixed_use_supply_cost_non_zero is
        cost number(10,2);
        projectId1 int;
        projectId2 int;
        supplyId1 int;
        supplyId2 int;
    begin
        -- First, create two projects
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Project 11111', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId1 FROM dev_ws.bsa_project p where p.title = 'Project 11111';

        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Project 22222', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId2 FROM dev_ws.bsa_project p where p.title = 'Project 22222';

        -- Add fixed use supplies and mappings
        INSERT INTO bsa_fixed_quantity_supply(name, description, datepurchased, unitspurchased, totalcost)
        VALUES ('Bubble Wrap 11111', '', CURRENT_DATE, 165, 165);
        SELECT fqs.id INTO supplyId1 FROM bsa_fixed_quantity_supply fqs WHERE name = 'Bubble Wrap 11111';

        INSERT INTO bsa_fixed_quantity_supply(name, description, datepurchased, unitspurchased, totalcost)
        VALUES ('Bubble Wrap 22222', '', CURRENT_DATE, 10, 150);
        SELECT fqs.id INTO supplyId2 FROM bsa_fixed_quantity_supply fqs WHERE name = 'Bubble Wrap 22222';
        -- Mappings
        INSERT INTO bsa_view_project_fixed_supply (supply_id, name, description, datepurchased, unitspurchased, totalcost, quantity, project_id)
        VALUES (supplyId1, null, null, null, null, null, null, projectId1);
        INSERT INTO bsa_view_project_fixed_supply (supply_id, name, description, datepurchased, unitspurchased, totalcost, quantity, project_id)
        VALUES (supplyId2, null, null, null, null, null, null, projectId1);
        INSERT INTO bsa_view_project_fixed_supply (supply_id, name, description, datepurchased, unitspurchased, totalcost, quantity, project_id)
        VALUES (supplyId2, null, null, null, null, null, null, projectId1);
        INSERT INTO bsa_view_project_fixed_supply (supply_id, name, description, datepurchased, unitspurchased, totalcost, quantity, project_id)
        VALUES (supplyId1, null, null, null, null, null, null, projectId2);
        INSERT INTO bsa_view_project_fixed_supply (supply_id, name, description, datepurchased, unitspurchased, totalcost, quantity, project_id)
        VALUES (supplyId2, null, null, null, null, null, null, projectId2);

        -- Act
        -- Supply 1 has cost basis (165/165) = 1/use, project 1 uses it once ($1)
        -- Supply 2 has cost basis (150/10) = 15/use, project 1 uses it twice ($30)
        cost := pu.bsa_func_return_fixed_supply_cost_for_project(projectId1);

        -- Assert
        ut.expect(cost).to_( equal(31) );
    end;

    procedure test_project_get_total_non_fixed_use_supply_cost_zero is
        cost number(10,2);
        projectId1 int;
        projectId2 int;
        supplyId1 int;
        supplyId2 int;
    begin
        -- First, create two projects
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Project 11111', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId1 FROM dev_ws.bsa_project p where p.title = 'Project 11111';

        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Project 22222', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId2 FROM dev_ws.bsa_project p where p.title = 'Project 22222';

        -- Add non-fixed use supplies and mappings
        INSERT INTO bsa_non_fixed_quantity_supply(name, description, datepurchased, cost)
        VALUES ('EvapoRust 99999', '', CURRENT_DATE, 15.67);
        SELECT nfqs.id INTO supplyId1 FROM bsa_non_fixed_quantity_supply nfqs WHERE name = 'EvapoRust 99999';

        INSERT INTO bsa_non_fixed_quantity_supply(name, description, datepurchased, cost)
        VALUES ('EvapoRust 33333', '', CURRENT_DATE, 15.67);
        SELECT nfqs.id INTO supplyId2 FROM bsa_non_fixed_quantity_supply nfqs WHERE name = 'EvapoRust 33333';
        -- Mappings
        INSERT INTO bsa_view_project_non_fixed_supply(supply_id, name, description, datepurchased, cost, quantity, project_id)
        VALUES (supplyId1, null, null, null, null, null, projectId2);
        INSERT INTO bsa_view_project_non_fixed_supply(supply_id, name, description, datepurchased, cost, quantity, project_id)
        VALUES (supplyId2, null, null, null, null, null, projectId2);

        -- Act
        cost := pu.bsa_func_return_non_fixed_supply_cost_for_project(projectId1);

        -- Assert
        ut.expect(cost).to_( equal(0) );
    end;

    procedure test_project_get_total_non_fixed_use_supply_cost_non_zero is
        cost number(10,2);
        projectId1 int;
        projectId2 int;
        supplyId1 int;
        supplyId2 int;
    begin
        -- First, create two projects
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Project 11111', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId1 FROM dev_ws.bsa_project p where p.title = 'Project 11111';

        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Project 22222', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId2 FROM dev_ws.bsa_project p where p.title = 'Project 22222';

        -- Add non-fixed use supplies and mappings
        INSERT INTO bsa_non_fixed_quantity_supply(name, description, datepurchased, cost)
        VALUES ('EvapoRust 99999', '', CURRENT_DATE, 30);
        SELECT nfqs.id INTO supplyId1 FROM bsa_non_fixed_quantity_supply nfqs WHERE name = 'EvapoRust 99999';

        INSERT INTO bsa_non_fixed_quantity_supply(name, description, datepurchased, cost)
        VALUES ('EvapoRust 33333', '', CURRENT_DATE, 100);
        SELECT nfqs.id INTO supplyId2 FROM bsa_non_fixed_quantity_supply nfqs WHERE name = 'EvapoRust 33333';
        -- Mappings
        INSERT INTO bsa_view_project_non_fixed_supply(supply_id, name, description, datepurchased, cost, quantity, project_id)
        VALUES (supplyId1, null, null, null, null, null, projectId1);
        INSERT INTO bsa_view_project_non_fixed_supply(supply_id, name, description, datepurchased, cost, quantity, project_id)
        VALUES (supplyId2, null, null, null, null, null, projectId2);

        -- Act
        -- Supply 1 is used once, by project 1, costs $30
        -- Supply 2 is used once, by project 2, costs $100
        cost := pu.bsa_func_return_non_fixed_supply_cost_for_project(projectId1);

        -- Assert
        ut.expect(cost).to_( equal(30) );

        -- Use the supplies more then test again
        INSERT INTO bsa_view_project_non_fixed_supply(supply_id, name, description, datepurchased, cost, quantity, project_id)
        VALUES (supplyId1, null, null, null, null, null, projectId1);
        INSERT INTO bsa_view_project_non_fixed_supply(supply_id, name, description, datepurchased, cost, quantity, project_id)
        VALUES (supplyId1, null, null, null, null, null, projectId2);
        INSERT INTO bsa_view_project_non_fixed_supply(supply_id, name, description, datepurchased, cost, quantity, project_id)
        VALUES (supplyId2, null, null, null, null, null, projectId1);
        INSERT INTO bsa_view_project_non_fixed_supply(supply_id, name, description, datepurchased, cost, quantity, project_id)
        VALUES (supplyId2, null, null, null, null, null, projectId2);

        -- Now supply 1 is used 3 times, 2x project1, 1x project 2 ($20)
        -- Supply 2 is used 3 times, 2x project1, 1x project 1 ($33.30)
        cost := pu.bsa_func_return_non_fixed_supply_cost_for_project(projectId1);
        ut.expect(cost).to_( equal(53.33) );
    end;
end test_project_utilities_package;
/
