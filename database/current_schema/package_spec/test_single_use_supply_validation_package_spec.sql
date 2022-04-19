
  CREATE OR REPLACE EDITIONABLE PACKAGE "DEV_WS"."TEST_SINGLE_USE_SUPPLY_VALIDATION" 
as
    -- %suite(Test Revenue Item Validation)

    --%test(Test Revenue Item Insert Same Name into Single Project)
    --%throws(-1)
    procedure test_single_use_supply_insert_same_name_into_single_project;
    --%test(Test Revenue Item Insert Same Name into Multiple Projects)
    procedure test_single_use_supply_insert_same_name_into_multi_project;
end test_single_use_supply_validation;
