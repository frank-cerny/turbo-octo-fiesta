--liquibase formatted sql

--changeset fcerny:1 runOnChange:true
create or replace package non_fixed_supp_utilities
as 
    function bsa_func_get_non_fixed_supply_usages(projectId IN number)
    return number;
end non_fixed_supp_utilities;
/

--changeset fcerny:2 runOnChange:true
-- Functionality package 
create or replace package body non_fixed_supp_utilities
as
    function bsa_func_get_non_fixed_supply_usages (supplyId in number)
    RETURN number
    AS
        totalUsages number;
        BEGIN
            -- Get outstanding total based on all project usages
            select sum(quantity) into totalUsages from bsa_project_non_fixed_quantity_supply
            where supply_id = supplyId;
            return totalUsages;
        END;
end non_fixed_supp_utilities;
/