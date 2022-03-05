CREATE OR REPLACE FORCE EDITIONABLE VIEW "FCERNY"."BSA_VIEW_PROJECT_TOOL" 
 ( "TOOL_ID", "NAME", "TOOLDESCRIPTION", "DATEPURCHASED", "TOTALCOST", "PROJECT_ID", "QUANTITY", "UNITCOST", "COSTBASIS"
  )  DEFAULT COLLATION "USING_NLS_COMP"  AS 
  select t.id as tool_id, t.name, t.description as tooldescription, t.datepurchased, t.totalcost, pt.project_id, pt.quantity, (t.totalcost/bsa_func_update_get_total_usages(t.id)) as unitcost, ((t.totalcost/bsa_func_update_get_total_usages(t.id))*pt.quantity) as costbasis 
from bsa_tool t 
inner join bsa_project_tool pt on pt.tool_id = t.id
