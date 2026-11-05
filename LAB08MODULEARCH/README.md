

\# LAB08 - Terraform Modular Infrastructure Architecture



\## 1. Overview



LAB08 demonstrates a reusable Terraform infrastructure architecture using Root Modules, Child Modules, for\_each, variables, CPU/RAM profiles and inter-module dependencies.



All infrastructure resources are simulated using terraform\_data.



No real VMs, cloud resources or applications are deployed.



\## 2. Architecture



&#x20;   Root Modules

&#x20;   |

&#x20;   +-- DEV  (Independent State)

&#x20;   +-- TEST (Independent State)

&#x20;   +-- PROD (Independent State)

&#x20;          |

&#x20;          +-- Network Module

&#x20;          |       |

&#x20;          |       v

&#x20;          +-- Server Module (for\_each)

&#x20;                  |

&#x20;                  v

&#x20;              Application Module



Three reusable Child Modules:



\- Network: Simulated network configuration

\- Server: Simulated servers and CPU/RAM profiles

\- Application: Simulated application deployment



\## 3. Project Structure



&#x20;   LAB08MODULEARCH/

&#x20;   |

&#x20;   +-- modules/

&#x20;   |   +-- network/

&#x20;   |   |   +-- main.tf

&#x20;   |   |   +-- variables.tf

&#x20;   |   |   +-- outputs.tf

&#x20;   |   |

&#x20;   |   +-- server/

&#x20;   |   |   +-- main.tf

&#x20;   |   |   +-- variables.tf

&#x20;   |   |   +-- outputs.tf

&#x20;   |   |

&#x20;   |   +-- application/

&#x20;   |       +-- main.tf

&#x20;   |       +-- variables.tf

&#x20;   |       +-- outputs.tf

&#x20;   |

&#x20;   +-- environments/

&#x20;   |   +-- dev/

&#x20;   |   |   +-- main.tf

&#x20;   |   |   +-- locals.tf

&#x20;   |   |   +-- variables.tf

&#x20;   |   |   +-- servers.auto.tfvars

&#x20;   |   |   +-- moved.tf

&#x20;   |   |

&#x20;   |   +-- test/

&#x20;   |   |   +-- main.tf

&#x20;   |   |   +-- locals.tf

&#x20;   |   |   +-- variables.tf

&#x20;   |   |   +-- servers.auto.tfvars

&#x20;   |   |

&#x20;   |   +-- prod/

&#x20;   |       +-- main.tf

&#x20;   |       +-- locals.tf

&#x20;   |       +-- variables.tf

&#x20;   |       +-- servers.auto.tfvars

&#x20;   |

&#x20;   +-- README.md



\## 4. Environment Configuration



| Environment | Network | Subnet | Servers | Total Resources |

|-------------|---------|--------|---------|-----------------|

| DEV | dev-network | 192.168.50.0/24 | 4 | 6 |

| TEST | test-network | 192.168.60.0/24 | 2 | 4 |

| PROD | prod-network | 192.168.70.0/24 | 2 | 4 |



Total: 14 simulated Terraform resources.



\## 5. Server Profiles



| Environment | Standard CPU/RAM | Database CPU/RAM |

|-------------|------------------|------------------|

| DEV | 1 CPU / 2048 MB | 4 CPU / 8192 MB |

| TEST | 2 CPU / 6144 MB | 4 CPU / 8192 MB |

| PROD | 4 CPU / 8192 MB | 8 CPU / 16384 MB |



Each environment defines its own profiles in locals.tf.



Server inventory is managed in servers.auto.tfvars.



\## 6. Terraform Concepts



\### Reusable Modules



The same Network, Server and Application modules are reused across DEV, TEST and PROD.



\### for\_each



Server instances are created from a map with stable keys.



\### Implicit Dependencies



Network output is passed to Server Module.



Server output is passed to Application Module.



Terraform automatically determines the dependency order.



\### State Isolation



DEV, TEST and PROD are independent Root Modules with separate Terraform State files.



\### State Migration



DEV uses a moved block to migrate the Server Module from a single instance to for\_each without replacing the existing resource.



\## 7. Deployment Commands



Run Terraform from the selected environment directory.



&#x20;   cd environments/dev

&#x20;   terraform init

&#x20;   terraform validate

&#x20;   terraform plan

&#x20;   terraform apply



Use environments/test or environments/prod for the other environments.



Verification:



&#x20;   terraform state list

&#x20;   terraform plan



\## 8. Final Results



\- DEV: 6 resources, No changes

\- TEST: 4 resources, No changes

\- PROD: 4 resources, No changes

\- Total: 14 resources



All three environments were successfully deployed and verified.



\## 9. Security and State Management



Do not commit:



\- terraform.tfstate

\- terraform.tfstate.backup

\- .terraform/

\- Sensitive variables or secrets



Terraform State is stored separately for each environment.



This lab uses simulated resources only and does not provision physical or virtual infrastructure.



\## 10. Conclusion



LAB08 demonstrates reusable Terraform Modules, environment isolation, profile-driven server management and inter-module dependencies.



The architecture provides a foundation for future VMware vSphere and AWS Terraform labs.



