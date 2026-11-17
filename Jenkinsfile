
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

                            withEnv([
                                'TF_DATA_DIR=.terraform/validate',
                                'TF_IN_AUTOMATION=true'
                            ]) {
                                sh '''
                                    set -eu
                                    terraform init -backend=false -input=false
                                    terraform validate
                                '''
                            }
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
        stage('Terraform Plan') {
            steps {
                withCredentials([
                    string(
                        credentialsId: 'minio-terraform-access-key',
                        variable: 'AWS_ACCESS_KEY_ID'
                    ),
                    string(
                        credentialsId: 'minio-terraform-secret-key',
                        variable: 'AWS_SECRET_ACCESS_KEY'
                    ),
                    usernamePassword(
                        credentialsId: 'vsphere-terraform-credentials',
                        usernameVariable: 'TF_VAR_vsphere_user',
                        passwordVariable: 'TF_VAR_vsphere_password'
                    )
                ]) {
                    withEnv([
                        'AWS_CA_BUNDLE=/etc/jenkins/certs/minio-public.crt',
                        'AWS_EC2_METADATA_DISABLED=true',
                        'TF_IN_AUTOMATION=true'
                    ]) {
                        script {
                            for (envName in ['dev', 'test', 'prod']) {
                                dir("LAB10-VSPHERE/environments/${envName}") {
                                    echo "Running Terraform Plan for ${envName.toUpperCase()}"

                                    sh '''
                                        set +x
                                        set -eu

                                        terraform init -reconfigure -input=false

                                        umask 077

					rm -f tfplan tfplan.sha256

					terraform plan -input=false -no-color -lock-timeout=60s -out=tfplan

					terraform show -no-color tfplan

					sha256sum tfplan > tfplan.sha256
                                    '''
                                }
                            }
                        }
                    }
                }
            }
        }

        stage('Manual Approval') {
            steps {
                script {
                    timeout(time: 15, unit: 'MINUTES') {
                        def approvedBy = input(
                            id: 'LAB10-Manual-Approval',
                            message: 'Review Terraform Plan for DEV, TEST and PROD before approval.',
                            ok: 'Approve',
                            submitter: 'admin',
                            submitterParameter: 'APPROVED_BY'
                        )

                        echo "LAB10: Approved by ${approvedBy}"
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
        aborted {
            echo 'LAB10: Pipeline aborted.'
        }
        cleanup {
            sh '''
                set -eu

                for env in dev test prod; do
                    rm -f "LAB10-VSPHERE/environments/$env/tfplan"
                    rm -f "LAB10-VSPHERE/environments/$env/tfplan.sha256"
                done
            '''

            echo 'LAB10: Saved Plan files cleaned up.'
        }
    }
}