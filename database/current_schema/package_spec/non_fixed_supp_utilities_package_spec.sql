
  CREATE OR REPLACE EDITIONABLE PACKAGE "DEV_WS"."NON_FIXED_SUPP_UTILITIES" 
as 
    function bsa_func_get_non_fixed_supply_usages(supplyId IN number)
    return number;
    function bsa_func_get_non_fixed_supply_unit_cost(supplyId IN number)
    return number;
    procedure bsa_func_split_non_fixed_supplies_over_projects(supplyIdString IN varchar2, projectIdString IN varchar2);
end non_fixed_supp_utilities;