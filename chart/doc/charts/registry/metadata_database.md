---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: Container registry metadata database
---

{{< details >}}

- Tier: Free, Premium, Ultimate
- Offering: GitLab Self-Managed

{{< /details >}}

{{< history >}}

- [Introduced](https://gitlab.com/groups/gitlab-org/-/epics/5521) in GitLab 16.4 as a [beta](https://docs.gitlab.com/policy/development_stages_support/#beta) feature.
- [Generally available](https://gitlab.com/gitlab-org/gitlab/-/issues/423459) in GitLab 17.3.

{{< /history >}}

The metadata database provides many new registry features, including online garbage collection, and increases the
efficiency of many registry operations.

If you have existing registries, you can migrate to the metadata database.

Some database-enabled features are only enabled for GitLab.com and automatic database provisioning for
the registry database is not available. Review the feature support section in the
[administration documentation](https://docs.gitlab.com/administration/packages/container_registry_metadata_database/#metadata-database-feature-support)
for the status of features related to the container registry database.

## Create an external metadata database

In production, you should create an external metadata database.

Prerequisites:

- Set up an [external PostgreSQL server](../../advanced/external-db/_index.md).

After you set up the external PostgreSQL server:

1. Create a secret for the metadata database password:

   ```shell
   kubectl create secret generic RELEASE_NAME-registry-database-password --from-literal=password=<your_registry_password>
    ```

1. Log in to your database server.
1. Use the following SQL commands to create the user and the database:

   ```sql
   -- Create the registry user
   CREATE USER registry WITH PASSWORD '<your_registry_password>';

   -- Create the registry database
   CREATE DATABASE registry OWNER registry;
   ```

1. For cloud-managed services, grant additional roles as needed:

   {{< tabs >}}

   {{< tab title="Amazon RDS" >}}

   ```sql
   GRANT rds_superuser TO registry;
   ```

   {{< /tab >}}

   {{< tab title="Azure database" >}}

   ```sql
   GRANT azure_pg_admin TO registry;
   ```

   {{< /tab >}}

   {{< tab title="Google Cloud SQL" >}}

   ```sql
   GRANT cloudsqlsuperuser TO registry;
   ```

   {{< /tab >}}

   {{< /tabs >}}

## Create a built-in metadata database

{{< alert type="warning" >}}

You can use the built-in cloud native metadata database for trial purposes only.
You should not use it in production.

{{< /alert >}}

### Create the database automatically

{{< history >}}

- [Introduced](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/5931) in GitLab 18.3.

{{</ history >}}

Prerequisites:

- Helm chart 9.3 or later.

New installations that set `postgresql.install=true`
when installing the GitLab chart, automatically create the registry database,
username, and shared secret `RELEASE-registry-database-password`.

This automatic provisioning:

- Creates a dedicated `registry` database.
- Sets up a `registry` user with appropriate permissions.
- Generates a Kubernetes secret named `RELEASE-registry-database-password` containing the database password.
- Configures the necessary database schema and permissions.

With automatic database creation, you can skip the manual database creation
steps and immediately [enable the metadata database](#enable-the-metadata-database).

### Create the database manually

To manually create the metadata database using the built-in PostgreSQL server:

1. Create the secret with the database password:

   ```shell
   kubectl create secret generic RELEASE_NAME-registry-database-password --from-literal=password=<your_registry_password>
   ```

1. Log into your database instance:

   ```shell
   kubectl exec -it $(kubectl get pods -l app.kubernetes.io/name=postgresql -o custom-columns=NAME:.metadata.name --no-headers) -- bash
   ```

   ```shell
   PGPASSWORD=${POSTGRES_POSTGRES_PASSWORD} psql -U postgres -d template1
   ```

1. Create the database user:

   ```sql
   CREATE ROLE registry WITH LOGIN;
   ```

1. Set the database user password.

   1. Fetch the password:

      ```shell
      kubectl get secret RELEASE_NAME-registry-database-password -o jsonpath="{.data.password}" | base64 --decode
      ```

   1. Set the password in the `psql` prompt:

      ```sql
      \password registry
      ```

1. Create the database:

   ```sql
   CREATE DATABASE registry WITH OWNER registry;
   ```

1. Safely exit from the PostgreSQL command line and then from the container using `exit`:

   ```shell
   template1=# exit
   ...@gitlab-postgresql-0/$ exit
   ```

## Enable the metadata database

After you've created the database, enable it. Additional steps are required when migrating an existing container registry.

### Prerequisites

Prerequisites:

- GitLab 17.3 or later.
- A deployment of the [required version of PostgreSQL](https://docs.gitlab.com/install/requirements/#postgresql), accessible from the registry pods.
- Access to the Kubernetes cluster and the Helm deployment locally.
- SSH access to the registry pods.

Also read the [before you start](https://docs.gitlab.com/administration/packages/container_registry_metadata_database/#before-you-start)
section of the Registry administration guide.

{{< alert type="note" >}}

For a list of import times for various test and user registries, see [this table in issue 423459](https://gitlab.com/gitlab-org/gitlab/-/issues/423459#completed-tests-and-user-reports). Your registry deployment is unique, and your import times might be longer than those reported in the issue.

{{< /alert >}}

### Enable for new registries

To enable the database for a new container registry:

1. Get the current Helm values for your release and save them to a file.
   For example, for a release named `gitlab` and a file named `values.yml`:

   ```shell
   helm get values gitlab > values.yml
   ```

1. Add the following lines to your `values.yml` file:

   ```yaml
   registry:
     enabled: true
     database:
       enabled: true
       name: registry  # must match the database name you created above
       user: registry  # must match the database username you created above
       password:
         secret: gitlab-registry-database-password # must match the secret name
         key: password  # must match the secret key to read the password from
       sslmode: verify-full
       # these settings are inherited from `global.psql.ssl`
       ssl:
         secret: gitlab-registry-postgresql-ssl # you will need to create this secret manually
         clientKey: client-key.pem
         clientCertificate: client-cert.pem
         serverCA: server-ca.pem
       migrations:
         enabled: true  # this option will execute the schema migration as part of the registry deployment
   ```

1. Optional. Verify the schema migrations have been applied properly. You can either:

   - Review the log output of the migrations job, for example:

     ```shell
     kubectl logs jobs/gitlab-registry-migrations-1
     ...
     OK: applied 154 migrations in 13.752s
     ```

   - Or, connect to the Postgres database and query the `schema_migrations` table:

     ```sql
     SELECT * FROM schema_migrations;
     ```

     Ensure the `applied_at` column timestamp is filled for all rows.

The registry is ready to use the metadata database!

### Enable for and import existing registries

You can import your existing container registry data in one step or three steps.
A few factors affect the duration of the migration:

- The size of your existing registry data.
- The specifications of your PostgresSQL instance.
- The number of registry pods running in your cluster.
- Network latency between the registry, PostgresSQL and your configured Object Storage.

{{< alert type="note" >}}

Work to automate the import process is being tracked in [issue 5293](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/5293).

{{< /alert >}}

Before attempting the one-step or three-step import, get the current Helm values for your release and save them into a file.
For example, for a release named `gitlab` and a file named `values.yml`:

```shell
helm get values gitlab > values.yml
```

#### Import in one step

When doing a one-step import, be aware that:

- The registry must remain in `read-only` mode during the import.
- If the Pod where the import is being executed is terminated,
  you have to completely restart the process. The work to improve this process is tracked in
  [issue 5293](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/5293).

To import existing container registry to the metadata database in one step:

1. Find the `registry:` section in the `values.yml` file and add the `database` section.
   Set:
   - `database.configure` to `true`.
   - `database.enabled` to `false`.
   - `maintenance.readonly.enabled` to `true`.
   - `migrations.enabled` to `true`.

   ```yaml
   registry:
     enabled: true
     maintenance:
       readonly:
         enabled: true  # must remain set to true while the migration is executed
     database:
       configure: true  # must be true for the migration step
       enabled: false  # must be false!
       name: registry  # must match the database name you created above
       user: registry  # must match the database username you created above
       password:
         secret: gitlab-registry-database-password  # must match the secret name
         key: password  # must match the secret key to read the password from
       sslmode: verify-full  # SSL connection mode. See https://www.postgresql.org/docs/current/libpq-ssl.html#LIBPQ-SSL-PROTECTION for more options.
       ssl:
         secret: gitlab-registry-postgresql-ssl  # you will need to create this secret manually
         clientKey: client-key.pem
         clientCertificate: client-cert.pem
         serverCA: server-ca.pem
       migrations:
         enabled: true  # this option will execute the schema migration as part of the registry deployment
   ```

1. Upgrade your Helm installation to apply changes in your deployment:

   ```shell
   helm upgrade gitlab gitlab/gitlab -f values.yml
   ```

1. Connect to one of the registry pods via SSH, for example for a pod named `gitlab-registry-5ddcd9f486-bvb57`:

   ```shell
   kubectl exec -ti gitlab-registry-5ddcd9f486-bvb57 bash
   ```

1. Change to the home directory and then run the following command:

   ```shell
   cd ~
   /usr/bin/registry database import /etc/docker/registry/config.yml
   ```

1. If the command completed successfully, all images are now fully imported. You
   can now enable the database and turn off read-only mode in the configuration:

   ```yaml
   registry:
     enabled: true
     maintenance:
       readonly:
         enabled: false
     database:
       configure: true  # once database.enabled is set to true, this option can be removed
       enabled: true
       name: registry
       user: registry
       password:
         secret: gitlab-registry-database-password
         key: password
       migrations:
         enabled: true
   ```

1. Upgrade your Helm installation to apply changes in your deployment:

   ```shell
   helm upgrade gitlab gitlab/gitlab -f values.yml
   ```

You can now use the metadata database for all operations!

#### Import in three steps

You can import existing container registry data to the metadata database in three separate steps,
which is recommended if:

- The registry contains a large amount of data.
- You need to minimize downtime during the migration.

To import in three steps, you must:

1. Pre-import repositories
1. Import all repository data
1. Import common blobs

{{< alert type="note" >}}

Users have reported step one import completed at [rates of 2 to 4 TB per hour](https://gitlab.com/gitlab-org/gitlab/-/issues/423459).
At the slower speed, registries with over 100 TB of data could take longer than 48 hours.

{{< /alert >}}

##### Step 1. Pre-import repositories

For larger instances, this process can take hours or even days to complete, depending
on the size of your registry. You can still use the registry during this process.

{{< alert type="warning" >}}

It is [not yet possible](https://gitlab.com/gitlab-org/container-registry/-/issues/1162)
to restart the import, so it's important to let the import run to completion.
If you must halt the operation, you have to restart this step.

{{< /alert >}}

1. Find the `registry:` section in the `values.yml` file and add the `database` section.
   Set:
   - `database.configure` to `true`.
   - `database.enabled` to `false`.
   - `migrations.enabled` to `true`.

   ```yaml
   registry:
     enabled: true
     database:
       configure: true
       enabled: false  # must be false!
       name: registry  # must match the database name you created above
       user: registry  # must match the database username you created above
       password:
         secret: gitlab-registry-database-password  # must match the secret name
         key: password  # must match the secret key to read the password from
       sslmode: verify-full  # SSL connection mode. See https://www.postgresql.org/docs/current/libpq-ssl.html#LIBPQ-SSL-PROTECTION for more options.
       ssl:
         secret: gitlab-registry-postgresql-ssl  # you will need to create this secret manually
         clientKey: client-key.pem
         clientCertificate: client-cert.pem
         serverCA: server-ca.pem
       migrations:
         enabled: true  # this option will execute the schema migration as part of the registry deployment
   ```

1. Save the file and upgrade your Helm installation to apply changes in your deployment:

   ```shell
   helm upgrade gitlab gitlab/gitlab -f values.yml
   ```

1. Connect to one of the registry pods with SSH. For example, for a pod named `gitlab-registry-5ddcd9f486-bvb57`:

   ```shell
   kubectl exec -ti gitlab-registry-5ddcd9f486-bvb57 bash
   ```

1. Change to the home directory and then run the following command:

   ```shell
   cd ~
   /usr/bin/registry database import --step-one /etc/docker/registry/config.yml
   ```

The first step is complete when the `registry import complete` displays.

{{< alert type="note" >}}

You should try to schedule the following step as soon as possible
to reduce the amount of downtime required. Ideally, less than one week
after step one completes. Any new data written to the registry before the next step
causes that step to take more time.

{{< /alert >}}

##### Step 2. Import all repository data

This step requires the registry to be set in `read-only` mode.
Allow enough time for downtime during this process.

1. Set the registry to `read-only` mode
   in your `values.yml` file:

   ```yaml
   registry:
     enabled: true
     maintenance:
       readonly:
         enabled: true   # must be true!
     database:
       configure: true
       enabled: false  # must be false!
       name: registry  # must match the database name you created above
       user: registry  # must match the database username you created above
       password:
         secret: gitlab-registry-database-password  # must match the secret name
         key: password  # must match the secret key to read the password from
       sslmode: verify-full  # SSL connection mode. See https://www.postgresql.org/docs/current/libpq-ssl.html#LIBPQ-SSL-PROTECTION for more options.
       ssl:
         secret: gitlab-registry-postgresql-ssl  # you will need to create this secret manually
         clientKey: client-key.pem
         clientCertificate: client-cert.pem
         serverCA: server-ca.pem
       migrations:
         enabled: true  # this option will execute the schema migration as part of the registry deployment
   ```

1. Save the file and upgrade your Helm installation to apply changes in your deployment:

   ```shell
   helm upgrade gitlab gitlab/gitlab -f values.yml
   ```

1. Connect to one of the registry pods with SSH. For example, for a pod named `gitlab-registry-5ddcd9f486-bvb57`:

   ```shell
   kubectl exec -ti gitlab-registry-5ddcd9f486-bvb57 bash
   ```

1. Change to the home directory and then run the following command:

   ```shell
   cd ~
   /usr/bin/registry database import --step-two /etc/docker/registry/config.yml
   ```

1. If the command completed successfully, all images are now fully imported. You
   can now enable the database and turn off read-only mode in the configuration:

   ```yaml
   registry:
     enabled: true
     maintenance:        # this section can be removed
       readonly:
         enabled: false
     database:
       configure: true  # once database.enabled is set to true, this option can be removed
       enabled: true   # must be true!
       name: registry  # must match the database name you created above
       user: registry  # must match the database username you created above
       password:
         secret: gitlab-registry-database-password  # must match the secret name
         key: password  # must match the secret key to read the password from
       sslmode: verify-full  # SSL connection mode. See https://www.postgresql.org/docs/current/libpq-ssl.html#LIBPQ-SSL-PROTECTION for more options.
       ssl:
         secret: gitlab-registry-postgresql-ssl  # you will need to create this secret manually
         clientKey: client-key.pem
         clientCertificate: client-cert.pem
         serverCA: server-ca.pem
       migrations:
         enabled: true  # this option will execute the schema migration as part of the registry deployment
   ```

1. Save the file and upgrade your Helm installation to apply changes in your deployment:

   ```shell
   helm upgrade gitlab gitlab/gitlab -f values.yml
   ```

You can now use the metadata database for all operations!

##### Step 3. Import common blobs

The registry is now fully using the database for its metadata, but it
does not yet have access to any potentially unused layer blobs.

To complete the process, run the final step of the migration:

```shell
cd ~
/usr/bin/registry database import --step-three /etc/docker/registry/config.yml
```

After the command completes successfully, the registry is now fully migrated to the database!

## Database migrations

The container registry supports two types of migrations:

- **Regular schema migrations**: Changes to the database structure that must run before deploying new application code. These should be fast to avoid deployment delays.

- **Post-deployment migrations**: Changes to the database structure that can run while the application is running. Used for longer operations like creating indexes on large tables, avoiding startup delays and extended upgrade downtime.

### Apply database migrations

By default, the registry chart applies both regular schema and post-deployment migrations automatically if `database.migrations.enabled` is set to `true`.

To reduce downtime during upgrades, you can skip post-deployment migrations and apply them manually after the application starts:

1. Set the `SKIP_POST_DEPLOYMENT_MIGRATIONS` environment variable to `true` using `ExtraEnv` for the registry deployment:

   ```yaml
   registry:
     extraEnv:
       SKIP_POST_DEPLOYMENT_MIGRATIONS: true
   ```

1. After upgrading, [connect to a registry pod](_index.md#running-administrative-commands-against-the-container-registry).

1. Apply pending post-deployment migrations:

   ```shell
   registry database migrate up /etc/docker/registry/config.yml
   ```

{{< alert type="note" >}}

The `migrate up` command offers some extra flags that can be used to control how the migrations are applied.
Run `registry database migrate up --help` for details.

{{< /alert >}}

## Troubleshooting

### Error: `panic: interface conversion: interface {} is nil, not bool`

When importing existing registries, you might see this error:

```shell
panic: interface conversion: interface {} is nil, not bool
```

This is a known [issue](https://gitlab.com/gitlab-org/container-registry/-/merge_requests/2041)
that is fixed in registry version `v4.15.2-gitlab` and in GitLab 17.9 and later.

To work around this issue, upgrade your registry version:

1. In your `values.yml` file, set the registry image tag:

   ```yaml
   registry:
     image:
       tag: v4.15.2-gitlab
   ```

1. Upgrade your Helm installation:

   ```shell
   helm upgrade gitlab -f values.yml
   ```

Alternatively, you can manually update the registry configuration:

- In `/etc/docker/registry/config.yml`, set `parallelwalk` to `false` for your storage provider. For example, with S3:

  ```yaml
  storage:
    s3:
      parallelwalk: false
  ```
