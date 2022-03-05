-- Create Functions -------------------------------------------------------------------------------------------------------------------------

-- Return the total usages of a tool given its id
-- Reference: https://www.guru99.com/subprograms-procedures-functions-pl-sql.html#3
create or replace function bsa_func_update_get_total_usages (toolId IN int)
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

-- Create stored procedure to calculate net value of a project
create or replace function bsa_func_calculate_net_project_value (projectId IN int)
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
/

create or replace function bsa_func_get_fixed_supply_units_remaining(supplyId in number)
RETURN number
AS
    totalUsages number;
    unitsPurchased number;
    BEGIN
        select sum(quantity) into totalUsages from bsa_project_fixed_quantity_supply
        where supply_id = supplyId;
        select fqs.unitspurchased into unitsPurchased
        from bsa_fixed_quantity_supply fqs
        where id = supplyId;
        return unitsPurchased - totalUsages;
    END;
/

create or replace function bsa_func_get_non_fixed_supply_usages (supplyId in number)
RETURN number
AS
    totalUsages number;
    BEGIN
        -- Get outstanding total based on all project usages
        select sum(quantity) into totalUsages from bsa_project_non_fixed_quantity_supply
        where supply_id = supplyId;
        return totalUsages;
    END;
/