
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
                env.LAB10_DEV_PLAN_MODE = 'INVALID'

                env.LAB10_DEV_PLAN_MODE = sh(
                    script: '''#!/bin/bash
                        set +x
                        set -euo pipefail

                        test -f tfplan
                        test -f ../../policies/dev-plan-safety.jq

                        terraform show -json tfplan |
                            jq -e -f ../../policies/dev-plan-safety.jq > /dev/null

                        terraform show -json tfplan |
                            jq -er '
                                [
                                    .resource_changes[]
                                    | select(.change.actions != ["no-op"])
                                ] as $resources
                                |
                                [
                                    (.output_changes // {})
                                    | to_entries[]
                                    | select(.value.actions != ["no-op"])
                                ] as $outputs
                                |
                                if ($resources | length) == 0
                                    and ($outputs | length) == 0
                                then
                                    "NO_OP"
                                elif ($resources | length) == 1
                                    and ($outputs | length) == 0
                                then
                                    "DEV_MEMORY_UPDATE"
                                elif ($resources | length) == 0
                                    and ($outputs | length) == 1
                                then
                                    "OUTPUT_ONLY"
                                else
                                    error("Invalid DEV Plan Mode")
                                end
                            '
                    ''',
                    returnStdout: true
                ).trim()

                if (!(env.LAB10_DEV_PLAN_MODE in [
                    'NO_OP',
                    'DEV_MEMORY_UPDATE',
                    'OUTPUT_ONLY'
                ])) {
                    error('LAB10: Invalid DEV Plan Mode.')
                }

                env.LAB10_DEV_HAS_CHANGES =
                    env.LAB10_DEV_PLAN_MODE == 'NO_OP' ? 'false' : 'true'

                echo 'LAB10: DEV Plan Safety Check V3 passed.'
                echo "LAB10: DEV Plan Mode = ${env.LAB10_DEV_PLAN_MODE}"
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
                    message: """
                        Review Terraform Plan for DEV, TEST and PROD.

                        DEV Plan Mode: ${env.LAB10_DEV_PLAN_MODE}
                        DEV Has Changes: ${env.LAB10_DEV_HAS_CHANGES}

                        Only authorized DEV changes may be applied.
                    """.stripIndent().trim(),
                    ok: 'Approve',
                    submitter: 'admin',
                    submitterParameter: 'APPROVED_BY'
                )

                echo "LAB10: Approved by ${approvedBy}"
                echo "LAB10: Approved DEV Plan Mode = ${env.LAB10_DEV_PLAN_MODE}"
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

                        POLICY="../../policies/dev-plan-safety.jq"

                        # Environment and Plan Mode Guards

                        test "$LAB10_APPLY_ENV" = "dev"
                        test "$LAB10_DEV_HAS_CHANGES" = "true"

                        case "$LAB10_DEV_PLAN_MODE" in
                            DEV_MEMORY_UPDATE|OUTPUT_ONLY)
                                ;;
                            *)
                                echo "LAB10: Unauthorized DEV Plan Mode."
                                exit 1
                                ;;
                        esac

                        # File Integrity Guards

                        test -f tfplan
                        test -f tfplan.sha256
                        test -f "$POLICY"

                        test ! -L tfplan
                        test ! -L tfplan.sha256
                        test ! -L "$POLICY"

                        test "$(stat -c '%a' tfplan)" = "600"
                        test "$(stat -c '%a' tfplan.sha256)" = "600"

                        sha256sum -c tfplan.sha256

                        test -n "$LAB10_DEV_PLAN_SHA256"
                        test -n "$LAB10_DEV_POLICY_SHA256"

                        CURRENT_PLAN_SHA256=$(sha256sum tfplan | cut -d ' ' -f1)
                        CURRENT_POLICY_SHA256=$(sha256sum "$POLICY" | cut -d ' ' -f1)

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

                        # Re-run Safety Policy V3

                        terraform show -json tfplan |
                            jq -e -f "$POLICY" > /dev/null

                        echo "LAB10: Post-Approval Safety Policy V3 passed."

                        # Exact Mode Verification

                        terraform show -json tfplan |
                            jq -e --arg mode "$LAB10_DEV_PLAN_MODE" '

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

                                and all(
                                    .resource_changes[];
                                    (has("deposed") | not)
                                )

                                and (
                                    [
                                        .resource_changes[]
                                        | select(.change.actions != ["no-op"])
                                    ] as $resources

                                    |

                                    [
                                        (.output_changes // {})
                                        | to_entries[]
                                        | select(.value.actions != ["no-op"])
                                    ] as $outputs

                                    |

                                    if $mode == "DEV_MEMORY_UPDATE" then

                                        ($resources | length) == 1
                                        and ($outputs | length) == 0

                                        and all($resources[];

                                            .mode == "managed"
                                            and .type == "vsphere_virtual_machine"
                                            and .name == "dev"

                                            and .provider_name ==
                                                "registry.terraform.io/vmware/vsphere"

                                            and .address ==
                                                "vsphere_virtual_machine.dev"

                                            and .change.actions == ["update"]

                                            and .change.before.name == "ubuntu-dev"
                                            and .change.after.name == "ubuntu-dev"

                                            and .change.before.id ==
                                                "420c4cc8-44ae-6f44-9bad-92b82085802b"

                                            and .change.after.id ==
                                                "420c4cc8-44ae-6f44-9bad-92b82085802b"

                                            and .change.before.memory == 1024
                                            and .change.after.memory == 2048
                                        )

                                    elif $mode == "OUTPUT_ONLY" then

                                        ($resources | length) == 0
                                        and ($outputs | length) == 1

                                        and all($outputs[];

                                            .key == "ansible_inventory"
                                            and .value.actions == ["create"]
                                            and .value.before == null

                                            and .value.after == {
                                                environment: "dev",
                                                hostname: "ubuntu-dev",
                                                ip_address: "192.168.174.154",
                                                vm_uuid: "420c4cc8-44ae-6f44-9bad-92b82085802b"
                                            }
                                        )

                                    else

                                        false

                                    end
                                )

                            ' > /dev/null

                        echo "LAB10: Exact DEV Plan Mode verification passed."

                        # Final Integrity Guards

                        test "$(sha256sum tfplan | cut -d ' ' -f1)" = "$LAB10_DEV_PLAN_SHA256"

                        test "$(sha256sum "$POLICY" | cut -d ' ' -f1)" = "$LAB10_DEV_POLICY_SHA256"

                        echo "LAB10: All Pre-Apply Security Checks passed."
                        echo "LAB10: Starting controlled DEV Apply."
                        echo "LAB10: Apply Mode = $LAB10_DEV_PLAN_MODE"

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
