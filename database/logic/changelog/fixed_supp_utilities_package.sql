--liquibase formatted sql

--changeset fcerny:1 runOnChange:true
create or replace package fixed_supp_utilities
as 
    function bsa_func_get_fixed_supply_units_remaining(supplyId IN number)
    return number;
end fixed_supp_utilities;
/

--changeset fcerny:2 runOnChange:true
-- Functionality package 
create or replace package body fixed_supp_utilities
as
    function bsa_func_get_fixed_supply_units_remaining(supplyId in number)
    RETURN number
    AS
        totalUsages number;
        unitsPurchased number;
        BEGIN
            select sum(quantity) into totalUsages from bsa_project_fixed_quantity_supply
            where supply_id = supplyId;
            select fqs.unitspurchased into unitsPurchased
            from bsa_fixed_quantity_supply fqs
            where id = supplyId;
            return unitsPurchased - totalUsages;
        END;
    /
end fixed_supp_utilities;
/