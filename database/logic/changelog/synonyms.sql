--liquibase formatted sql

--changeset fcerny:1 runOnChange:true
create or replace synonym fsu
for frankcerny.fixed_supp_utilities;

--changeset fcerny:2 runOnChange:true
create or replace synonym nfsu
for frankcerny.non_fixed_supp_utilities;

--changeset fcerny:3 runOnChange:true
create or replace synonym tu
for frankcerny.tool_utilities;

--changeset fcerny:4 runOnChange:true
create or replace synonym pu
for frankcerny.project_utilities;