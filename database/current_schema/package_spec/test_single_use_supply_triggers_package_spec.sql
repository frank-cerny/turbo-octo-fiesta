
  CREATE OR REPLACE EDITIONABLE PACKAGE "DEV_WS"."TEST_SINGLE_USE_SUPPLY_TRIGGERS" 
as
    -- %suite(Test Single Use Supply Triggers)

    --%test(Test Single Use Supply Insert Trigger With Logs)
    procedure test_single_use_supply_insert_trigger_with_logs;
    --%test(Test Single Use Update Trigger With Logs)
    procedure test_single_use_supply_update_trigger_with_logs;
    --%test(Test Single Use Supply Delete Trigger With Logs)
    procedure test_single_use_supply_delete_trigger_with_logs;
end test_single_use_supply_triggers;