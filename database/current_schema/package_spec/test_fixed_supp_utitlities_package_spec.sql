
  CREATE OR REPLACE EDITIONABLE PACKAGE "DEV_WS"."TEST_FIXED_SUPP_UTITLITIES" 
as
    

    
    procedure test_get_f_supp_remaining_0;
    
    procedure test_get_f_supp_remaining_not_0_single_project;
    
    procedure test_get_f_supp_remaining_not_0_multi_project;
    
    procedure test_get_f_supp_remaining_handle_negative;
end test_fixed_supp_utitlities;