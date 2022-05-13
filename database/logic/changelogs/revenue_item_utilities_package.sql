--liquibase formatted sql

--changeset fcerny:1 runOnChange:true endDelimiter:"/"
create or replace package revenue_item_utilities
as 
    procedure bsa_proc_split_revenue_item_among_projects(projectIdString IN varchar2, name IN varchar2, description IN varchar2, salePrice IN number, platformSoldOn IN varchar2, isPending IN varchar2, dateSold IN Date);
end revenue_item_utilities;
/

--changeset fcerny:2 runOnChange:true endDelimiter:"/"
-- Functionality package 
create or replace package body revenue_item_utilities
as
    procedure bsa_proc_split_revenue_item_among_projects(projectIdString IN varchar2, name IN varchar2, description IN varchar2, salePrice IN number, platformSoldOn IN varchar2, isPending IN varchar2, dateSold IN Date)
    IS
        projectIdList apex_t_varchar2;
        projectDescription varchar2(100);
        unitSalePrice number;
    BEGIN
        -- Break the strings into arrays (can be empty)
        projectIdList := apex_string.split(projectIdString, ':');
        -- Array must be non empty for this to work
        if projectIdList.count = 0 then
            return;
        end if;
        unitSalePrice := salePrice / projectIdList.count;
        -- Add revenue item to each project, with an updated description explaining which projects the item is split with
        for i in 1 .. projectIdList.count loop
            -- Use given parameters from client
            INSERT INTO BSA_REVENUE_ITEM(project_id, name, description, salePrice, platformSoldOn, isPending, dateSold)
            VALUES (TO_NUMBER(projectIdList(i)), name, '' || description || ' (Split Among Projects: ' || pu.bsa_func_return_project_name_string_from_ids(projectIdString) || ')', unitSalePrice, platformSoldOn, isPending, dateSold);
        end loop;
    END;
end revenue_item_utilities;
/