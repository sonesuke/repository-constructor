FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# Install tenv (Terraform, Terragrunt, OpenTofu version manager)
RUN TENV_VERSION=$(curl -s https://api.github.com/repos/tofuutils/tenv/releases/latest | grep tag_name | cut -d '"' -f 4) \
    && ARCH=$(uname -m) \
    && if [ "$ARCH" = "x86_64" ]; then ARCH="x86_64"; elif [ "$ARCH" = "aarch64" ]; then ARCH="arm64"; fi \
    && curl -L -s "https://github.com/tofuutils/tenv/releases/download/${TENV_VERSION}/tenv_${TENV_VERSION}_Linux_${ARCH}.tar.gz" | tar -xz -C /usr/local/bin

# Install TFLint
RUN curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

# Setup tenv for terraform
RUN tenv tf install latest
