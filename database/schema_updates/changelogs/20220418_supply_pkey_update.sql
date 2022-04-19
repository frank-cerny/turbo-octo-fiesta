--liquibase formatted sql

--changeset fcerny:1 endDelimiter:"/"
declare 
  l_count integer;
begin
    SELECT count(*) INTO l_count FROM USER_CONSTRAINTS 
    WHERE CONSTRAINT_NAME='BSA_REVENUE_ITEM_UK';

    if l_count > 0 then 
        execute immediate 'alter table bsa_single_use_supply drop constraint bsa_single_use_supply_uk';
    end if;
end;
/

--changest fcerny:2 
-- Add a new constraint back
alter table bsa_single_use_supply
ADD constraint bsa_single_use_supply_uk unique (project_id, name);

--changeset fcerny:3 endDelimiter:"/"
-- Do the same for revenue items, dropping first to aid in testing
-- Reference: https://docs.oracle.com/cd/B19306_01/server.102/b14237/statviews_1037.htm#i1576022
declare 
  l_count integer;
begin
    SELECT count(*) INTO l_count FROM USER_CONSTRAINTS 
    WHERE CONSTRAINT_NAME='BSA_REVENUE_ITEM_UK';

    if l_count > 0 then 
        execute immediate 'alter table bsa_revenue_item drop constraint bsa_revenue_item_uk';
    end if;
end;
/

--changeset fcerny:4
alter table bsa_revenue_item
ADD constraint bsa_revenue_item_uk unique (project_id, name);