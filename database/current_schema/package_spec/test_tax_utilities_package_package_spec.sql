
  CREATE OR REPLACE EDITIONABLE PACKAGE "DEV_WS"."TEST_TAX_UTILITIES_PACKAGE" 
as
    -- %suite(Test Tax Utility Package)
    
    -- %test(Test 2021 Tax Calculations)
    procedure test_tax_calculation_2021;
    -- %test(Test 2022 Tax Calculations)
    procedure test_tax_calculation_2022;
    -- %test(Test Tax Calculations Empty Project)
    procedure test_aggregate_tax_caclulation_empty_project;
    -- %test(Test Tax Calculations Single Year Single Project)
    procedure test_aggregate_tax_calculation_single_year_single_project;
    -- %test(Test Tax Calculations Single Year Multi Projects)
    procedure test_aggregate_tax_calculation_single_year_multi_project;
    -- %test(Test Tax Calculations Multi Year Single Project)
    procedure test_aggregate_tax_calculation_multi_year_single_project;
    -- %test(Test Tax Calculations Multi Year Multi Projects)
    procedure test_aggregate_tax_calculation_multi_year_multi_project;
    -- %test(Test Tax Calculations with No Income Set)
    procedure test_aggregate_tax_calculation_with_no_income_set;
    -- %test(Test Tax Income Validation)
    procedure test_tax_income_validation;
end test_tax_utilities_package;