
pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
        skipDefaultCheckout(true)
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Tool Versions') {
            steps {
                sh '''
                    terraform version
                    ansible --version
                    git --version
                '''
            }
        }

        stage('Terraform Format') {
            steps {
                dir('LAB10-VSPHERE') {
                    sh 'terraform fmt -check -recursive'
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                script {
                    for (envName in ['dev', 'test', 'prod']) {
                        dir("LAB10-VSPHERE/environments/${envName}") {
                            echo "Validating environment: ${envName}"

                            sh '''
                                terraform init -backend=false -input=false
                                terraform validate
                            '''
                        }
                    }
                }
            }
        }

        stage('Terraform Remote State Check') {
            steps {
                withCredentials([
                    string(
                        credentialsId: 'minio-terraform-access-key',
                        variable: 'AWS_ACCESS_KEY_ID'
                    ),
                    string(
                        credentialsId: 'minio-terraform-secret-key',
                        variable: 'AWS_SECRET_ACCESS_KEY'
                    )
                ]) {
                    withEnv([
                        'AWS_CA_BUNDLE=/etc/jenkins/certs/minio-public.crt',
                        'AWS_EC2_METADATA_DISABLED=true'
                    ]) {
                        script {
                            for (envName in ['dev', 'test', 'prod']) {
                                dir("LAB10-VSPHERE/environments/${envName}") {
                                    echo "Checking Remote State: ${envName}"

                                    sh '''
                                        set +x
                                        set -eu
                                        terraform init -reconfigure -input=false
                                        terraform state list
                                    '''
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'LAB10: All CI checks passed.'
        }
        failure {
            echo 'LAB10: CI checks failed.'
        }
    }
}
