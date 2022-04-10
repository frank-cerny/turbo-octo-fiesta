#!groovy

pipeline {
    agent any

    stages {
        stage ('Test') {
            // when {
            //     // Only run this stage on PR (once tested of course!)
            // }
            environment {
                TNS_ADMIN = "/opt/wallet_dev"
                DEV_ADB_ADMIN_CREDS = credentials('bsa-dev-admin-creds')
                DEV_ADB_TEST_CREDS = credentials('bsa-dev-test-creds')
                DEV_ADB_USER_CREDS = credentials('bsa-dev-user-creds')
            }
            steps {
                echo "Creating DEV_WS Schema to Perform Unit Testing"
                script {
                    sh ''' 
                    cd "${WORKSPACE}"/ansible/database/setup/scripts
                    /opt/sqlcl/bin/sql /nolog <<EOF
                    connect $DEV_ADB_ADMIN_CREDS_USR/$DEV_ADB_ADMIN_CREDS_PSW@bsaapexdev_high
                    CREATE USER dev_ws IDENTIFIED BY "$DEV_ADB_USER_CREDS_PSW" QUOTA UNLIMITED ON DATA;
                    GRANT CREATE SESSION, CREATE CLUSTER, CREATE DIMENSION, CREATE INDEXTYPE,
                        CREATE JOB, CREATE MATERIALIZED VIEW, CREATE OPERATOR, CREATE PROCEDURE,
                        CREATE SEQUENCE, CREATE SYNONYM, CREATE TABLE,
                        CREATE TRIGGER, CREATE TYPE, CREATE VIEW TO dev_ws;
                    EOF
                    '''
                }
                echo "Importing Schema"
                script {
                    sh ''' 
                    cd "${WORKSPACE}"/database/schema_updates
                    /opt/sqlcl/bin/sql /nolog <<EOF
                    connect dev_ws/$DEV_ADB_USER_CREDS_PSW@bsaapexdev_high
                    lb update -changelog controller.xml
                    EOF
                    '''
                }
                // Import Logic
                echo "Importing Logic"
                script {
                    sh ''' 
                    cd "${WORKSPACE}/database/logic"
                    /opt/sqlcl/bin/sql /nolog <<EOF
                    connect dev_ws/$DEV_ADB_USER_CREDS_PSW@bsaapexdev_high
                    lb update -changelog controller.xml
                    EOF
                    '''
                }
                echo "Importing Tests"
                script {
                    sh ''' 
                    cd "${WORKSPACE}/tests"
                    /opt/sqlcl/bin/sql /nolog <<EOF
                    connect dev_ws/$DEV_ADB_USER_CREDS_PSW@bsaapexdev_high
                    lb update -changelog controller.xml
                    EOF
                    '''
                }
                echo "Giving Test User Permission to Execute Tests in Temporary Schema"
                script {
                    sh ''' 
                    cd "${WORKSPACE}/etc"
                    /opt/sqlcl/bin/sql /nolog <<EOF
                    connect $DEV_ADB_ADMIN_CREDS_USR/$DEV_ADB_ADMIN_CREDS_PSW@bsaapexdev_high
                    @ut3_permission_grants.sql
                    EOF
                    '''
                }
                // TODO - What happens on test failure? Do we need to put a conditionally somewhere to fail the pipeline?
                echo "Running tests"
                script {
                    sh ''' 
                    /opt/sqlcl/bin/sql /nolog <<EOF
                    connect $DEV_ADB_TEST_CREDS_USR/$DEV_ADB_TEST_CREDS_PSW@bsaapexdev_high
                    set serveroutput on;
                    exec ut.run('dev_ws');
                    EOF
                    '''
                }
                script {
                    sh ''' 
                    cd "${WORKSPACE}"/ansible/database/setup/scripts
                    /opt/sqlcl/bin/sql /nolog <<EOF
                    connect $DEV_ADB_ADMIN_CREDS_USR/$DEV_ADB_ADMIN_CREDS_PSW@bsaapexdev_high
                    DROP USER dev_ws CASCADE;
                    EOF
                    '''
                }
            }
        }
        stage('Deploy') {
            // when {
            //     branch 'main'
            // }
            environment {
                TNS_ADMIN = "/opt/wallet_prod"
                // Reference on how to use creds: https://mtijhof.wordpress.com/2019/06/03/jenkins-working-with-credentials-in-your-pipeline/
                PROD_ADB_USER_CREDS = credentials('bsa-prod-user-creds')
                // VERSION = ''
            }
            steps {
                // TODO - Should we use an artifact or the source code repo?
                // script {
                //     // Only the main branch has version tags to deploy releases
                //     VERSION = sh(returnStdout: true, script: "git tag --contains").trim()
                // }
                // // Use the version to download the latest artifacts from the github actions run
                // echo "Current Deployable Version is: ${VERSION}"
                // sh "curl -L -o /tmp/app.tar https://github.com/frank-cerny/turbo-octo-fiesta/releases/download/${VERSION}/app.tar"
                // sh "mkdir ${WORKSPACE}/deployTemp"
                // sh "tar -xvf app.tar --directory ./deployTemp/"
                // Un-tarring always results in tmp being the top level directory for the archive
                // Import Schema
                echo "Importing Schema Updates"
                script {
                    sh ''' 
                    cd "${WORKSPACE}"/database/schema_updates
                    /opt/sqlcl/bin/sql /nolog <<EOF
                    connect $PROD_ADB_USER_CREDS_USR/$PROD_ADB_USER_CREDS_PSW@bsaapexprod_high
                    lb update -changelog controller.xml
                    EOF
                    '''
                }
                // Import Logic
                echo "Importing Logic Updates"
                script {
                    sh ''' 
                    cd "${WORKSPACE}"/database/logic
                    /opt/sqlcl/bin/sql /nolog <<EOF
                    connect $PROD_ADB_USER_CREDS_USR/$PROD_ADB_USER_CREDS_PSW@bsaapexprod_high
                    lb update -changelog controller.xml
                    EOF
                    '''
                }
                // Import Application
                echo "Importing Application"
                script {
                    sh ''' 
                    cd "${WORKSPACE}"/app/deploy
                    /opt/sqlcl/bin/sql /nolog <<EOF
                    connect $PROD_ADB_USER_CREDS_USR/$PROD_ADB_USER_CREDS_PSW@bsaapexprod_high
                    lb update -changelog f100.xml
                    EOF
                    '''
                }
            }
        }
    }
}