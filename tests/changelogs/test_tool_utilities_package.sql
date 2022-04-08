--liquibase formatted sql

--changeset fcerny:1 runOnChange:true endDelimiter:"/"
create or replace package test_tool_utilities
as
    -- %suite(Test Tool Utilities)

    --%test(Test Get Tool Usage 0)
    procedure test_tool_usage_zero;
    --%test(Test Get Tool Usage Not 0 Single Project)
    procedure test_tool_usage_not_zero_single_project;
    --%test(Test Get Tool Usage Not 0 Multi-Project)
    procedure test_tool_usage_not_zero_multi_project;
end test_tool_utilities;
/

--changeset fcerny:2 runOnChange:true endDelimiter:"/"
create or replace package body test_tool_utilities
as
    procedure test_tool_usage_zero is
    projectId NUMBER;
    toolId NUMBER;
    usages NUMBER;
    begin
        -- Setup
        -- Create a project
        INSERT INTO BSA_PROJECT (description, title, datestarted, dateended)
        VALUES ('Tools test', 'Tools test', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM BSA_PROJECT p WHERE p.title = 'Tools test';
        -- Create a tool
        INSERT INTO BSA_TOOL (name, description, datepurchased, totalcost)
        VALUES ('testTool', 'testTool', CURRENT_DATE, 5.67);
        SELECT t.id INTO toolId FROM BSA_TOOL t WHERE t.name = 'TestTool' and t.datepurchased = CURRENT_DATE;
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
        INSERT INTO BSA_PROJECT (description, title, datestarted, dateended)
        VALUES ('Tools test', 'Tools test', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM BSA_PROJECT p WHERE p.title = 'Tools test';
        -- Create a tool
        INSERT INTO BSA_TOOL (name, description, datepurchased, totalcost)
        VALUES ('testTool', 'testTool', CURRENT_DATE, 5.67);
        SELECT t.id INTO toolId FROM BSA_TOOL t WHERE t.name = 'TestTool' and t.datepurchased = CURRENT_DATE;
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
        INSERT INTO BSA_PROJECT (description, title, datestarted, dateended)
        VALUES ('Tools test', 'Tools test', CURRENT_DATE, NULL),
               ('Tools test 1', 'Tools test 1', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM BSA_PROJECT p WHERE p.title = 'Tools test';
        SELECT p.id INTO projectId1 FROM BSA_PROJECT p WHERE p.title = 'Tools test 1';
        -- Create a tool
        INSERT INTO BSA_TOOL (name, description, datepurchased, totalcost)
        VALUES ('testTool', 'testTool', CURRENT_DATE, 5.67);
        SELECT t.id INTO toolId FROM BSA_TOOL t WHERE t.name = 'TestTool' and t.datepurchased = CURRENT_DATE;
        -- Add mappings of project to tool (so the tool has been used)
        INSERT INTO BSA_PROJECT_TOOL(project_id, tool_id, quantity)
        VALUES (projectId, toolId, 5),
               (projectId1, toolId, 50);
        -- Act
        usages := dev_ws.TU.bsa_func_get_tool_total_usage(toolId);
        -- Assert
        ut.expect(usages).to_( equal(55) );
    end;
end test_tool_utilities;
/
