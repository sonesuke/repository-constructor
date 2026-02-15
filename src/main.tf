variable "description" {
  type        = string
  description = "The description of the repository"
  default     = "Repository managed by terraform"
}

locals {
  # Configuration map per workspace
  workspace_config = {
    docgraph = {
      manage_files          = false
      codeql_languages      = ["actions", "rust", "javascript-typescript"]
      dependabot_ecosystems = ["npm", "cargo", "github-actions"]
    }
  }

  # Default configuration
  default_config = {
    manage_files          = true
    codeql_languages      = ["actions"]
    ci_checks             = ["Build & Verify"]
    dependabot_ecosystems = ["github-actions"]
  }

  # Merge default config with workspace specific config
  config = merge(local.default_config, lookup(local.workspace_config, terraform.workspace, {}))
}

resource "github_repository" "repo" {
  name        = terraform.workspace
  description = var.description
  # checkov:skip=CKV_GIT_1:Repository is intended to be public per user requirement
  visibility = "public"

  has_issues   = true
  has_projects = false
  has_wiki     = false
  auto_init    = true

  delete_branch_on_merge = true

  vulnerability_alerts = true

  lifecycle {
    ignore_changes = [
      description,
      homepage_url,
      topics,
      has_issues,
      has_projects,
      has_wiki,
      auto_init,
    ]
  }

  pages {
    source {
      branch = "main"
    }
  }

  security_and_analysis {
    secret_scanning {
      status = "enabled"
    }
    secret_scanning_push_protection {
      status = "enabled"
    }
  }
}

resource "github_repository_ruleset" "main" {
  name        = "main-protection"
  repository  = github_repository.repo.name
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["refs/heads/main"]
      exclude = []
    }
  }

  rules {
    creation                = false
    update                  = false
    deletion                = true
    non_fast_forward        = true
    required_linear_history = true

    pull_request {
      required_approving_review_count   = 0
      dismiss_stale_reviews_on_push     = false
      require_code_owner_review         = false
      require_last_push_approval        = false
      required_review_thread_resolution = false
    }

    dynamic "required_status_checks" {
      for_each = length(concat(local.config.ci_checks, local.config.codeql_languages)) > 0 ? [1] : []
      content {
        strict_required_status_checks_policy = true

        # Customize CI checks
        dynamic "required_check" {
          for_each = local.config.ci_checks
          content {
            context = required_check.value
          }
        }

        # Customize CodeQL checks
        dynamic "required_check" {
          for_each = local.config.codeql_languages
          content {
            context = "Analyze (${required_check.value})"
          }
        }
      }
    }

    required_code_scanning {
      required_code_scanning_tool {
        tool                      = "CodeQL"
        security_alerts_threshold = "high_or_higher"
        alerts_threshold          = "errors_and_warnings"
      }
    }
  }
}

resource "github_repository_dependabot_security_updates" "repo" {
  repository = github_repository.repo.name
  enabled    = true
}

# Example of initial file: .github/workflows/ci.yml
resource "github_repository_file" "ci" {
  count = local.config.manage_files ? 1 : 0

  repository          = github_repository.repo.name
  branch              = "main"
  file                = ".github/workflows/ci.yml"
  content             = <<EOF
name: CI
on: [push, pull_request]
jobs:
  verify:
    name: Build & Verify
    runs-on: ubuntu-latest
    permissions:
      contents: read
    steps:
      - run: echo "CI is running and always passing!"
EOF
  commit_message      = "chore: add default CI workflow"
  overwrite_on_create = true

  lifecycle {
    ignore_changes = [
      content,
      commit_message,
    ]
  }

  depends_on = [github_repository.repo]
}
# Example of initial file: .github/workflows/codeql.yml
resource "github_repository_file" "codeql" {
  count = local.config.manage_files ? 1 : 0

  repository          = github_repository.repo.name
  branch              = "main"
  file                = ".github/workflows/codeql.yml"
  content             = <<EOF
name: "CodeQL"

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]
  schedule:
    - cron: '30 1 * * 0'

jobs:
  analyze:
    name: Analyze
    runs-on: ubuntu-latest
    permissions:
      actions: read
      contents: read
      security-events: write

    strategy:
      fail-fast: false
      matrix:
        language: ${jsonencode(local.config.codeql_languages)}

    steps:
    - name: Checkout repository
      uses: actions/checkout@v4

    - name: Initialize CodeQL
      uses: github/codeql-action/init@v4
      with:
        languages: $${{ matrix.language }}

    - name: Autobuild
      uses: github/codeql-action/autobuild@v4

    - name: Perform CodeQL Analysis
      uses: github/codeql-action/analyze@v4
      with:
        category: "/language:$${{matrix.language}}"
EOF
  commit_message      = "chore: add CodeQL analysis workflow"
  overwrite_on_create = true

  lifecycle {
    ignore_changes = [
      content,
      commit_message,
    ]
  }

  depends_on = [github_repository.repo]
}

# Example of initial file: .github/dependabot.yml
resource "github_repository_file" "dependabot" {
  count = local.config.manage_files ? 1 : 0

  repository = github_repository.repo.name
  branch     = "main"
  file       = ".github/dependabot.yml"
  content = yamlencode({
    version = 2
    updates = [
      for ecosystem in local.config.dependabot_ecosystems : {
        package-ecosystem = ecosystem
        directory         = "/"
        schedule = {
          interval = "weekly"
        }
        groups = {
          all-dependencies = {
            patterns = ["*"]
          }
        }
      }
    ]
  })
  commit_message      = "chore: add dependabot configuration"
  overwrite_on_create = true

  lifecycle {
    ignore_changes = [
      content,
      commit_message,
    ]
  }

  depends_on = [github_repository.repo]
}
