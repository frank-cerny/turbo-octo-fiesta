--liquibase formatted sql

--changeset fcerny:1 runOnChange:true endDelimiter:"/"
create or replace package tax_utilities
as 
    function bsa_func_calculate_yearly_federal_tax_string(projectId IN int)
    return varchar2;
    function bsa_func_calculate_total_federal_tax(projectId IN int)
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
    function bsa_func_calculate_yearly_federal_tax_string (projectId IN int)
    RETURN varchar2
    AS
    BEGIN
        -- See below, except we should return a string for each year that can be added to a project page
        return '1';
    END;

    function bsa_func_calculate_total_federal_tax (projectId IN int)
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
    function bsa_func_calculate_federal_income_tax_2021 (income IN number)
    RETURN number
    AS
    BEGIN
        return 1;
    END;

    function bsa_func_calculate_federal_income_tax_2022 (income IN number)
    RETURN number
    AS
    BEGIN
        return 1;
    END;
end tax_utilities;
/
