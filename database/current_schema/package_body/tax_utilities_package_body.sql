
  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "DEV_WS"."TAX_UTILITIES" 
as
    
    
    
    
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

    
    function bsa_func_calculate_yearly_federal_tax_string (projectId IN int)
    RETURN varchar2
    AS
        numberOfRevenueItems int;
        taxDueOnProject number(10,2);
        taxString varchar2(150);
    BEGIN
        numberOfRevenueItems := 0;
        taxDueOnProject := 0;
        
        
        SELECT count(id) INTO numberOfRevenueItems from bsa_revenue_item WHERE project_id = projectId and EXTRACT(YEAR FROM dateSold) = '2021' and ispending = 'N' and platformsoldon = 'Ebay';
        if numberOfRevenueItems > 0 THEN
            if (bsa_func_validate_income_params('2021') = 1) THEN
                taxDueOnProject := bsa_func_calculate_federal_tax_helper_2021(projectId);
                taxString := ('2021 Tax = $' || taxDueOnProject);
            else
                taxString := '2021 Tax = N/A';
            end if;
        end if;
        
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

    
    function bsa_func_calculate_total_federal_tax (projectId IN int)
    RETURN number
    AS
        numberOfRevenueItems int;
        taxDueOnProject number(10,2);
    BEGIN
        numberOfRevenueItems := 0;
        taxDueOnProject := 0;
        
        
        SELECT count(id) INTO numberOfRevenueItems from bsa_revenue_item WHERE project_id = projectId and EXTRACT(YEAR FROM dateSold) = '2021' and ispending = 'N' and platformsoldon = 'Ebay';
        if numberOfRevenueItems > 0 THEN
            
            if (bsa_func_validate_income_params('2021') = 1) THEN
                taxDueOnProject := taxDueOnProject + bsa_func_calculate_federal_tax_helper_2021(projectId);
            end if;
        end if;
        
        SELECT count(id) INTO numberOfRevenueItems from bsa_revenue_item WHERE project_id = projectId and EXTRACT(YEAR FROM dateSold) = '2022' and ispending = 'N' and platformsoldon = 'Ebay';
        if numberOfRevenueItems > 0 THEN
            if (bsa_func_validate_income_params('2022') = 1) THEN
                taxDueOnProject := taxDueOnProject + bsa_func_calculate_federal_tax_helper_2022(projectId);
            end if;
        end if;
        return taxDueOnProject;
    END;

    
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
        
        
        SELECT sum(salePrice) INTO totalProjectRevenue from bsa_revenue_item where (SELECT EXTRACT(YEAR FROM dateSold) FROM DUAL) = yearToCompute and ispending = 'N' and platformsoldon = 'Ebay';
        
        SELECT sum(salePrice) INTO projectRevenue from bsa_revenue_item where (SELECT EXTRACT(YEAR FROM dateSold) FROM DUAL) = yearToCompute and project_id = projectId and ispending = 'N' and platformsoldon = 'Ebay';
        
        SELECT ti.income INTO income from bsa_tax_income ti WHERE year = yearToCompute;
        
        taxFromIncome := bsa_func_calculate_federal_income_tax_2021(income);
        
        taxFromIncomeWithRevenue := bsa_func_calculate_federal_income_tax_2021(income + totalProjectRevenue);
        
        revenueRatio := projectRevenue / totalProjectRevenue;
        taxDueOnProject := taxDueOnProject + (revenueRatio * (taxFromIncomeWithRevenue - taxFromIncome));
        
        return taxDueOnProject;
    END;

    
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
        
        
        SELECT sum(salePrice) INTO totalProjectRevenue from bsa_revenue_item where (SELECT EXTRACT(YEAR FROM dateSold) FROM DUAL) = yearToCompute and ispending = 'N' and platformsoldon = 'Ebay';
        
        SELECT sum(salePrice) INTO projectRevenue from bsa_revenue_item where (SELECT EXTRACT(YEAR FROM dateSold) FROM DUAL) = yearToCompute and project_id = projectId and ispending = 'N' and platformsoldon = 'Ebay';
        
        SELECT ti.income INTO income from bsa_tax_income ti WHERE year = yearToCompute;
        
        taxFromIncome := bsa_func_calculate_federal_income_tax_2022(income);
        
        taxFromIncomeWithRevenue := bsa_func_calculate_federal_income_tax_2022(income + totalProjectRevenue);
        
        revenueRatio := projectRevenue / totalProjectRevenue;
        taxDueOnProject := taxDueOnProject + (revenueRatio * (taxFromIncomeWithRevenue - taxFromIncome));
        
        return taxDueOnProject;
    END;

    
    
    
    function bsa_func_calculate_federal_income_tax_2021 (income IN number)
    RETURN number
    AS
        taxDue number(10, 2);
    BEGIN
        if income <= 0 THEN
            
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
            
            taxDue := ((income - 523600) * .37) + 157804.25;
        end if;
        return taxDue; 
    END;

    
    function bsa_func_calculate_federal_income_tax_2022 (income IN number)
    RETURN number
    AS
        taxDue number(10, 2);
    BEGIN
        if income <= 0 THEN
            
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
            
            taxDue := ((income - 647851) * .37) + 174253.50;
        end if;
        return taxDue; 
    END;
end tax_utilities;