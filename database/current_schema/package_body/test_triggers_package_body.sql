
  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "DEV_WS"."TEST_TRIGGERS" 
as
    -- Inserting a tool into a project for the first time should create a quantity of 1 for that tool for that project
    procedure test_trigger_insert_project_tool_insert_single_project is
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

    -- Each project should be independent in terms of adding tools
    procedure test_trigger_insert_project_tool_insert_multi_project is
    toolId int;
    projectId int;
    projectId1 int;
    joinId int;
    quantity int;
    begin
        -- Setup
        -- Create two project and a single tool
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 112233', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM dev_ws.bsa_project p where p.title = 'Test Project 112233';
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('project2', 'project2 122', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId1 FROM dev_ws.bsa_project p where p.title = 'project2 122';

        INSERT INTO dev_ws.bsa_tool (name, description, datepurchased, totalcost)
        VALUES ('New Tool 112233', 'A new tool!', CURRENT_DATE, 5.67);
        SELECT t.id INTO toolId FROM dev_ws.bsa_tool t WHERE t.name = 'New Tool 112233' and t.datepurchased = CURRENT_DATE;
        -- Act 
        -- Insert into View twice
        INSERT INTO bsa_view_project_tool (tool_id, name, ToolDescription, datepurchased, totalcost, project_id, quantity, unitcost, costbasis)
        VALUES (toolId, NULL, NULL, NULL, NULL, projectId, NULL, NULL, NULL);
        INSERT INTO bsa_view_project_tool (tool_id, name, ToolDescription, datepurchased, totalcost, project_id, quantity, unitcost, costbasis)
        VALUES (toolId, NULL, NULL, NULL, NULL, projectId1, NULL, NULL, NULL);
        -- Assert
        -- If there is a record in the join table then we know that it worked
        SELECT pt.id, pt.quantity INTO joinId, quantity FROM dev_ws.bsa_project_tool pt WHERE tool_id = toolId and project_id = projectId;
        -- Quantity should be 1 since we added a single tool to a single project (this also proves there is an entry in the join table)
        ut.expect( joinId ).not_to( be_null() );
        ut.expect( quantity ).to_( equal(1) );
        -- Re-Assert
        SELECT pt.id, pt.quantity INTO joinId, quantity FROM dev_ws.bsa_project_tool pt WHERE tool_id = toolId and project_id = projectId1;
        ut.expect( joinId ).not_to( be_null() );
        ut.expect( quantity ).to_( equal(1) );
    end;

    -- Attempting to insert a tool a second, third, etc. time should increment the quantity by 1 each time 
    procedure test_trigger_insert_project_tool_upsert is
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
        -- Re-Act
        -- Re-Insert once, which should only update the quantity
        INSERT INTO bsa_view_project_tool (tool_id, name, ToolDescription, datepurchased, totalcost, project_id, quantity, unitcost, costbasis)
        VALUES (toolId, NULL, NULL, NULL, NULL, projectId, NULL, NULL, NULL);
        SELECT pt.id, pt.quantity INTO joinId, quantity FROM dev_ws.bsa_project_tool pt WHERE tool_id = toolId and project_id = projectId;
        ut.expect( joinId ).not_to( be_null() );
        ut.expect( quantity ).to_( equal(2) );
        -- One more time
        INSERT INTO bsa_view_project_tool (tool_id, name, ToolDescription, datepurchased, totalcost, project_id, quantity, unitcost, costbasis)
        VALUES (toolId, NULL, NULL, NULL, NULL, projectId, NULL, NULL, NULL);
        SELECT pt.id, pt.quantity INTO joinId, quantity FROM dev_ws.bsa_project_tool pt WHERE tool_id = toolId and project_id = projectId;
        ut.expect( joinId ).not_to( be_null() );
        ut.expect( quantity ).to_( equal(3) );
    end;

    procedure test_trigger_delete_project_tool is
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
        -- Now delete the associated tool from the project and ensure null
        DELETE FROM bsa_view_project_tool WHERE toolId = tool_id and project_id = projectId;
        -- This statement should throw a no_data_found exception ()
        SELECT pt.id, pt.quantity INTO joinId, quantity FROM dev_ws.bsa_project_tool pt WHERE tool_id = toolId and project_id = projectId;
    end;

    procedure test_trigger_update_project_tool is
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
        -- Now attempt to update the view
        UPDATE bsa_view_project_tool SET quantity = 50 WHERE project_id = projectId and toolId = toolId;
        SELECT pt.id, pt.quantity INTO joinId, quantity FROM dev_ws.bsa_project_tool pt WHERE tool_id = toolId and project_id = projectId;
        ut.expect( joinId ).not_to( be_null() );
        ut.expect( quantity ).to_( equal(50) );
    end;
end test_triggers;