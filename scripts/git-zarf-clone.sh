#!/bin/bash
set -euo pipefail

REPO_NAME="${1:?You must specify the name of the repo}"
shift
LOCATION="${1:-$REPO_NAME}"
shift

# run a tunnel to zarf gitea
coproc zarffd {
    zarf connect git --no-color \
        --no-log-file \
        --no-progress \
        --log-level warn \
        --cli-only
}

zarf_output=""

# wait for the tunnel to become available
set +e
while true; do
    IFS= read -r -t 2 line
    zarf_output+="$line"
    if echo "$zarf_output" | grep -q "127.0.0.1"; then
        break
    fi
done <&"${zarffd[0]}"
set -e

# get the tunnel port
gitea_port=${zarf_output##*:}

# Set your Gitea server URL
gitea_host="localhost:$gitea_port"

# get the password
git_password=$(zarf tools get-creds git --no-color --no-log-file --no-progress --log-level warn)

git_credentials="zarf-git-user:${git_password}"

# Search for repositories containing "$REPO_NAME"
SEARCH_RESULTS=$(curl -s -u "$git_credentials" "http://$gitea_host/api/v1/repos/search?q=$REPO_NAME")

# Extract repository names from the search results
REPO_NAMES=$(echo "$SEARCH_RESULTS" | jq -r '.data[].full_name')

git_url="http://$git_credentials@$gitea_host/$REPO_NAMES"

# shellcheck disable=SC2068
git clone "$git_url" $@ "$LOCATION"

# TODO: make sure zarf process gets terminated, this isn't working
# shellcheck disable=SC2154
pkill --parent "$zarffd_PID" || :
kill "$zarffd_PID" || :