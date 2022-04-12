--liquibase formatted sql

--changeset fcerny:1
-- We renamed the test_trigger package to test_tool_triggers, so we need to drop it
DROP PACKAGE test_triggers;