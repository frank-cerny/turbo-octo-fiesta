#!groovy

pipeline {
    agent any

    stages {
        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                sh 'echo helloWorld'
            }
        }
    }
}