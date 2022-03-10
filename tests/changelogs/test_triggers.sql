--liquibase formatted sql

--changeset fcerny:1 runOnChange:true endDelimiter:"/"
create or replace package test_triggers
as
    -- TODO
    -- %suite(Test Triggers)

    --%test(Test Get Fixed Supplies Remaining with no usages)
    procedure test_get_f_supp_remaining_0;
    --%test(Test Get Fixed Supplies Remaining with usages from a single project)
    procedure test_get_f_supp_remaining_not_0_single_project;
    --%test(Test Get Fixed Supplies Remaining with usages from more than one project)
    procedure test_get_f_supp_remaining_not_0_multi_project;
    --%test(Test Get Fixed Supplies Remaining with usages over quantity)
    procedure test_get_f_supp_remaining_handle_negative;
end test_fixed_supp_utitlities;
/

--changeset fcerny:2 runOnChange:true endDelimiter:"/"
create or replace package body test_triggers
as

end test_triggers;
/
