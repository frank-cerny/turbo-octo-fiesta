
  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "DEV_WS"."TEST_FIXED_SUPP_UTITLITIES" 
as
    procedure test_get_f_supp_remaining_0 is
    fixedSupplyId int;
    unitsRemaining int;
    begin
        
        
        INSERT INTO dev_ws.bsa_fixed_quantity_supply(name, description, datepurchased, unitspurchased, totalcost)
        VALUES ('Bubble Wrap 112233', '', CURRENT_DATE, 165, 23.45);
        SELECT fqs.id INTO fixedSupplyId FROM dev_ws.bsa_fixed_quantity_supply fqs WHERE name = 'Bubble Wrap 112233';
        
        
        unitsRemaining := dev_ws.fsu.bsa_func_get_fixed_supply_units_remaining(fixedSupplyId);
        
        
        ut.expect(unitsRemaining).to_( equal(165) );
    end;

    procedure test_get_f_supp_remaining_not_0_single_project is
    projectId int;
    fixedSupplyId int;
    unitsRemaining int;
    begin
        
        
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 112233', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM dev_ws.bsa_project p where p.title = 'Test Project 112233';
        
        INSERT INTO dev_ws.bsa_fixed_quantity_supply(name, description, datepurchased, unitspurchased, totalcost)
        VALUES ('Bubble Wrap 112233', '', CURRENT_DATE, 165, 23.45);
        SELECT fqs.id INTO fixedSupplyId FROM dev_ws.bsa_fixed_quantity_supply fqs WHERE name = 'Bubble Wrap 112233';
        
        INSERT INTO dev_ws.bsa_project_fixed_quantity_supply (project_id, supply_id, quantity)
        VALUES (projectId, fixedSupplyId, 65);
        
        
        unitsRemaining := dev_ws.fsu.bsa_func_get_fixed_supply_units_remaining(fixedSupplyId);
        
        ut.expect(unitsRemaining).to_( equal(100) );
    end;

    procedure test_get_f_supp_remaining_not_0_multi_project is
    projectId1 int;
    projectId2 int;
    fixedSupplyId int;
    unitsRemaining int;
    begin
        
        
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 112233', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId1 FROM dev_ws.bsa_project p where p.title = 'Test Project 112233';
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 332211', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId2 FROM dev_ws.bsa_project p where p.title = 'Test Project 332211';
        
        INSERT INTO dev_ws.bsa_fixed_quantity_supply(name, description, datepurchased, unitspurchased, totalcost)
        VALUES ('Bubble Wrap 112233', '', CURRENT_DATE, 165, 23.45);
        SELECT fqs.id INTO fixedSupplyId FROM dev_ws.bsa_fixed_quantity_supply fqs WHERE name = 'Bubble Wrap 112233';
        
        INSERT INTO dev_ws.bsa_project_fixed_quantity_supply (project_id, supply_id, quantity)
        VALUES (projectId1, fixedSupplyId, 65);
        INSERT INTO dev_ws.bsa_project_fixed_quantity_supply (project_id, supply_id, quantity)
        VALUES (projectId2, fixedSupplyId, 50);
        
        
        unitsRemaining := dev_ws.fsu.bsa_func_get_fixed_supply_units_remaining(fixedSupplyId);
        
        ut.expect(unitsRemaining).to_( equal(50) );
    end;

    
    procedure test_get_f_supp_remaining_handle_negative is
    projectId int;
    fixedSupplyId int;
    unitsRemaining int;
    begin
        
        
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 112233', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM dev_ws.bsa_project p where p.title = 'Test Project 112233';
        
        INSERT INTO dev_ws.bsa_fixed_quantity_supply(name, description, datepurchased, unitspurchased, totalcost)
        VALUES ('Bubble Wrap 112233', '', CURRENT_DATE, 165, 23.45);
        SELECT fqs.id INTO fixedSupplyId FROM dev_ws.bsa_fixed_quantity_supply fqs WHERE name = 'Bubble Wrap 112233';
        
        
        INSERT INTO dev_ws.bsa_project_fixed_quantity_supply (project_id, supply_id, quantity)
        VALUES (projectId, fixedSupplyId, 166);
        
        
        unitsRemaining := dev_ws.fsu.bsa_func_get_fixed_supply_units_remaining(fixedSupplyId);
        
        ut.expect(unitsRemaining).to_( equal(0) );
    end;

end test_fixed_supp_utitlities;