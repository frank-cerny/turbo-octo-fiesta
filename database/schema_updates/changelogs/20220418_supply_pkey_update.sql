--liquibase formatted sql

--changeset fcerny:1
alter table bsa_single_use_supply
DROP constraint bsa_single_use_supply_uk;

--changest fcerny:2
-- Add a new constraint back
alter table bsa_single_use_supply
ADD constraint bsa_single_use_supply_uk unique (project_id, name);

--changeset fcerny:3
-- Do the same for revenue items, dropping first to aid in testing
alter table bsa_revenue_item
DROP constraint bsa_revenue_item_uk;

--changeset fcerny:4
alter table bsa_revenue_item
ADD constraint bsa_revenue_item_uk unique (project_id, name);
