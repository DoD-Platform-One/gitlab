---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# IAM roles for AWS

The default configuration for external object storage in the charts is to use access and secret keys.
It is also possible to use IAM roles in combination with [`kube2iam`](https://github.com/jtblin/kube2iam) or [`kiam`](https://github.com/uswitch/kiam).

## IAM role

The IAM role will need read, write and list permissions on the S3 buckets. You can choose to have a role per bucket or combine them.

## Chart configuration

IAM roles can be specified by adding annotations and changing the secrets, as specified below:

### Registry

An IAM role can be specified via the annotations key:

```plaintext
--set registry.annotations."iam\.amazonaws\.com/role"=<role name>
```

When creating the [`registry-storage.yaml`](../../charts/registry/index.md#storage) secret, omit the access and secret key:

```yaml
s3:
  bucket: gitlab-registry
  v4auth: true
  region: us-east-1
```

*Note*: If you provide the key pair, IAM role will be ignored. See [AWS documentation](https://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/credentials.html#credentials-default) for more details.

### LFS, Artifacts, Uploads, Packages, Pseudonymizer

For LFS, artifacts, uploads, packages and pseudonymizer an IAM role can be specified via the annotations key in the `webservice` and `sidekiq` configuration:

```shell
--set gitlab.sidekiq.annotations."iam\.amazonaws\.com/role"=<role name>
--set gitlab.webservice.annotations."iam\.amazonaws\.com/role"=<role name>
```

For the [`object-storage.yaml`](../../charts/globals.md#connection) secret, omit
the access and secret key. Because the GitLab Rails codebase uses Fog for S3
storage, the [`use_iam_profile`](https://docs.gitlab.com/ee/administration/job_artifacts.html#s3-compatible-connection-settings)
key should be added for Fog to use the role:

```yaml
provider: AWS
use_iam_profile: true
region: us-east-1
```

### Backups

The Task Runner configuration allows for annotations to be set to upload backups to S3:

```shell
--set gitlab.task-runner.annotations."iam\.amazonaws\.com/role"=<role name>
```

The [`s3cmd.config`](index.md#backups-storage-example) secret is to be created without the access and secret keys:

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
AWS documentation.

A number of items need to be setup in AWS in addition to enabling the IAM
role in the GitLab configuration:

1. An IAM policy needs to be constructed to access the S3 bucket.
   This policy can be constructed to suit specific access and compliance
   requirements. Otherwise, the `AmazonS3FullAccess` IAM policy can be used,
   but this will allow access to **all** S3 buckets.
1. An OIDC provider will need to be established for the EKS cluster.
   This is best done with using the [`eksctl` command](https://eksctl.io/):

   ```shell
   eksctl utils associate-iam-oidc-provider --name <CLUSTER NAME> --approve
   ```

1. Create the Kubernetes ServiceAccount for GitLab to use with `eksctl`.
   This will add the proper annotations to associate the ServiceAccount with
   the IAM role:

   ```shell
   eksctl create iamserviceaccount --name <SERVICE ACCT NAME> \
                --namespace <NAMESPACE> --cluster <CLUSTER NAME> \
                --attach-policy-arn <AWS IAM ARN> \
                --approve
   ```

1. Set the following options when the GitLab chart is deployed. Using
   quotes around the AWS IAM ARN will assist the YAML parser to not be confused
   by the multiple colons encoded into the ARN. It is important to note that
   the ServiceAccount is enabled but not created (default is to enable and
   create the ServiceAccount) as it was created in the previous step:

   ```yaml
   global:
     serviceAccount:
       enabled: true
       create: false
       name: <SERVICE ACCT NAME>
     platform:
       eksRoleArn: "<AWS IAM ARN>"
   ```

   The settings can also be added to the Helm deployment command with the
   following command line switches:

   ```shell
   --set global.serviceAccount.enabled=true
   --set global.serviceAccount.create=false
   --set global.serviceAccount.name=<SERVICE ACCT NAME>
   --set global.platform.eksRoleArn=<AWS IAM ARN>
   ```

The above procedure will create the `eks.amazonaws.com/role-arn` annotations
on the `gitlab-sidekiq`, `taskrunner` and `webservice` pods. In addition, the
ServiceAccount created in step 3 will also have the annotation.

WARNING:
Using the `backup-utility` as specified in the [backup documenation](../../backup-restore/backup.md)
does not properly copy the backup file to the S3 bucket. The `backup-utility` uses
the `s3cmd` to perform the copy of the backup file and it has a known
issue of [not supporting OIDC authentication](https://github.com/s3tools/s3cmd/issues/1075).
There is a [pull request](https://github.com/s3tools/s3cmd/pull/1112)
to mitigate this issue, but it has yet to be accepted into the `s3cmd` code base.

## Troubleshooting

You can test if the IAM role is correctly set up and that GitLab is accessing
S3 using the IAM role by logging into the `taskrunner` pod and installing the
`awscli` Python package:

```shell
kubectl exec -it <TASK RUNNER POD> bash
pip install awscli
```

With the `awscli` package installed, verify that you are able to communicate
with the AWS API:

```shell
/home/git/.local/bin/aws sts get-caller-identity
```

NOTE:
The `aws` command is not in the path so it is necessary to use the
full path to execute the command.

A normal response showing the temporary user ID, account number and IAM
ARN (this will not be the IAM ARN for the role used to access S3) will be
returned if connection to the AWS API was successful. An unsuccessful
connection will require more troubleshooting to determine why the `taskrunner`
pod is not able to communicate with the AWS APIs.

If connecting to the AWS APIs is successful, then the following command
will assume the IAM role that was created and verify that a STS token can
be retrieved for accessing S3. The `AWS_ROLE_ARN` and `AWS_WEB_IDENTITY_TOKEN_FILE`
variables are defined in the environment when IAM role annotation has been
added to the pod and do not require that they be defined:

```shell
/home/git/.local/bin/aws sts assume-role-with-web-identity --role-arn $AWS_ROLE_ARN  --role-session-name gitlab --web-identity-token file://$AWS_WEB_IDENTITY_TOKEN_FILE
```

If the IAM role could not be assumed then an error message similar to the
following will be displayed:

```plaintext
An error occurred (AccessDenied) when calling the AssumeRoleWithWebIdentity operation: Not authorized to perform sts:AssumeRoleWithWebIdentity
```

Otherwise, the STS credentials and IAM role information will be displayed.
