-- References
-- https://github.com/oraclebase/liquibase_apex_demo
-- https://oracle-base.com/articles/misc/liquibase-deploying-oracle-application-express-apex-applications

-- Create the workspace

-- Create a user assigned to the worksapce
CREATE USER dev_ws IDENTIFIED BY dev_ws QUOTA UNLIMITED ON users;
GRANT CREATE SESSION, CREATE CLUSTER, CREATE DIMENSION, CREATE INDEXTYPE,
      CREATE JOB, CREATE MATERIALIZED VIEW, CREATE OPERATOR, CREATE PROCEDURE,
      CREATE SEQUENCE, CREATE SYNONYM, CREATE TABLE,
      CREATE TRIGGER, CREATE TYPE, CREATE VIEW TO dev_ws;