---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Using the Praefect chart

The Praefect chart is used to manage a [Gitaly cluster](https://docs.gitlab.com/ee/administration/gitaly/praefect.html) inside a GitLab installment deployed with the Helm charts.

## Known Limitations

1. Only a managed, `default` [virtual storage](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/2307) is supported.
1. The database has to be [manually created](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/2310).
1. [Migrating from an existing Gitaly setup](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/2311) to Praefect is not supported.

## Requirements

This chart consumes the Gitaly chart. Settings from `global.gitaly` are used to configure the instances created by this chart. Documentation of these settings can be found in [Gitaly chart documentation](../gitaly/index.md).

*Important*: `global.gitaly.tls` is independent of `global.praefect.tls`. They are configured separately.

By default, this chart will create 3 Gitaly Replicas.

## Configuration

The chart is disabled by default. To enable it as part of a chart deploy set `global.praefect.enabled=true`.

The default number of replicas to deploy is 3. This can be changed by setting `global.praefect.gitalyReplicas` to the desired number of replicas.

### Creating the database

Praefect uses its own database to track its state. This has to be manually created in order for Praefect to be functional.

NOTE:
These instructions assume you are using the bundled PostgreSQL server. If you are using your own server,
there will be some variation in how you connect.

1. Log into your database instance:

   ```shell
   kubectl exec -it $(kubectl get pods -l app=postgresql -o custom-columns=NAME:.metadata.name --no-headers) -- bash
   PGPASSWORD=$(cat $POSTGRES_POSTGRES_PASSWORD_FILE) psql -U postgres -d template1
   ```

1. Create the database user:

   ```sql
   template1=# CREATE ROLE praefect WITH LOGIN;
   ```

1. Set the database user password.

   By default, the `shared-secrets` chart will generate a secret for you.

   1. Fetch the password:

      ```shell
      kubectl get secret RELEASE_NAME-praefect-dbsecret -o jsonpath="{.data.secret}" | base64 --decode
      ```

   1. Set the password in the `psql` prompt:

      ```sql
      template1=# \password praefect
      Enter new password:
      Enter it again:
      ```

1. Create the database:

   ```sql
   CREATE DATABASE praefect WITH OWNER praefect;
   ```

### Running Praefect over TLS

Praefect supports communicating with client and Gitaly nodes over TLS. This is
controlled by the settings `global.praefect.tls.enabled` and `global.praefect.tls.secretName`.
To run Praefect over TLS follow these steps:

1. The Helm chart expects a certificate to be provided for communicating over
   TLS with Praefect. This certificate should apply to all the Praefect nodes that
   are present. Hence all hostnames of each of these nodes should be added as a
   Subject Alternate Name (SAN) to the certificate or alternatively, you can use wildcards.

   To know the hostnames to use, check the file `/srv/gitlab/config/gitlab.yml`
   file in the Task Runner Pod and check the various `gitaly_address` fields specified
   under `repositories.storages` key within it.

   ```shell
   kubectl exec -it <Task Runner Pod> -- grep gitaly_address /srv/gitlab/config/gitlab.yml
   ```

NOTE:
A basic script for generating custom signed certificates for internal Praefect Pods
[can be found in this repo](https://gitlab.com/gitlab-org/charts/gitlab/blob/master/scripts/generate_certificates.sh).
Users can use or refer that script to generate certificates with proper SAN attributes.

1. Create a TLS Secret using the certificate created.

   ```shell
   kubectl create secret tls <secret name> --cert=praefect.crt --key=praefect.key
   ```

1. Redeploy the Helm chart by passing the additional arguments `--set global.praefect.tls.enabled=true --set global.praefect.tls.secretName=<secret name>`

### Installation command line options

The table below contains all the possible charts configurations that can be supplied to
the `helm install` command using the `--set` flags.

| Parameter                      | Default                                           | Description                                                                                             |
| ------------------------------ | ------------------------------------------        | ----------------------------------------                                                                |
| failover.enabled               | true                                              | Whether Praefect should perform failover on node failure                                                |
| failover.readonlyAfter         | false                                             | Whether the nodes should be in read-only mode after failover                                            |
| autoMigrate                    | true                                              | Automatically run migrations on startup                                                                 |
| electionStrategy               | sql                                               | See [election strategy](https://docs.gitlab.com/ee/administration/gitaly/praefect.html#automatic-failover-and-leader-election) |
| image.repository               | `registry.gitlab.com/gitlab-org/build/cng/gitaly` | The default image repository to use. Praefect is bundled as part of the Gitaly image                    |
| service.name                   | `praefect`                                        | The name of the service to create                                                                       |
| service.type                   | ClusterIP                                         | The type of service to create                                                                           |
| service.internalPort           | 8075                                              | The internal port number that the Praefect pod will be listening on                                     |
| service.externalPort           | 8075                                              | The port number the Praefect service should expose in the cluster                                       |
| init.resources                 |                                                   |                                                                                                         |
| init.image                     |                                                   |                                                                                                         |
| logging.level                  |                                                   | Log level                                                                                               |
| logging.format                 | `json`                                            | Log format                                                                                              |
| logging.sentryDsn              |                                                   | Sentry DSN URL - Exceptions from Go server                                                              |
| logging.rubySentryDsn          |                                                   | Sentry DSN URL - Exceptions from `gitaly-ruby`                                                          |
| logging.sentryEnvironment      |                                                   | Sentry environment to be used for logging                                                               |
| metrics.enabled                | true                                              |                                                                                                         |
| metrics.port                   | 9236                                              |                                                                                                         |
| securityContext.runAsUser      | 1000                                              |                                                                                                         |
| securityContext.fsGroup        | 1000                                              |                                                                                                         |
