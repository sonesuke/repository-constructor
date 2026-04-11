#!/bin/bash
set -e

docker run -d \
  --name repository-constructor \
  -v "$(pwd):/workspaces/repository-constructor" \
  -v "${HOME}/.config/gh:/home/user/.config/gh" \
  -e Z_AI_API_KEY="${Z_AI_API_KEY}" \
  repository-constructor:latest \
  sleep infinity
