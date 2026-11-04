# LAB07 - Terraform Lifecycle & Dependencies

## Overview

This lab demonstrates Terraform resource lifecycle management and dependency handling using local_file and terraform_data resources.

All resources are simulations. No VMware virtual machines, cloud infrastructure, or databases are deployed.

## Learning Objectives

- Understand resource creation, update, replacement and deletion.
- Test create_before_destroy.
- Protect resources using prevent_destroy.
- Control attribute changes using ignore_changes.
- Understand explicit and implicit dependencies.
- Inspect Terraform State and Dependency Graph.

## Lab Structure

LAB07LIFECYCLE/
    ├── main.tf
    ├── replacement.tf
    ├── ignore_changes.tf
    ├── depends_on.tf
    ├── implicit_dependency.tf
    └── README.md

## Lifecycle Tests

| Feature | Test Result |
|---------|-------------|
| Create Resource | Passed |
| Resource Replacement | Passed |
| Update In-Place | Passed |
| create_before_destroy | Passed |
| prevent_destroy | Passed |
| ignore_changes | Passed |
| Explicit Dependency | Passed |
| Implicit Dependency | Passed |
| Dependency Graph | Passed |

## Dependency Architecture

Explicit Dependency:

Network Setup
         |
         v
    Application Deployment

Implicit Dependency:

Database Setup
         |
         v
    Backend Service

Explicit dependencies are declared using depends_on.

Implicit dependencies are automatically detected through resource references.

## Current Lab State

The lab manages seven simulated resources.

- One local_file resource
- Six terraform_data resources

The application settings contain log_level = DEBUG.

The deployment resource uses release-v2 and is protected by prevent_destroy.

Final verification:

terraform state list
    terraform plan
    terraform graph

Expected plan result:

No changes. Your infrastructure matches the configuration.

## Important Notes

- create_before_destroy does not guarantee zero downtime.
- prevent_destroy blocks planned destruction while the rule remains in configuration.
- ignore_changes can cause differences between configuration and managed state.
- depends_on controls execution ordering, not application readiness.
- Terraform State and generated files must not be committed to Git.

## Conclusion

LAB07 demonstrates how Terraform manages resource lifecycles and dependencies.

These concepts provide a foundation for future infrastructure automation using VMware vSphere and AWS.
