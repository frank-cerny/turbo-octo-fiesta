
  ALTER TABLE "FRANKCERNY"."BSA_REVENUE_ITEM" ADD CONSTRAINT "REVENUE_ITEM_PROJECT_ID_FK" FOREIGN KEY ("PROJECT_ID")
	  REFERENCES "FRANKCERNY"."BSA_PROJECT" ("ID") ON DELETE CASCADE ENABLE