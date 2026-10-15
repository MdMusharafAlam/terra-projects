
pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Check Terraform') {
            steps {
                bat 'terraform version'
            }
        }

        stage('Format Check') {
            steps {
                bat 'terraform fmt -check -recursive'
            }
        }

        stage('Initialize') {
            steps {
                bat 'terraform -chdir=environments/dev init -backend=false -input=false'
            }
        }

        stage('Validate') {
            steps {
                bat 'terraform -chdir=environments/dev validate'
            }
        }

        stage('Terraform Plan') {
            steps {
                bat 'terraform -chdir=environments/dev plan -input=false'
            }
        }
    }

    post {
        success {
            echo 'Terraform CI pipeline completed successfully!'
        }

        failure {
            echo 'Pipeline failed. Check Console Output.'
        }
    }
}
