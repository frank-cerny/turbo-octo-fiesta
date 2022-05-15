
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
end test_project_utilities_package;