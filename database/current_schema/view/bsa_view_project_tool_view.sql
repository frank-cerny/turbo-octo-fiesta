CREATE OR REPLACE FORCE EDITIONABLE VIEW "FRANKCERNY"."BSA_VIEW_PROJECT_TOOL" 
 ( "TOOL_ID", "NAME", "TOOLDESCRIPTION", "DATEPURCHASED", "TOTALCOST", "PROJECT_ID", "QUANTITY", "UNITCOST", "COSTBASIS"
  )  AS 
  select t.id as tool_id, t.name, t.description as tooldescription, t.datepurchased, t.totalcost, pt.project_id, pt.quantity, (t.totalcost/TU.bsa_func_get_tool_total_usage(t.id)) as unitcost, ((t.totalcost/TU.bsa_func_get_tool_total_usage(t.id))*pt.quantity) as costbasis
from bsa_tool t
inner join bsa_project_tool pt on pt.tool_id = t.id