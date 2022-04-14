--liquibase formatted sql

--changeset fcerny:1
-- Reference: https://stackoverflow.com/questions/10321775/changing-the-data-type-of-a-column-in-oracle
-- We need to add a column with the new data type, copy data from old column, then rename (we can't rename a column with data in it)
ALTER TABLE bsa_bike
ADD (serialnumber1 varchar2(40 char));

--changeset fcerny:2
-- Copy data from old column
UPDATE bsa_bike
SET serialnumber1 = serialnumber;

--changeset fcerny:3
-- Drop constraints (added back later)
alter table bsa_bike
DROP constraint bsa_bike_uk;

--changeset fcerny:4
-- Drop old column (be careful of constraints)
ALTER TABLE bsa_bike
DROP (serialnumber);

--changeset fcerny:5
ALTER TABLE bsa_bike
RENAME COLUMN serialnumber1 TO serialnumber;

--changeset fcerny:6
-- Add constraint back
alter table bsa_bike 
add constraint bsa_bike_uk unique (make, model, year, serialnumber);