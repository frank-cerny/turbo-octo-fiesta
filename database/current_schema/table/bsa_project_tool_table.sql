  CREATE TABLE "FRANKCERNY"."BSA_PROJECT_TOOL"
   (	"ID" NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY
 MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER NOCYCLE NOKEEP NOSCALE NOT NULL ENABLE,
	"PROJECT_ID" NUMBER,
	"TOOL_ID" NUMBER,
	"QUANTITY" NUMBER DEFAULT 0,
	CONSTRAINT "BSA_PROJECT_TOOL_ID_PK" PRIMARY KEY ("ID")
  USING INDEX
  PCTFREE 10 INITRANS 2 MAXTRANS 255 LOGGING
  TABLESPACE "APEX_1900686847875038"  ENABLE
   ) SEGMENT CREATION DEFERRED
  PCTFREE 10 PCTUSED 40 INITRANS 1 NOCOMPRESS LOGGING
  TABLESPACE "APEX_1900686847875038";