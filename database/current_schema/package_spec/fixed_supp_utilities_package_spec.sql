
  CREATE OR REPLACE EDITIONABLE PACKAGE "DEV_WS"."FIXED_SUPP_UTILITIES" 
as 
    function bsa_func_get_fixed_supply_units_remaining(supplyId IN number)
    return number;
    -- This is a wrapper on simple division, but with rounding 
    function bsa_func_get_fixed_supply_unit_cost(supplyId IN number)
    return number;
end fixed_supp_utilities;
