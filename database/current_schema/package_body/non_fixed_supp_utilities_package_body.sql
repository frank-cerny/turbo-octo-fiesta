
  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "DEV_WS"."NON_FIXED_SUPP_UTILITIES" 
as
    function bsa_func_get_non_fixed_supply_usages (supplyId in number)
    RETURN number
    AS
        totalUsages number;
        BEGIN
            
            select sum(quantity) into totalUsages from bsa_project_non_fixed_quantity_supply
            where supply_id = supplyId;
            return totalUsages;
        END;
end non_fixed_supp_utilities;