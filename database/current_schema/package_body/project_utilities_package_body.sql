
  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "DEV_WS"."PROJECT_UTILITIES" 
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
        taxDue number;
        BEGIN
            -- APEX_DEBUG.ENABLE(apex_debug.c_log_level_engine_trace);
            bikeCost := bsa_func_return_bike_cost_for_project(projectId);
            toolCost := bsa_func_return_tool_cost_for_project(projectId);
            singleUseSupplyCost := bsa_func_return_single_use_supply_cost_for_project(projectId);
            fixedSupplyCost := bsa_func_return_fixed_supply_cost_for_project(projectId);
            nonFixedSupplyCost := bsa_func_return_non_fixed_supply_cost_for_project(projectId);
            revenue := bsa_func_return_revenue_for_project(projectId);
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
            taxDue := taxu.bsa_func_calculate_total_federal_tax(projectId);
            -- apex_debug.info('Bike Purchase Price: ' || bikeCost);
            -- apex_debug.info('Tool Cost: ' || toolCost);
            -- apex_debug.info('Single Use Supply Cost: ' || singleUseSupplyCost);
            -- apex_debug.info('Fixed Supply Cost: ' || fixedSupplyCost);
            -- apex_debug.info('Non Fixed Supply Cost: ' || nonFixedSupplyCost);
            -- apex_debug.info('Revenue: ' || revenue);
            -- Setting the out value is the same as "returning a value"
            return  (revenue - bikeCost - toolCost - singleUseSupplyCost - fixedSupplyCost - nonFixedSupplyCost - taxDue);
        END;

    -- projectIdString is a colon separated project id string
    function bsa_func_return_project_name_string_from_ids (projectIdString IN varchar2)
    RETURN varchar2
    AS
        projectNameString varchar2(500);
        projectIdList apex_t_varchar2;
        projectId number;
        projectTitle varchar2(200);
        BEGIN
            projectIdList := apex_string.split(projectIdString, ':');
            -- Count the number of non-null items in the 1xN table 
            if projectIdList.count = 0 then
                return 'No Projects Selected';
            end if;
            -- Iterate through the list of ids to get the name of the project (works on 1 - N ids)
            projectNameString := '';
            for i in 1 .. projectIdList.count loop
                projectId := TO_NUMBER(projectidList(i));
                SELECT p.title into projectTitle from bsa_project p where id = projectId;
                projectNameString := (projectNameString || projectTitle);
                -- If there are more items in the list, append a comma (when i = count, we have found the last item)
                if i < projectIdList.count then
                    projectNameString := (projectNameString || ', ');
                end if;
            end loop;
            return projectNameString;
        END;

    function bsa_func_return_bike_cost_for_project(projectId IN int)
    RETURN number
    AS
        cost number(10,2);
        numBikes int;
        BEGIN
            -- If count returns 0, an exception will not be thrown
            select count(id) into numBikes from bsa_bike where project_id = projectId;
            if numBikes = 0 THEN
                return 0;
            end if;
            select sum(purchaseprice) into cost from bsa_bike where project_id = projectId;
            return cost;
        END;

    function bsa_func_return_single_use_supply_cost_for_project(projectId IN int)
    RETURN number
    AS
        cost number(10,2);
        numSingleUseSupplies int;
        BEGIN
            -- If count returns 0, an exception will not be thrown
            select count(id) into numSingleUseSupplies from bsa_single_use_supply where project_id = projectId;
            if numSingleUseSupplies = 0 THEN
                return 0;
            end if;
            select sum(unitcost*unitspurchased) into cost from bsa_single_use_supply where project_id = projectId;
            return cost;
        END;

    function bsa_func_return_tool_cost_for_project(projectId IN int)
    RETURN number
    AS
        cost number(10,2);
        numTools int;
        BEGIN
            -- If count returns 0, an exception will not be thrown
            select count(tool_id) into numTools from bsa_view_project_tool where project_id = projectId;
            if numTools = 0 THEN
                return 0;
            end if;
            select sum(costbasis) into cost from bsa_view_project_tool where project_id = projectId;
            return cost;
        END;

    function bsa_func_return_revenue_for_project(projectId IN int)
    RETURN number
    AS
        revenue number(10,2);
        numRevenueItems int;
        BEGIN
            -- If count returns 0, an exception will not be thrown
            select count(id) into numRevenueItems from bsa_revenue_item where project_id = projectId;
            if numRevenueItems = 0 THEN
                return 0;
            end if;
            select sum(saleprice) into revenue from bsa_revenue_item where project_id = projectId;
            return revenue;
        END;

    function bsa_func_return_fixed_supply_cost_for_project(projectId IN int)
    RETURN number
    AS
        cost number(10,2);
        numItems int;
        BEGIN
            -- If count returns 0, an exception will not be thrown
            select count(costbasis) into numItems from bsa_view_project_fixed_supply where project_id = projectId;
            if numItems = 0 THEN
                return 0;
            end if;
            select sum(costbasis) into cost from bsa_view_project_fixed_supply where project_id = projectId;
            return cost;
        END;

    function bsa_func_return_non_fixed_supply_cost_for_project(projectId IN int)
    RETURN number
    AS
        cost number(10,2);
        numItems int;
        BEGIN
            -- If count returns 0, an exception will not be thrown
            select count(costbasis) into numItems from bsa_view_project_non_fixed_supply where project_id = projectId;
            if numItems = 0 THEN
                return 0;
            end if;
            select sum(costbasis) into cost from bsa_view_project_non_fixed_supply where project_id = projectId;
            return cost;
        END;

end project_utilities;
