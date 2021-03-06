--liquibase formatted sql

--changeset fcerny:1
create table bsa_project (
    id                             number generated by default on null as identity constraint bsa_project_id_pk primary key,
    description                    varchar2(2500char),
    title                          varchar2(500 char) constraint bsa_project_title_unq unique not null,
    datestarted                    date,
    dateended                      date
);

--changset fcerny:2
create table bsa_revenue_item (
    id                             number generated by default on null as identity constraint bsa_revenue_item_id_pk primary key,
    project_id                     number constraint revenue_item_project_id_fk references bsa_project on delete cascade,
    name                           varchar2(255 char) not null,
    description                    varchar2(4000 char),
    saleprice                      number,
    platformsoldon                 varchar2(4000 char) not null,
    ispending                      varchar2(1 char) default 'N',
    datesold                       date not null
);

--changeset fcerny:3
--comment: Tools are capital items used to work on a bike (wrenches, etc.)
create table bsa_tool (
    id                             number generated by default on null as identity constraint bsa_tool_id_pk primary key,
    name                           varchar2(255 char) constraint bsa_tool_name_unq unique not null,
    description                    varchar2(4000 char),
    datepurchased                  date,
    totalcost                      number not null
);

--changset fcerny:4
--comment: Single use supplies are things like cables, brake pads, etc. (used on a single project)
create table bsa_single_use_supply (
    id                             number generated by default on null as identity constraint bsa_single_use_supply_id_pk primary key,
    name                           varchar2(255 char),
    description                    varchar2(4000 char),
    datepurchased                  date,
    project_id                     number constraint bsa_single_use_supply_fk references bsa_project on delete cascade,
    ispending                      varchar2(1 char) default 'N',
    unitcost                       number not null,
    unitspurchased                 number default 1,
    revenueitem_id                 number constraint bsa_single_use_supply_revenue_item_fk references bsa_revenue_item on delete set null
);

alter table bsa_single_use_supply add constraint bsa_single_use_supply_uk unique (name, datepurchased);

--changeset fcerny:5
--comment: Fixed quantity supplies are things like bubble wrap, mailers, etc. that are used across multiple projects
create table bsa_fixed_quantity_supply (
    id                             number generated by default on null as identity constraint bsa_fixed_quantity_supply_id_pk primary key,
    name                           varchar2(255 char),
    description                    varchar2(4000 char),
    datepurchased                  date,
    unitspurchased                 integer default 0,
    totalcost                      number not null
);

alter table bsa_fixed_quantity_supply add constraint bsa_fixed_quantity_supply unique (name, datepurchased);

--changeset fcerny:6
--comment: Non-fixed quantity supplies are things like Tape, EvapoRust, etc. that will be used on more than one project but without knowing the exact quantity
create table bsa_non_fixed_quantity_supply (
    id                             number generated by default on null as identity constraint bsa_non_fixed_quantity_supply_id_pk primary key,
    name                           varchar2(255 char),
    description                    varchar2(4000 char),
    datepurchased                  date,
    cost                           number not null
);

alter table bsa_non_fixed_quantity_supply add constraint bsa_non_fixed_quantity_supply unique (name, datepurchased);

--changeset fcerny:7
create table bsa_bike (
    id                             number generated by default on null as identity constraint bsa_bike_id_pk primary key,
    serialnumber                   number,
    make                           varchar2(200 char),
    model                          varchar2(200 char),
    year                           number,
    purchaseprice                  number,
    purchasedfrom                  varchar2(4000 char),
    datepurchased                  date,
    description                    varchar2(4000 char),
    project_id                     number constraint bsa_bike_project_fk references bsa_project on delete cascade
);

alter table bsa_bike add constraint bsa_bike_uk unique (make, model, year, serialnumber);

--changeset fcerny:8
--comment: Configurable locations to track where items are bought/sold (like Ebay, Facebook Marketplace, etc.)
create table bsa_location (
    id                             number generated by default on null as identity constraint bsa_location_id_pk primary key,
    name                           varchar2(100 char)
);

--changeset fcerny:9
--comment: Maps tools between project
create table bsa_project_tool (
    id                             number generated by default on null as identity constraint bsa_project_tool_id_pk primary key,
    project_id                     number constraint bsa_project_tool_project_fk references bsa_project on delete cascade,
    tool_id                        number constraint bsa_project_tool_tool_fk references bsa_tool on delete cascade,
    quantity                       number default 0
);

--changeset fcerny:10
--comment: Maps fixed quantity supplies and projects
create table bsa_project_fixed_quantity_supply (
    id                             number generated by default on null as identity constraint bsa_project_fix_quant_supp_id_pk primary key,
    project_id                     number constraint bsa_project_fix_quant_supp_project_fk references bsa_project on delete cascade,
    supply_id                      number constraint bsa_project_fix_quant_supp_fk references bsa_fixed_quantity_supply on delete cascade,
    quantity                       number default 0
);

--changeset fcerny:11
--comment: Maps non-fixed quantity supplies and projects
create table bsa_project_non_fixed_quantity_supply (
    id                             number generated by default on null as identity constraint bsa_project_non_fix_quant_supp_id_pk primary key,
    project_id                     number constraint bsa_project_non_fix_quant_supp_project_fk references bsa_project on delete cascade,
    supply_id                       number constraint bsa_project_non_fix_quant_supp_sup_fk references bsa_non_fixed_quantity_supply on delete cascade,
    quantity                       number default 0
);
