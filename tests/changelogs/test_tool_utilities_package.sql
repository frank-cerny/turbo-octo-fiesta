--liquibase formatted sql

--changeset fcerny:1 runOnChange:true endDelimiter:"/" stripComments:false failOnError:true
create or replace package test_tool_utilities
as
    -- %suite(Test Tool Utilities)

    --%test(Test Get Tool Usage 0)
    procedure test_tool_usage_zero;
    --%test(Test Get Tool Usage Not 0 Single Project)
    procedure test_tool_usage_not_zero_single_project;
    --%test(Test Get Tool Usage Not 0 Multi-Project)
    procedure test_tool_usage_not_zero_multi_project;
    --%test(Test Get Tool Unit Cost 0)
    procedure test_tool_unit_cost_0;
    --%test(Test Get Tool Unit Cost Not 0 Single Project)
    procedure test_tool_unit_cost_non_zero_single_project;
    --%test(Test Get Tool Unit Cost Not 0 Multi-Project)
    procedure test_tool_unit_cost_non_zero_multi_project;
end test_tool_utilities;
/

--changeset fcerny:2 runOnChange:true endDelimiter:"/" stripComments:false failOnError:true
create or replace package body test_tool_utilities
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
end test_tool_utilities;
/
