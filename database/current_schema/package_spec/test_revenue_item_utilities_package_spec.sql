
  CREATE OR REPLACE EDITIONABLE PACKAGE "DEV_WS"."TEST_REVENUE_ITEM_UTILITIES" 
as
    -- %suite(Test Revenue Item Utilities)

    --%test(Test Revenue Item Split With Empty Project String)
    --%throws(-01403)
    procedure test_revenue_item_split_with_empty_project_string;
    --%test(Test Revenue Item Split With Single Project String)
    procedure test_revenue_item_split_with_single_project_string;
    --%test(Test Revenue Item Split With Two Project String)
    procedure test_revenue_item_split_with_two_project_string;
    --%test(Test Revenue Item Split With Rounded Value)
    procedure test_revenue_item_split_with_rounded_value;
end test_revenue_item_utilities;