--liquibase formatted sql

--changeset fcerny:1 runOnChange:true endDelimiter:"/"
create or replace package test_fixed_supp_utitlities
as
    -- %suite(Test Fixed Supply Utilities)

    --%test(Test Get Fixed Supplies Remaining with no usages)
    procedure test_get_f_supp_remaining_0;
    --%test(Test Get Fixed Supplies Remaining with usages from a single project)
    procedure test_get_f_supp_remaining_not_0_single_project;
    --%test(Test Get Fixed Supplies Remaining with usages from more than one project)
    procedure test_get_f_supp_remaining_not_0_multi_project;
    --%test(Test Get Fixed Supplies Remaining with usages over quantity)
    procedure test_get_f_supp_remaining_handle_negative;
end test_fixed_supp_utitlities;
/

--changeset fcerny:2 runOnChange:true endDelimiter:"/"
create or replace package body test_fixed_supp_utitlities
as
    procedure test_get_f_supp_remaining_0 is
    fixedSupplyId int;
    unitsRemaining int;
    begin
        -- Setup
        -- Insert a single fixed supply into the table
        INSERT INTO dev_ws.bsa_fixed_quantity_supply(name, description, datepurchased, unitspurchased, totalcost)
        VALUES ('Bubble Wrap 112233', '', CURRENT_DATE, 165, 23.45);
        SELECT fqs.id INTO fixedSupplyId FROM dev_ws.bsa_fixed_quantity_supply fqs WHERE name = 'Bubble Wrap 112233';
        -- Act 
        -- fsu is a public synomym for the fixed supply package
        unitsRemaining := dev_ws.fsu.bsa_func_get_fixed_supply_units_remaining(fixedSupplyId);
        -- Assert
        -- We haven't used any of the fixed use supplies yet, so this should equal the original supply
        ut.expect(unitsRemaining).to_( equal(165) );
    end;

    procedure test_get_f_supp_remaining_not_0_single_project is
    projectId int;
    fixedSupplyId int;
    unitsRemaining int;
    begin
        -- Setup
        -- Create a project
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 112233', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM dev_ws.bsa_project p where p.title = 'Test Project 112233';
        -- Insert a single fixed supply into the table
        INSERT INTO dev_ws.bsa_fixed_quantity_supply(name, description, datepurchased, unitspurchased, totalcost)
        VALUES ('Bubble Wrap 112233', '', CURRENT_DATE, 165, 23.45);
        SELECT fqs.id INTO fixedSupplyId FROM dev_ws.bsa_fixed_quantity_supply fqs WHERE name = 'Bubble Wrap 112233';
        -- Add records to the project fixed use supply table directly (do not use the trigger here)
        INSERT INTO dev_ws.bsa_project_fixed_quantity_supply (project_id, supply_id, quantity)
        VALUES (projectId, fixedSupplyId, 65);
        -- Act 
        -- fsu is a public synomym for the fixed supply package
        unitsRemaining := dev_ws.fsu.bsa_func_get_fixed_supply_units_remaining(fixedSupplyId);
        -- Assert
        ut.expect(unitsRemaining).to_( equal(100) );
    end;

    procedure test_get_f_supp_remaining_not_0_multi_project is
    projectId1 int;
    projectId2 int;
    fixedSupplyId int;
    unitsRemaining int;
    begin
        -- Setup
        -- Create two projects
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 112233', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId1 FROM dev_ws.bsa_project p where p.title = 'Test Project 112233';
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 332211', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId2 FROM dev_ws.bsa_project p where p.title = 'Test Project 332211';
        -- Insert a single fixed supply into the table
        INSERT INTO dev_ws.bsa_fixed_quantity_supply(name, description, datepurchased, unitspurchased, totalcost)
        VALUES ('Bubble Wrap 112233', '', CURRENT_DATE, 165, 23.45);
        SELECT fqs.id INTO fixedSupplyId FROM dev_ws.bsa_fixed_quantity_supply fqs WHERE name = 'Bubble Wrap 112233';
        -- Add records to the project fixed use supply table directly (do not use the trigger here)
        INSERT INTO dev_ws.bsa_project_fixed_quantity_supply (project_id, supply_id, quantity)
        VALUES (projectId1, fixedSupplyId, 65);
        INSERT INTO dev_ws.bsa_project_fixed_quantity_supply (project_id, supply_id, quantity)
        VALUES (projectId2, fixedSupplyId, 50);
        -- Act 
        -- fsu is a public synomym for the fixed supply package
        unitsRemaining := dev_ws.fsu.bsa_func_get_fixed_supply_units_remaining(fixedSupplyId);
        -- Assert
        ut.expect(unitsRemaining).to_( equal(50) );
    end;

    -- Not sure this can happen, but it doesn't hurt to check and tighten the conditions on the function
    procedure test_get_f_supp_remaining_handle_negative is
    projectId int;
    fixedSupplyId int;
    unitsRemaining int;
    begin
        -- Setup
        -- Create a project
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 112233', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM dev_ws.bsa_project p where p.title = 'Test Project 112233';
        -- Insert a single fixed supply into the table
        INSERT INTO dev_ws.bsa_fixed_quantity_supply(name, description, datepurchased, unitspurchased, totalcost)
        VALUES ('Bubble Wrap 112233', '', CURRENT_DATE, 165, 23.45);
        SELECT fqs.id INTO fixedSupplyId FROM dev_ws.bsa_fixed_quantity_supply fqs WHERE name = 'Bubble Wrap 112233';
        -- Add records to the project fixed use supply table directly (do not use the trigger here)
        -- For this specific test we want to "use" more than we have to ensure the function does NOT return a negatvie number
        INSERT INTO dev_ws.bsa_project_fixed_quantity_supply (project_id, supply_id, quantity)
        VALUES (projectId, fixedSupplyId, 166);
        -- Act 
        -- fsu is a public synomym for the fixed supply package
        unitsRemaining := dev_ws.fsu.bsa_func_get_fixed_supply_units_remaining(fixedSupplyId);
        -- Assert
        ut.expect(unitsRemaining).to_( equal(0) );
    end;

end test_fixed_supp_utitlities;
/
