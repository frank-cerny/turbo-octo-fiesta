
  ALTER TABLE "FCERNY"."BSA_SINGLE_USE_SUPPLY" ADD CONSTRAINT "BSA_SINGLE_USE_SUPPLY_REVENUE_ITEM_FK" FOREIGN KEY ("REVENUEITEM_ID")
	  REFERENCES "FCERNY"."BSA_REVENUE_ITEM" ("ID") ON DELETE SET NULL ENABLE;