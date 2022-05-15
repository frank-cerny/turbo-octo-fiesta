# Bike Selling Inventory Application

TBA

## Tools

- SQLcl with Liquibase
- Oracle Database XE
- Oracle APEX
- UTPLSQL

## Project Structure

TBA

## Development Process

### Infrastructure

1. Ansible removes APEX, Oracle Database XE, ORDS, and Tomcat from the development server 
2. Ansible installs APEX, Oracle Database XE, ORDS, and Tomcat on the development server
3. TBA

server:45001/XEPDB1

### Code

1. Developer makes UI changes inside the APEX instance
2. Developer makes SQL changes inside the APEX instance
3. Developer writes UTPLSQL tests for all SQL logic (adds to to the database as the ut3 user)
4. When "done" developer ensures all SQL changes are added to changesets and changelogs
5. Developer runs unit tests as ut3 via SQLcl
6. Developer exports apex application and schema 
    Note: Developer must use SQLcl as themselves or exports won't work (grants are important)
7. Developer creates a PR and merges

This means that Developers can still do "everything" within an APEX instance, but they **must** ensure all changes are added to changesets, otherwise their changes will not be carried over to other environments.

## Testing

1. Write updated tests within tests/changelogs
2. Run update-tests.sh (handles updating tests and permissions as neccessary)
3. Login to the DB as ut3
4. Run `set serveroutput on;`
5. Run neccessary tests with `exec ut.run('<ID>')`

## Deployment Process (to "Production")

Production is a public Oracle Cloud (OCI) hosted Autonomous Database instance running version 21c

Created inside that database are a workspace and schema called PROD_WS

TBA

## Useful Commands

- Export an APEX app: lb genobject -type apex -applicationid {id} -skipExportDate -expOriginalIds -expACLAssignments -split -dir {dir}
- Delete all XML files in the current_schema directory: rm -rf database/current_schema/**/*.xml
- Export the current schema with sql: lb genschema -sql -split

## References

[Using Liquibase with Oracle APEX](https://oracle-base.com/articles/misc/liquibase-deploying-oracle-application-express-apex-applications)
[Creating SQL Changesets](https://docs.liquibase.com/concepts/changelogs/sql-format.html)
[Liquibase Best Practices](https://docs.liquibase.com/concepts/bestpractices.html)
[Running PLSQL with Liquibase 1](https://stackoverflow.com/questions/47156510/liquibase-migration-with-oracle-pl-sql-function-gets-pls-00103)

## Default Credentials

### Database Credentials

SYS/ADMIN: Passw0rd1    
APEX_PUBLIC_USER: Passw0rd!    
ut3:x123456x890!!**&&!!  
dev_ws:dev_ws

### APEX Credentials

Instance Admin: INTERNAL:ADMIN:Passw0rd!  
Workspace User: DEV_WS:DEV:Passw0rd! (or Passw0rd!!) (Default Schema is DEV_WS)


### Troubleshooting

1. Connect as an admin to the test database (set TNS_ADMIN to dev wallet)
2. Run CREATE USER dev_ws IDENTIFIED BY "Passw0rd!00000" QUOTA UNLIMITED ON DATA;
3. Run GRANT CREATE SESSION, CREATE CLUSTER, CREATE DIMENSION, CREATE INDEXTYPE,
        CREATE JOB, CREATE MATERIALIZED VIEW, CREATE OPERATOR, CREATE PROCEDURE,
        CREATE SEQUENCE, CREATE SYNONYM, CREATE TABLE,
        CREATE TRIGGER, CREATE TYPE, CREATE VIEW TO dev_ws;
4. In another terminal prompt, open to the neccessary location as dev_ws
4. Test importing any files neccessary to triage the issue (use @ syntax to import directly)
5. Cleanup by running: DROP USER dev_ws CASCADE; (as an Admin)