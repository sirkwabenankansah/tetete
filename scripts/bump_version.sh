#!/bin/bash
# This script creates a release branch and sets the version in the files of
# the branch
# The version in 1.YYYYMMDD.N

# From http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'
GREEN='\033[0;32m'
NC='\033[0m'
DONE="[ ${GREEN}DONE${NC} ]"

# Fetch the latest tag
LATEST_TAG=$(git describe --tags "$(git rev-list --tags --max-count=1)")

MAJOR=${LATEST_TAG%%.*}

_TAG_DATE=${LATEST_TAG#*.}

# Extract the date part of the latest tag
LATEST_DATE=${_TAG_DATE%.*}

# Extract the increment part of the latest tag
LATEST_INCREMENT=${LATEST_TAG##*.}

# Get today's date
DATE=$(date +"%Y%m%d")

# Check if the latest tag date matches today's date
if [ "$LATEST_DATE" = "$DATE" ]; then
  # If the dates match, increment the version
  NEW_INCREMENT=$((LATEST_INCREMENT + 1))
else
  # If the dates do not match, start with increment 1
  NEW_INCREMENT=1
fi

# Store the newest version
NEW_VERSION="${MAJOR}.${DATE}.${NEW_INCREMENT}"

# Update VERSION
echo -n "Updating VERSION in repo..."
echo "$NEW_VERSION" > VERSION
echo -e "${DONE}"

# Update layer4_stratus version
echo -n "Updating stratus package version..."
(
  cd ./src/layer4_stratus/
  # Try running sed as macos or as linux
  sed -i "s/^\( version:\).*/\1 ${NEW_VERSION}/" zarf.yaml || sed -i "" "s/^\( version:\).*/\1 ${NEW_VERSION}/" zarf.yaml
)
echo -e "${DONE}"