  CREATE UNIQUE INDEX "DEV_WS"."BSA_BIKE_UK" ON "DEV_WS"."BSA_BIKE" ("MAKE","MODEL","YEAR","SERIALNUMBER")
  PCTFREE 10 INITRANS 2 MAXTRANS 255 LOGGING
  TABLESPACE "USERS";
