
  CREATE OR REPLACE EDITIONABLE PACKAGE "DEV_WS"."TEST_SINGLE_USE_SUPPLY_UTILITIES" 
as
    -- %suite(Test Single Use Supply Utilities)

    --%test(Test Single Use Supply Split With Empty Project String)
    --%throws(-01403)
    procedure test_single_use_supply_split_with_empty_project_string;
    --%test(Test Single Use Supply Split With Single Project String)
    procedure test_single_use_supply_split_with_single_project_string;
    --%test(Test Single Use Supply Split With Two Project String)
    procedure test_single_use_supply_split_with_two_project_string;
    --%test(Test Single Use Supply With Rounded Value)
    procedure test_single_use_supply_split_with_rounded_value;
    --%test(Test Single Use Supply With Multiple Units Purchased)
    procedure test_single_use_supply_split_with_multiple_units_purchased;
end test_single_use_supply_utilities;