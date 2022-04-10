
  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "DEV_WS"."TEST_TRIGGERS" 
as
    procedure test_trigger_insert_project_tool_insert is
    toolId int;
    projectId int;
    joinId int;
    quantity int;
    begin
        -- Setup
        -- Create a project and a tool
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 112233', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM dev_ws.bsa_project p where p.title = 'Test Project 112233';
        INSERT INTO dev_ws.bsa_tool (name, description, datepurchased, totalcost)
        VALUES ('New Tool 112233', 'A new tool!', CURRENT_DATE, 5.67);
        SELECT t.id INTO toolId FROM dev_ws.bsa_tool t WHERE t.name = 'New Tool 112233' and t.datepurchased = CURRENT_DATE;
        -- Act 
        -- Insert into View (which should trigger the trigger)
        INSERT INTO bsa_view_project_tool (tool_id, name, ToolDescription, datepurchased, totalcost, project_id, quantity, unitcost, costbasis)
        VALUES (toolId, NULL, NULL, NULL, NULL, projectId, NULL, NULL, NULL);
        -- Assert
        -- If there is a record in the join table then we know that it worked
        SELECT pt.id, pt.quantity INTO joinId, quantity FROM dev_ws.bsa_project_tool pt WHERE tool_id = toolId and project_id = projectId;
        -- Quantity should be 1 since we added a single tool to a single project (this also proves there is an entry in the join table)
        ut.expect( joinId ).not_to( be_null() );
        ut.expect( quantity ).to_( equal(1) );
    end;
end test_triggers;
