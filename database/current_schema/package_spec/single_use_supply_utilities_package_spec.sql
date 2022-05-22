
  CREATE OR REPLACE EDITIONABLE PACKAGE "DEV_WS"."SINGLE_USE_SUPPLY_UTILITIES" 
as 
    procedure bsa_proc_split_single_use_supply_among_projects(projectIdString IN varchar2, name IN varchar2, description IN varchar2, datePurchased Date, isPending varchar2, unitCost number, unitsPurchased int, revenueItemId int);
end single_use_supply_utilities;