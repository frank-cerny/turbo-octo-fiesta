--liquibase formatted sql

-- I added runOnChange = true for this changeset only as I modified it after going to production which caused production deployment issues
--changeset fcerny:1 endDelimiter:"/" runOnChange:true
-- We renamed the test_trigger package to test_tool_triggers, so we need to drop it
-- Reference: https://stackoverflow.com/questions/34151428/drop-trigger-only-if-it-exists-oracle
declare 
  l_count integer;
begin
    SELECT count(*) INTO l_count FROM USER_PROCEDURES 
    WHERE OBJECT_TYPE='PACKAGE' and OBJECT_NAME='TEST_TRIGGERS';

    if l_count > 0 then 
        execute immediate 'drop package test_triggers';
    end if;
end;
/