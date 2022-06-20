
  CREATE OR REPLACE EDITIONABLE PACKAGE "DEV_WS"."TEST_PROJECT_UTILITIES_PACKAGE" 
as
    -- %suite(Test Project Utility Package)

    --%test(Test Project Id String Conversion on Empty String)
    procedure test_project_id_string_conversion_empty;
    --%test(Test Project Id String Conversion on Single Project)
    procedure test_project_id_string_single_project;
    --%test(Test Project Id String Conversion on Multiple Project)
    procedure test_project_id_string_multi_project;
    --%test(Test Project Get Net Value)
    procedure test_project_get_net_value;
    --%test(Test Get Total Bike Cost For Project 0)
    procedure test_project_get_total_bike_cost_zero;
    --%test(Test Get Total Bike Cost For Project Non-Zero)
    procedure test_project_get_total_bike_cost_non_zero;
    --%test(Test Get Total Single Use Supply Cost For Project 0)
    procedure test_project_get_total_single_use_supply_cost_zero;
    --%test(Test Get Total Single Use Supply Cost For Project Non-Zero)
    procedure test_project_get_total_single_use_supply_cost_non_zero;
    --%test(Test Get Total Tool Cost For Project 0)
    procedure test_project_get_total_tool_cost_zero;
    --%test(Test Get Total Tool Cost For Project Non-Zero)
    procedure test_project_get_total_tool_cost_non_zero;
    --%test(Test Get Total Revenue For Project 0)
    procedure test_project_get_total_revenue_zero;
    --%test(Test Get Total Revenue For Project Non-Zero)
    procedure test_project_get_total_revenue_non_zero;
    --%test(Test Get Total Fixed Use Supply Cost For Project 0)
    procedure test_project_get_total_fixed_use_supply_cost_zero;
    --%test(Test Get Total Fixed Use Supply Cost For Project Non-Zero)
    procedure test_project_get_total_fixed_use_supply_cost_non_zero;
    --%test(Test Get Total Non Fixed Use Supply Cost For Project 0)
    procedure test_project_get_total_non_fixed_use_supply_cost_zero;
    --%test(Test Get Total Non Fixed Use Supply Cost For Project Non-Zero)
    procedure test_project_get_total_non_fixed_use_supply_cost_non_zero;
end test_project_utilities_package;
