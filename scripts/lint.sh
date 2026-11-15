#!/usr/bin/env bash
# Check formatting and run linters for Terraform and Nix files.
set -euo pipefail
cd "$(dirname "$0")/.."

echo "==> terraform fmt"
terraform fmt -check -recursive src

echo "==> nixfmt"
git ls-files -z '*.nix' | xargs -0 nixfmt --check

echo "==> tflint"
tflint --chdir=src

echo "==> checkov"
checkov -d src --quiet --compact

echo "==> statix"
statix check .

echo "==> deadnix"
deadnix --fail .

echo "==> actionlint"
actionlint
