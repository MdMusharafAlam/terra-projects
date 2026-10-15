
pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
        skipDefaultCheckout(true)
    }

    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'staging', 'production'],
            description: 'Select the Terraform environment'
        )

        booleanParam(
            name: 'DEPLOY',
            defaultValue: false,
            description: 'Apply infrastructure after manual approval'
        )
    }

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        TF_IN_AUTOMATION = 'true'
        TF_INPUT = 'false'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                echo 'Terraform repository checked out.'
            }
        }

        stage('Check Tools') {
            steps {
                bat 'git --version'
                bat 'terraform version'
                bat 'aws --version'
            }
        }

        stage('Format Check') {
            steps {
                bat 'terraform fmt -check -recursive'
            }
        }

        stage('Initialize Terraform') {
            steps {
                bat 'terraform -chdir=environments/%ENVIRONMENT% init -input=false'
            }
        }

        stage('Validate Terraform') {
            steps {
                bat 'terraform -chdir=environments/%ENVIRONMENT% validate'
            }
        }

        stage('Terraform Plan') {
            steps {
                bat 'terraform -chdir=environments/%ENVIRONMENT% plan -input=false -out=tfplan'
            }
        }

        stage('Approval') {
            when {
                expression { params.DEPLOY }
            }
            steps {
                input message: "Review the Terraform plan before applying to ${params.ENVIRONMENT}. Continue?",
                      ok: 'Approve deployment'
            }
        }

        stage('Apply Infrastructure') {
            when {
                expression { params.DEPLOY }
            }
            steps {
                bat 'terraform -chdir=environments/%ENVIRONMENT% apply -input=false tfplan'
            }
        }

        stage('Deployment Output') {
            when {
                expression { params.DEPLOY }
            }
            steps {
                bat 'terraform -chdir=environments/%ENVIRONMENT% output'
            }
        }
    }

    post {
        success {
            echo 'SUCCESS: Terraform pipeline completed.'
        }

        failure {
            echo 'FAILED: Review the Jenkins Console Output.'
        }

        always {
            echo 'Terraform pipeline finished.'
        }
    }
}
