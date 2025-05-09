#!/bin/bash

set -euo pipefail

: "${CI_SERVER_HOST:=unset}"
HELM_PACKAGE="$1"
REGISTRY_URL="us-east1-docker.pkg.dev"
REGISTRY_PATH="oci://${REGISTRY_URL}/gitlab-com-artifact-registry/gitlab-devel-chart"

# "feature flag" this script
: "${ENABLE_OCI_PUSH:=unset}"

# Function to log messages
log() {
    echo "$1"
}

# Function to validate CI server host
validate_ci_server() {
    if [[ -z "${CI_SERVER_HOST}" ]]; then
        log "ERROR: CI_SERVER_HOST environment variable is not set"
        exit 0
    fi

    if [[ "${CI_SERVER_HOST}" != "dev.gitlab.org" ]]; then
        log "This script can only be run on dev.gitlab.org instance"
        log "Current CI_SERVER_HOST: ${CI_SERVER_HOST}"
        exit 0
    fi
}

# Function to validate OCI push is enabled
validate_oci_push() {
    if [[ "${ENABLE_OCI_PUSH}" != "true" ]]; then
        log "ERROR: ENABLE_OCI_PUSH must be set to 'true' to proceed"
        log "Current value: ${ENABLE_OCI_PUSH}"
        exit 0
    fi
}

# Validate required arguments
if [[ $# -lt 1 ]]; then
    log "Usage: $0 <helm_package_file>"
    log "Example: $0 ./gitlab-chart.tgz"
    exit 1
fi

# Main script execution
log "Starting helm chart OCI push process..."

# Run validations
validate_ci_server
validate_oci_push

echo "Vault Auth Path: ${VAULT_AUTH_PATH:=dev-gitlab-org}"
echo "Vault Auth Role: ${VAULT_AUTH_ROLE:=unset}"
echo "Vault Secret Path: ${VAULT_SECRETS_PATH:=unset}"

export VAULT_ADDR='https://vault.ops.gke.gitlab.net'
VAULT_TOKEN="$(vault write -field=token "auth/${VAULT_AUTH_PATH}/login" role="${VAULT_AUTH_ROLE}" jwt="${VAULT_ID_TOKEN}")"; export VAULT_TOKEN
GAR_JSON_KEY="$(vault kv get -field key "ci/${VAULT_SECRETS_PATH}/shared/gitlab-devel-chart-rw-key")"

echo "Vault Token SHA: ${GAR_JSON_KEY}" | sha256sum

# Perform registry login
log "Logging into helm registry at ${REGISTRY_URL}..."
if ! echo "${GAR_JSON_KEY}" | helm registry login -u _json_key --password-stdin "https://${REGISTRY_URL}"; then
    log "ERROR: Failed to login to helm registry"
    exit 1
fi
log "Successfully logged into helm registry"

# Push the helm chart
log "Pushing helm chart ${HELM_PACKAGE} to ${REGISTRY_PATH}..."
if ! helm push "${HELM_PACKAGE}" "${REGISTRY_PATH}"; then
    log "ERROR: Failed to push helm chart"
    exit 1
fi
log "Successfully pushed helm chart to registry"

exit 0