
  CREATE OR REPLACE EDITIONABLE PACKAGE "DEV_WS"."TEST_NON_FIXED_SUPP_UTITLITIES" 
as
    -- %suite(Test Non-Fixed Supply Utilities)

    --%test(Test Get Non-Fixed Supplies 0)
    procedure test_get_nf_supp_0;
    --%test(Test Get Non-Fixed Supplies Non 0 Single Project)
    procedure test_get_nf_supp_not_0_single_project;
    --%test(Test Get Non-Fixed Supplies Non 0 Multi-Project)
    procedure test_get_nf_supp_not_0_multi_project;
    --%test(Test Get Non-Fixed Supply Unit Cost 0)
    procedure test_nf_supp_unit_cost_0;
    --%test(Test Get Non-Fixed Supply Unit Cost Not 0 Single Project)
    procedure test_nf_supp_unit_cost_non_zero_single_project;
    --%test(Test Get Non-Fixed Supply Unit Cost Not 0 Multi-Project)
    procedure test_nf_supp_unit_cost_non_zero_multi_project;
    --%test(Test Split Single Tool No Op)
    --%throws(-01403)
    procedure test_non_fixed_supply_split_none;
    --%test(Test Split Single Non-Fixed Supply Among Single Project First Insert)
    procedure test_non_fixed_supply_split_among_single_project_first_insert;
    --%test(Test Split Single Non-Fixed Supply Among Single Project Upsert)
    procedure test_non_fixed_supply_split_among_single_project_upsert;
    --%test(Test Split Single Non-Fixed Supply Among Multiple Projects First Insert)
    procedure test_non_fixed_supply_split_among_multiple_projects_first_insert;
    --%test(Test Split Multiple Non-Fixed Supplies Among Multiple Projects First Insert)
    procedure test_multi_non_fixed_supply_split_among_multiple_projects_first_insert;
end test_non_fixed_supp_utitlities;