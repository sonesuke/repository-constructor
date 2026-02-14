# Repository Constructor

A Terraform-based tool for managing GitHub repositories using Dev Container.

## Features

- **Dev Container Powered**: Environment managed by `devcontainer` CLI with `tenv` (Terraform version manager), `tflint`, `checkov`, and `commitlint`.
- **Workspace-based Management**: Each workspace in Terraform corresponds to a GitHub repository name.
- **Branch Protection**: Automatically protects the `main` branch (disallows force pushes and deletions).
- **Security Features**: Enables Dependabot alerts, Dependabot security updates, CodeQL analysis (Code Scanning), Secret Scanning, and Secret Scanning Push Protection.
- **Git-managed State**: Terraform state files are tracked by Git for simplicity (intended for personal use).
- **Conventional Commits**: Enforced via `commitlint`.

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
- **Commitlint**: `commitlint --from HEAD~1` (checks the latest commit)

## Important Notes

- **State Management**: State files are NOT ignored by `.gitignore`. This repository tracks them in Git.
- **Locking**: No state locking is implemented as this is intended for single-user scenarios.
