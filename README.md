# Repository Constructor

A Terraform-based tool for managing GitHub repositories using Dev Container.

## Features

- **Dev Container Powered**: Environment managed by `devcontainer` CLI with `tenv` (Terraform version manager), `tflint`, and `checkov`.
- **Workspace-based Management**: Each workspace in Terraform corresponds to a GitHub repository name.
- **Branch Protection**: Automatically protects the `main` branch (disallows force pushes and deletions).
- **Security Features**: Enables Dependabot alerts, Dependabot security updates, CodeQL analysis (Code Scanning), Secret Scanning, and Secret Scanning Push Protection.
- **Git-managed State**: Terraform state files are tracked by Git for simplicity (intended for personal use).

## Prerequisites

- [Docker](https://www.docker.com/)
- [devcontainer CLI](https://github.com/devcontainers/cli)
- [GitHub CLI (gh)](https://cli.github.com/) authenticated on your host machine.

## Getting Started

1. Authenticate with GitHub CLI on your host:
   ```bash
   gh auth login
   ```

2. Start the Dev Container:
   ```bash
   devcontainer up --workspace-folder .
   devcontainer exec --workspace-folder . /bin/zsh
   ```

3. Initialize Terraform (Inside the container):
   ```bash
   cd src
   terraform init
   ```

## Creating a New Repository

1. Create a new Terraform workspace (this will be the repository name):
   ```bash
   cd src
   terraform workspace new my-awesome-repo
   ```

2. Plan and Apply:
   ```bash
   terraform plan
   terraform apply
   ```

## Linting and Security

- **Formatting**: `terraform fmt` (run inside `src/` to format HCL files)
- **TFLint**: `tflint`
- **Checkov**: `checkov -d .`

## Important Notes

- **State Management**: State files are NOT ignored by `.gitignore`. This repository tracks them in Git.
- **Locking**: No state locking is implemented as this is intended for single-user scenarios.

## Configuration (Map Strategy)

This project uses a **Map Strategy** in `src/main.tf` to manage per-workspace configurations. Instead of using external `.tfvars` files, settings are defined in the `locals` block.

### How to Configure
Modify `src/main.tf` to add your repository-specific settings:

```hcl
locals {
  workspace_config = {
    # Add your repository here
    docgraph = { manage_files = false }
  }
}
```

- **`manage_files` (bool)**:
    - `true` (Default): For **new repositories**. Terraform manages CI/CodeQL files.
    - `false`: For **existing repositories** (like `docgraph`). Terraform imports the repository but leaves files untouched to avoid conflicts with Rulesets.
