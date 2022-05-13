--liquibase formatted sql

--changeset fcerny:1 runOnChange:true
create or replace synonym fsu
for dev_ws.fixed_supp_utilities;

--changeset fcerny:2 runOnChange:true
create or replace synonym nfsu
for dev_ws.non_fixed_supp_utilities;

--changeset fcerny:3 runOnChange:true
create or replace synonym tu
for dev_ws.tool_utilities;

--changeset fcerny:4 runOnChange:true
create or replace synonym pu
for dev_ws.project_utilities;

--changeset fcerny:5 runOnChange:true
create or replace synonym ru
for dev_ws.revenue_item_utilities;