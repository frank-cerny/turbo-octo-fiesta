
  CREATE OR REPLACE EDITIONABLE PACKAGE "DEV_WS"."NON_FIXED_SUPP_UTILITIES" 
as 
    function bsa_func_get_non_fixed_supply_usages(supplyId IN number)
    return number;
    function bsa_func_get_non_fixed_supply_unit_cost(supplyId IN number)
    return number;
end non_fixed_supp_utilities;