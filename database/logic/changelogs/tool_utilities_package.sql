--liquibase formatted sql

--changeset fcerny:1 runOnChange:true endDelimiter:"/"
create or replace package tool_utilities
as 
    function bsa_func_get_tool_total_usage (toolId IN int)
    return number;
end tool_utilities;
/

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
            where toolId = tool_id;
            return totalUsages;
        END;
end tool_utilities;
/