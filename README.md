

# Terraform Infrastructure Labs



Hands-on Terraform labs focused on Infrastructure as Code (IaC), automation, reusable modules, and multi-environment infrastructure management.



## Project Overview



This repository documents my Terraform learning journey, from basic configuration to reusable infrastructure architecture.



Current implementations use local resources to simulate server provisioning without requiring cloud infrastructure.



Future goals include VMware vSphere and AWS infrastructure automation.



## Learning Roadmap



| Lab | Topic | Status |
|-----|-------|--------|
| LAB01 | Terraform Basics and Outputs | Completed |
| LAB02 | Providers, Resources and State | Completed |
| LAB03 | Variables, TFVARS and Backends | Completed |
| LAB04 | Root and Child Modules | Completed |
| LAB05FOREACH | for_each and Server Inventory | Completed |
| LAB06MULTIENV | Multi-Environment and State Isolation | Completed |



## LAB06 - Multi-Environment Architecture



LAB06 implements three independent environments:



- DEV: 4 simulated servers
- TEST: 2 simulated servers
- PROD: 2 simulated servers



Key features:



- Independent Terraform State per environment
- Shared Child Module
- for_each-based server provisioning
- Standard, Database and Monitoring profiles
- CPU and RAM configuration by environment
- Input validation for server profiles
- State isolation and configuration change testing



## Repository Structure



    terraform-infrastructure-labs/
    ├── LAB01/
    ├── LAB02/
    ├── LAB03/
    ├── LAB04/
    ├── LAB05FOREACH/
    ├── LAB06MULTIENV/
    │   ├── modules/
    │   │   └── server/
    │   └── environments/
    │       └── local/
    │           ├── dev/
    │           ├── test/
    │           └── prod/
    ├── .gitignore
    └── README.md



## Requirements



- Terraform CLI
- Git
- Local File Terraform Provider
- Windows PowerShell or a compatible terminal



## Running LAB06



Example: Deploy the DEV environment.



    cd LAB06MULTIENV/environments/local/dev
    terraform init
    terraform validate
    terraform plan
    terraform apply



Inspect managed resources:



    terraform state list
    terraform output



Run Terraform separately in each environment directory to maintain independent local State.



## State Management and Security



Terraform State files, working directories, and generated server configuration files are excluded from Git.



Provider dependency lock files are version-controlled.



Do not commit credentials, private keys, access tokens, or sensitive infrastructure configuration.



## Future Roadmap



- Advanced Terraform validation
- Terraform lifecycle management
- VMware vSphere VM provisioning
- AWS EC2 infrastructure
- Remote State and State Locking
- Terraform automation with CI/CD



## Disclaimer



Current labs provision local text files to simulate server configurations. They do not create actual VMware virtual machines or AWS resources.



This repository is intended for educational and hands-on learning purposes.



