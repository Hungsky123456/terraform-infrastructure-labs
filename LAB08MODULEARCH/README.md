

\# LAB08 - Terraform Modular Infrastructure Architecture



\## 1. Overview



LAB08 demonstrates a reusable Terraform infrastructure architecture using Root Modules, Child Modules, `for\_each`, variables, CPU/RAM profiles, and inter-module dependencies.



The lab simulates infrastructure across three independent environments:



\- \*\*DEV\*\* - Development

\- \*\*TEST\*\* - Testing

\- \*\*PROD\*\* - Production



All resources are simulated using Terraform's built-in `terraform\_data` resource.



\*\*No real virtual machines, networks, databases, or cloud resources are deployed.\*\*



\## 2. Learning Objectives



\- Build reusable Terraform Child Modules.

\- Organize infrastructure using Root Modules.

\- Manage multiple environments independently.

\- Use `for\_each` to deploy multiple server instances.

\- Standardize CPU/RAM configurations using profiles.

\- Store server inventory in `.auto.tfvars` files.

\- Implement implicit dependencies between modules.

\- Use `moved` blocks for safe State migration.

\- Maintain separate Terraform State files for DEV, TEST, and PROD.



\## 3. Infrastructure Architecture



The infrastructure consists of three reusable Child Modules:



1\. \*\*Network Module\*\* - Simulates network configuration.

2\. \*\*Server Module\*\* - Simulates server provisioning.

3\. \*\*Application Module\*\* - Simulates application deployment.



\### Module Dependency Flow



```text

&#x20;             ROOT MODULE

&#x20;                  |

&#x20;                  v

&#x20;           NETWORK MODULE

&#x20;                  |

&#x20;                  | network\_info

&#x20;                  v

&#x20;            SERVER MODULE

&#x20;                  |

&#x20;                  | server\_info

&#x20;                  v

&#x20;          APPLICATION MODULE

```



Terraform automatically detects dependencies through module output references.



\### Multi-Environment Architecture



```text

&#x20;                SHARED MODULES

&#x20;             Network / Server / App

&#x20;                       |

&#x20;         +-------------+-------------+

&#x20;         |             |             |

&#x20;         v             v             v

&#x20;     DEV ROOT      TEST ROOT      PROD ROOT

&#x20;         |             |             |

&#x20;         v             v             v

&#x20;     DEV STATE     TEST STATE     PROD STATE

&#x20;         |             |             |

&#x20;     6 resources   4 resources   4 resources

```



Each environment is deployed independently.



\## 4. Project Structure



```text

LAB08MODULEARCH/

|

+-- modules/

|   |

|   +-- network/

|   |   +-- main.tf

|   |   +-- variables.tf

|   |   +-- outputs.tf

|   |

|   +-- server/

|   |   +-- main.tf

|   |   +-- variables.tf

|   |   +-- outputs.tf

|   |

|   +-- application/

|       +-- main.tf

|       +-- variables.tf

|       +-- outputs.tf

|

+-- environments/

|   |

|   +-- dev/

|   |   +-- main.tf

|   |   +-- locals.tf

|   |   +-- variables.tf

|   |   +-- servers.auto.tfvars

|   |   +-- moved.tf

|   |

|   +-- test/

|   |   +-- main.tf

|   |   +-- locals.tf

|   |   +-- variables.tf

|   |   +-- servers.auto.tfvars

|   |

|   +-- prod/

|       +-- main.tf

|       +-- locals.tf

|       +-- variables.tf

|       +-- servers.auto.tfvars

|

+-- README.md

```



Terraform State files and `.terraform/` directories are excluded from Git.



\## 5. Environment Configuration



| Environment | Network | Subnet | Gateway | Servers | Resources |

|---|---|---|---|---:|---:|

| DEV | dev-network | 192.168.50.0/24 | 192.168.50.1 | 4 | 6 |

| TEST | test-network | 192.168.60.0/24 | 192.168.60.1 | 2 | 4 |

| PROD | prod-network | 192.168.70.0/24 | 192.168.70.1 | 2 | 4 |

| \*\*Total\*\* | \*\*3 Networks\*\* | | | \*\*8\*\* | \*\*14\*\* |



Each environment contains:



\- One Network resource.

\- Multiple Server resources.

\- One Application resource.



\## 6. Server Inventory



\### DEV Environment



| Server | Profile | CPU | RAM |

|---|---|---:|---:|

| ubuntu-dev-01 | standard | 1 vCPU | 2048 MB |

| ubuntu-dev-02 | standard | 1 vCPU | 2048 MB |

| ubuntu-db-01 | database | 4 vCPU | 8192 MB |

| ubuntu-mon-01 | monitoring | 2 vCPU | 4096 MB |



Application: `nginx-web`



Port: `8080`



\### TEST Environment



| Server | Profile | CPU | RAM |

|---|---|---:|---:|

| ubuntu-test-01 | standard | 2 vCPU | 6144 MB |

| ubuntu-test-db-01 | database | 4 vCPU | 8192 MB |



Application: `nginx-web-test`



Port: `8080`



\### PROD Environment



| Server | Profile | CPU | RAM |

|---|---|---:|---:|

| ubuntu-prod-01 | standard | 4 vCPU | 8192 MB |

| ubuntu-prod-db-01 | database | 8 vCPU | 16384 MB |



Application: `nginx-web-prod`



Port: `8080`



\## 7. Terraform Module Design



\### 7.1 Network Module



