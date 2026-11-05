# LAB08 - Terraform Modular Infrastructure Architecture

**Status:** Completed  
**Platform:** Windows 11 / PowerShell / Terraform CLI  
**Scope:** Infrastructure simulation with `terraform_data` (no actual VMs or cloud resources)

## 1. Overview

LAB08 builds a modular Terraform project with **three reusable child modules** and **three isolated root environments**. The project models the dependency chain **Network → Server → Application**, manages server inventories with `for_each`, and applies environment-specific CPU/RAM profiles.

**Lab results:** 3 networks + 8 servers + 3 applications = **14 simulated resources** across DEV, TEST, and PROD.

## 2. Architecture

### Resource dependency flow

```text
                  ROOT MODULE
                       |
                       v
                NETWORK MODULE
                  network_info
                       |
                       v
                 SERVER MODULE
                  server_info
                       |
                       v
               APPLICATION MODULE
```

- The **Network module** exposes `network_info`.
- The **Server module** receives `network_info` and exposes `server_info`.
- The **Application module** consumes `server_info`.
- These output references establish **implicit dependencies**. Terraform manages resource ordering; it does not deploy actual services in this lab.

### Environment isolation

```text
                  SHARED CHILD MODULES
              network / server / application
                          |
              +-----------+-----------+
              |           |           |
              v           v           v
             DEV         TEST         PROD
          Root Module  Root Module  Root Module
              |           |           |
              v           v           v
          DEV State   TEST State   PROD State
          6 resources 4 resources  4 resources
```

Each environment has its own root configuration and local Terraform State. Operations in one root directory do not directly modify another environment's State.

## 3. Project structure

```text
LAB08MODULEARCH/
|-- modules/
|   |-- network/
|   |   |-- main.tf
|   |   |-- variables.tf
|   |   `-- outputs.tf
|   |-- server/
|   |   |-- main.tf
|   |   |-- variables.tf
|   |   `-- outputs.tf
|   `-- application/
|       |-- main.tf
|       |-- variables.tf
|       `-- outputs.tf
|-- environments/
|   |-- dev/
|   |   |-- main.tf
|   |   |-- locals.tf
|   |   |-- variables.tf
|   |   |-- servers.auto.tfvars
|   |   `-- moved.tf
|   |-- test/
|   |   |-- main.tf
|   |   |-- locals.tf
|   |   |-- variables.tf
|   |   `-- servers.auto.tfvars
|   `-- prod/
|       |-- main.tf
|       |-- locals.tf
|       |-- variables.tf
|       `-- servers.auto.tfvars
`-- README.md
```

The `.terraform/` directories and `*.tfstate` files exist locally after initialization or deployment but are excluded from Git.

## 4. Environment summary

| Environment | Network | Subnet | Gateway | Servers | Applications | Total resources |
|---|---|---|---|---:|---:|---:|
| DEV | dev-network | 192.168.50.0/24 | 192.168.50.1 | 4 | 1 | 6 |
| TEST | test-network | 192.168.60.0/24 | 192.168.60.1 | 2 | 1 | 4 |
| PROD | prod-network | 192.168.70.0/24 | 192.168.70.1 | 2 | 1 | 4 |
| **Total** | **3 networks** | - | - | **8** | **3** | **14** |

### DEV server inventory

| Instance key | Server name | Profile | vCPU | RAM (MB) |
|---|---|---|---:|---:|
| dev01 | ubuntu-dev-01 | standard | 1 | 2048 |
| dev02 | ubuntu-dev-02 | standard | 1 | 2048 |
| db01 | ubuntu-db-01 | database | 4 | 8192 |
| mon01 | ubuntu-mon-01 | monitoring | 2 | 4096 |

**Application:** `nginx-web` on `dev01`, simulated port `8080`.

### TEST server inventory

| Instance key | Server name | Profile | vCPU | RAM (MB) |
|---|---|---|---:|---:|
| test01 | ubuntu-test-01 | standard | 2 | 6144 |
| db01 | ubuntu-test-db-01 | database | 4 | 8192 |

**Application:** `nginx-web-test` on `test01`, simulated port `8080`.

### PROD server inventory

| Instance key | Server name | Profile | vCPU | RAM (MB) |
|---|---|---|---:|---:|
| prod01 | ubuntu-prod-01 | standard | 4 | 8192 |
| db01 | ubuntu-prod-db-01 | database | 8 | 16384 |

**Application:** `nginx-web-prod` on `prod01`, simulated port `8080`.

## 5. Module design

| Child module | Main input variables | Outputs | Simulated resource |
|---|---|---|---|
| `modules/network` | `network_name`, `subnet_cidr`, `gateway_ip` | `network_info`, `network_id` | `terraform_data.network_config` |
| `modules/server` | `server_name`, `server_cpu`, `server_ram`, `network_info` | `server_info`, `server_id` | `terraform_data.server_config` |
| `modules/application` | `application_name`, `application_port`, `server_info` | `application_info`, `application_id` | `terraform_data.application_config` |

### Reusable server instances

In each root module, `for_each` turns the server inventory into module instances:

```hcl
module "server" {
  source   = "../../modules/server"
  for_each = var.servers

