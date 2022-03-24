
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
        BEGIN
            
            SELECT sum(purchaseprice) into bikeCost from bsa_bike where project_id = projectId;
            SELECT sum(costbasis) into toolCost FROM bsa_view_project_tool WHERE project_id = projectId;
            SELECT sum(unitcost*unitspurchased) into singleUseSupplyCost from bsa_single_use_supply where project_id = projectId;
            SELECT sum(costbasis) into fixedSupplyCost FROM bsa_view_project_fixed_supply WHERE project_id = projectId;
            SELECT sum(costbasis) into nonFixedSupplyCost FROM bsa_view_project_non_fixed_supply WHERE project_id = projectId;
            SELECT sum(saleprice) into revenue FROM bsa_revenue_item WHERE project_id = projectId;
            
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
            
            
            
            
            
            
            
            return  (revenue - bikeCost - toolCost - singleUseSupplyCost - fixedSupplyCost - nonFixedSupplyCost);
        END;
end project_utilities;