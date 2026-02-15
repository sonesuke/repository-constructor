# Agent Context: Repository Constructor

This file provides essential information for AI agents working on this repository.

## Project Overview

This repository uses Terraform to automate the creation and management of GitHub repositories. It is designed to run within a Dev Container using the `devcontainer` CLI.

## Tech Stack & Tools

- **Terraform Version Management**: Managed by `tenv`.
- **Infrastructure as Code**: Terraform with `integrations/github` provider.
- **Backend**: `local` backend with state files tracked by Git (for solo use).
- **Environment**: Dev Container (see `.devcontainer/Dockerfile`).
- **Linter**: `tflint`.
- **Security**: `checkov`.


## Core Logic & Workflows

### Workspace-as-Repository
- All Terraform files are located in the `src/` directory.
- Each Terraform workspace corresponds to a distinct GitHub repository.
- `src/main.tf` uses `terraform.workspace` for the `github_repository` name.

### State Persistence
- `.tfstate` files are **NOT** ignored by Git. They are stored in `src/terraform.tfstate.d/` (and potentially `src/terraform.tfstate`) and tracked to maintain state across different environments.

### Authentication
- The GitHub provider natively supports GitHub CLI (`gh`) authentication. No manual token export is required as long as you are logged in via `gh auth login`.

## Instruction for Agents

- Always use the `devcontainer` CLI workflow for testing.
- Follow Conventional Commits for all commit messages.
- Use `terraform fmt` to maintain consistent HCL style.
- Maintain documentation (README, Walkthrough, etc.) in English.
- When adding new infrastructure resources, ensure they are compatible with the workspace-based separation.
