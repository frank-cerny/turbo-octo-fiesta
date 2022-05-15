--liquibase formatted sql

--changeset fcerny:1 runOnChange:true endDelimiter:"/"
create or replace package single_use_supply_utilities
as 
    procedure bsa_proc_split_single_use_supply_among_projects(projectIdString IN varchar2, name IN varchar2, description IN varchar2, datePurchased Date, isPending varchar2, unitCost number, unitsPurchased int, revenueItemId int);
end single_use_supply_utilities;
/

--changeset fcerny:2 runOnChange:true endDelimiter:"/"
-- Functionality package 
create or replace package body single_use_supply_utilities
as
    procedure bsa_proc_split_single_use_supply_among_projects(projectIdString IN varchar2, name IN varchar2, description IN varchar2, datePurchased Date, isPending varchar2, unitCost number, unitsPurchased int, revenueItemId int)
    IS
        projectIdList apex_t_varchar2;
        projectDescription varchar2(100);
        splitUnitCost number(10,2);
    BEGIN
        -- Break the strings into arrays (can be empty)
        projectIdList := apex_string.split(projectIdString, ':');
        -- Array must be non empty for this to work
        if projectIdList.count = 0 then
            return;
        end if;
        splitUnitCost := (unitCost * unitsPurchased) / projectIdList.count;
        -- Add revenue item to each project, with an updated description explaining which projects the item is split with
        for i in 1 .. projectIdList.count loop
            -- Use given parameters from client
            INSERT INTO BSA_SINGLE_USE_SUPPLY(name, description, datePurchased, project_id, isPending, unitCost, unitsPurchased, revenueItem_id)
            VALUES (name, '' || description || ' (Split Among Projects: ' || pu.bsa_func_return_project_name_string_from_ids(projectIdString) || ')', datePurchased, TO_NUMBER(projectIdList(i)), isPending, splitUnitCost, unitsPurchased, revenueItemId);
        end loop;
    END;
end single_use_supply_utilities;
/