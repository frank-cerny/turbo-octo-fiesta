
  CREATE OR REPLACE EDITIONABLE PACKAGE "DEV_WS"."FIXED_SUPP_UTILITIES" 
as 
    function bsa_func_get_fixed_supply_units_remaining(supplyId IN number)
    return number;
end fixed_supp_utilities;