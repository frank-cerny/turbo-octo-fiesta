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

## Deployment Process (to "Production")

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

SYS/ADMIN: ?  
APEX_PUBLIC_USER: ?  
ut3:x123456x890!!**&&!!  

### APEX Credentials

Instance Admin: INTERNAL:ADMIN:Passw0rd!  
Workspace User: DEV_WS:DEV:Passw0rd! (Default Schema is DEV_WS)
