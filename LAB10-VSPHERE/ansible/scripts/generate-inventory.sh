#!/usr/bin/env bash

set -euo pipefail
umask 077

if [[ $# -ne 0 ]]; then
    echo "ERROR: Unexpected arguments." >&2
    exit 1
fi

# Read and validate exactly one Terraform Output JSON object.
jq -e -s '
    if length != 1 then
        error("Inventory rejected: Expected exactly one JSON object")
    else
        .[0]
    end
    | if . == {
        environment: "dev",
        hostname: "ubuntu-dev",
        ip_address: "192.168.174.154",
        vm_uuid: "420c4cc8-44ae-6f44-9bad-92b82085802b"
    }
    then
        {
            dev: {
                hosts: {
                    (.hostname): {
                        ansible_host: .ip_address,
                        ansible_user: "ansible-svc",
                        ansible_port: 22,
                        ansible_python_interpreter: "/usr/bin/python3",
                        terraform_vm_uuid: .vm_uuid,
                        ansible_ssh_common_args: (
                            "-o StrictHostKeyChecking=yes " +
                            "-o PasswordAuthentication=no " +
                            "-o KbdInteractiveAuthentication=no " +
                            "-o UserKnownHostsFile=/etc/jenkins/ssh/lab10-dev-known-hosts"
                        )
                    }
                }
            }
        }
    else
        error("Inventory rejected: DEV identity validation failed")
    end
'
