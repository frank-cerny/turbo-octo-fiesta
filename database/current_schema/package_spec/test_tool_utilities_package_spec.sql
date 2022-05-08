
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
    --%test(Test Split Single Tool No Op)
    --%throws(-01403)
    procedure test_tool_split_none;
    --%test(Test Split Single Tool Among Single Project First Insert)
    procedure test_tool_split_among_single_project_first_insert;
    --%test(Test Split Single Tool Among Single Project Upsert)
    procedure test_tool_split_among_single_project_upsert;
    --%test(Test Split Single Tool Among Multiple Projects First Insert)
    procedure test_tool_split_among_multiple_projects_first_insert;
    --%test(Test Split Multiple Tools Among Multiple Projects First Insert)
    procedure test_multi_tool_split_among_multiple_projects_first_insert;
end test_tool_utilities;
