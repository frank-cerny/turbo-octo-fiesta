
  CREATE OR REPLACE EDITIONABLE PACKAGE "DEV_WS"."FIXED_SUPP_UTILITIES" 
as 
    function bsa_func_get_fixed_supply_units_remaining(supplyId IN number)
    return number;
    
    function bsa_func_get_fixed_supply_unit_cost(supplyId IN number)
    return number;
    procedure bsa_func_split_fixed_supplies_over_projects (supplyIdString IN varchar2, projectIdString IN varchar2);
end fixed_supp_utilities;