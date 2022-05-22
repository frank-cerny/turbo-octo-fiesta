
  CREATE OR REPLACE EDITIONABLE PACKAGE "DEV_WS"."REVENUE_ITEM_UTILITIES" 
as 
    procedure bsa_proc_split_revenue_item_among_projects(projectIdString IN varchar2, name IN varchar2, description IN varchar2, salePrice IN number, platformSoldOn IN varchar2, isPending IN varchar2, dateSold IN Date);
end revenue_item_utilities;