
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
end test_non_fixed_supp_utitlities;
