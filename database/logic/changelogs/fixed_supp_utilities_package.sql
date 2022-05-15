--liquibase formatted sql

--changeset fcerny:1 runOnChange:true endDelimiter:"/"
create or replace package fixed_supp_utilities
as 
    function bsa_func_get_fixed_supply_units_remaining(supplyId IN number)
    return number;
    -- This is a wrapper on simple division, but with rounding 
    function bsa_func_get_fixed_supply_unit_cost(supplyId IN number)
    return number;
    procedure bsa_func_split_fixed_supplies_over_projects (supplyIdString IN varchar2, projectIdString IN varchar2);
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

    -- Not sure if this is neccessary or we should use PL/SQL in line but for now we will be explicit 
    function bsa_func_get_fixed_supply_unit_cost(supplyId in number)
    RETURN number
    AS
        unitsPurchased number;
        totalCost number;
        unitCost number(10, 2);
        BEGIN
            select bfqs.unitsPurchased, bfqs.totalCost into unitsPurchased, totalCost from bsa_fixed_quantity_supply bfqs WHERE id = supplyId;
            -- This would only occur in user error, but would allow them to edit the entry without breaking the application
            if unitsPurchased = 0 THEN
                return null;
            END IF;
            unitCost := totalCost/unitsPurchased;
            return unitCost;
        END;

    -- Requires:
    --  1. supplyIdString and projectIdString are well formatted colon separated strings of integers
    procedure bsa_func_split_fixed_supplies_over_projects (supplyIdString IN varchar2, projectIdString IN varchar2)
    IS
        projectIdList apex_t_varchar2;
        supplyIdList apex_t_varchar2;
    BEGIN
        -- Break the strings into arrays (can be empty)
        projectIdList := apex_string.split(projectIdString, ':');
        supplyIdList := apex_string.split(supplyIdString, ':');
        -- Both arrays must be non empty for this to work
        if projectIdList.count = 0 or supplyIdList.count = 0 then
            return;
        end if;
        -- Iterate through both arrays
        for i in 1 .. projectIdList.count loop
            for j in 1 .. supplyIdList.count loop
                -- We use the view here because otherwise our trigger wouldn't work (it would be a recursive, never ending trigger)
                INSERT INTO bsa_view_project_fixed_supply (supply_id, name, description, datepurchased, unitspurchased, totalcost, quantity, project_id)
                        VALUES (TO_NUMBER(supplyIdList(j)), null, null, null, null, null, null, TO_NUMBER(projectIdList(i)));
            end loop;
        end loop;
    END;
end fixed_supp_utilities;
/