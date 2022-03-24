CREATE OR REPLACE FORCE EDITIONABLE VIEW "DEV_WS"."BSA_VIEW_PROJECT_FIXED_SUPPLY" 
 ( "SUPPLY_ID", "NAME", "DESCRIPTION", "DATEPURCHASED", "UNITSPURCHASED", "TOTALCOST", "QUANTITY", "PROJECT_ID", "UNITCOST", "COSTBASIS"
  )  AS 
  select fqs.id as supply_id, fqs.name, fqs.description, fqs.datepurchased, fqs.unitspurchased, fqs.totalcost, pt.quantity, pt.project_id, (fqs.totalCost/fqs.unitspurchased) as unitcost, ((fqs.totalCost/fqs.unitspurchased) * pt.quantity) as costbasis
from bsa_fixed_quantity_supply fqs 
inner join bsa_project_fixed_quantity_supply pt on pt.supply_id = fqs.id