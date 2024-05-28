#!/bin/bash

# This script creates a release branch and sets the version in the files of
# the branch

# The version in 1.YYYYMMDD.N

# From http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

# Fetch the latest tag
LATEST_TAG=$(git describe --tags "$(git rev-list --tags --max-count=1)")
MAJOR=${LATEST_TAG%%.*}

# Get today's date
DATE=$(date +"%Y%m%d")

git fetch origin
git branch "release/${MAJOR}.${DATE}" origin/develop || :
git checkout "release/${MAJOR}.${DATE}"
git merge origin/develop
git remote -vv

./scripts/bump_version.sh

# disable precommit
git commit -m "chore: bump release" --no-verify VERSION ./src/layer4_stratus/zarf.yaml || :
git push origin "HEAD:release/${MAJOR}.${DATE}" -o ci.skip