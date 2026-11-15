# Repository Constructor

Manage personal GitHub repositories with Terraform. Each Terraform workspace is one GitHub repository.

What gets created for each repository (repository settings, `main` ruleset, security features, initial workflow files) is defined in [`src/main.tf`](src/main.tf).

## Prerequisites

- [Nix](https://nixos.org/) with flakes enabled.
- `gh` and `git` on your machine (not part of the dev shell), with `gh auth login` done. The GitHub provider picks up the `gh` token.

## Dev Environment

With [direnv](https://direnv.net/) and [nix-direnv](https://github.com/nix-community/nix-direnv), the dev shell loads automatically in your current shell on `cd` (see [`.envrc`](.envrc)). Run `direnv allow` once. Without direnv, use `nix develop` (always starts bash; use `nix develop -c zsh` for zsh).

Tools are defined in [`flake.nix`](flake.nix). It permits an insecure `ecdsa` version required by `checkov`; update `permittedInsecurePackages` when nixpkgs bumps it.

## Adding a Repository

1. Add an entry to `workspace_config` in [`src/main.tf`](src/main.tf). It is merged over `default_config` in the same file.
2. Create the workspace and apply:

   ```bash
   cd src
   terraform init
   terraform workspace new <repository-name>
   terraform apply
   ```

3. Commit `src/main.tf` and `src/terraform.tfstate.d/<repository-name>/`.

Notes:

- `manage_files = false` leaves workflow files to the repository itself. Use it for existing repositories or ones that maintain their own workflows.
- The ruleset requires the `ci_checks` status checks. The repository needs a job with that name, or pull requests cannot be merged.

## State

State is committed to Git on purpose (`src/terraform.tfstate.d/`). There is no locking; this setup is for a single user. Applying with a newer Terraform upgrades the version recorded in state.

## Conventions

- Before committing, run [`scripts/fmt.sh`](scripts/fmt.sh) and [`scripts/lint.sh`](scripts/lint.sh) inside the dev shell.
- New resources must work per workspace (`terraform.workspace` is the repository name).
- Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/).
- Documentation is written in English.
