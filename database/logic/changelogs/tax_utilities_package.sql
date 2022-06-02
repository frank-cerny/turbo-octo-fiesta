--liquibase formatted sql

--changeset fcerny:1 runOnChange:true endDelimiter:"/"
create or replace package tax_utilities
as 
    function bsa_func_calculate_yearly_federal_tax_string(projectId IN int, isEstimated IN int)
    return varchar2;
    function bsa_func_calculate_total_federal_tax(projectId IN int, isEstimated IN int)
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
    function bsa_func_calculate_yearly_federal_tax_string (projectId IN int, isEstimated IN int)
    RETURN varchar2
    AS
    BEGIN
        -- See below, except we should return a string for each year that can be added to a project page
        return '1';
    END;

    -- If isEstimated = 1, then use estimated income value from db, instead of actual
    function bsa_func_calculate_total_federal_tax (projectId IN int, isEstimated IN int)
    RETURN number
    AS
    BEGIN
        -- For each year, get all income from project
        -- Get all income from all projects
        -- Get income from income table (outside base income)
        -- Get tax for base income
        -- Get tax for added income
        -- Divide tax by ratio of project income vs all projects
        -- Add to sum then iterate (return aggregate sum)
        return 1;
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
    BEGIN
        return 1;
    END;
end tax_utilities;
/
