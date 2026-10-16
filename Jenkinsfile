
pipeline {
    agent any

    options {
        timestamps()
    }

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

        stage('Initialize Dev') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-credentials'
                ]]) {
                    bat 'terraform -chdir=environments/dev init -input=false'
                }
            }
        }

        stage('Validate Dev') {
            steps {
                bat 'terraform -chdir=environments/dev validate -no-color'
            }
        }

        stage('Plan Dev') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-credentials'
                ]]) {
                    bat '''
                        terraform -chdir=environments/dev plan -input=false -no-color ^
                        -var="aws_region=us-east-1" ^
                        -var="ami_id=ami-08c982207dfbf2b27" ^
                        -var="instance_type=t3.micro" ^
                        -var="vpc_cidr_block=10.10.0.0/16" ^
                        -var="subnet_cidr_block=10.10.1.0/24" ^
                        -var="availability_zone=us-east-1a" ^
                        -var="bucket_name=musharaf-terraform-dev-215514708499" ^
                        -var="allowed_ssh_cidr=152.58.134.29/32"
                    '''
                }
            }
        }

        stage('Initialize Production') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-credentials'
                ]]) {
                    bat 'terraform -chdir=environments/production init -input=false'
                }
            }
        }

        stage('Validate Production') {
            steps {
                bat 'terraform -chdir=environments/production validate -no-color'
            }
        }

        stage('Plan Production') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-credentials'
                ]]) {
                    bat 'terraform -chdir=environments/production plan -input=false -no-color'
                }
            }
        }
    }

    post {
        success {
            echo 'Terraform CI pipeline completed successfully for Dev and Production!'
        }

        failure {
            echo 'Pipeline failed. Check Console Output for the failing stage.'
        }
    }
}
