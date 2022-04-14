
  CREATE OR REPLACE EDITIONABLE PACKAGE "DEV_WS"."TEST_NON_FIXED_USE_SUPPLY_TRIGGERS" 
as
    -- %suite(Test Non-Fixed Use Supply Triggers)

    --%test(Test Trigger Insert Non-Fixed Use Supply Single Project)
    procedure test_trigger_insert_non_fixed_use_supply_single_project;
    --%test(Test Trigger Insert Non-Fixed Use Supply Multi-Project)
    procedure test_trigger_insert_non_fixed_use_supply_multi_project;
    --%test(Test Trigger Upsert Non-Fixed Use Supply)
    procedure test_trigger_upsert_non_fixed_use_supply;
    --%test(Test Trigger Delete Non-Fixed Supply)
    --%throws(-01403)
    procedure test_trigger_delete_non_fixed_supply;
    --%test(Test Trigger Update Non-Fixed Supply)
    procedure test_trigger_update_non_fixed_supply;
end test_non_fixed_use_supply_triggers;