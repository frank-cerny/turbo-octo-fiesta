
  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "FRANKCERNY"."FCERNY_ADD_PET" 
as
    procedure addRow(val number) is
    begin
        INSERT
        INTO pets (id, pets)
        VALUES (1, 500);
    end;
end fcerny_add_pet;
