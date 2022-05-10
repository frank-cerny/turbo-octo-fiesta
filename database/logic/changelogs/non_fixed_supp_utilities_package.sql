--liquibase formatted sql

--changeset fcerny:1 runOnChange:true endDelimiter:"/"
create or replace package non_fixed_supp_utilities
as 
    function bsa_func_get_non_fixed_supply_usages(supplyId IN number)
    return number;
    function bsa_func_get_non_fixed_supply_unit_cost(supplyId IN number)
    return number;
    procedure bsa_func_split_non_fixed_supplies_over_projects(supplyIdString IN varchar2, projectIdString IN varchar2);
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

    -- Requires:
    --  1. supplyIdString and projectIdString are well formatted colon separated strings of integers
    procedure bsa_func_split_non_fixed_supplies_over_projects (supplyIdString IN varchar2, projectIdString IN varchar2)
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
                INSERT INTO bsa_view_project_non_fixed_supply (supply_id, name, description, datepurchased, cost, quantity, project_id)
                        VALUES (TO_NUMBER(supplyIdList(j)), null, null, null, null, null, TO_NUMBER(projectIdList(i)));
            end loop;
        end loop;
    END;
end non_fixed_supp_utilities;
/