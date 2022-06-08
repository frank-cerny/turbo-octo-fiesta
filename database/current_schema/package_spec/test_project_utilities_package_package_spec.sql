
  CREATE OR REPLACE EDITIONABLE PACKAGE "DEV_WS"."TEST_PROJECT_UTILITIES_PACKAGE" 
as
    -- %suite(Test Project Utility Package)

    --%test(Test Project Id String Conversion on Empty String)
    procedure test_project_id_string_conversion_empty;
    --%test(Test Project Id String Conversion on Single Project)
    procedure test_project_id_string_single_project;
    --%test(Test Project Id String Conversion on Multiple Project)
    procedure test_project_id_string_multi_project;
    -- TODO
    --%test(Test Project Get Net Value)
    procedure test_project_get_net_value;
end test_project_utilities_package;
