#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Fetch the zarf version
ZARF_VERSION=$(zarf version)
# Fetch the latest tag
LATEST_TAG=$(git describe --tags "$(git rev-list --tags --max-count=1)")

MAJOR=${LATEST_TAG%%.*}
MAJOR=${MAJOR#v}

# Get today's date
DATE=$(date +"%Y%m%d")

# Extract the date part of the latest tag
LATEST_DATE=$(echo "$LATEST_TAG" | cut -d'.' -f2)

# Extract the increment part of the latest tag
LATEST_INCREMENT=$(echo "$LATEST_TAG" | cut -d'.' -f3)

# Check if the latest tag date matches today's date
if [ "$LATEST_DATE" = "$DATE" ]; then
 # If the dates match, increment the version
 NEW_INCREMENT=$((LATEST_INCREMENT + 1))
else
 # If the dates do not match, start with increment 1
 NEW_INCREMENT=1
fi

# Create the new version tag
NEW_TAG="v${MAJOR}.$DATE.$NEW_INCREMENT"

# echo "Creating platform compatible package"
# (
#   cd ./src/platform_compatible
#   make package
# )

echo "Creating zarf init package"
(
 cd ./src/layer3_bootstrap/
 echo "$REGISTRY1_CLI_SECRET" | zarf tools registry login registry1.dso.mil --username "$REGISTRY1_USERNAME" --password-stdin
 make ensure-build-dir
 make install-node-deps
 make build-module
 make aws-init-package
)

./scripts/artifact_upload.sh "$NEW_TAG" zarf-init-amd64-package "${CI_PROJECT_DIR}/src/layer3_bootstrap/build/zarf-init-amd64-v0.32.6.tar.zst"

echo "Creating zarf stratus package"
(
 cd ./src/layer4_stratus/
 # Try running sed as macos or as linux
 echo "$REGISTRY1_CLI_SECRET" | zarf tools registry login registry1.dso.mil --username "$REGISTRY1_USERNAME" --password-stdin
 make build-package
)

./scripts/artifact_upload.sh "$NEW_TAG" zarf-stratus-package "${CI_PROJECT_DIR}/src/layer4_stratus/build/zarf-package-stratus-amd64-${NEW_TAG}.tar.zst"

echo "Creating stratus container image"
(
 VERSION="${NEW_TAG}" make build-and-save
)

./scripts/artifact_upload.sh "$NEW_TAG" stratus-container-image "${CI_PROJECT_DIR}/dist/stratus-${NEW_TAG}.tar.xz"

# Create the release using the GitLab Release API
RELEASE_NAME="$NEW_TAG"
RELEASE_DESCRIPTION="Automated release for version $NEW_TAG"

curl --request POST --header "PRIVATE-TOKEN: ${CI_JOB_TOKEN}" \
 --data "name=${RELEASE_NAME}" \
 --data "tag_name=${NEW_TAG}" \
 --data "description=${RELEASE_DESCRIPTION}" \
 --data "assets[links][][name]=Stratus-Container-Image" \
 --data "assets[links][][url]=${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/generic/stratus-container-image/${NEW_TAG}/stratus-${NEW_TAG}.tar.xz" \
 --data "assets[links][][link_type]=image" \
 --data "assets[links][][name]=Zarf-Init-AMD64-Package" \
 --data "assets[links][][url]=${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/generic/zarf-init-amd64-package/${NEW_TAG}/zarf-init-amd64-${ZARF_VERSION}.tar.zst" \
 --data "assets[links][][link_type]=package" \
 --data "assets[links][][name]=Zarf-Stratus-Package" \
 --data "assets[links][][url]=${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/generic/zarf-stratus-package/${NEW_TAG}/zarf-package-stratus-amd64-${NEW_TAG}.tar.zst" \
 --data "assets[links][][link_type]=package" \
 "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/releases?ref=main"

# Output the new tag
echo "New release created: $NEW_TAG"