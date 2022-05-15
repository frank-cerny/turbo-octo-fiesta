
  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "DEV_WS"."FIXED_SUPP_UTILITIES" 
as
    function bsa_func_get_fixed_supply_units_remaining(supplyId in number)
    RETURN number
    AS
        totalUsages number := 0;
        unitsPurchased number := 0;
        BEGIN
            select sum(quantity) into totalUsages from bsa_project_fixed_quantity_supply
            where supply_id = supplyId;
            
            totalUsages := COALESCE(totalUsages, 0);
            select fqs.unitspurchased into unitsPurchased
            from bsa_fixed_quantity_supply fqs
            where id = supplyId;
            
            IF totalUsages > unitsPurchased THEN
                return 0;
            ELSE
                return unitsPurchased - totalUsages;
            END IF;
        END;

    
    function bsa_func_get_fixed_supply_unit_cost(supplyId in number)
    RETURN number
    AS
        unitsPurchased number;
        totalCost number;
        unitCost number(10, 2);
        BEGIN
            select bfqs.unitsPurchased, bfqs.totalCost into unitsPurchased, totalCost from bsa_fixed_quantity_supply bfqs WHERE id = supplyId;
            
            if unitsPurchased = 0 THEN
                return null;
            END IF;
            unitCost := totalCost/unitsPurchased;
            return unitCost;
        END;

    
    
    procedure bsa_func_split_fixed_supplies_over_projects (supplyIdString IN varchar2, projectIdString IN varchar2)
    IS
        projectIdList apex_t_varchar2;
        supplyIdList apex_t_varchar2;
    BEGIN
        
        projectIdList := apex_string.split(projectIdString, ':');
        supplyIdList := apex_string.split(supplyIdString, ':');
        
        if projectIdList.count = 0 or supplyIdList.count = 0 then
            return;
        end if;
        
        for i in 1 .. projectIdList.count loop
            for j in 1 .. supplyIdList.count loop
                
                INSERT INTO bsa_view_project_fixed_supply (supply_id, name, description, datepurchased, unitspurchased, totalcost, quantity, project_id)
                        VALUES (TO_NUMBER(supplyIdList(j)), null, null, null, null, null, null, TO_NUMBER(projectIdList(i)));
            end loop;
        end loop;
    END;
end fixed_supp_utilities;