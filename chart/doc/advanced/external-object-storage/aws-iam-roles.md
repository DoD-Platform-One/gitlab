---
stage: GitLab Delivery
group: Self Managed
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: IAM roles for AWS when using the GitLab chart
---

The default configuration for external object storage in the charts uses access and secret keys.
It is also possible to use IAM roles in combination with [`kube2iam`](https://github.com/jtblin/kube2iam),
[`kiam`](https://github.com/uswitch/kiam), or [IRSA](https://aws.amazon.com/blogs/opensource/introducing-fine-grained-iam-roles-service-accounts/).

## IAM role

The IAM role will need read, write and list permissions on the S3 buckets. You can choose to have a role per bucket or combine them.

## Chart configuration

IAM roles can be specified by adding annotations and changing the secrets, as specified below:

### Registry

An IAM role can be specified via the annotations key:

```plaintext
--set registry.annotations."iam\.amazonaws\.com/role"=<role name>
```

When creating the [`registry-storage.yaml`](../../charts/registry/_index.md#storage) secret, omit the access and secret key:

```yaml
s3:
  bucket: gitlab-registry
  v4auth: true
  region: us-east-1
```

*Note*: If you provide the key pair, IAM role will be ignored. See [AWS documentation](https://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/credentials.html#credentials-default) for more details.

### LFS, Artifacts, Uploads, Packages

For LFS, artifacts, uploads, and packages an IAM role can be specified via the annotations key in the `webservice` and `sidekiq` configuration:

```shell
--set gitlab.sidekiq.annotations."iam\.amazonaws\.com/role"=<role name>
--set gitlab.webservice.annotations."iam\.amazonaws\.com/role"=<role name>
```

For the [`object-storage.yaml`](../../charts/globals.md#connection) secret, omit
the access and secret key. Because the GitLab Rails codebase uses Fog for S3
storage, the [`use_iam_profile`](https://docs.gitlab.com/administration/cicd/secure_files/#s3-compatible-connection-settings)
key should be added for Fog to use the role:

```yaml
provider: AWS
use_iam_profile: true
region: us-east-1
```

{{< alert type="note" >}}

Do NOT include `endpoint` in this configuration.
IRSA makes use of [STS tokens, which use specialized endpoints](https://docs.aws.amazon.com/STS/latest/APIReference/welcome.html).
When `endpoint` is provided, the AWS client will attempt
[to send an `AssumeRoleWithWebIdentity` message to this endpoint and will fail](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/3148#note_889357676).

{{< /alert >}}

### Backups

The Toolbox configuration allows for annotations to be set to upload backups to S3:

```shell
--set gitlab.toolbox.annotations."iam\.amazonaws\.com/role"=<role name>
```

The [`s3cmd.config`](_index.md#backups-storage-example) secret is to be created without the access and secret keys:

```ini
[default]
bucket_location = us-east-1
```

### Using IAM roles for service accounts

If GitLab is running in an AWS EKS cluster (version 1.14 or greater), you can
use an AWS IAM role to authenticate to the S3 object storage without the need
of generating or storing access tokens. More information regarding using
IAM roles in an EKS cluster can be found in the
[Introducing fine-grained IAM roles for service accounts](https://aws.amazon.com/blogs/opensource/introducing-fine-grained-iam-roles-service-accounts/)
documentation from AWS.

Appropriate IRSA annotations for roles can be applied to ServiceAccounts throughout
this Helm chart in one of two ways:

1. ServiceAccounts that have been pre-created as described in the above AWS documentation.
   This ensures the proper annotations on the ServiceAccount and the linked OIDC provider.
1. Chart-generated ServiceAccounts with annotations defined. We allow for the configuration
   of annotations on ServiceAccounts both globally and on a per-chart basis.

To use IAM roles for ServiceAccounts in EKS clusters, the specific annotation must be `eks.amazonaws.com/role-arn: arn:aws:iam::<ACCOUNT_ID>:role/<IAM_ROLE_NAME>`.

To enable IAM roles for ServiceAccounts for GitLab running in an AWS EKS cluster, follow the instructions on
[IAM roles for service accounts](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html).

#### Using pre-created service accounts

Set the following options when the GitLab chart is deployed. It is important
to note that the ServiceAccount is enabled but not created.

```yaml
global:
  serviceAccount:
    enabled: true
    create: false
    name: <SERVICE ACCT NAME>
```

Fine-grained ServiceAccounts control is also available:

```yaml
registry:
  serviceAccount:
    create: false
    name: gitlab-registry
gitlab:
  migrations:
    serviceAccount:
      create: false
      name: gitlab-migrations
  webservice:
    serviceAccount:
      create: false
      name: gitlab-webservice
  sidekiq:
    serviceAccount:
      create: false
      name: gitlab-sidekiq
  toolbox:
    serviceAccount:
      create: false
      name: gitlab-toolbox
```

Ensure that the IAM role's trust policy is configured to [trust these Kubernetes service accounts](https://docs.aws.amazon.com/eks/latest/userguide/associate-service-account-role.html).

#### Using chart-owned service accounts

The `eks.amazonaws.com/role-arn` annotation can be applied to *all* ServiceAccounts
created by GitLab owned charts by configuring `global.serviceAccount.annotations`.

```yaml
global:
  serviceAccount:
    annotations:
      eks.amazonaws.com/role-arn: arn:aws:iam::xxxxxxxxxxxx:role/name
```

Annotations can also be added on a per ServiceAccount basis, but adding the matching
definition for each chart. These can be the same role, or individual roles.

```yaml
registry:
  serviceAccount:
    annotations:
      eks.amazonaws.com/role-arn: arn:aws:iam::xxxxxxxxxxxx:role/gitlab-registry
gitlab:
  migrations:
    serviceAccount:
      annotations:
        eks.amazonaws.com/role-arn: arn:aws:iam::xxxxxxxxxxxx:role/gitlab
  webservice:
    serviceAccount:
      annotations:
        eks.amazonaws.com/role-arn: arn:aws:iam::xxxxxxxxxxxx:role/gitlab
  sidekiq:
    serviceAccount:
      annotations:
        eks.amazonaws.com/role-arn: arn:aws:iam::xxxxxxxxxxxx:role/gitlab
  toolbox:
    serviceAccount:
      annotations:
        eks.amazonaws.com/role-arn: arn:aws:iam::xxxxxxxxxxxx:role/gitlab-toolbox
```

## Troubleshooting

You can test if the IAM role is correctly set up and that GitLab is
accessing S3 using the IAM role by logging into the `toolbox` pod and
using `awscli` (replace `<namespace>` with the namespace where GitLab is
installed):

```shell
kubectl exec -ti $(kubectl get pod -n <namespace> -lapp=toolbox -o jsonpath='{.items[0].metadata.name}') -n <namespace> -- bash
```

With the `awscli` package installed, verify that you are able to communicate
with the AWS API:

```shell
aws sts get-caller-identity
```

A normal response showing the temporary user ID, account number and IAM
ARN (this will not be the IAM ARN for the role used to access S3) will be
returned if connection to the AWS API was successful. An unsuccessful
connection will require more troubleshooting to determine why the `toolbox`
pod is not able to communicate with the AWS APIs.

If connecting to the AWS APIs is successful, then the following command
will assume the IAM role that was created and verify that a STS token can
be retrieved for accessing S3. The `AWS_ROLE_ARN` and `AWS_WEB_IDENTITY_TOKEN_FILE`
variables are defined in the environment when IAM role annotation has been
added to the pod and do not require that they be defined:

```shell
aws sts assume-role-with-web-identity --role-arn $AWS_ROLE_ARN  --role-session-name gitlab --web-identity-token file://$AWS_WEB_IDENTITY_TOKEN_FILE
```

If the IAM role could not be assumed then an error message similar to the
following will be displayed:

```plaintext
An error occurred (AccessDenied) when calling the AssumeRoleWithWebIdentity operation: Not authorized to perform sts:AssumeRoleWithWebIdentity
```

Otherwise, the STS credentials and IAM role information will be displayed.

## `WebIdentityErr: failed to retrieve credentials`

If you see this error in the logs, this suggests that `endpoint` has
been configured in your [`object-storage.yaml`](../../charts/globals.md#connection) secret. Remove
this setting and restart the `webservice` and `sidekiq` pods.
