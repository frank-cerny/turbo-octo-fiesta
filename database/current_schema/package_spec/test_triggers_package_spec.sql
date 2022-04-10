
  CREATE OR REPLACE EDITIONABLE PACKAGE "DEV_WS"."TEST_TRIGGERS" 
as
    -- %suite(Test Triggers)

    --%test(Test Trigger Insert Project Tool With insert)
    procedure test_trigger_insert_project_tool_insert;
    --%test(Test Trigger Insert Project Tool with upsert)
    -- procedure test_trigger_insert_project_tool_upsert;
end test_triggers;
