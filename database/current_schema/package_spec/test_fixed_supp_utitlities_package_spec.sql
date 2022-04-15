
  CREATE OR REPLACE EDITIONABLE PACKAGE "DEV_WS"."TEST_FIXED_SUPP_UTITLITIES" 
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
    --%test(Test Get Fixed Supply Unit Cost 0)
    procedure test_fixed_supply_unit_cost_0;
    --%test(Test Get Fixed Supply Unit Cost Not 0)
    procedure test_fixed_supply_unit_cost_non_zero;
end test_fixed_supp_utitlities;
