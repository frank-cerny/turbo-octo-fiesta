
  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "DEV_WS"."SINGLE_USE_SUPPLY_UTILITIES" 
as
    procedure bsa_proc_split_single_use_supply_among_projects(projectIdString IN varchar2, name IN varchar2, description IN varchar2, datePurchased Date, isPending varchar2, unitCost number, unitsPurchased int, revenueItemId int)
    IS
        projectIdList apex_t_varchar2;
        projectDescription varchar2(100);
        splitUnitCost number(10,2);
    BEGIN
        
        projectIdList := apex_string.split(projectIdString, ':');
        
        if projectIdList.count = 0 then
            return;
        end if;
        splitUnitCost := (unitCost * unitsPurchased) / projectIdList.count;
        
        for i in 1 .. projectIdList.count loop
            
            INSERT INTO BSA_SINGLE_USE_SUPPLY(name, description, datePurchased, project_id, isPending, unitCost, unitsPurchased, revenueItem_id)
            VALUES (name, '' || description || ' (Split Among Projects: ' || pu.bsa_func_return_project_name_string_from_ids(projectIdString) || ')', datePurchased, TO_NUMBER(projectIdList(i)), isPending, splitUnitCost, unitsPurchased, revenueItemId);
        end loop;
    END;
end single_use_supply_utilities;