
  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "DEV_WS"."TEST_PROJECT_UTILITIES_PACKAGE" 
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
end test_project_utilities_package;