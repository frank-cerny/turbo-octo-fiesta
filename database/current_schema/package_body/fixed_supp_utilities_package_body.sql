
  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "FRANKCERNY"."FIXED_SUPP_UTILITIES" 
as
    function bsa_func_get_fixed_supply_units_remaining(supplyId in number)
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
end fixed_supp_utilities;