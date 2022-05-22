
  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "DEV_WS"."TEST_TOOL_UTILITIES" 
as
    procedure test_tool_usage_zero is
    projectId NUMBER;
    toolId NUMBER;
    usages NUMBER;
    begin
        -- Setup
        -- Create a project
        INSERT INTO dev_ws.BSA_PROJECT (description, title, datestarted, dateended)
        VALUES ('Tools test', 'Tools test', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM BSA_PROJECT p WHERE p.title = 'Tools test';
        -- Create a tool
        INSERT INTO dev_ws.BSA_TOOL (name, description, datepurchased, totalcost)
        VALUES ('testTool', 'testTool', CURRENT_DATE, 5.67);
        SELECT t.id INTO toolId FROM BSA_TOOL t WHERE t.name = 'testTool' and t.datepurchased = CURRENT_DATE;
        -- Act
        usages := dev_ws.TU.bsa_func_get_tool_total_usage(toolId);
        -- Assert
        -- Since the tool was not used, the function should return 0
        ut.expect(usages).to_( equal(0) );
    end;

    procedure test_tool_usage_not_zero_single_project is
    projectId NUMBER;
    toolId NUMBER;
    usages NUMBER;
    begin
        -- Setup
        -- Create a project
        INSERT INTO dev_ws.BSA_PROJECT (description, title, datestarted, dateended)
        VALUES ('Tools test', 'Tools test', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM BSA_PROJECT p WHERE p.title = 'Tools test';
        -- Create a tool
        INSERT INTO dev_ws.BSA_TOOL (name, description, datepurchased, totalcost)
        VALUES ('testTool', 'testTool', CURRENT_DATE, 5.67);
        SELECT t.id INTO toolId FROM BSA_TOOL t WHERE t.name = 'testTool' and t.datepurchased = CURRENT_DATE;
        -- Add a mapping of project to tool (so the tool has been used)
        INSERT INTO BSA_PROJECT_TOOL(project_id, tool_id, quantity)
        VALUES (projectId, toolId, 5);
        -- Act
        usages := dev_ws.TU.bsa_func_get_tool_total_usage(toolId);
        -- Assert
        ut.expect(usages).to_( equal(5) );
    end;

    procedure test_tool_usage_not_zero_multi_project is
    projectId NUMBER;
    projectId1 NUMBER;
    toolId NUMBER;
    usages NUMBER;
    begin
        -- Setup
        -- Create a project
        INSERT INTO BSA_PROJECT (description, title, datestarted, dateended) VALUES ('Tools test', 'Tools test', CURRENT_DATE, NULL);
        INSERT INTO BSA_PROJECT (description, title, datestarted, dateended) VALUES ('Tools test 1', 'Tools test 1', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM BSA_PROJECT p WHERE p.title = 'Tools test';
        SELECT p.id INTO projectId1 FROM BSA_PROJECT p WHERE p.title = 'Tools test 1';
        -- Create a tool
        INSERT INTO BSA_TOOL (name, description, datepurchased, totalcost)
        VALUES ('testTool', 'testTool', CURRENT_DATE, 5.67);
        SELECT t.id INTO toolId FROM BSA_TOOL t WHERE t.name = 'testTool' and t.datepurchased = CURRENT_DATE;
        -- Add mappings of project to tool (so the tool has been used)
        INSERT INTO BSA_PROJECT_TOOL(project_id, tool_id, quantity) VALUES (projectId, toolId, 5);
        INSERT INTO BSA_PROJECT_TOOL(project_id, tool_id, quantity) VALUES (projectId1, toolId, 50);
        -- Act
        usages := dev_ws.TU.bsa_func_get_tool_total_usage(toolId);
        -- Assert
        ut.expect(usages).to_( equal(55) );
    end;

    -- Unit Cost Tests
    procedure test_tool_unit_cost_0 is
    projectId NUMBER;
    toolId NUMBER;
    unitCost NUMBER;
    begin
        -- Setup
        -- Create a project
        INSERT INTO BSA_PROJECT (description, title, datestarted, dateended)
        VALUES ('Tools test', 'Tools test', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM BSA_PROJECT p WHERE p.title = 'Tools test';
        -- Create a tool
        INSERT INTO BSA_TOOL (name, description, datepurchased, totalcost)
        VALUES ('testTool', 'testTool', CURRENT_DATE, 5.67);
        SELECT t.id INTO toolId FROM BSA_TOOL t WHERE t.name = 'testTool' and t.datepurchased = CURRENT_DATE;
        -- Act
        unitCost := dev_ws.TU.bsa_func_get_tool_unit_cost(toolId);
        -- Assert
        -- Since the tool was not used, the function should return null (but not throw an exception)
        ut.expect(unitCost).to_( be_null() );
    end;

    procedure test_tool_unit_cost_non_zero_single_project is
    projectId NUMBER;
    toolId NUMBER;
    unitCost NUMBER;
    begin
        -- Setup
        -- Create a project
        INSERT INTO BSA_PROJECT (description, title, datestarted, dateended)
        VALUES ('Tools test', 'Tools test', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM BSA_PROJECT p WHERE p.title = 'Tools test';
        -- Create a tool
        INSERT INTO BSA_TOOL (name, description, datepurchased, totalcost)
        VALUES ('testTool', 'testTool', CURRENT_DATE, 5.50);
        SELECT t.id INTO toolId FROM BSA_TOOL t WHERE t.name = 'testTool' and t.datepurchased = CURRENT_DATE;
        -- Attach the tool to the project
        INSERT INTO BSA_PROJECT_TOOL(project_id, tool_id, quantity) VALUES (projectId, toolId, 5);
        -- Act
        unitCost := dev_ws.TU.bsa_func_get_tool_unit_cost(toolId);
        -- Assert
        -- Since the tool was not used, the function should return null (but not throw an exception)
        -- 5.50 / 5 = 1.10
        ut.expect(unitCost).to_( equal(1.10) );
    end;

    procedure test_tool_unit_cost_non_zero_multi_project is
    projectId NUMBER;
    projectId1 NUMBER;
    toolId NUMBER;
    unitCost NUMBER;
    begin
        -- Setup
        -- Create two projects
        INSERT INTO BSA_PROJECT (description, title, datestarted, dateended) VALUES ('Tools test', 'Tools test', CURRENT_DATE, NULL);
        INSERT INTO BSA_PROJECT (description, title, datestarted, dateended) VALUES ('Tools test 1', 'Tools test 1', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM BSA_PROJECT p WHERE p.title = 'Tools test';
        SELECT p.id INTO projectId1 FROM BSA_PROJECT p WHERE p.title = 'Tools test 1';
        -- Create a tool
        INSERT INTO BSA_TOOL (name, description, datepurchased, totalcost)
        VALUES ('testTool', 'testTool', CURRENT_DATE, 10);
        SELECT t.id INTO toolId FROM BSA_TOOL t WHERE t.name = 'testTool' and t.datepurchased = CURRENT_DATE;
        -- Attach the tool to each of the projects
        INSERT INTO BSA_PROJECT_TOOL(project_id, tool_id, quantity) VALUES (projectId, toolId, 5);
        INSERT INTO BSA_PROJECT_TOOL(project_id, tool_id, quantity) VALUES (projectId1, toolId, 6);
        -- Act
        unitCost := dev_ws.TU.bsa_func_get_tool_unit_cost(toolId);
        -- Assert
        -- Since the tool was not used, the function should return null (but not throw an exception)
        -- 10 / 11 = .91 (rounded to 2 decimal places)
        ut.expect(unitCost).to_( equal(.91) );
    end;

    procedure test_tool_split_none is
    projectId NUMBER;
    toolId NUMBER;
    id number;
    quantity number;
    begin
        -- Setup
        -- Create a project
        INSERT INTO BSA_PROJECT (description, title, datestarted, dateended) VALUES ('Tools test', 'Tools test', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM BSA_PROJECT p WHERE p.title = 'Tools test';
        -- Create a tool
        INSERT INTO BSA_TOOL (name, description, datepurchased, totalcost)
        VALUES ('testTool', 'testTool', CURRENT_DATE, 10);
        SELECT t.id INTO toolId FROM BSA_TOOL t WHERE t.name = 'testTool' and t.datepurchased = CURRENT_DATE;
        -- Act
        -- Pass empty strings to show they are handled correctly
        tu.bsa_func_split_tools_over_projects('', '');
        -- Assert
        -- The tool should not have been added to the project, so this should throw a no_data_found exception
        SELECT bpt.id, bpt.quantity INTO id, quantity from BSA_PROJECT_TOOL bpt WHERE project_id = projectId AND tool_id = toolId;
    end;

    procedure test_tool_split_among_single_project_first_insert is
    projectId NUMBER;
    toolId NUMBER;
    id number;
    quantity number;
    begin
        -- Setup
        -- Create a project
        INSERT INTO BSA_PROJECT (description, title, datestarted, dateended) VALUES ('Tools test', 'Tools test', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM BSA_PROJECT p WHERE p.title = 'Tools test';
        -- Create a tool
        INSERT INTO BSA_TOOL (name, description, datepurchased, totalcost)
        VALUES ('testTool', 'testTool', CURRENT_DATE, 10);
        SELECT t.id INTO toolId FROM BSA_TOOL t WHERE t.name = 'testTool' and t.datepurchased = CURRENT_DATE;
        -- Act
        tu.bsa_func_split_tools_over_projects('' || toolId, '' || projectId);
        -- Assert
        -- Look for the tool to be added to the join table
        SELECT bpt.id, bpt.quantity INTO id, quantity from BSA_PROJECT_TOOL bpt WHERE project_id = projectId AND tool_id = toolId;
        ut.expect(id).not_to( be_null() );
        ut.expect(quantity).to_( equal(1) );
    end;

    procedure test_tool_split_among_single_project_upsert is
    projectId NUMBER;
    toolId NUMBER;
    id number;
    quantity number;
    begin
        -- Setup
        -- Create a project
        INSERT INTO BSA_PROJECT (description, title, datestarted, dateended) VALUES ('Tools test', 'Tools test', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM BSA_PROJECT p WHERE p.title = 'Tools test';
        -- Create a tool
        INSERT INTO BSA_TOOL (name, description, datepurchased, totalcost)
        VALUES ('testTool', 'testTool', CURRENT_DATE, 10);
        SELECT t.id INTO toolId FROM BSA_TOOL t WHERE t.name = 'testTool' and t.datepurchased = CURRENT_DATE;
        -- Add mappings of project to tool (so the tool has been used)
        INSERT INTO BSA_PROJECT_TOOL(project_id, tool_id, quantity) VALUES (projectId, toolId, 5);
        -- Act
        tu.bsa_func_split_tools_over_projects('' || toolId, '' || projectId);
        -- Assert
        -- Look for the tool to be added to the join table
        SELECT bpt.id, bpt.quantity INTO id, quantity from BSA_PROJECT_TOOL bpt WHERE project_id = projectId AND tool_id = toolId;
        ut.expect(id).not_to( be_null() );
        ut.expect(quantity).to_( equal(6) );
    end;

    procedure test_tool_split_among_multiple_projects_first_insert is
    projectId NUMBER;
    projectId1 NUMBER;
    toolId NUMBER;
    id number;
    quantity number;
    begin
        -- Setup
        -- Create two projects
        INSERT INTO BSA_PROJECT (description, title, datestarted, dateended) VALUES ('Tools test', 'Tools test', CURRENT_DATE, NULL);
        INSERT INTO BSA_PROJECT (description, title, datestarted, dateended) VALUES ('Tools test 1', 'Tools test 1', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM BSA_PROJECT p WHERE p.title = 'Tools test';
        SELECT p.id INTO projectId1 FROM BSA_PROJECT p WHERE p.title = 'Tools test 1';
        -- Create a tool
        INSERT INTO BSA_TOOL (name, description, datepurchased, totalcost)
        VALUES ('testTool', 'testTool', CURRENT_DATE, 10);
        SELECT t.id INTO toolId FROM BSA_TOOL t WHERE t.name = 'testTool' and t.datepurchased = CURRENT_DATE;
        -- Act
        tu.bsa_func_split_tools_over_projects('' || toolId, '' || projectId || ':' || projectId1);
        -- Assert
        -- Look for the tool to be added to the join table for both projects
        SELECT bpt.id, bpt.quantity INTO id, quantity from BSA_PROJECT_TOOL bpt WHERE project_id = projectId AND tool_id = toolId;
        ut.expect(id).not_to( be_null() );
        ut.expect(quantity).to_( equal(1) );
        SELECT bpt.id, bpt.quantity INTO id, quantity from BSA_PROJECT_TOOL bpt WHERE project_id = projectId1 AND tool_id = toolId;
        ut.expect(id).not_to( be_null() );
        ut.expect(quantity).to_( equal(1) );
    end;

    procedure test_multi_tool_split_among_multiple_projects_first_insert is
    projectId NUMBER;
    projectId1 NUMBER;
    toolId NUMBER;
    toolId1 NUMBER;
    id number;
    quantity number;
    begin
        -- Setup
        -- Create two projects
        INSERT INTO BSA_PROJECT (description, title, datestarted, dateended) VALUES ('Tools test', 'Tools test', CURRENT_DATE, NULL);
        INSERT INTO BSA_PROJECT (description, title, datestarted, dateended) VALUES ('Tools test 1', 'Tools test 1', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM BSA_PROJECT p WHERE p.title = 'Tools test';
        SELECT p.id INTO projectId1 FROM BSA_PROJECT p WHERE p.title = 'Tools test 1';
        -- Create two tools
        INSERT INTO BSA_TOOL (name, description, datepurchased, totalcost)
        VALUES ('11111', 'testTool', CURRENT_DATE, 10);
        SELECT t.id INTO toolId FROM BSA_TOOL t WHERE t.name = '11111' and t.datepurchased = CURRENT_DATE;
        INSERT INTO BSA_TOOL (name, description, datepurchased, totalcost)
        VALUES ('22222', 'testTool', CURRENT_DATE, 10);
        SELECT t.id INTO toolId1 FROM BSA_TOOL t WHERE t.name = '22222' and t.datepurchased = CURRENT_DATE;
        -- Act (create a colon separated string to mirror a shuttle list output)
        tu.bsa_func_split_tools_over_projects('' || toolId || ':' || toolId1 , '' || projectId || ':' || projectId1);
        -- Assert
        -- Look for both tools to be added to the join table for both projects
        SELECT bpt.id, bpt.quantity INTO id, quantity from BSA_PROJECT_TOOL bpt WHERE project_id = projectId AND tool_id = toolId;
        ut.expect(id).not_to( be_null() );
        ut.expect(quantity).to_( equal(1) );
        SELECT bpt.id, bpt.quantity INTO id, quantity from BSA_PROJECT_TOOL bpt WHERE project_id = projectId AND tool_id = toolId1;
        ut.expect(id).not_to( be_null() );
        ut.expect(quantity).to_( equal(1) );
        SELECT bpt.id, bpt.quantity INTO id, quantity from BSA_PROJECT_TOOL bpt WHERE project_id = projectId1 AND tool_id = toolId;
        ut.expect(id).not_to( be_null() );
        ut.expect(quantity).to_( equal(1) );
        SELECT bpt.id, bpt.quantity INTO id, quantity from BSA_PROJECT_TOOL bpt WHERE project_id = projectId1 AND tool_id = toolId1;
        ut.expect(id).not_to( be_null() );
        ut.expect(quantity).to_( equal(1) );
    end;
end test_tool_utilities;