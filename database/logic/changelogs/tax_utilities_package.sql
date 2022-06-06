--liquibase formatted sql

--changeset fcerny:1 runOnChange:true endDelimiter:"/"
create or replace package tax_utilities
as 
    function bsa_func_calculate_yearly_federal_tax_string(projectId IN int, isEstimated IN int)
    return varchar2;
    function bsa_func_calculate_total_federal_tax(projectId IN int, isEstimated IN int)
    return number;
    function bsa_func_calculate_federal_tax_helper_2021(projectId IN int, isEstimated IN int)
    return number;
    function bsa_func_calculate_federal_tax_helper_2022(projectId IN int, isEstimated IN int)
    return number;
    function bsa_func_calculate_federal_income_tax_2021(income IN number)
    return number;
    function bsa_func_calculate_federal_income_tax_2022(income IN number)
    return number;
end tax_utilities;
/

--changeset fcerny:2 runOnChange:true endDelimiter:"/"
-- Functionality package 
create or replace package body tax_utilities
as
    -- If isEstimated = 1, then use estimated income value from db, instead of actual
    -- See below, except we should return a string for each year that can be added to a project page
    function bsa_func_calculate_yearly_federal_tax_string (projectId IN int, isEstimated IN int)
    RETURN varchar2
    AS
        numberOfRevenueItems int;
        taxDueOnProject number(10,2);
        taxString varchar2(150);
    BEGIN
        numberOfRevenueItems := 0;
        taxDueOnProject := 0;
        -- For each year, call a helper function to make updating this easier in the future :)
        -- 2021
        SELECT count(id) INTO numberOfRevenueItems from bsa_revenue_item WHERE project_id = projectId and EXTRACT(YEAR FROM dateSold) = '2021';
        if numberOfRevenueItems > 0 THEN
            taxDueOnProject := taxDueOnProject + bsa_func_calculate_federal_tax_helper_2021(projectId, isEstimated);
            taxString := ('2021 Tax = $' || taxDueOnProject);
        end if;
        -- 2022
        SELECT count(id) INTO numberOfRevenueItems from bsa_revenue_item WHERE project_id = projectId and EXTRACT(YEAR FROM dateSold) = '2022';
        if numberOfRevenueItems > 0 THEN
            taxDueOnProject := taxDueOnProject + bsa_func_calculate_federal_tax_helper_2022(projectId, isEstimated);
            taxString := (taxString || '; 2022 Tax = $' || taxDueOnProject);
        end if;
        return taxString;
    END;

    -- If isEstimated = 1, then use estimated income value from db, instead of actual
    function bsa_func_calculate_total_federal_tax (projectId IN int, isEstimated IN int)
    RETURN number
    AS
        numberOfRevenueItems int;
        taxDueOnProject number(10,2);
        actualIncome number(10,2);
        estimatedIncome number(10,2);
    BEGIN
        numberOfRevenueItems := 0;
        taxDueOnProject := 0;
        -- For each year, call a helper function to make updating this easier in the future :)
        -- 2021
        SELECT count(id) INTO numberOfRevenueItems from bsa_revenue_item WHERE project_id = projectId and EXTRACT(YEAR FROM dateSold) = '2021';
        if numberOfRevenueItems > 0 THEN
            -- Ensure the income table has the correct values for the computation
            SELECT ti.actualIncome, ti.estimatedIncome INTO actualIncome, estimatedIncome from bsa_tax_income ti WHERE year = '2021';
            if (isEstimated = 1 and estimatedIncome != NULL and estimatedIncome > 0) or (isEstimated = 0 and actualIncome != NULL and actualIncome > 0) THEN
                taxDueOnProject := taxDueOnProject + bsa_func_calculate_federal_tax_helper_2021(projectId, isEstimated);
            end if;
        end if;
        -- 2022
        SELECT count(id) INTO numberOfRevenueItems from bsa_revenue_item WHERE project_id = projectId and EXTRACT(YEAR FROM dateSold) = '2022';
        if numberOfRevenueItems > 0 THEN
            SELECT ti.actualIncome, ti.estimatedIncome INTO actualIncome, estimatedIncome from bsa_tax_income ti WHERE year = '2022';
            if (isEstimated = 1 and estimatedIncome != NULL and estimatedIncome > 0) or (isEstimated = 0 and actualIncome != NULL and actualIncome > 0) THEN
                taxDueOnProject := taxDueOnProject + bsa_func_calculate_federal_tax_helper_2022(projectId, isEstimated);
            end if;
        end if;
        return taxDueOnProject;
    END;

    -- Number of revenue items for 2021 must be greater than 0, otherwise the behavior of this function is undefined
    function bsa_func_calculate_federal_tax_helper_2021 (projectId IN int, isEstimated IN int)
    RETURN number
    AS
        totalProjectRevenue number(10,2);
        projectRevenue number(10,2);
        estimatedIncome number(10,2);
        actualIncome number(10,2);
        taxFromIncome number(10,2);
        taxFromIncomeWithRevenue number(10,2);
        taxDueOnProject number(10,2);
        revenueRatio number(10,8);
        yearToCompute varchar2(4);
    BEGIN
        yearToCompute := '2021';
        taxDueOnProject := 0;
        -- For each year, get all income from project
        -- Get all income from all projects
        SELECT sum(salePrice) INTO totalProjectRevenue from bsa_revenue_item where (SELECT EXTRACT(YEAR FROM dateSold) FROM DUAL) = yearToCompute;
        -- Get income from single project
        SELECT sum(salePrice) INTO projectRevenue from bsa_revenue_item where (SELECT EXTRACT(YEAR FROM dateSold) FROM DUAL) = yearToCompute and project_id = projectId;
        -- Get income from income table (outside base income)
        SELECT ti.actualIncome, ti.estimatedIncome INTO actualIncome, estimatedIncome from bsa_tax_income ti WHERE year = yearToCompute;
        -- Get tax for base income (use isEstimated to determine if we should use estimate or actual income)
        if isEstimated = 1 then
            -- Estimated
            taxFromIncome := bsa_func_calculate_federal_income_tax_2021(estimatedIncome);
            -- Get tax from income with revenue added on
            taxFromIncomeWithRevenue := bsa_func_calculate_federal_income_tax_2021(estimatedIncome + totalProjectRevenue);
        else
            taxFromIncome := bsa_func_calculate_federal_income_tax_2021(actualIncome);
            taxFromIncomeWithRevenue := bsa_func_calculate_federal_income_tax_2021(actualIncome + totalProjectRevenue);
        end if;
        -- Divide tax by ratio of project income vs all projects
        revenueRatio := projectRevenue / totalProjectRevenue;
        taxDueOnProject := taxDueOnProject + (revenueRatio * (taxFromIncomeWithRevenue - taxFromIncome));
        -- Add to sum then iterate (return aggregate sum)
        return taxDueOnProject;
    END;

    -- Number of revenue items for 2022 must be greater than 0, otherwise the behavior of this function is undefined
    function bsa_func_calculate_federal_tax_helper_2022 (projectId IN int, isEstimated IN int)
    RETURN number
    AS
        totalProjectRevenue number(10,2);
        projectRevenue number(10,2);
        estimatedIncome number(10,2);
        actualIncome number(10,2);
        taxFromIncome number(10,2);
        taxFromIncomeWithRevenue number(10,2);
        taxDueOnProject number(10,2);
        revenueRatio number(10,8);
        yearToCompute varchar2(4);
    BEGIN
        yearToCompute := '2022';
        taxDueOnProject := 0;
        -- For each year, get all income from project
        -- Get all income from all projects
        SELECT sum(salePrice) INTO totalProjectRevenue from bsa_revenue_item where (SELECT EXTRACT(YEAR FROM dateSold) FROM DUAL) = yearToCompute;
        -- Get income from single project
        SELECT sum(salePrice) INTO projectRevenue from bsa_revenue_item where (SELECT EXTRACT(YEAR FROM dateSold) FROM DUAL) = yearToCompute and project_id = projectId;
        -- Get income from income table (outside base income)
        SELECT ti.actualIncome, ti.estimatedIncome INTO actualIncome, estimatedIncome from bsa_tax_income ti WHERE year = yearToCompute;
        -- Get tax for base income (use isEstimated to determine if we should use estimate or actual income)
        if isEstimated = 1 then
            -- Estimated
            taxFromIncome := bsa_func_calculate_federal_income_tax_2022(estimatedIncome);
            -- Get tax from income with revenue added on
            taxFromIncomeWithRevenue := bsa_func_calculate_federal_income_tax_2022(estimatedIncome + totalProjectRevenue);
        else
            taxFromIncome := bsa_func_calculate_federal_income_tax_2022(actualIncome);
            taxFromIncomeWithRevenue := bsa_func_calculate_federal_income_tax_2022(actualIncome + totalProjectRevenue);
        end if;
        -- Divide tax by ratio of project income vs all projects
        revenueRatio := projectRevenue / totalProjectRevenue;
        taxDueOnProject := taxDueOnProject + (revenueRatio * (taxFromIncomeWithRevenue - taxFromIncome));
        -- Add to sum then iterate (return aggregate sum)
        return taxDueOnProject;
    END;

    -- Each year will get a function based on the year's tax bracket
    -- Note that income is expected to be "after any and all deductions"
    -- Note: 2021 was filed as a single filer
    function bsa_func_calculate_federal_income_tax_2021 (income IN number)
    RETURN number
    AS
        taxDue number(10, 2);
    BEGIN
        if income <= 0 THEN
            -- If income is 0 (or negative, we return 0)
            taxDue := 0;
        elsif income > 0 and income < 9950 THEN
            taxDue := .10 * income;
        elsif income > 9950 and income < 40525 THEN
            taxDue := ((income - 9950) * .12) + 995;
        elsif income > 40525 and income < 86375 THEN
            taxDue := ((income - 40525) * .22) + 4664;
        elsif income > 86376 and income < 164925 THEN
            taxDue := ((income - 86376) *.24) + 14751;
        elsif income > 164926 and income < 209425 THEN
            taxDue := ((income - 164925) * .32) + 33603;
        elsif income > 209426 and income < 523600 THEN
            taxDue := ((income - 209426) * .35) + 47843;
        else
            -- Anything over 523600
            taxDue := ((income - 523600) * .37) + 157804.25;
        end if;
        return taxDue; 
    END;

    -- Note: 2022 will be filed as married; jointly
    function bsa_func_calculate_federal_income_tax_2022 (income IN number)
    RETURN number
    AS
        taxDue number(10, 2);
    BEGIN
        if income <= 0 THEN
            -- If income is 0 (or negative, we return 0)
            taxDue := 0;
        elsif income > 0 and income < 20550 THEN
            taxDue := .10 * income;
        elsif income > 20550 and income < 83550 THEN
            taxDue := ((income - 20550) * .12) + 2055;
        elsif income > 83550 and income < 178150 THEN
            taxDue := ((income - 83550) * .22) + 9615;
        elsif income > 178150 and income < 340100 THEN
            taxDue := ((income - 178150) *.24) + 30427;
        elsif income > 340100 and income < 431900 THEN
            taxDue := ((income - 340100) * .32) + 69295;
        elsif income > 431900 and income < 647851 THEN
            taxDue := ((income - 431900) * .35) + 98671;
        else
            -- Anything over 523600
            taxDue := ((income - 647851) * .37) + 174253.50;
        end if;
        return taxDue; 
    END;
end tax_utilities;
/
