#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

NEW_TAG=$(cat VERSION)

# Tag the new version
git tag "$NEW_TAG"

# Push the new tag to the repository
git push origin "$NEW_TAG"