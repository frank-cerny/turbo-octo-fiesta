
  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "DEV_WS"."TAX_UTILITIES" 
as
    -- Validates that the proper prerequsitite data exists in the database to perform the calculation
    -- Returns:
    --  0 = false
    --  1 = true
    function bsa_func_validate_income_params (yearToCheck IN varchar2)
    RETURN number
    AS
        income number (10,2);
    BEGIN
        SELECT ti.income INTO income from bsa_tax_income ti WHERE year = yearToCheck;
        if (income is NULL) THEN
            return 0;
        end if;
        return 1;
        EXCEPTION
        WHEN no_data_found THEN
            return 0;
    END;

    -- See below, except we should return a string for each year that can be added to a project page
    function bsa_func_calculate_yearly_federal_tax_string (projectId IN int)
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
        SELECT count(id) INTO numberOfRevenueItems from bsa_revenue_item WHERE project_id = projectId and EXTRACT(YEAR FROM dateSold) = '2021' and ispending = 'N' and platformsoldon = 'Ebay';
        if numberOfRevenueItems > 0 THEN
            if (bsa_func_validate_income_params('2021') = 1) THEN
                taxDueOnProject := bsa_func_calculate_federal_tax_helper_2021(projectId);
                taxString := ('2021 Tax = $' || taxDueOnProject);
            else
                taxString := '2021 Tax = N/A';
            end if;
        end if;
        -- 2022
        SELECT count(id) INTO numberOfRevenueItems from bsa_revenue_item WHERE project_id = projectId and EXTRACT(YEAR FROM dateSold) = '2022' and ispending = 'N' and platformsoldon = 'Ebay';
        if numberOfRevenueItems > 0 THEN
            if (bsa_func_validate_income_params('2022') = 1) THEN
                taxDueOnProject := bsa_func_calculate_federal_tax_helper_2022(projectId);
                taxString := (taxString || '; 2022 Tax = $' || taxDueOnProject);
            else
                taxString := (taxString || '; 2022 Tax = N/A');
            end if;
        end if;
        return taxString;
    END;

    -- If isEstimated = 1, then use estimated income value from db, instead of actual
    function bsa_func_calculate_total_federal_tax (projectId IN int)
    RETURN number
    AS
        numberOfRevenueItems int;
        taxDueOnProject number(10,2);
    BEGIN
        numberOfRevenueItems := 0;
        taxDueOnProject := 0;
        -- For each year, call a helper function to make updating this easier in the future :)
        -- 2021
        SELECT count(id) INTO numberOfRevenueItems from bsa_revenue_item WHERE project_id = projectId and EXTRACT(YEAR FROM dateSold) = '2021' and ispending = 'N' and platformsoldon = 'Ebay';
        if numberOfRevenueItems > 0 THEN
            -- Ensure the income table has the correct values for the computation
            if (bsa_func_validate_income_params('2021') = 1) THEN
                taxDueOnProject := taxDueOnProject + bsa_func_calculate_federal_tax_helper_2021(projectId);
            end if;
        end if;
        -- 2022
        SELECT count(id) INTO numberOfRevenueItems from bsa_revenue_item WHERE project_id = projectId and EXTRACT(YEAR FROM dateSold) = '2022' and ispending = 'N' and platformsoldon = 'Ebay';
        if numberOfRevenueItems > 0 THEN
            if (bsa_func_validate_income_params('2022') = 1) THEN
                taxDueOnProject := taxDueOnProject + bsa_func_calculate_federal_tax_helper_2022(projectId);
            end if;
        end if;
        return taxDueOnProject;
    END;

    -- Number of revenue items for 2021 must be greater than 0, otherwise the behavior of this function is undefined
    function bsa_func_calculate_federal_tax_helper_2021 (projectId IN int)
    RETURN number
    AS
        totalProjectRevenue number(10,2);
        projectRevenue number(10,2);
        income number(10,2);
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
        SELECT sum(salePrice) INTO totalProjectRevenue from bsa_revenue_item where (SELECT EXTRACT(YEAR FROM dateSold) FROM DUAL) = yearToCompute and ispending = 'N' and platformsoldon = 'Ebay';
        -- Get income from single project
        SELECT sum(salePrice) INTO projectRevenue from bsa_revenue_item where (SELECT EXTRACT(YEAR FROM dateSold) FROM DUAL) = yearToCompute and project_id = projectId and ispending = 'N' and platformsoldon = 'Ebay';
        -- Get income from income table (outside base income)
        SELECT ti.income INTO income from bsa_tax_income ti WHERE year = yearToCompute;
        -- Get tax for base income (use isEstimated to determine if we should use estimate or actual income)
        taxFromIncome := bsa_func_calculate_federal_income_tax_2021(income);
        -- Get tax from income with revenue added on
        taxFromIncomeWithRevenue := bsa_func_calculate_federal_income_tax_2021(income + totalProjectRevenue);
        -- Divide tax by ratio of project income vs all projects
        revenueRatio := projectRevenue / totalProjectRevenue;
        taxDueOnProject := taxDueOnProject + (revenueRatio * (taxFromIncomeWithRevenue - taxFromIncome));
        -- Add to sum then iterate (return aggregate sum)
        return taxDueOnProject;
    END;

    -- Number of revenue items for 2022 must be greater than 0, otherwise the behavior of this function is undefined
    function bsa_func_calculate_federal_tax_helper_2022 (projectId IN int)
    RETURN number
    AS
        totalProjectRevenue number(10,2);
        projectRevenue number(10,2);
        income number(10,2);
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
        SELECT sum(salePrice) INTO totalProjectRevenue from bsa_revenue_item where (SELECT EXTRACT(YEAR FROM dateSold) FROM DUAL) = yearToCompute and ispending = 'N' and platformsoldon = 'Ebay';
        -- Get income from single project
        SELECT sum(salePrice) INTO projectRevenue from bsa_revenue_item where (SELECT EXTRACT(YEAR FROM dateSold) FROM DUAL) = yearToCompute and project_id = projectId and ispending = 'N' and platformsoldon = 'Ebay';
        -- Get income from income table (outside base income)
        SELECT ti.income INTO income from bsa_tax_income ti WHERE year = yearToCompute;
        -- Get tax for base income 
        taxFromIncome := bsa_func_calculate_federal_income_tax_2022(income);
        -- Get tax from income with revenue added on
        taxFromIncomeWithRevenue := bsa_func_calculate_federal_income_tax_2022(income + totalProjectRevenue);
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
