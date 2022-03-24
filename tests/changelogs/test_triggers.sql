--liquibase formatted sql

--changeset fcerny:1 runOnChange:true endDelimiter:"/"
create or replace package test_triggers
as
    -- %suite(Test Triggers)

    --%test(Test Trigger Insert Project Tool With insert)
    procedure test_trigger_insert_project_tool_insert;
    --%test(Test Trigger Insert Project Tool with upsert)
    procedure test_trigger_insert_project_tool_upsert;
end test_fixed_supp_utitlities;
/

--changeset fcerny:2 runOnChange:true endDelimiter:"/"
create or replace package body test_triggers
as
    procedure test_trigger_insert_project_tool_insert is
    toolId int;
    projectId int;
    joinId int;
    quantity int;
    begin
        -- Setup
        -- Create a project and a tool
        INSERT INTO frankcerny.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 112233', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM frankcerny.bsa_project p where p.title = 'Test Project 112233';
        INSERT INTO frankcerny.bsa_tool (name, description, datepurchased, totalcost)
        VALUES ('New Tool 112233', 'A new tool!', CURRENT_DATE, 5.67);
        SELECT t.id INTO toolId FROM frankcerny.bsa_tool t WHERE t.name = 'New Tool 112233' and t.datepurchased = CURRENT_DATE;
        -- Act 
        -- Insert into View (which should trigger the trigger)
        INSERT INTO bsa_view_project_tool (tool_id, name, ToolDescription, datepurchased, totalcost, project_id)
        VALUES (toolId, NULL, NULL, NULL, NULL, projectId);
        -- Assert
        -- If there is a record in the join table then we know that it worked
        SELECT pt.id, pt.quantity INTO joinId, quantity FROM frankcerny.bsa_project_tool pt WHERE tool_id = toolId and project_id = projectId;
        ut.expect(unitsRemaining).to_( equal(165) );
        -- Also validate that the associated quantity is = 0
        ut.expect( quantity ).to_be_null();
    end;
end test_triggers;
/
