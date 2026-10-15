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
                bat 'terraform -chdir=environments/dev init -input=false -reconfigure'
            }
        }

        stage('Validate') {
            steps {
                bat 'terraform -chdir=environments/dev validate'
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('environments/dev') {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-credentials']]) {
                        bat '''
                            terraform plan -input=false ^
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
