  CREATE TABLE "FRANKCERNY"."BSA_FIXED_QUANTITY_SUPPLY"
   (	"ID" NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY
 MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER NOCYCLE NOKEEP NOSCALE NOT NULL ENABLE,
	"NAME" VARCHAR2(255 CHAR),
	"DESCRIPTION" VARCHAR2(4000 CHAR),
	"DATEPURCHASED" DATE,
	"UNITSPURCHASED" NUMBER(*,0) DEFAULT 0,
	"TOTALCOST" NUMBER NOT NULL ENABLE,
	CONSTRAINT "BSA_FIXED_QUANTITY_SUPPLY_ID_PK" PRIMARY KEY ("ID")
  USING INDEX
  PCTFREE 10 INITRANS 2 MAXTRANS 255 LOGGING
  TABLESPACE "APEX_1900686847875038"  ENABLE,
	CONSTRAINT "BSA_FIXED_QUANTITY_SUPPLY" UNIQUE ("NAME","DATEPURCHASED")
  USING INDEX
  PCTFREE 10 INITRANS 2 MAXTRANS 255 LOGGING
  TABLESPACE "APEX_1900686847875038"  ENABLE
   ) SEGMENT CREATION DEFERRED
  PCTFREE 10 PCTUSED 40 INITRANS 1 NOCOMPRESS LOGGING
  TABLESPACE "APEX_1900686847875038";
