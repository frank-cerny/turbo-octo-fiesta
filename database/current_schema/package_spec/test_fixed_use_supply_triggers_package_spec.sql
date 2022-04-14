
  CREATE OR REPLACE EDITIONABLE PACKAGE "DEV_WS"."TEST_FIXED_USE_SUPPLY_TRIGGERS" 
as
    -- %suite(Test Fixed Use Supply Triggers)

    --%test(Test Trigger Insert Fixed Use Supply Single Project)
    procedure test_trigger_insert_fixed_use_supply_single_project;
    --%test(Test Trigger Insert Fixed Use Supply on multiple projects)
    procedure test_trigger_insert_fixed_use_supply_multi_project;
    --%test(Test Trigger Insert Project Fixed Use Supply with upsert)
    procedure test_trigger_insert_fixed_use_supply_upsert;
    --%test(Test Trigger Delete Project Fixed Use Supply)
    --%throws(-01403)
    procedure test_trigger_delete_project_fixed_use_supply;
    --%test(Test Trigger Update Fixed Use Supply)
    procedure test_trigger_update_project_fixed_use_supply;
end test_fixed_use_supply_triggers;