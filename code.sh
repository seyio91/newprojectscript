#!/bin/bash

REPO_LIST=$(curl https://api.github.com/users/seyio91/repos | jq -r '.[] | .name')



while IFS= read -r line; do
    # echo $line
    if [[ $line == "todobackend" ]]; then
        echo "Repo Name Already Exists"
        exit 1
    fi
done <<< "$REPO_LIST"