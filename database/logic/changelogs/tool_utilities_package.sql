--liquibase formatted sql

--changeset fcerny:1 runOnChange:true endDelimiter:"/"
create or replace package tool_utilities
as 
    function bsa_func_get_tool_total_usage (toolId IN int)
    return number;
    function bsa_func_get_tool_unit_cost (toolId IN int)
    return number;
    procedure bsa_func_split_tools_over_projects(toolIdString IN varchar2, projectIdString IN varchar2);
end tool_utilities;
/

-- TODO Add functionality to spread tool across more than 1 project at once (colon separated string from shuttle list)

--changeset fcerny:2 runOnChange:true endDelimiter:"/"
-- Functionality package 
create or replace package body tool_utilities
as
    -- Return the total usages of a tool given its id
    -- Reference: https://www.guru99.com/subprograms-procedures-functions-pl-sql.html#3
    function bsa_func_get_tool_total_usage (toolId IN int)
    RETURN number
    AS
        totalUsages number;
        BEGIN
            -- If none, return 0 instead of null (and avoid no_data_found error)
            select COALESCE(sum(quantity), 0) into totalUsages 
            from bsa_project_tool
            where tool_id = toolId;
            return totalUsages;
        END;

    function bsa_func_get_tool_unit_cost (toolId IN int)
    RETURN number
    AS
        totalUsages number;
        totalCost number;
        -- number(precision, scale) (max precision = digits, scale = digits to right of decimal)
        unitCost number(10,2);
        BEGIN
            -- If none, return 0 instead of null (and avoid no_data_found error)
            totalUsages := bsa_func_get_tool_total_usage(toolId);
            if totalUsages = 0 THEN
                return null;
            END IF;
            -- Get total cost of tool
            select totalCost into totalCost from bsa_tool where Id = toolId;
            unitCost := totalCost/totalUsages;
            return unitCost;
        END;

    -- Requires:
    --  1. toolIdString and projectIdString are well formatted colon separated strings of integers
    procedure bsa_func_split_tools_over_projects (toolIdString IN varchar2, projectIdString IN varchar2)
    IS
        projectIdList apex_t_varchar2;
        toolIdList apex_t_varchar2;
    BEGIN
        -- Break the strings into arrays (can be empty)
        projectIdList := apex_string.split(projectIdString, ':');
        toolIdList := apex_string.split(toolIdString, ':');
        -- Both arrays must be non empty for this to work
        if projectIdList.count = 0 or toolIdList.count = 0 then
            return;
        end if;
        -- Iterate through both arrays
        for i in 1 .. projectIdList.count loop
            for j in 1 .. toolIdList.count loop
                -- We use the view here because otherwise our trigger wouldn't work (it would be a recursive, never ending trigger)
                INSERT INTO bsa_view_project_tool (tool_id, name, ToolDescription, datepurchased, totalcost, unitcost, project_id)
                        VALUES (TO_NUMBER(toolIdList(j)), NULL, NULL, NULL, NULL, NULL, TO_NUMBER(projectIdList(i)));
            end loop;
        end loop;
    END;
end tool_utilities;
/