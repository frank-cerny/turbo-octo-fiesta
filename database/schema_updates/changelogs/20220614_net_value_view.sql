--liquibase formatted sql

--changeset fcerny:1
-- TODO - Add functions for each of these sums (add tests) so that we can show 0 values (inner join fails with no results)
SELECT p.title, sum(purchaseprice) as BikeCost, sum(vpt.costbasis) as ToolCost, sum(sus.unitcost*sus.unitspurchased) as SingleUseSupplyCost, sum(vpfs.costbasis) as FixedSupplyCost, sum(vpnfs.costbasis) as NonFixedSupplyCost, sum(r.saleprice) as Revenue, taxu.bsa_func_calculate_total_federal_tax(p.id) as Tax, pu.bsa_func_calculate_net_project_value(p.id) as NetValue from bsa_project p
INNER join bsa_bike b on b.project_id = p.id
INNER join bsa_view_project_tool vpt on vpt.project_id = p.id
INNER join bsa_single_use_supply sus on sus.project_id = p.id
INNER join bsa_view_project_fixed_supply vpfs on vpfs.project_id = p.id
INNER join bsa_view_project_non_fixed_supply vpnfs on vpnfs.project_id = p.id
INNER join bsa_revenue_item r on r.project_id = p.id
GROUP by p.title, p.id
