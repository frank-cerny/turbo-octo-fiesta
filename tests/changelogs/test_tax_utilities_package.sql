--liquibase formatted sql

--changeset fcerny:1 runOnChange:true endDelimiter:"/" stripComments:false
create or replace package test_tax_utilities_package
as
    -- %suite(Test Tax Utility Package)
    
    -- %test(Test 2021 Tax Calculations)
    procedure test_tax_calculation_2021;
    -- %test(Test 2022 Tax Calculations)
    procedure test_tax_calculation_2022;
end test_tax_utilities_package;
/

--changeset fcerny:2 runOnChange:true endDelimiter:"/" stripComments:false
create or replace package body test_tax_utilities_package
as
    -- Note that this was validated with my excel budget sheet with tax calculations built in (within +- $3 which is fine)
    -- But all calculations are based directly on Nerd Wallets Brackets/Calculations: https://www.nerdwallet.com/article/taxes/federal-income-tax-brackets
    -- The excel document does more "intense" calculation for an exact value. Being off a few dollars is fine for our case
    procedure test_tax_calculation_2021 is
        taxDue number(10, 2);
    begin
        -- Test each part of the tax bracket to ensure math holds, computations are straight forward inside the function
        -- hence we can use a single test instead of breaking it out
        -- 10% bracket
        taxDue := taxu.bsa_func_calculate_federal_income_tax_2021(500);
        ut.expect(taxDue).to_( equal(50) );
        -- 12% bracket
        taxDue := taxu.bsa_func_calculate_federal_income_tax_2021(32405);
        ut.expect(taxDue).to_( equal(3689.60) );
        -- 22% bracket
        taxDue := taxu.bsa_func_calculate_federal_income_tax_2021(67800);
        ut.expect(taxDue).to_( equal(10664.50) );
        -- 24% bracket 
        taxDue := taxu.bsa_func_calculate_federal_income_tax_2021(90500);
        ut.expect(taxDue).to_( equal(15741) );
        -- 32% bracket
        taxDue := taxu.bsa_func_calculate_federal_income_tax_2021(175900);
        ut.expect(taxDue).to_( equal(37115) );
        -- 35% bracket
        taxDue := taxu.bsa_func_calculate_federal_income_tax_2021(350600);
        ut.expect(taxDue).to_( equal(97254.25) );
        -- 37% bracket
        taxDue := taxu.bsa_func_calculate_federal_income_tax_2021(750000);
        ut.expect(taxDue).to_( equal(241572.25) );
    end;

    procedure test_tax_calculation_2022 is
        taxDue number(10, 2);
    begin
        -- Test each part of the tax bracket to ensure math holds, computations are straight forward inside the function
        -- hence we can use a single test instead of breaking it out
        -- 10% bracket
        taxDue := taxu.bsa_func_calculate_federal_income_tax_2021(500);
        ut.expect(taxDue).to_( equal(50) );
        -- 12% bracket
        taxDue := taxu.bsa_func_calculate_federal_income_tax_2021(32405);
        ut.expect(taxDue).to_( equal(3477.60) );
        -- 22% bracket
        taxDue := taxu.bsa_func_calculate_federal_income_tax_2021(99600);
        ut.expect(taxDue).to_( equal(13146) );
        -- 24% bracket 
        taxDue := taxu.bsa_func_calculate_federal_income_tax_2021(250000);
        ut.expect(taxDue).to_( equal(47671) );
        -- 32% bracket
        taxDue := taxu.bsa_func_calculate_federal_income_tax_2021(400000);
        ut.expect(taxDue).to_( equal(88463) );
        -- 35% bracket
        taxDue := taxu.bsa_func_calculate_federal_income_tax_2021(567000);
        ut.expect(taxDue).to_( equal(145956) );
        -- 37% bracket
        taxDue := taxu.bsa_func_calculate_federal_income_tax_2021(750000);
        ut.expect(taxDue).to_( equal(212049) );
    end;
end test_tax_utilities_package;
/
