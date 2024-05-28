#!/bin/bash
# Upload release artifacts
# From http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

CI_API_V4_URL="${CI_API_V4_URL:-https://gitlab.accenturefederaldev.com/api/v4}"
CI_PROJECT_ID="${CI_PROJECT_ID:-21}"

PACKAGE_VERSION=$1
PACKAGE=$2
FILENAME="$(basename "$3")"

curl --header "PRIVATE-TOKEN: ${CI_JOB_TOKEN}" \
     --upload-file "${3}" \
     --header "Content-Type: multipart/form-data" \
     "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/generic/${PACKAGE}/${PACKAGE_VERSION}/${FILENAME}"