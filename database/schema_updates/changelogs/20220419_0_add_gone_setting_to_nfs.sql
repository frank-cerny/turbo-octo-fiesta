--liquibase formatted sql

--changeset fcerny:1
alter table bsa_non_fixed_quantity_supply
add (isusedup varchar2(1 char) default 'N');

--changeset fcerny:2
-- Update all current items and set to isusedup = 'N'
UPDATE bsa_non_fixed_quantity_supply
SET isusedup = 'N';