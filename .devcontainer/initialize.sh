#!/bin/bash
set -e

# Generate .env file for devcontainer from host's gh CLI
# This script runs on the host machine.

TOKEN_FILE="$(dirname "$0")/.env"

if command -v gh &> /dev/null && gh auth status &> /dev/null; then
    echo "Fetching GitHub CLI token from host..."
    TOKEN=$(gh auth token)
    echo "GH_TOKEN=$TOKEN" > "$TOKEN_FILE"
    echo "GITHUB_TOKEN=$TOKEN" >> "$TOKEN_FILE"
    echo "Successfully generated $TOKEN_FILE"
else
    echo "Warning: GitHub CLI is not installed or not logged in on the host."
    echo "# GitHub CLI token not found" > "$TOKEN_FILE"
fi
