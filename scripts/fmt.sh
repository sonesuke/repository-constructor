#!/usr/bin/env bash
# Format Terraform and Nix files.
set -euo pipefail
cd "$(dirname "$0")/.."

terraform fmt -recursive src
nix fmt
