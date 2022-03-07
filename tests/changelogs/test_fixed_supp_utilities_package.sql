--liquibase formatted sql

--changeset fcerny:1 runOnChange:true endDelimiter:"/"
create or replace package test_fixed_supp_utitlities
as
    -- %suite(Test Fixed Supply Utilities)

    --%test(Test Get Fixed Supplies Remaining with 0)
    procedure test_get_f_supp_remaining_0;
    --%test(Test Get Fixed Supplies Remaining with More than 0)
    procedure test_get_f_supp_remaining_not_0;
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
        INSERT INTO frankcerny.bsa_fixed_quantity_supply(name, description, datepurchased, unitspurchased, totalcost)
        VALUES ('Bubble Wrap', '', CURRENT_DATE, 165, 23.45);
        SELECT fqs.id INTO fixedSupplyId FROM frankcerny.bsa_fixed_quantity_supply fqs WHERE name = 'Bubble Wrap';
        -- Act 
        -- fsu is a public synomym for the fixed supply package
        unitsRemaining := frankcerny.fsu.bsa_func_get_fixed_supply_units_remaining(fixedSupplyId);
        -- Assert
        ut.expect(unitsRemaining).to_( equal(0) );
    end;

    procedure test_get_f_supp_remaining_not_0 is
    begin
        -- Setup

        -- Act 

        -- Assert
        ut.expect(0).to_( equal(1) );
    end;

end test_fixed_supp_utitlities;
/