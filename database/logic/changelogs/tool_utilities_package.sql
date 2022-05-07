--liquibase formatted sql

--changeset fcerny:1 runOnChange:true endDelimiter:"/"
create or replace package tool_utilities
as 
    function bsa_func_get_tool_total_usage (toolId IN int)
    return number;
    function bsa_func_get_tool_unit_cost (toolId IN int)
    return number;
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
end tool_utilities;
/