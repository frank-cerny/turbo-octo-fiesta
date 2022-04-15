--liquibase formatted sql

--changeset fcerny:1 runOnChange:true endDelimiter:"/"
create or replace package non_fixed_supp_utilities
as 
    function bsa_func_get_non_fixed_supply_usages(supplyId IN number)
    return number;
    function bsa_func_get_non_fixed_supply_unit_cost(supplyId IN number)
    return number;
end non_fixed_supp_utilities;
/

--changeset fcerny:2 runOnChange:true endDelimiter:"/"
-- Functionality package 
create or replace package body non_fixed_supp_utilities
as
    function bsa_func_get_non_fixed_supply_usages (supplyId in number)
    RETURN number
    AS
        totalUsages number;
        BEGIN
            -- Get outstanding total based on all project usages
            select COALESCE(sum(quantity), 0) into totalUsages from bsa_project_non_fixed_quantity_supply
            where supply_id = supplyId;
            return totalUsages;
        END;

    function bsa_func_get_non_fixed_supply_unit_cost (supplyId in number)
    RETURN number
    AS
        totalUsages number;
        totalCost number;
        unitCost number(10, 2);
        BEGIN
            -- Get outstanding total based on all project usages
            totalUsages := bsa_func_get_non_fixed_supply_usages(supplyId);
            if totalUsages = 0 THEN
                return null;
            END IF;
            select cost into totalCost from bsa_non_fixed_quantity_supply where id = supplyId;
            unitCost := totalCost/totalUsages;
            return unitCost;
        END;
end non_fixed_supp_utilities;
/