--liquibase formatted sql

--changeset fcerny:1 runOnChange:true endDelimiter:"/" stripComments:false
create or replace package test_tax_utilities_package
as
    -- %suite(Test Tax Utility Package)
end test_tax_utilities_package;
/

--changeset fcerny:2 runOnChange:true endDelimiter:"/" stripComments:false
create or replace package body test_tax_utilities_package
as
    procedure test_project_id_string_single_project is
    begin
    end;
end test_tax_utilities_package;
/