  server_name  = each.value.name
  server_cpu   = local.server_profiles[each.value.profile].cpu
  server_ram   = local.server_profiles[each.value.profile].ram
  network_info = module.network.network_info
}
```

The inventory is declared in `servers.auto.tfvars`. For example:

```hcl
servers = {
  dev01 = {
    name    = "ubuntu-dev-01"
    profile = "standard"
  }
}
```

The CPU/RAM profiles are defined in each environment's `locals.tf`. This separates **server inventory** from **resource sizing policy**.

### Implicit dependencies between modules

A root module passes Network output into Server and Server output into Application:

```hcl
# Inside module "server":
network_info = module.network.network_info

# Inside module "application" for DEV:
server_info = module.server["dev01"].server_info
```

Terraform derives the required dependency relationships from those references without an explicit `depends_on` block.

### Preserving an existing server with `moved`

DEV initially used one `module.server` instance. When switching to `for_each`, `environments/dev/moved.tf` preserved the existing server identity:

```hcl
moved {
  from = module.server
  to   = module.server["dev01"]
}
```

The migration plan was:

```text
Plan: 0 to add, 0 to change, 0 to destroy.
```

The `dev01` simulated resource ID stayed unchanged after migration. Keep the `moved` block in version control to document that address change.

## 6. Deployment and verification

**Requirements:** Terraform CLI and Windows PowerShell. No ESXi/vCenter VM or AWS account is required to run this simulation.

Run Terraform **from the root directory of the environment you want to manage**.

### DEV

```powershell
cd C:\Terraform-Labs\LAB08MODULEARCH\environments\dev
terraform init
terraform validate
terraform plan
terraform apply
```

### TEST

```powershell
cd C:\Terraform-Labs\LAB08MODULEARCH\environments\test
terraform init
terraform validate
terraform plan
terraform apply
```

### PROD

```powershell
cd C:\Terraform-Labs\LAB08MODULEARCH\environments\prod
terraform init
terraform validate
terraform plan
terraform apply
```

Check a selected environment:

```powershell
terraform state list
terraform plan
terraform graph
```

`terraform graph` prints Graphviz DOT output; Graphviz is only required if you want to render the DOT into an image.

## 7. Verified lab results

| Environment | Network resources | Server resources | Application resources | Total | Final plan |
|---|---:|---:|---:|---:|---|
| DEV | 1 | 4 | 1 | 6 | No changes |
| TEST | 1 | 2 | 1 | 4 | No changes |
| PROD | 1 | 2 | 1 | 4 | No changes |
| **Total** | **3** | **8** | **3** | **14** | **Verified** |

Each environment's final Terraform Plan returned:

```text
No changes. Your infrastructure matches the configuration.
```

**Important:** All 14 resources are Terraform simulations. The server CPU/RAM values are configuration metadata, not resources consumed by running virtual machines.

## 8. State and Git practices

- Keep DEV, TEST, and PROD State separate.
- Do not commit `terraform.tfstate`, `*.tfstate.backup`, or `.terraform/`.
- Do not commit secrets or credential-bearing variable files.
- Commit reusable module source code, root configuration, non-sensitive inventories, and this README.
- Review `terraform plan` before any `terraform apply`, especially for real infrastructure.

## 9. Conclusion

LAB08 combines the concepts from previous labs into a reusable infrastructure design: **modules, `for_each`, configuration profiles, TFVARS, implicit dependencies, isolated State, and State migration with `moved`**.

The next step is to adapt this structure for a real infrastructure provider such as VMware vSphere or AWS, after validating connectivity, credentials, capacity, and cost.

**LAB08 status: Completed.**
