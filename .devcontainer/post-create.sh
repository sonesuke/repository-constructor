#!/bin/bash
set -e


# Install Checkov for infrastructure security scanning
# Using --break-system-packages because this is a dedicated dev container environment
pip3 install --no-cache-dir checkov --break-system-packages

# Install latest Terraform
export TENV_AUTO_INSTALL=true
tenv tf install latest
tenv tf use latest

echo "Post-create setup completed successfully."
