#!/bin/bash
set -e

MAX_HELM_REPO_UPDATE_ATTEMPTS=3
HELM_REPO_WAIT_TIMER=5

while (( MAX_HELM_REPO_UPDATE_ATTEMPTS >= 0 )); do
    if helm dependency update; then
        exit 0
    fi

    echo "Failed to update dependency list, trying again in ${HELM_REPO_WAIT_TIMER} seconds..."
    sleep "${HELM_REPO_WAIT_TIMER}"
    (( MAX_HELM_REPO_UPDATE_ATTEMPTS-- ))
done

# Something has gone very wrong.
echo "Failed to update helm dependencies."
exit 1
