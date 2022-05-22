
  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "DEV_WS"."REVENUE_ITEM_UTILITIES" 
as
    procedure bsa_proc_split_revenue_item_among_projects(projectIdString IN varchar2, name IN varchar2, description IN varchar2, salePrice IN number, platformSoldOn IN varchar2, isPending IN varchar2, dateSold IN Date)
    IS
        projectIdList apex_t_varchar2;
        unitSalePrice number(10,2);
    BEGIN
        
        projectIdList := apex_string.split(projectIdString, ':');
        
        if projectIdList.count = 0 then
            return;
        end if;
        unitSalePrice := salePrice / projectIdList.count;
        
        for i in 1 .. projectIdList.count loop
            
            INSERT INTO BSA_REVENUE_ITEM(project_id, name, description, salePrice, platformSoldOn, isPending, dateSold)
            VALUES (TO_NUMBER(projectIdList(i)), name, '' || description || ' (Split Among Projects: ' || pu.bsa_func_return_project_name_string_from_ids(projectIdString) || ')', unitSalePrice, platformSoldOn, isPending, dateSold);
        end loop;
    END;
end revenue_item_utilities;