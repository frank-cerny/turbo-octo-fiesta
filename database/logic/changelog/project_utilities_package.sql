--liquibase formatted sql

--changeset fcerny:1 runOnChange:true
create or replace package project_utilities
as 
    function bsa_func_calculate_net_project_value(projectId IN int)
    return number;
end project_utilities;
/

--changeset fcerny:2 runOnChange:true
-- Functionality package 
create or replace package body project_utilities
as
    function bsa_func_calculate_net_project_value (projectId IN int)
    RETURN number
    AS
        bikeCost number;
        toolCost number;
        singleUseSupplyCost number;
        fixedSupplyCost number;
        nonFixedSupplyCost number;
        revenue number;
        BEGIN
            -- APEX_DEBUG.ENABLE(apex_debug.c_log_level_engine_trace);
            SELECT sum(purchaseprice) into bikeCost from bsa_bike where project_id = projectId;
            SELECT sum(costbasis) into toolCost FROM bsa_view_project_tool WHERE project_id = projectId;
            SELECT sum(unitcost*unitspurchased) into singleUseSupplyCost from bsa_single_use_supply where project_id = projectId;
            SELECT sum(costbasis) into fixedSupplyCost FROM bsa_view_project_fixed_supply WHERE project_id = projectId;
            SELECT sum(costbasis) into nonFixedSupplyCost FROM bsa_view_project_non_fixed_supply WHERE project_id = projectId;
            SELECT sum(saleprice) into revenue FROM bsa_revenue_item WHERE project_id = projectId;
            -- Check for any null values
            if bikeCost is NULL then
                bikeCost := 0;
            end if;
            if toolCost is NULL then
                toolCost := 0;
            end if;
            if singleUseSupplyCost is NULL then
                singleUseSupplyCost := 0;
            end if;
            if fixedSupplyCost is NULL then
                fixedSupplyCost := 0;
            end if;
            if nonFixedSupplyCost is NULL then
                nonFixedSupplyCost := 0;
            end if;
            if revenue is NULL then
                revenue := 0;
            end if;
            -- apex_debug.info('Bike Purchase Price: ' || bikeCost);
            -- apex_debug.info('Tool Cost: ' || toolCost);
            -- apex_debug.info('Single Use Supply Cost: ' || singleUseSupplyCost);
            -- apex_debug.info('Fixed Supply Cost: ' || fixedSupplyCost);
            -- apex_debug.info('Non Fixed Supply Cost: ' || nonFixedSupplyCost);
            -- apex_debug.info('Revenue: ' || revenue);
            -- Setting the out value is the same as "returning a value"
            return  (revenue - bikeCost - toolCost - singleUseSupplyCost - fixedSupplyCost - nonFixedSupplyCost);
        END;
end project_utilities;
/