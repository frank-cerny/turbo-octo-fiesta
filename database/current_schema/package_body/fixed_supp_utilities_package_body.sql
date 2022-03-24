
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
end fixed_supp_utilities;