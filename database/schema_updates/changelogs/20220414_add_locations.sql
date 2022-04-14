--liquibase formatted sql

--changeset fcerny:1
-- Add the basic locations we known of
-- Reference: https://stackoverflow.com/questions/39576/best-way-to-do-multi-row-insert-in-oracle
-- We used the union select method here because otherwise we get a pkey unique error
INSERT INTO bsa_location (name)
    select 'Ebay' from dual
    union all select 'Facebook Marketplace' from dual
    union all select 'Goodwill' from dual
    union all select 'Estate Sale' from dual
    union all select 'Frostville/Bob' from dual
    union all select 'Garage Sale' from dual
    union all select 'Salvation Army' from dual
    union all select 'Litchfield Swap Meet' from dual
    union all select 'Jamies Flea Market' from dual;