variable "description" {
  type        = string
  description = "The description of the repository"
  default     = "Repository managed by terraform"
}

variable "manage_files" {
  type        = bool
  description = "Whether to manage repository files via Terraform"
  default     = true
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

    required_status_checks {
      strict_required_status_checks_policy = true
      # checkov:skip=CKV_GIT_5:PR-only flow without approvals is intended for solo development
      # checkov:skip=CKV_GIT_6:Signed commits are not required for personal development
      required_check {
        context = "Analyze (actions)" # Match CodeQL job name
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
  count = var.manage_files ? 1 : 0

  repository          = github_repository.repo.name
  branch              = "main"
  file                = ".github/workflows/ci.yml"
  content             = <<EOF
name: CI
on: [push, pull_request]
jobs:
  build:
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
  count = var.manage_files ? 1 : 0

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
        language: [ 'actions' ]

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
