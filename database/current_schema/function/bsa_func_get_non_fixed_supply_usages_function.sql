
  CREATE OR REPLACE EDITIONABLE FUNCTION "FCERNY"."BSA_FUNC_GET_NON_FIXED_SUPPLY_USAGES" (supplyId in number) 
RETURN number 
AS 
    totalUsages number; 
    BEGIN 
        -- Get outstanding total based on all project usages 
        select sum(quantity) into totalUsages from bsa_project_non_fixed_quantity_supply 
        where supply_id = supplyId; 
        return totalUsages; 
    END; 
/