
  ALTER TABLE "DEV_WS"."BSA_PROJECT_NON_FIXED_QUANTITY_SUPPLY" ADD CONSTRAINT "BSA_PROJECT_NON_FIX_QUANT_SUPP_SUP_FK" FOREIGN KEY ("SUPPLY_ID")
	  REFERENCES "DEV_WS"."BSA_NON_FIXED_QUANTITY_SUPPLY" ("ID") ON DELETE CASCADE ENABLE