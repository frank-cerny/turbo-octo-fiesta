
  CREATE OR REPLACE EDITIONABLE PACKAGE "DEV_WS"."TEST_TOOL_UTILITIES" 
as
    -- %suite(Test Tool Utilities)

    --%test(Test Get Tool Usage 0)
    procedure test_tool_usage_zero;
    --%test(Test Get Tool Usage Not 0 Single Project)
    procedure test_tool_usage_not_zero_single_project;
    --%test(Test Get Tool Usage Not 0 Multi-Project)
    procedure test_tool_usage_not_zero_multi_project;
end test_tool_utilities;