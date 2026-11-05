# LAB08 - Terraform Modular Infrastructure Architecture

## 1. Overview

LAB08 demonstrates a reusable Terraform infrastructure architecture using Root Modules, Child Modules, `for_each`, variables, CPU/RAM profiles, and inter-module dependencies.

The lab simulates infrastructure across three independent environments:

- **DEV** - Development

- **TEST** - Testing

- **PROD** - Production

All resources are simulated using Terraform's built-in `terraform_data` resource.

**No real virtual machines, networks, databases, or cloud resources are deployed.**

## 2. Learning Objectives

- Build reusable Terraform Child Modules.

- Organize infrastructure using Root Modules.

- Manage multiple environments independently.

- Use `for_each` to deploy multiple server instances.

- Standardize CPU/RAM configurations using profiles.

- Store server inventory in `.auto.tfvars` files.

- Implement implicit dependencies between modules.

- Use `moved` blocks for safe State migration.

- Maintain separate Terraform State files for DEV, TEST, and PROD.

## 3. Infrastructure Architecture

The infrastructure consists of three reusable Child Modules:

1. **Network Module** - Simulates network configuration.

2. **Server Module** - Simulates server provisioning.

3. **Application Module** - Simulates application deployment.

### Module Dependency Flow

```text
              ROOT MODULE
                   |
                   v
            NETWORK MODULE
                   |
                   | network_info
                   v
             SERVER MODULE
                   |
                   | server_info
                   v
```

Terraform automatically detects dependencies through module output references.

### Multi-Environment Architecture

```text
                 SHARED MODULES
              Network / Server / App
                        |
          +-------------+-------------+
          |             |             |
          v             v             v
      DEV ROOT      TEST ROOT      PROD ROOT
          |             |             |
          v             v             v
      DEV STATE     TEST STATE     PROD STATE
          |             |             |
```

Each environment is deployed independently.

