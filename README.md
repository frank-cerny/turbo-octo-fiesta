## Tools

- SQLcl with Liquibase
- Oracle Database XE
- Oracle APEX
- UTPLSQL

## Project Structure

- ansible: contains all ansible related files for setting up infrastructure (for now only development servers)
- app: contains deploy and src
    - deploy: contains full exports of the application, used to import into other workspaces (ie. for deployments)
    - src: contains split exports (with stripped changeset ids) used for source control purposes (easier to see what changed than in a full deployment)
- database: contains current_schema, logic, and schema_updates
    - current_schema: contains split exports of the entire schema (with stripped changeset ids) used for source control purposes
    - logic: contains changelogs/scripts for logical pieces of database functionality (functions, stored procedures, etc.) all changelogs are runOnChange=true
    - schema_updates: contains changelogs/scripts for non-logical pieces of database functionality (tables, constraints, etc.) 
- etc: contains various helper scripts 
- tests: contains changelogs and scripts which are UTPLSQL unit tests

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

## References

[Using Liquibase with Oracle APEX](https://oracle-base.com/articles/misc/liquibase-deploying-oracle-application-express-apex-applications)
[Creating SQL Changesets](https://docs.liquibase.com/concepts/changelogs/sql-format.html)
[Liquibase Best Practices](https://docs.liquibase.com/concepts/bestpractices.html)
[Running PLSQL with Liquibase 1](https://stackoverflow.com/questions/47156510/liquibase-migration-with-oracle-pl-sql-function-gets-pls-00103)