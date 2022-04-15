
  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "DEV_WS"."FIXED_SUPP_UTILITIES" 
as
    function bsa_func_get_fixed_supply_units_remaining(supplyId in number)
    RETURN number
    AS
        totalUsages number := 0;
        unitsPurchased number := 0;
        BEGIN
            select sum(quantity) into totalUsages from bsa_project_fixed_quantity_supply
            where supply_id = supplyId;
            
            totalUsages := COALESCE(totalUsages, 0);
            select fqs.unitspurchased into unitsPurchased
            from bsa_fixed_quantity_supply fqs
            where id = supplyId;
            
            IF totalUsages > unitsPurchased THEN
                return 0;
            ELSE
                return unitsPurchased - totalUsages;
            END IF;
        END;

    
    function bsa_func_get_fixed_supply_unit_cost(supplyId in number)
    RETURN number
    AS
        unitsPurchased number;
        totalCost number;
        unitCost number(10, 2);
        BEGIN
            select bfqs.unitsPurchased, bfqs.totalCost into unitsPurchased, totalCost from bsa_fixed_quantity_supply bfqs WHERE id = supplyId;
            
            if unitsPurchased = 0 THEN
                return null;
            END IF;
            unitCost := totalCost/unitsPurchased;
            return unitCost;
        END;
end fixed_supp_utilities;