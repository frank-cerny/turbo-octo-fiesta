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

--changeset fcerny:4 runOnChange:true
create or replace view bsa_view_net_value
AS
SELECT p.id, p.title, pu.bsa_func_return_bike_cost_for_project(id) as BikeCost, pu.bsa_func_return_tool_cost_for_project(id) as toolCost, pu.bsa_func_return_single_use_supply_cost_for_project(id) as SingleUseSupplyCost, pu.bsa_func_return_fixed_supply_cost_for_project(id) as FixedUseSupplyCost, pu.bsa_func_return_non_fixed_supply_cost_for_project(id) as NonFixedSupplyCost, pu.bsa_func_return_revenue_for_project(id) as Revenue, taxu.bsa_func_calculate_total_federal_tax(id) as Tax, pu.bsa_func_calculate_net_project_value(id) as NetValue from bsa_project p;