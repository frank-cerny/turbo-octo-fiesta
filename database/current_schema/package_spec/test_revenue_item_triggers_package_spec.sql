
  CREATE OR REPLACE EDITIONABLE PACKAGE "DEV_WS"."TEST_REVENUE_ITEM_TRIGGERS" 
as
    -- %suite(Test Revenue Item Triggers)

    --%test(Test Revenue Item Insert Trigger With Logs)
    procedure test_revenue_item_insert_trigger_with_logs;
    --%test(Test Revenue Item Update Trigger With Logs)
    procedure test_revenue_item_update_trigger_with_logs;
    --%test(Test Revenue Item Delete Trigger With Logs)
    procedure test_revenue_item_delete_trigger_with_logs;
end test_revenue_item_triggers;