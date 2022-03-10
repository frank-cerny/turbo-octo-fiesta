--liquibase formatted sql

--changeset fcerny:1 runOnChange:true endDelimiter:"/"
create or replace package fixed_supp_utilities
as 
    function bsa_func_get_fixed_supply_units_remaining(supplyId IN number)
    return number;
end fixed_supp_utilities;
/

--changeset fcerny:2 runOnChange:true endDelimiter:"/"
-- Functionality package 
-- Returns the number of units remaining from a fixed use supply 
-- Returns: (number)
-- Requires: supplyId must exist
create or replace package body fixed_supp_utilities
as
    function bsa_func_get_fixed_supply_units_remaining(supplyId in number)
    RETURN number
    AS
        totalUsages number := 0;
        unitsPurchased number := 0;
        BEGIN
            select sum(quantity) into totalUsages from bsa_project_fixed_quantity_supply
            where supply_id = supplyId;
            -- Ensure that if totalUsages = null, to set to 0 to not break other calculations
            totalUsages := COALESCE(totalUsages, 0);
            select fqs.unitspurchased into unitsPurchased
            from bsa_fixed_quantity_supply fqs
            where id = supplyId;
            -- If units used is greater than purchased, return 0
            IF totalUsages > unitsPurchased THEN
                return 0;
            ELSE
                return unitsPurchased - totalUsages;
            END IF;
        END;
end fixed_supp_utilities;
/