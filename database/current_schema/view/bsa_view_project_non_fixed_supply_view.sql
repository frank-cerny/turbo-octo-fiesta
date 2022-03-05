CREATE OR REPLACE FORCE EDITIONABLE VIEW "FCERNY"."BSA_VIEW_PROJECT_NON_FIXED_SUPPLY" 
 ( "SUPPLY_ID", "NAME", "DESCRIPTION", "DATEPURCHASED", "COST", "QUANTITY", "PROJECT_ID", "UNITCOST", "COSTBASIS"
  )  DEFAULT COLLATION "USING_NLS_COMP"  AS 
  select nfqs.id as supply_id, nfqs.name, nfqs.description, nfqs.datepurchased, nfqs.cost, pt.quantity, pt.project_id, (nfqs.cost / bsa_func_get_non_fixed_supply_usages(nfqs.id)) as unitcost, ((nfqs.cost / bsa_func_get_non_fixed_supply_usages(nfqs.id)) * quantity) as costbasis 
from bsa_non_fixed_quantity_supply nfqs  
inner join bsa_project_non_fixed_quantity_supply pt on pt.supply_id = nfqs.id
