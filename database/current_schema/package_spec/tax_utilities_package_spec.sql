
  CREATE OR REPLACE EDITIONABLE PACKAGE "DEV_WS"."TAX_UTILITIES" 
as 
    function bsa_func_calculate_yearly_federal_tax_string(projectId IN int)
    return varchar2;
    function bsa_func_calculate_total_federal_tax(projectId IN int)
    return number;
    function bsa_func_validate_income_params(yearToCheck IN varchar2)
    return number;
    function bsa_func_calculate_federal_tax_helper_2021(projectId IN int)
    return number;
    function bsa_func_calculate_federal_tax_helper_2022(projectId IN int)
    return number;
    function bsa_func_calculate_federal_income_tax_2021(income IN number)
    return number;
    function bsa_func_calculate_federal_income_tax_2022(income IN number)
    return number;
end tax_utilities;
