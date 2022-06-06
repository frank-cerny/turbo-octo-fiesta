
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
    --%test(Test Split Single Tool No Op)
    --%throws(-01403)
    procedure test_fixed_supply_split_none;
    --%test(Test Split Single Fixed Supply Among Single Project First Insert)
    procedure test_fixed_supply_split_among_single_project_first_insert;
    --%test(Test Split Single Fixed Supply Among Single Project Upsert)
    procedure test_fixed_supply_split_among_single_project_upsert;
    --%test(Test Split Single Fixed Supply Among Multiple Projects First Insert)
    procedure test_fixed_supply_split_among_multiple_projects_first_insert;
    --%test(Test Split Multiple Fixed Supplies Among Multiple Projects First Insert)
    procedure test_multi_fixed_supply_split_among_multiple_projects_first_insert;
end test_fixed_supp_utitlities;