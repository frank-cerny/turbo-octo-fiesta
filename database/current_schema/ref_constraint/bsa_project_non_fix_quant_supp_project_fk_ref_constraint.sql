
  ALTER TABLE "FRANKCERNY"."BSA_PROJECT_NON_FIXED_QUANTITY_SUPPLY" ADD CONSTRAINT "BSA_PROJECT_NON_FIX_QUANT_SUPP_PROJECT_FK" FOREIGN KEY ("PROJECT_ID")
	  REFERENCES "FRANKCERNY"."BSA_PROJECT" ("ID") ON DELETE CASCADE ENABLE