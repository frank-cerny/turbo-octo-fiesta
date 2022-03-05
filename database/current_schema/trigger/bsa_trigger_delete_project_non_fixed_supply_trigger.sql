
  CREATE OR REPLACE EDITIONABLE TRIGGER "FCERNY"."BSA_TRIGGER_DELETE_PROJECT_NON_FIXED_SUPPLY" 
    instead of DELETE on bsa_view_project_non_fixed_supply 
    FOR EACH ROW 
    BEGIN  
        DELETE  
        FROM bsa_project_non_fixed_quantity_supply 
        WHERE project_id = :old.project_id AND supply_id = :old.supply_id; 
    END; 

/
ALTER TRIGGER "FCERNY"."BSA_TRIGGER_DELETE_PROJECT_NON_FIXED_SUPPLY" ENABLE;