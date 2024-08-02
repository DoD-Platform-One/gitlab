---
stage: Systems
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
---

# Using the GitLab Runner chart

DETAILS:
**Tier:** Free, Premium, Ultimate
**Offering:** Self-managed

The GitLab Runner subchart provides a GitLab Runner for running CI jobs. It is enabled by default and should work out of the box with support for caching using s3 compatible object storage.

WARNING:
The default configuration of the included GitLab Runner chart is **not intended for production**.
It is provided as a proof of concept (PoC) implementation where all GitLab services are deployed
in the cluster. For production deployments, install GitLab Runner on a separate machine for
[security and performance reasons](https://docs.gitlab.com/ee/install/requirements.html#gitlab-runner).
For more information, see the
[reference architecture documentation](../../../installation/index.md#use-the-reference-architectures).

## Requirements

In GitLab 16.0, we introduced a new runner creation workflow that uses runner authentication tokens to
register runners. The legacy workflow that uses registration tokens is deprecated and disabled by default
in GitLab 17.0. It will be removed in GitLab 18.0.

To use the recommended workflow:

- [Generate an authentication token.](https://docs.gitlab.com/ee/ci/runners/new_creation_workflow.html#prevent-your-runner-registration-workflow-from-breaking)
- Update the runner secret (`<release>-gitlab-runner-secret`) manually, as the configuration
  is not handled by the [`shared-secrets`](../../shared-secrets.md) job.
- Set `gitlab-runner.runners.locked` to `null`:

  ```yaml
  gitlab-runner:
    runners:
      locked: null
  ```

If you want to use the legacy workflow (not recommended):

- You must [re-enable the legacy workflow](https://docs.gitlab.com/ee/administration/settings/continuous_integration.html#enable-runner-registrations-tokens).
- The registration token is populated by the [`shared-secrets`](../../shared-secrets.md) Job.
- You must migrate to the new workflow before GitLab 18.0, which will remove support for the legacy workflow.

## Configuration

For more information, see the documentation on [usage and configuration](https://docs.gitlab.com/runner/install/kubernetes.html).

## Deploying a stand-alone runner

By default we do infer `gitlabUrl`, automatically generate a registration token, and generate it through the `migrations` chart. This behavior will not work if you intend to deploy it with a running GitLab instance.

In this case you will need to set `gitlabUrl` value to be the URL of the running GitLab instance. You will also need to manually create `gitlab-runner` secret and fill it with the `registrationToken` provided by the running GitLab.

## Using Docker-in-Docker

In order to run Docker-in-Docker, the runner container needs to be privileged to have access to the needed capabilities. To enable it set the `privileged` value to `true`. See the [upstream documentation](https://docs.gitlab.com/runner/install/kubernetes.html#running-docker-in-docker-containers-with-gitlab-runners) in regards to why this is does not default to `true`.

### Security concerns

Privileged containers have extended capabilities, for example they can mount arbitrary files from the host they run on. Make sure to run the container in an isolated environment such that nothing important runs beside it.

## Default runner configuration

The default runner configuration used in the GitLab chart has been customized to use the included MinIO for cache by default. If you are setting the runner `config` value, you will need to also configure your own cache configuration.

```yaml
gitlab-runner:
  runners:
    config: |
      [[runners]]
        [runners.kubernetes]
        image = "ubuntu:22.04"
        {{- if .Values.global.minio.enabled }}
        [runners.cache]
          Type = "s3"
          Path = "gitlab-runner"
          Shared = true
          [runners.cache.s3]
            ServerAddress = {{ include "gitlab-runner.cache-tpl.s3ServerAddress" . }}
            BucketName = "runner-cache"
            BucketLocation = "us-east-1"
            Insecure = false
        {{ end }}
```

All customized GitLab Runner chart configuration is available in the
[top-level `values.yaml` file](https://gitlab.com/gitlab-org/charts/gitlab/raw/master/values.yaml)
under the `gitlab-runner` key.
