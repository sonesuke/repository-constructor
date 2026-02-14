terraform {
  required_version = ">= 1.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }

  backend "local" {
    # .tfstate will be stored in the repository and managed by Git
    # Workspace specific states will be in terraform.tfstate.d/<workspace>/terraform.tfstate
  }
}

provider "github" {
  # Token will be provided via GITHUB_TOKEN environment variable
}
