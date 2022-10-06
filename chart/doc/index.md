---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# GitLab Helm chart **(FREE SELF)**

To install GitLab in a cloud-native environment, use the GitLab Helm chart.
This chart contains all the required components to get started and can scale to large deployments.

Use this installation method if your infrastructure is built
on Kubernetes and you're familiar with how it works. This method of deployment has different
management, observability, and concepts than traditional deployments.

NOTE:
Use the **default** chart for proof-of-concept deployments only. For production deployments,
additional setup and configuration is required. [View details](installation/index.md).

## Subcharts

The GitLab Helm chart includes all the components for a complete deployment.

The GitLab Helm chart is made up of multiple subcharts, each of which
can be installed separately.

- Core GitLab components:
  - [NGINX Ingress](charts/nginx/index.md)
  - [Registry](charts/registry/index.md)
  - GitLab/[Gitaly](charts/gitlab/gitaly/index.md)
  - GitLab/[GitLab Exporter](charts/gitlab/gitlab-exporter/index.md)
  - GitLab/[GitLab Grafana](charts/gitlab/gitlab-grafana/index.md)
  - GitLab/[GitLab Pages](charts/gitlab/gitlab-pages/index.md)
  - GitLab/[GitLab Shell](charts/gitlab/gitlab-shell/index.md)
  - GitLab/[Mailroom](charts/gitlab/mailroom/index.md)
  - GitLab/[Migrations](charts/gitlab/migrations/index.md)
  - GitLab/[Sidekiq](charts/gitlab/sidekiq/index.md)
  - GitLab/[Toolbox](charts/gitlab/toolbox/index.md)
  - GitLab/[Webservice](charts/gitlab/webservice/index.md)
- Optional dependencies:
  - [PostgreSQL](https://artifacthub.io/packages/helm/bitnami/postgresql)
  - [Redis](https://artifacthub.io/packages/helm/bitnami/redis)
  - [MinIO](charts/minio/index.md)
- Optional additions:
  - [Prometheus](https://artifacthub.io/packages/helm/prometheus-community/prometheus)
  - [Grafana](https://artifacthub.io/packages/helm/grafana/grafana)
  - [_Unprivileged_](https://docs.gitlab.com/runner/install/kubernetes.html#running-docker-in-docker-containers-with-gitlab-runner) [GitLab Runner](https://docs.gitlab.com/runner/) that uses the Kubernetes executor
  - Automatically provisioned SSL from [Let's Encrypt](https://letsencrypt.org/), which uses [Jetstack](https://www.jetstack.io/)'s [cert-manager](https://cert-manager.io/docs/) with [certmanager-issuer](charts/certmanager-issuer/index.md)
  - GitLab/[Praefect](charts/gitlab/praefect/index.md)
  - GitLab/[GitLab agent server (KAS)](charts/gitlab/kas/index.md)
  - GitLab/[Spamcheck](charts/gitlab/spamcheck/index.md)

## Related topics

- [Test the GitLab chart on GKE or EKS](quickstart/index.md).
- [Migrate from Omnibus to the GitLab chart](installation/migration/index.md).
- [Prepare to deploy](installation/index.md).
- [Deploy](installation/deployment.md).
- [Configure globals](charts/globals.md).
- [View deployment options](installation/command-line-options.md).
- [View advanced configuration options](advanced/index.md).
- [View architectural decisions](architecture/index.md).
- Contribute to development by viewing the [developer documentation](development/index.md) and
  [contribution guidelines](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/CONTRIBUTING.md).
- Create an [issue](https://gitlab.com/gitlab-org/charts/gitlab/-/issues).
- Create a [merge request](https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests).
- View [troubleshooting](troubleshooting/index.md) information.
