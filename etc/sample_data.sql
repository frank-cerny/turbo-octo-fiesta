-- Sample Data
INSERT INTO BSA_PROJECT (description, title, datestarted, dateended)
VALUES ('Simple project', 'Ohio City Project', CURRENT_DATE, NULL);

DECLARE
    projectId NUMBER;
    toolId NUMBER;
    fixedSupplyId NUMBER;
    nonFixedSupplyId NUMBER;
BEGIN
    SELECT p.id INTO projectId FROM BSA_PROJECT p WHERE p.title = 'Ohio City Project';
    -- Insert a Bike
    INSERT INTO BSA_BIKE (serialNumber, make, model, year, purchaseprice, purchasedfrom, datepurchased, description, project_id)
    VALUES ('12345', 'Schwinn', 'Tempo', 1988, 56.78, 'FBM', CURRENT_DATE, 'A simple bike!', projectId);
    -- Insert a Tool
    INSERT INTO BSA_TOOL (name, description, datepurchased, totalcost)
    VALUES ('New Tool', 'A new tool!', CURRENT_DATE, 5.67);
    SELECT t.id INTO toolId FROM BSA_TOOL t WHERE t.name = 'New Tool' and t.datepurchased = CURRENT_DATE;
    -- Insert the tool mapping (via a view for ease of use within the application)
    INSERT INTO bsa_view_project_tool (tool_id, name, ToolDescription, datepurchased, totalcost, project_id)
    VALUES (toolId, NULL, NULL, NULL, NULL, projectId);
    -- Create a fixed supply then add the mapping
    INSERT INTO bsa_fixed_quantity_supply(name, description, datepurchased, unitspurchased, totalcost)
    VALUES ('Bubble Wrap', '', CURRENT_DATE, 165, 23.45);
    SELECT fqs.id INTO fixedSupplyId FROM bsa_fixed_quantity_supply fqs WHERE name = 'Bubble Wrap';
    INSERT INTO bsa_view_project_fixed_supply (supply_id, name, description, datepurchased, unitspurchased, totalcost, quantity, project_id)
    VALUES (fixedSupplyId, null, null, null, null, null, null, projectId);
    -- Create a non-fixed supply then add the mapping
    INSERT INTO bsa_non_fixed_quantity_supply(name, description, datepurchased, cost)
    VALUES ('EvapoRust', '', CURRENT_DATE, 15.67);
    SELECT nfqs.id INTO nonFixedSupplyId FROM bsa_non_fixed_quantity_supply nfqs WHERE name = 'EvapoRust';
    INSERT INTO bsa_view_project_non_fixed_supply(supply_id, name, description, datepurchased, cost, quantity, project_id)
    VALUES (nonFixedSupplyId, null, null, null, null, null, projectId);
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
        union all select 'Salvation Army' from dual;
END;
/