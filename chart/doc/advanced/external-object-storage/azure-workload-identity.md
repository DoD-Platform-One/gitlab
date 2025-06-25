---
stage: GitLab Delivery
group: Self Managed
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: Azure Workload Identity when using the GitLab chart
---

The default configuration for external object storage in the charts uses
secret keys. [Azure Workload Identity](https://azure.github.io/azure-workload-identity/docs/)
makes it possible to grant access to object storage to the Kubernetes cluster using short-lived
tokens. Read the [Microsoft documentation on how to deploy and configure workload identity on an Azure Kubernetes Service (AKS) cluster](https://learn.microsoft.com/en-us/azure/aks/workload-identity-deploy-cluster).

## Requirements

To use workload identity with object storage, you need:

1. An AKS cluster with an OpenID Connect Issuer (OIDC) issuer enabled.
1. An Azure managed identity with the `Storage Blob Data Contributor` role assigned to it.
1. A Kubernetes service account associated with the managed identity with the annotation `azure.workload.identity/client-id: <CLIENT ID>`.

To activate workload identity each pod needs the label `azure.workload.identity/use: "true"`. Note
that this is a pod **label**, not an annotation.

## Chart configuration

### Registry

{{< history >}}

- [Introduced](https://gitlab.com/gitlab-org/container-registry/-/issues/1431) in GitLab 17.9 as a beta feature.

{{< /history >}}

Workload identity support for the registry is in beta. Workload identity can be enabled by setting the pod labels:

```plaintext
--set registry.podLabels."azure\.workload\.identity/use"=true
```

When creating the [`registry-storage.yaml`](../../charts/registry/_index.md#storage)
secret, you need to:

1. Use the `azure_v2` storage settings.
1. Set `credentialstype` to `default_credentials`.

For example:

```yaml
azure_v2:
  accountname: accountname
  container: containername
  credentialstype: default_credentials
  realm: core.windows.net
```

The `azure_v2` storage driver supports workload identity, but the
`azure` driver does not. If you are you currently using the `azure`
driver and wish to use workload identity, migrate to the `azure_v2`
driver. See the [`azure_v2` documentation](https://gitlab.com/gitlab-org/container-registry/-/blob/3ebb5bffd3f6cfbf4479b1b8a4079d842a1c8025/docs/storage-drivers/azure_v2.md)
for more details.

### LFS, artifacts, uploads, packages

For LFS, artifacts, uploads, and packages an IAM role can be specified via the annotations key in the `webservice`, `sidekiq`, and `toolbox` configuration:

```shell
--set gitlab.sidekiq.podLabels."azure\.workload\.identity/use"="true"
--set gitlab.webservice.podLabels."azure\.workload\.identity/use"="true"
--set gitlab.toolbox.podLabels."azure\.workload\.identity/use"="true"
```

For the [`object-storage.yaml`](../../charts/globals.md#connection) secret, omit
`azure_storage_access_key`:

```yaml
provider: AzureRM
azure_storage_account_name: YOUR_AZURE_STORAGE_ACCOUNT_NAME
azure_storage_domain: blob.core.windows.net
```

### Backups

The Toolbox configuration allows for pod labels to be set:

```shell
--set gitlab.toolbox.podLabels."azure\.workload\.identity/use"="true"
```

For the [`azure-backup-conf.yaml`](../../backup-restore/_index.md)
stored in the `gitlab.toolbox.backups.objectStorage.config.secret`
secret, omit `azure_storage_access_key`:

```yaml
# azure-backup-conf.yaml
azure_storage_account_name: <storage account>
azure_storage_domain: blob.core.windows.net # optional
```

## Troubleshooting

You can test if the Azure workload identity is correctly set up and that GitLab is
accessing Azure Blob storage by logging into the `toolbox` pod (replace `<namespace>` with the namespace where GitLab is):

```shell
kubectl exec -ti $(kubectl get pod -n <namespace> -lapp=toolbox -o jsonpath='{.items[0].metadata.name}') -n <namespace> -- bash
```

First, check whether the required environment variables are present:

- `AZURE_TENANT_ID`
- `AZURE_FEDERATED_TOKEN_FILE`
- `AZURE_CLIENT_ID`

For example, you should see something like this:

```shell
$ env | grep AZURE
AZURE_TENANT_ID=abcdefghi-c2c5-43d6-b426-1d8c9e8e7ad1
AZURE_FEDERATED_TOKEN_FILE=/var/run/secrets/azure/tokens/azure-identity-token
AZURE_AUTHORITY_HOST=https://login.microsoftonline.com/
AZURE_CLIENT_ID=123456789-abcd-12ab-89ca-cb379118f978
```

Next, use `azcopy` to list files in the blob container:

```shell
export AZCOPY_AUTO_LOGIN_TYPE=workload
azcopy --log-level debug list https://<YOUR STORAGE ACCOUNT NAME>.blob.core.windows.net/<YOUR AZURE BLOB CONTAINER NAME>
```

If authentication is successful, you should see the following messages with the contents of the blob container:

```plaintext
INFO: Login with Workload Identity succeeded
INFO: Authenticating to source using Azure AD
```

If you see a 401 or 403 error, check your managed identity settings. Here are some common errors:

1. Check the spelling of the Azure storage account and blob container names.
1. With `kubectl describe pod <pod>`, check that the pod has the correct Kubernetes service account and `azure.workload.identity/use: "true"` pod label.
1. For the managed identity, ensure that the settings for federated credentials have the right issuer URL, namespace, and associated Kubernetes service account.
   You can check this in the Azure portal or using the [`az` command-line interface](https://learn.microsoft.com/en-us/cli/azure/identity).
1. Check that the managed identity has the `Storage Blob Data Contributor` for the blob storage container.
