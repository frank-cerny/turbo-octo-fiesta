
  CREATE OR REPLACE EDITIONABLE FUNCTION "FCERNY"."BSA_FUNC_GET_FIXED_SUPPLY_UNITS_REMAINING" (supplyId in number) 
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
/