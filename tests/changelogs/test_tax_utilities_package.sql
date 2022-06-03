--liquibase formatted sql

--changeset fcerny:1 runOnChange:true endDelimiter:"/" stripComments:false
create or replace package test_tax_utilities_package
as
    -- %suite(Test Tax Utility Package)
    
    -- %test(Test 2021 Tax Calculations)
    procedure test_tax_calculation_2021;
    -- %test(Test 2022 Tax Calculations)
    procedure test_tax_calculation_2022;
    -- %test(Test Tax Calculations Empty Project)
    procedure test_aggregate_tax_caclulation_empty_project;
    -- %test(Test Tax Calculations Single Year Single Project)
    -- procedure test_aggregate_tax_calculation_single_year_single_project;
    -- %test(Test Tax Calculations Multi Year Single Project)
    -- procedure test_aggregate_tax_calculation_multi_year_single_project;
    -- %test(Test Tax Calculations Single Year Multi Projects)
    procedure test_aggregate_tax_calculation_single_year_multi_project;
    -- %test(Test Tax Calculations Multi Year Multi Projects)
    -- procedure test_aggregate_tax_calculation_multi_year_multi_project;
    -- TODO (Add string calculation tests as well!)
end test_tax_utilities_package;
/

--changeset fcerny:2 runOnChange:true endDelimiter:"/" stripComments:false
create or replace package body test_tax_utilities_package
as
    -- Note that this was validated with my excel budget sheet with tax calculations built in (within +- $3 which is fine)
    -- But all calculations are based directly on Nerd Wallets Brackets/Calculations: https://www.nerdwallet.com/article/taxes/federal-income-tax-brackets
    -- The excel document does more "intense" calculation for an exact value. Being off a few dollars is fine for our case
    procedure test_tax_calculation_2021 is
        taxDue number(10, 2);
    begin
        -- Test each part of the tax bracket to ensure math holds, computations are straight forward inside the function
        -- hence we can use a single test instead of breaking it out
        -- 10% bracket
        taxDue := taxu.bsa_func_calculate_federal_income_tax_2021(500);
        ut.expect(taxDue).to_( equal(50) );
        -- 12% bracket
        taxDue := taxu.bsa_func_calculate_federal_income_tax_2021(32405);
        ut.expect(taxDue).to_( equal(3689.60) );
        -- 22% bracket
        taxDue := taxu.bsa_func_calculate_federal_income_tax_2021(67800);
        ut.expect(taxDue).to_( equal(10664.50) );
        -- 24% bracket 
        taxDue := taxu.bsa_func_calculate_federal_income_tax_2021(90500);
        ut.expect(taxDue).to_( equal(15740.76) );
        -- 32% bracket
        taxDue := taxu.bsa_func_calculate_federal_income_tax_2021(175900);
        ut.expect(taxDue).to_( equal(37115) );
        -- 35% bracket
        taxDue := taxu.bsa_func_calculate_federal_income_tax_2021(350600);
        ut.expect(taxDue).to_( equal(97253.90) );
        -- 37% bracket
        taxDue := taxu.bsa_func_calculate_federal_income_tax_2021(750000);
        ut.expect(taxDue).to_( equal(241572.25) );
    end;

    procedure test_tax_calculation_2022 is
        taxDue number(10, 2);
    begin
        -- Test each part of the tax bracket to ensure math holds, computations are straight forward inside the function
        -- hence we can use a single test instead of breaking it out
        -- 10% bracket
        taxDue := taxu.bsa_func_calculate_federal_income_tax_2022(500);
        ut.expect(taxDue).to_( equal(50) );
        -- 12% bracket
        taxDue := taxu.bsa_func_calculate_federal_income_tax_2022(32405);
        ut.expect(taxDue).to_( equal(3477.60) );
        -- 22% bracket
        taxDue := taxu.bsa_func_calculate_federal_income_tax_2022(99600);
        ut.expect(taxDue).to_( equal(13146) );
        -- 24% bracket 
        taxDue := taxu.bsa_func_calculate_federal_income_tax_2022(250000);
        ut.expect(taxDue).to_( equal(47671) );
        -- 32% bracket
        taxDue := taxu.bsa_func_calculate_federal_income_tax_2022(400000);
        ut.expect(taxDue).to_( equal(88463) );
        -- 35% bracket
        taxDue := taxu.bsa_func_calculate_federal_income_tax_2022(567000);
        ut.expect(taxDue).to_( equal(145956) );
        -- 37% bracket
        taxDue := taxu.bsa_func_calculate_federal_income_tax_2022(750000);
        ut.expect(taxDue).to_( equal(212048.63) );
    end;

    procedure test_aggregate_tax_caclulation_empty_project is
        taxDue number(10, 2);
        projectId int;
    begin
        -- Create a project
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Project 11111', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId FROM dev_ws.bsa_project p where p.title = 'Project 11111';

        -- Add estimated/actual tax values for 2022 (all revenue items will be in 2022)
        INSERT INTO dev_ws.bsa_tax_income (year, estimatedIncome, actualIncome)
        VALUES ('2022', 50000, 67500);

        -- Act
        taxDue := taxu.bsa_func_calculate_total_federal_tax(projectId, 0);
        -- Assert
        ut.expect(taxDue).to_( equal(0) );
    end;

    -- TODO SINGLE PROJECT SINGLE YEAR

    procedure test_aggregate_tax_calculation_single_year_multi_project is
        taxDue number(10, 2);
        taxString varchar2(150);
        projectId1 int;
        projectId2 int;
        projectId3 int;
    begin
        -- Create 3 projects
        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Project 11111', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId1 FROM dev_ws.bsa_project p where p.title = 'Project 11111';

        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Project 22222', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId2 FROM dev_ws.bsa_project p where p.title = 'Project 22222';

        INSERT INTO dev_ws.bsa_project (description, title, datestarted, dateended)
        VALUES ('A very simple testing project!', 'Project 33333', CURRENT_DATE, NULL);
        SELECT p.id INTO projectId3 FROM dev_ws.bsa_project p where p.title = 'Project 33333';

        -- Add estimated/actual tax values for 2022 (all revenue items will be in 2022)
        INSERT INTO dev_ws.bsa_tax_income (year, estimatedIncome, actualIncome)
        VALUES ('2022', 50000, 67500);

        -- Then add two revenue items to each project 
        INSERT INTO dev_ws.bsa_revenue_item (project_id, name, description, saleprice, platformsoldon, ispending, datesold)
        VALUES (projectId1, 'temp 11111', 'description', 10, 'Ebay', 'N', Date '2022-05-20');
        INSERT INTO dev_ws.bsa_revenue_item (project_id, name, description, saleprice, platformsoldon, ispending, datesold)
        VALUES (projectId1, 'temp 22222', 'description', 20, 'Ebay', 'N', Date '2022-04-20');
        -- Project 2
        INSERT INTO dev_ws.bsa_revenue_item (project_id, name, description, saleprice, platformsoldon, ispending, datesold)
        VALUES (projectId2, 'temp 33333', 'description', 30.50, 'Ebay', 'N', Date '2022-03-20');
        INSERT INTO dev_ws.bsa_revenue_item (project_id, name, description, saleprice, platformsoldon, ispending, datesold)
        VALUES (projectId2, 'temp 44444', 'description', 40.50, 'Ebay', 'N', Date '2022-02-20');
        -- Project 3
        INSERT INTO dev_ws.bsa_revenue_item (project_id, name, description, saleprice, platformsoldon, ispending, datesold)
        VALUES (projectId3, 'temp 55555', 'description', 35, 'Ebay', 'N', Date '2022-01-20');
        INSERT INTO dev_ws.bsa_revenue_item (project_id, name, description, saleprice, platformsoldon, ispending, datesold)
        VALUES (projectId3, 'temp 66666', 'description', 160, 'Ebay', 'N', Date '2022-01-15');

        -- Act & Assert (All for project 1)

        -- Example:
        -- Total Project Revenue = 296
        -- Total Project 1 Revenue = 30
        -- Total Outside Income = 67500
        -- Total Outside Income Tax = 7689
        -- Total Combined Tax = 7724.52
        -- Tax for all projects = 35.52
        -- Project 1 tax = (30/296) * 35.52 = 3.60

        -- First check the estimated value (the values are the same here because the tax brackets are the same)
        taxDue := taxu.bsa_func_calculate_total_federal_tax(projectId1, 1);
        ut.expect(taxDue).to_( equal(3.60) );
        -- Then check the actual
        taxDue := taxu.bsa_func_calculate_total_federal_tax(projectId1, 0);
        ut.expect(taxDue).to_( equal(3.60) );
        -- Then check the estimated string
        taxString := taxu.bsa_func_calculate_yearly_federal_tax_string(projectId1, 1);
        ut.expect(taxString).to_( equal('2022 Tax = $3.60') );
        -- And finally check the actual string
        taxString := taxu.bsa_func_calculate_yearly_federal_tax_string(projectId1, 0);
        ut.expect(taxString).to_( equal('2022 Tax = $3.60') );
    end;
end test_tax_utilities_package;
/
