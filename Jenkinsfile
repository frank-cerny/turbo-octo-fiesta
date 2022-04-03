#!groovy

pipeline {
    agent any

    environment {
        VERSION = ''
        TNS_ADMIN = "/opt/wallet/"
        // Reference on how to use creds: https://mtijhof.wordpress.com/2019/06/03/jenkins-working-with-credentials-in-your-pipeline/
        PROD_ADB_CREDS = credentials('bsa-prod-creds')
        ORACLE_HOME = "/usr/lib/oracle/21/client64"
    }

    stages {
        stage ('Test') {
            steps {
                // Reference: https://plugins.jenkins.io/sqlplus-script-runner/
                step([$class: 'SQLPlusRunnerBuilder',credentialsId:'bsa-prod-creds', 
                    instance:'bsaapex_high',scriptType:'userDefined', script: '', scriptContent: 
                    'show con_name;'])
            }
        }
        // TODO - Add PR testing stage locally (for PRs) have to be manually triggered sadly
        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                script {
                    // Only the main branch has version tags to deploy releases
                    VERSION = sh(returnStdout: true, script: "git tag --contains").trim()
                }
                // Use the version to download the latest artifacts from the github actions run
                echo "Current Deployable Version is: ${VERSION}"
                sh "curl -L -o /tmp/app.tar https://github.com/frank-cerny/turbo-octo-fiesta/releases/download/${VERSION}/app.tar"
                // Now use SQLPlus to make a connection to the database
                // TODO - Just login for now
            }
        }
    }
}