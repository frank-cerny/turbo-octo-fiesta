
  CREATE OR REPLACE EDITIONABLE PACKAGE "DEV_WS"."TEST_TOOL_UTILITIES" 
as
    -- %suite(Test Tool Utilities)

    --%test(Test Get Tool Usage 0)
    procedure test_tool_usage_zero;
    --%test(Test Get Tool Usage Not 0 Single Project)
    procedure test_tool_usage_not_zero_single_project;
    --%test(Test Get Tool Usage Not 0 Multi-Project)
    procedure test_tool_usage_not_zero_multi_project;
    --%test(Test Get Tool Unit Cost 0)
    procedure test_tool_unit_cost_0;
    --%test(Test Get Tool Unit Cost Not 0 Single Project)
    procedure test_tool_unit_cost_non_zero_single_project;
    --%test(Test Get Tool Unit Cost Not 0 Multi-Project)
    procedure test_tool_unit_cost_non_zero_multi_project;
end test_tool_utilities;
