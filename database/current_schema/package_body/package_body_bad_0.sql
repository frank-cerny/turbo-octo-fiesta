
  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "DEV_WS"."TEST_NON_FIXED_SUPP_UTITLITIES" 
as
    procedure test_get_nf_supp_0
    projectId int;
    supplyId int;
    usages int;
    as
    begin
        
        
        INSERT INTO frankcerny.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 112233', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM frankcerny.bsa_project p where p.title = 'Test Project 112233';
        INSERT INTO bsa_non_fixed_quantity_supply(name, description, datepurchased, cost)
        VALUES ('EvapoRust 112233', '', CURRENT_DATE, 15.67);
        SELECT nfqs.id INTO supplyId FROM bsa_non_fixed_quantity_supply nfqs WHERE name = 'EvapoRust 112233';
        
        usages := frankcerny.nfsu.bsa_func_get_non_fixed_supply_usages(supplyId);
        
        ut.expect(usages).to_( equal(0) );
    end;

    procedure test_get_nf_supp_not_0
    projectId int;
    supplyId int;
    usages int;
    as
    begin
        
        
        INSERT INTO frankcerny.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Test Project 112233', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM frankcerny.bsa_project p where p.title = 'Test Project 112233';
        INSERT INTO bsa_non_fixed_quantity_supply(name, description, datepurchased, cost)
        VALUES ('EvapoRust 112233', '', CURRENT_DATE, 15.67);
        SELECT nfqs.id INTO supplyId FROM bsa_non_fixed_quantity_supply nfqs WHERE name = 'EvapoRust 112233';
        
        INSERT INTO frankcerny.bsa_project_non_fixed_quantity_supply (project_id, supply_id, quantity)
        VALUES (projectId, supplyId, 72);
        
        usages := frankcerny.nfsu.bsa_func_get_non_fixed_supply_usages(supplyId);
        
        ut.expect(usages).to_( equal(72) );
    end;
end test_non_fixed_supp_utitlities;