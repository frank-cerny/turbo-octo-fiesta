
  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "FRANKCERNY"."TEST_FIXED_SUPP_UTITLITIES" 
as
    procedure test_get_f_supp_remaining_0 is
    fixedSupplyId int;
    unitsRemaining int;
    begin
        
        
        INSERT INTO frankcerny.bsa_fixed_quantity_supply(name, description, datepurchased, unitspurchased, totalcost)
        VALUES ('Bubble Wrap', '', CURRENT_DATE, 165, 23.45);
        SELECT fqs.id INTO fixedSupplyId FROM frankcerny.bsa_fixed_quantity_supply fqs WHERE name = 'Bubble Wrap';
        
        
        unitsRemaining := frankcerny.fsu.bsa_func_get_fixed_supply_units_remaining(fixedSupplyId);
        
        ut.expect(unitsRemaining).to_( equal(0) );
    end;

    procedure test_get_f_supp_remaining_not_0 is
    begin
        

        

        
        ut.expect(0).to_( equal(1) );
    end;

end test_fixed_supp_utitlities;