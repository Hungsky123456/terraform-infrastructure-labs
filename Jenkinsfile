
pipeline {
    agent any

    environment {
        LAB10_APPLY_ENV = 'dev'
    }

    options {
        timestamps()
        disableConcurrentBuilds()
        skipDefaultCheckout(true)
        disableRestartFromStage()
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
        stage('Plan Integrity Check') {
            steps {
                script {
                    for (envName in ['dev', 'test', 'prod']) {
                        dir("LAB10-VSPHERE/environments/${envName}") {
                            echo "Checking Plan Integrity: ${envName.toUpperCase()}"

                            sh '''
                                set -eu

                                test -f tfplan
                                test -f tfplan.sha256

                                test "$(stat -c '%a' tfplan)" = "600"
                                test "$(stat -c '%a' tfplan.sha256)" = "600"

                                sha256sum -c tfplan.sha256
                            '''
                        }
                    }
                }
            }
        }
        stage('Capture Trusted SHA256') {
            steps {
                dir('LAB10-VSPHERE/environments/dev') {
                    script {
                        env.LAB10_DEV_PLAN_SHA256 = sh(
                            script: '''#!/bin/bash
                                set +x
                                set -euo pipefail

                                test -f tfplan
                                sha256sum -c tfplan.sha256 > /dev/null

                                sha256sum tfplan | cut -d ' ' -f1
                            ''',
                            returnStdout: true
                        ).trim()

                        env.LAB10_DEV_POLICY_SHA256 = sh(
                            script: '''#!/bin/bash
                                set +x
                                set -euo pipefail

                                test -f ../../policies/dev-plan-safety.jq

                                sha256sum ../../policies/dev-plan-safety.jq |
                                    cut -d ' ' -f1
                            ''',
                            returnStdout: true
                        ).trim()

                        if (!(env.LAB10_DEV_PLAN_SHA256 ==~ /[a-f0-9]{64}/)) {
                            error('LAB10: Invalid DEV Plan SHA256.')
                        }

                        if (!(env.LAB10_DEV_POLICY_SHA256 ==~ /[a-f0-9]{64}/)) {
                            error('LAB10: Invalid DEV Policy SHA256.')
                        }

                        echo 'LAB10: Trusted DEV Plan SHA256 captured.'
                        echo 'LAB10: Trusted DEV Policy SHA256 captured.'
                    }
                }
            }
        }
        stage('Plan Safety Check') {
            steps {
                dir('LAB10-VSPHERE/environments/dev') {
                    script {
                        env.LAB10_DEV_HAS_CHANGES = 'false'

                        sh '''#!/bin/bash
                            set +x
                            set -euo pipefail

                            test -f tfplan
                            test -f ../../policies/dev-plan-safety.jq

                            terraform show -json tfplan |
                                jq -e -f ../../policies/dev-plan-safety.jq > /dev/null

                            echo "LAB10: DEV Plan Safety Check passed."
                        '''

                        env.LAB10_DEV_HAS_CHANGES = sh(
                            script: '''#!/bin/bash
                                set +x
                                set -euo pipefail

                                terraform show -json tfplan |
                                    jq -r 'any(.resource_changes[];
                                        .mode == "managed"
                                        and .change.actions == ["update"]
                                    )'
                            ''',
                            returnStdout: true
                        ).trim()

                        if (!(env.LAB10_DEV_HAS_CHANGES in ['true', 'false'])) {
                            error('LAB10: Invalid DEV change detection result.')
                        }

                        echo "LAB10: DEV has changes = ${env.LAB10_DEV_HAS_CHANGES}"
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
        stage('Terraform Apply - DEV Only') {
            when {
                allOf {
                    environment name: 'LAB10_APPLY_ENV', value: 'dev'

                    environment name: 'LAB10_DEV_HAS_CHANGES', value: 'true'
                }
            }
            steps {
                dir('LAB10-VSPHERE/environments/dev') {
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
                            sh '''#!/bin/bash
                                set +x
                                set -euo pipefail

                                # 1. Environment verification

                                test "$LAB10_APPLY_ENV" = "dev"
                                test "$LAB10_DEV_HAS_CHANGES" = "true"

                                # 2. Required file verification

                                test -f tfplan
                                test -f tfplan.sha256
                                test -f ../../policies/dev-plan-safety.jq

                                test ! -L tfplan
                                test ! -L tfplan.sha256
                                test ! -L ../../policies/dev-plan-safety.jq

                                # 3. File permission verification

                                test "$(stat -c '%a' tfplan)" = "600"
                                test "$(stat -c '%a' tfplan.sha256)" = "600"

                                sha256sum -c tfplan.sha256 > /dev/null

                                # 4. Original SHA256 verification

                                test -n "$LAB10_DEV_PLAN_SHA256"
                                test -n "$LAB10_DEV_POLICY_SHA256"

                                CURRENT_PLAN_SHA256=$(sha256sum tfplan | cut -d ' ' -f1)

                                CURRENT_POLICY_SHA256=$(sha256sum ../../policies/dev-plan-safety.jq | cut -d ' ' -f1)

                                if [ "$CURRENT_PLAN_SHA256" != "$LAB10_DEV_PLAN_SHA256" ]; then
                                    echo "LAB10: DEV Saved Plan integrity verification failed."
                                    exit 1
                                fi

                                if [ "$CURRENT_POLICY_SHA256" != "$LAB10_DEV_POLICY_SHA256" ]; then
                                    echo "LAB10: DEV Safety Policy integrity verification failed."
                                    exit 1
                                fi

                                echo "LAB10: Post-Approval Plan Integrity passed."
                                echo "LAB10: Post-Approval Policy Integrity passed."

                                # 5. External Safety Policy revalidation

                                terraform show -json tfplan |
                                    jq -e -f ../../policies/dev-plan-safety.jq > /dev/null

                                echo "LAB10: Post-Approval Safety Policy passed."

                                # 6. Enforce exact DEV update

                                terraform show -json tfplan |
                                    jq -e '
                                        (.applyable == true)
                                        and (.complete == true)
                                        and (.errored == false)
                                        and (
                                            [.resource_changes[] | .address] as $addresses
                                            |
                                            ($addresses | length)
                                            ==
                                            ($addresses | unique | length)
                                        )
                                        and all(.resource_changes[];
                                            (has("deposed") | not)
                                        )
                                        and (
                                            [
                                                .resource_changes[]
                                                | select(.change.actions != ["no-op"])
                                            ] as $changes
                                            |
                                            ($changes | length == 1)
                                            and all($changes[];
                                                .mode == "managed"
                                                and .type == "vsphere_virtual_machine"
                                                and .name == "dev"
                                                and .provider_name == "registry.terraform.io/vmware/vsphere"
                                                and .address == "vsphere_virtual_machine.dev"
                                                and .change.actions == ["update"]
                                                and .change.before.name == "ubuntu-dev"
                                                and .change.after.name == "ubuntu-dev"
                                                and .change.before.id == "420c4cc8-44ae-6f44-9bad-92b82085802b"
                                                and .change.after.id == "420c4cc8-44ae-6f44-9bad-92b82085802b"
                                                and .change.before.memory == 1024
                                                and .change.after.memory == 2048
                                            )
                                        )
                                    ' > /dev/null

                                echo "LAB10: Exact DEV Update verification passed."

                                # 7. Final integrity verification

                                test "$(sha256sum tfplan | cut -d ' ' -f1)" = "$LAB10_DEV_PLAN_SHA256"

                                test "$(sha256sum ../../policies/dev-plan-safety.jq | cut -d ' ' -f1)" = "$LAB10_DEV_POLICY_SHA256"

                                echo "LAB10: All Pre-Apply Security Checks passed."

                                # 8. Execute approved DEV Saved Plan

                                echo "LAB10: Starting controlled DEV Apply."

                                terraform apply \
                                    -input=false \
                                    -no-color \
                                    -lock-timeout=60s \
                                    tfplan

                                echo "LAB10: DEV Apply completed."
                            '''
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