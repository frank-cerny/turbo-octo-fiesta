--liquibase formatted sql

--changeset fcerny:1 runOnChange:true
create or replace package tool_utilities
as 
    function bsa_func_get_tool_total_usage (toolId IN int)
    return number;
end tool_utilities;
/

--changeset fcerny:2 runOnChange:true
-- Functionality package 
create or replace package body tool_utilities
as
    -- Return the total usages of a tool given its id
    -- Reference: https://www.guru99.com/subprograms-procedures-functions-pl-sql.html#3
    function bsa_func_get_tool_total_usage (toolId IN int)
    RETURN number
    AS
        totalUsages number := 0;
        BEGIN
            select sum(quantity) into totalUsages 
            from bsa_project_tool bpt
            where toolId = tool_id;
            return totalUsages;
        END;
    /
end tool_utilities;
/