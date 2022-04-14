
  CREATE OR REPLACE EDITIONABLE PACKAGE "DEV_WS"."TEST_TRIGGERS" 
as
    -- %suite(Test Triggers)

    --%test(Test Trigger Insert Project Tool With insert)
    procedure test_trigger_insert_project_tool_insert_single_project;
    --%test(Test Trigger Insert Project Tool With insert on multiple projects)
    procedure test_trigger_insert_project_tool_insert_multi_project;
    --%test(Test Trigger Insert Project Tool with upsert)
    procedure test_trigger_insert_project_tool_upsert;
    --%test(Test Trigger Delete Project Tool)
    --%throws(-01403)
    procedure test_trigger_delete_project_tool;
    --%test(Test Trigger Update Project Tool)
    procedure test_trigger_update_project_tool;
end test_triggers;