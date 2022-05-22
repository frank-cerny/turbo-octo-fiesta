--liquibase formatted sql

--changeset fcerny:1
-- Copy data to a temp column
alter table bsa_revenue_item
add (saleprice1 number(10,2));

--changeset fcerny:2
UPDATE bsa_revenue_item
SET saleprice1 = saleprice;

--changeset fcerny:3
alter table bsa_revenue_item
drop column saleprice;

--changeset fcerny:4
alter table bsa_revenue_item
add (saleprice number(10,2));

--changeset fcerny:5
UPDATE bsa_revenue_item
SET saleprice = saleprice1;

--changeset fcerny:6
-- Drop in future changeset IF change is successful
-- alter table bsa_revenue_item
-- drop column saleprice1;