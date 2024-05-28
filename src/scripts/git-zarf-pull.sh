#!/bin/bash

set -euo pipefail

REMOTE="${1:-origin}"

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

current_url=$(git remote get-url "$REMOTE")
REPO_NAME="${current_url##*/}"

git_url="http://$git_credentials@$gitea_host/zarf-git-user/$REPO_NAME"

git remote set-url "$REMOTE" "$git_url"

git pull "$REMOTE"

# TODO: make sure zarf process gets terminated, this isn't working
# shellcheck disable=SC2154
pkill --parent "$zarffd_PID" || :
kill "$zarffd_PID" || :