## 4. Project Structure

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
```

Terraform State files and `.terraform/` directories are excluded from Git.

## 5. Environment Configuration

| Environment | Network | Subnet | Gateway | Servers | Resources |
|---|---|---|---|---:|---:|
| DEV | dev-network | 192.168.50.0/24 | 192.168.50.1 | 4 | 6 |
| TEST | test-network | 192.168.60.0/24 | 192.168.60.1 | 2 | 4 |
| PROD | prod-network | 192.168.70.0/24 | 192.168.70.1 | 2 | 4 |
| **Total** | **3 Networks** | | | **8** | **14** |

Each environment contains:

- One Network resource.

- Multiple Server resources.

- One Application resource.

## 6. Server Inventory

### DEV Environment

| Server | Profile | CPU | RAM |
|---|---|---:|---:|
| ubuntu-dev-01 | standard | 1 vCPU | 2048 MB |
| ubuntu-dev-02 | standard | 1 vCPU | 2048 MB |
| ubuntu-db-01 | database | 4 vCPU | 8192 MB |
| ubuntu-mon-01 | monitoring | 2 vCPU | 4096 MB |

Application: `nginx-web`

Port: `8080`

### TEST Environment

| Server | Profile | CPU | RAM |
|---|---|---:|---:|
| ubuntu-test-01 | standard | 2 vCPU | 6144 MB |
| ubuntu-test-db-01 | database | 4 vCPU | 8192 MB |

Application: `nginx-web-test`

Port: `8080`

### PROD Environment

| Server | Profile | CPU | RAM |
|---|---|---:|---:|
| ubuntu-prod-01 | standard | 4 vCPU | 8192 MB |
| ubuntu-prod-db-01 | database | 8 vCPU | 16384 MB |

Application: `nginx-web-prod`

Port: `8080`

## 7. Terraform Module Design

### 7.1 Network Module

The Network Module receives:

- `network_name`

- `subnet_cidr`

- `gateway_ip`

It exposes:

- `network_info`

- `network_id`

The Server Module receives `network_info` through a Root Module reference.

### 7.2 Server Module

The Server Module receives:

- `server_name`

- `server_cpu`

- `server_ram`

- `network_info`

It exposes:

- `server_info`

- `server_id`

The Root Module uses `for_each` to create multiple instances from the inventory.

### 7.3 Application Module

The Application Module receives:

- `application_name`

- `application_port`

- `server_info`

It exposes:

- `application_info`

- `application_id`

The Application Module uses Server Module output to establish an implicit dependency.

## 8. Important Terraform Concepts

### 8.1 Reusable Modules

The three Child Modules are shared across all environments.

This reduces duplicated Terraform configuration and makes infrastructure easier to maintain.

### 8.2 for_each

The Server Module uses:

```hcl
```

Each server has a stable key, such as:

- `dev01`

- `dev02`

- `db01`

- `mon01`

This allows new servers to be added without recreating existing instances.

### 8.3 Server Profiles

CPU and RAM settings are defined in `locals.tf`.

Example:

```hcl
server_profiles = {
  standard = {
    cpu = 1
    ram = 2048
  }
  database = {
    cpu = 4
    ram = 8192
  }
  monitoring = {
    cpu = 2
    ram = 4096
  }
```

Each environment can use different resource profiles.

### 8.4 Server Inventory

Server inventory is stored in `servers.auto.tfvars`.

Example:

```hcl
servers = {
  dev01 = {
    name    = "ubuntu-dev-01"
    profile = "standard"
  }
```

Terraform automatically loads `.auto.tfvars` files.

### 8.5 Implicit Dependencies

The Root Module connects Network and Server:

```hcl
```

The Application Module receives Server information:

```hcl
```

These references allow Terraform to determine the required creation order.

### 8.6 State Isolation

Each environment has its own Root Module and local Terraform State.

Benefits include:

- DEV changes do not directly modify TEST State.

- TEST changes do not directly modify PROD State.

- Each environment can be planned and applied independently.

- State management is easier to control.

### 8.7 State Migration

DEV originally used a single Server Module.

The module was migrated to `for_each` using:

```hcl
moved {
  from = module.server
  to   = module.server\["dev01"]
```

Terraform successfully preserved the existing Server resource ID.

Migration result:

```text
```

## 9. Deployment Guide

### Requirements

- Terraform CLI

- Windows PowerShell

- Git

No VMware, AWS, or Ubuntu VM is required.

### Deploy DEV

```powershell
cd C:\\Terraform-Labs\\LAB08MODULEARCH\\environments\\dev
terraform init
terraform fmt
terraform validate
terraform plan
```

### Deploy TEST

```powershell
cd C:\\Terraform-Labs\\LAB08MODULEARCH\\environments\\test
terraform init
terraform validate
terraform plan
```

### Deploy PROD

```powershell
cd C:\\Terraform-Labs\\LAB08MODULEARCH\\environments\\prod
terraform init
terraform validate
terraform plan
```

### Verification Commands

```powershell
terraform state list
terraform plan
```

Run these commands from the relevant environment directory.

## 10. Final Lab Results

| Environment | Network | Servers | Application | Total |
|---|---:|---:|---:|---:|
| DEV | 1 | 4 | 1 | 6 |
| TEST | 1 | 2 | 1 | 4 |
| PROD | 1 | 2 | 1 | 4 |
| **Total** | **3** | **8** | **3** | **14** |

### Verified Results

**DEV**

```text
6 resources
```

**TEST**

```text
4 resources
```

**PROD**

```text
4 resources
```

All three environments were deployed successfully.

## 11. Security and Git Management

The following files must not be committed:

- `terraform.tfstate`

- `terraform.tfstate.backup`

- `.terraform/`

- Files containing passwords, tokens, or secrets

Non-sensitive infrastructure configuration files can be committed to Git.

Terraform State is maintained independently for each environment.

## 12. Conclusion

LAB08 successfully demonstrates a modular Terraform infrastructure architecture with:

- 3 reusable Child Modules.

- 3 independent environments.

- 8 simulated servers.

- 3 simulated networks.

- 3 simulated applications.

- 14 managed Terraform resources.

- Profile-driven infrastructure configuration.

- Implicit module dependencies.

- Safe State migration using `moved`.

The architecture provides a foundation for future Terraform automation using VMware vSphere and AWS.

**LAB08 Status: Completed**
