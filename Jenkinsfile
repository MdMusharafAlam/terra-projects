
pipeline {
    agent any

    options {
        timestamps()
    }

    parameters {
        choice(
            name: 'DEPLOY_ENVIRONMENT',
            choices: ['none', 'dev', 'production'],
            description: 'none = CI only; dev or production = plan, approval, apply, and verify.'
        )
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
                        terraform -chdir=environments/dev plan -input=false -no-color -out=tfplan ^
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
                    bat '''
                        terraform -chdir=environments/production plan -input=false -no-color -out=tfplan ^
                        -var="aws_region=us-east-1" ^
                        -var="ami_id=ami-08c982207dfbf2b27" ^
                        -var="instance_type=t3.micro" ^
                        -var="vpc_cidr_block=10.30.0.0/16" ^
                        -var="subnet_cidr_block=10.30.1.0/24" ^
                        -var="availability_zone=us-east-1a" ^
                        -var="bucket_name=musharaf-terraform-prod-215514708499" ^
                        -var="allowed_ssh_cidr=152.58.134.29/32"
                    '''
                }
            }
        }

        stage('Approve Dev') {
            when {
                expression { params.DEPLOY_ENVIRONMENT == 'dev' }
            }
            steps {
                timeout(time: 15, unit: 'MINUTES') {
                    input(
                        message: 'Review the Dev plan in the earlier console output. Approve deployment?',
                        ok: 'Approve Dev'
                    )
                }
            }
        }

        stage('Apply Dev') {
            when {
                expression { params.DEPLOY_ENVIRONMENT == 'dev' }
            }
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-credentials'
                ]]) {
                    bat 'terraform -chdir=environments/dev apply -input=false -auto-approve tfplan'
                }
            }
        }

        stage('Verify Dev') {
            when {
                expression { params.DEPLOY_ENVIRONMENT == 'dev' }
            }
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-credentials'
                ]]) {
                    script {
                        def result = bat(
                            returnStatus: true,
                            script: '''
                                terraform -chdir=environments/dev plan -input=false -no-color -detailed-exitcode ^
                                -var="aws_region=us-east-1" ^
                                -var="ami_id=ami-08c982207dfbf2b27" ^
                                -var="instance_type=t3.micro" ^
                                -var="vpc_cidr_block=10.10.0.0/16" ^
                                -var="subnet_cidr_block=10.10.1.0/24" ^
                                -var="availability_zone=us-east-1a" ^
                                -var="bucket_name=musharaf-terraform-dev-215514708499" ^
                                -var="allowed_ssh_cidr=152.58.134.29/32"
                            '''
                        )

                        if (result != 0) {
                            error("Dev verification failed. Terraform plan exit code: ${result}. Check the console output.")
                        }
                    }
                }
                echo 'Dev verification passed: Terraform reports no further changes.'
            }
        }

        stage('Approve Production') {
            when {
                expression { params.DEPLOY_ENVIRONMENT == 'production' }
            }
            steps {
                timeout(time: 15, unit: 'MINUTES') {
                    input(
                        message: 'Review the Production plan in the earlier console output. Approve deployment?',
                        ok: 'Approve Production'
                    )
                }
            }
        }

        stage('Apply Production') {
            when {
                expression { params.DEPLOY_ENVIRONMENT == 'production' }
            }
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-credentials'
                ]]) {
                    bat 'terraform -chdir=environments/production apply -input=false -auto-approve tfplan'
                }
            }
        }

        stage('Verify Production') {
            when {
                expression { params.DEPLOY_ENVIRONMENT == 'production' }
            }
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-credentials'
                ]]) {
                    script {
                        def result = bat(
                            returnStatus: true,
                            script: '''
                                terraform -chdir=environments/production plan -input=false -no-color -detailed-exitcode ^
                                -var="aws_region=us-east-1" ^
                                -var="ami_id=ami-08c982207dfbf2b27" ^
                                -var="instance_type=t3.micro" ^
                                -var="vpc_cidr_block=10.30.0.0/16" ^
                                -var="subnet_cidr_block=10.30.1.0/24" ^
                                -var="availability_zone=us-east-1a" ^
                                -var="bucket_name=musharaf-terraform-prod-215514708499" ^
                                -var="allowed_ssh_cidr=152.58.134.29/32"
                            '''
                        )

                        if (result != 0) {
                            error("Production verification failed. Terraform plan exit code: ${result}. Check the console output.")
                        }
                    }
                }
                echo 'Production verification passed: Terraform reports no further changes.'
            }
        }
    }

    post {
        always {
            bat '''
                @echo off
                if exist "environments\\dev\\tfplan" del /f /q "environments\\dev\\tfplan"
                if exist "environments\\production\\tfplan" del /f /q "environments\\production\\tfplan"
                exit /b 0
            '''
        }

        success {
            echo 'Terraform pipeline completed successfully.'
        }

        failure {
            echo 'Pipeline failed. Review the first failed stage in Console Output.'
        }
    }
}
