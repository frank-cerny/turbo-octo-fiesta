--liquibase formatted sql

--changeset fcerny:1 runOnChange:true
create or replace view bsa_view_project_tool
AS
select t.id as tool_id, t.name, t.description as tooldescription, t.datepurchased, t.totalcost, pt.project_id, pt.quantity, (t.totalcost/TU.bsa_func_get_tool_total_usage(t.id)) as unitcost, ((t.totalcost/TU.bsa_func_get_tool_total_usage(t.id))*pt.quantity) as costbasis
from bsa_tool t
inner join bsa_project_tool pt on pt.tool_id = t.id;

--changeset fcerny:2 runOnChange:true
create or replace view bsa_view_project_fixed_supply
AS
select fqs.id as supply_id, fqs.name, fqs.description, fqs.datepurchased, fqs.unitspurchased, fqs.totalcost, pt.quantity, pt.project_id, (fqs.totalCost/fqs.unitspurchased) as unitcost, ((fqs.totalCost/fqs.unitspurchased) * pt.quantity) as costbasis
from bsa_fixed_quantity_supply fqs 
inner join bsa_project_fixed_quantity_supply pt on pt.supply_id = fqs.id;

--changeset fcerny:3 runOnChange:true
create or replace view bsa_view_project_non_fixed_supply
AS
select nfqs.id as supply_id, nfqs.name, nfqs.description, nfqs.datepurchased, nfqs.cost, pt.quantity, pt.project_id, (nfqs.cost / NFSU.bsa_func_get_non_fixed_supply_usages(nfqs.id)) as unitcost, ((nfqs.cost / NFSU.bsa_func_get_non_fixed_supply_usages(nfqs.id)) * quantity) as costbasis
from bsa_non_fixed_quantity_supply nfqs 
inner join bsa_project_non_fixed_quantity_supply pt on pt.supply_id = nfqs.id;