The Network Module receives:



\- `network\_name`

\- `subnet\_cidr`

\- `gateway\_ip`



It exposes:



\- `network\_info`

\- `network\_id`



The Server Module receives `network\_info` through a Root Module reference.



\### 7.2 Server Module



The Server Module receives:



\- `server\_name`

\- `server\_cpu`

\- `server\_ram`

\- `network\_info`



It exposes:



\- `server\_info`

\- `server\_id`



The Root Module uses `for\_each` to create multiple instances from the inventory.



\### 7.3 Application Module



The Application Module receives:



\- `application\_name`

\- `application\_port`

\- `server\_info`



It exposes:



\- `application\_info`

\- `application\_id`



The Application Module uses Server Module output to establish an implicit dependency.



\## 8. Important Terraform Concepts



\### 8.1 Reusable Modules



The three Child Modules are shared across all environments.



This reduces duplicated Terraform configuration and makes infrastructure easier to maintain.



\### 8.2 for\_each



The Server Module uses:



```hcl

for\_each = var.servers

```



Each server has a stable key, such as:



\- `dev01`

\- `dev02`

\- `db01`

\- `mon01`



This allows new servers to be added without recreating existing instances.



\### 8.3 Server Profiles



CPU and RAM settings are defined in `locals.tf`.



Example:



```hcl

server\_profiles = {

&#x20; standard = {

&#x20;   cpu = 1

&#x20;   ram = 2048

&#x20; }



&#x20; database = {

&#x20;   cpu = 4

&#x20;   ram = 8192

&#x20; }



&#x20; monitoring = {

&#x20;   cpu = 2

&#x20;   ram = 4096

&#x20; }

}

```



Each environment can use different resource profiles.



\### 8.4 Server Inventory



Server inventory is stored in `servers.auto.tfvars`.



Example:



```hcl

servers = {

&#x20; dev01 = {

&#x20;   name    = "ubuntu-dev-01"

&#x20;   profile = "standard"

&#x20; }

}

```



Terraform automatically loads `.auto.tfvars` files.



\### 8.5 Implicit Dependencies



The Root Module connects Network and Server:



```hcl

network\_info = module.network.network\_info

```



The Application Module receives Server information:



```hcl

server\_info = module.server\["dev01"].server\_info

```



These references allow Terraform to determine the required creation order.



\### 8.6 State Isolation



Each environment has its own Root Module and local Terraform State.



Benefits include:



\- DEV changes do not directly modify TEST State.

\- TEST changes do not directly modify PROD State.

\- Each environment can be planned and applied independently.

\- State management is easier to control.



\### 8.7 State Migration



DEV originally used a single Server Module.



The module was migrated to `for\_each` using:



```hcl

moved {

&#x20; from = module.server

&#x20; to   = module.server\["dev01"]

}

```



Terraform successfully preserved the existing Server resource ID.



Migration result:



```text

Plan: 0 to add, 0 to change, 0 to destroy.

```



\## 9. Deployment Guide



\### Requirements



\- Terraform CLI

\- Windows PowerShell

\- Git



No VMware, AWS, or Ubuntu VM is required.



\### Deploy DEV



```powershell

cd C:\\Terraform-Labs\\LAB08MODULEARCH\\environments\\dev



terraform init

terraform fmt

terraform validate

terraform plan

terraform apply

```



\### Deploy TEST



```powershell

cd C:\\Terraform-Labs\\LAB08MODULEARCH\\environments\\test



terraform init

terraform validate

terraform plan

terraform apply

```



\### Deploy PROD



```powershell

cd C:\\Terraform-Labs\\LAB08MODULEARCH\\environments\\prod



terraform init

terraform validate

terraform plan

terraform apply

```



\### Verification Commands



```powershell

terraform state list

terraform plan

terraform graph

```



Run these commands from the relevant environment directory.



\## 10. Final Lab Results



| Environment | Network | Servers | Application | Total |

|---|---:|---:|---:|---:|

| DEV | 1 | 4 | 1 | 6 |

| TEST | 1 | 2 | 1 | 4 |

| PROD | 1 | 2 | 1 | 4 |

| \*\*Total\*\* | \*\*3\*\* | \*\*8\*\* | \*\*3\*\* | \*\*14\*\* |



\### Verified Results



\*\*DEV\*\*



```text

6 resources

No changes. Your infrastructure matches the configuration.

```



\*\*TEST\*\*



```text

4 resources

No changes. Your infrastructure matches the configuration.

```



\*\*PROD\*\*



```text

4 resources

No changes. Your infrastructure matches the configuration.

```



All three environments were deployed successfully.



\## 11. Security and Git Management



The following files must not be committed:



\- `terraform.tfstate`

\- `terraform.tfstate.backup`

\- `.terraform/`

\- Files containing passwords, tokens, or secrets



Non-sensitive infrastructure configuration files can be committed to Git.



Terraform State is maintained independently for each environment.



\## 12. Conclusion



LAB08 successfully demonstrates a modular Terraform infrastructure architecture with:



\- 3 reusable Child Modules.

\- 3 independent environments.

\- 8 simulated servers.

\- 3 simulated networks.

\- 3 simulated applications.

\- 14 managed Terraform resources.

\- Profile-driven infrastructure configuration.

\- Implicit module dependencies.

\- Safe State migration using `moved`.



The architecture provides a foundation for future Terraform automation using VMware vSphere and AWS.



\*\*LAB08 Status: Completed\*\*



