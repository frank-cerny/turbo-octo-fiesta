
  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "DEV_WS"."TEST_TRIGGERS" 
as
    procedure test_trigger_insert_project_tool_insert is
    toolId int;
    projectId int;
    joinId int;
    quantity int;
    begin
        
        
        INSERT INTO frankcerny.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 112233', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM frankcerny.bsa_project p where p.title = 'Test Project 112233';
        INSERT INTO frankcerny.bsa_tool (name, description, datepurchased, totalcost)
        VALUES ('New Tool 112233', 'A new tool!', CURRENT_DATE, 5.67);
        SELECT t.id INTO toolId FROM frankcerny.bsa_tool t WHERE t.name = 'New Tool 112233' and t.datepurchased = CURRENT_DATE;
        
        
        INSERT INTO bsa_view_project_tool (tool_id, name, ToolDescription, datepurchased, totalcost, project_id)
        VALUES (toolId, NULL, NULL, NULL, NULL, projectId);
        
        
        SELECT pt.id, pt.quantity INTO joinId, quantity FROM frankcerny.bsa_project_tool pt WHERE tool_id = toolId and project_id = projectId;
        ut.expect(unitsRemaining).to_( equal(165) );
        
        ut.expect( quantity ).to_be_null();
    end;
end test_triggers;