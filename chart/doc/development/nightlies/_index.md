---
stage: Systems
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: Development of Nightly Builds
---

Built each night on the Dev instance.
The resulting package lives on the dev instance but is also pushed up to the Google Artifact Registry for Production workload consumption.

## Development Tools

### Helm OCI Registry Push Script

The `scripts/helm_push_oci.sh` script is used to push Helm charts to the Google Artifact Registry. This script handles Vault authentication and pushing of Helm charts to our OCI-compatible registry.

#### Usage

```shell
./scripts/helm_push_oci.sh <helm_package_file>
```

#### Required Parameters

- `helm_package_file`: Path to the Helm chart package file to be pushed (e.g., `./gitlab-chart.tgz`)

#### Environment Variables

The script requires specific environment variables for Vault authentication:

- `VAULT_AUTH_PATH`: Vault authentication path (defaults to `dev-gitlab-org`)
- `VAULT_AUTH_ROLE`: Vault authentication role
- `VAULT_SECRETS_PATH`: Path to the Vault secrets
- `VAULT_ID_TOKEN`: JWT token for Vault authentication
- `ENABLE_OCI_PUSH`: Must be set to `true` to enable pushing to the registry

#### Registry Details

The script pushes Helm charts to:

- Registry URL: `us-east1-docker.pkg.dev`
- Registry Path: `gitlab-com-artifact-registry/gitlab-devel-chart`

#### Process Overview

1. Authenticates with Vault to obtain registry credentials
1. Retrieves the service account key from Vault
1. Logs into the Google Artifact Registry using the service account
1. Pushes the specified Helm chart package to the OCI registry
1. Provides detailed feedback about each operation's success or failure

Note: This script is designed to run in CI/CD environments with proper Vault access and permissions.
