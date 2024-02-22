---
stage: Systems
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
---

# Manage the container registry metadata database

DETAILS:
**Tier:** Free, Premium, Ultimate
**Offering:** Self-managed
**Status:** Beta

> - [Introduced](https://gitlab.com/groups/gitlab-org/-/epics/5521) in GitLab 16.4 as a [Beta](https://docs.gitlab.com/ee/policy/experiment-beta-support.html#beta) feature.

The metadata database enables many new registry features, including
online garbage collection, and increases the efficiency of many registry operations.
This page contains information on how to create the database.

## Metadata database feature support

You can migrate existing registries to the metadata database, and use online garbage collection.

Some database-enabled features are only enabled for GitLab.com and automatic database provisioning for
the registry database is not available. Review the feature support table in the [feedback issue](https://gitlab.com/gitlab-org/gitlab/-/issues/423459#supported-feature-status)
for the status of features related to the container registry database.

## Create the database

Follow the steps below to manually create the database and role.

NOTE:
These instructions assume you are using the bundled PostgreSQL server. If you are using your own server,
there will be some variation in how you connect.

1. Create the secret with the database password:

   ```shell
   kubectl create secret generic RELEASE_NAME-registry-database-password --from-literal=password=randomstring
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

## Enable the metadata database for Helm charts installations

Prerequisites:

- GitLab 16.4 or later.
- PostgreSQL database version 12 or later, accessible from the registry pods.
- Access to the Kubernetes cluster and the Helm deployment locally.
- SSH access to the registry pods.

Follow the instructions that match your situation:

- [New installation](#new-installations) or enabling the container registry for the first time.
- Migrate existing container images to the metadata database:
  - [One-step migration](#one-step-migration). Only recommended for relatively small registries or no requirement to avoid downtime.
  - [Three-step migration](#three-step-migration). Recommended for larger container registries.

NOTE:
Users have reported the one-step import completed at [rates of 2 to 4 TB per hour](https://gitlab.com/gitlab-org/gitlab/-/issues/423459).
At the slower speed, registries with over 100 TB of data could take longer than 48 hours.

### Before you start

Read the [before you start](https://docs.gitlab.com/ee/administration/packages/container_registry_metadata_database.html#before-you-start)
section of the Registry administration guide.

### New installations

To enable the database:

1. [Create the database and Kubernetes secret](#create-the-database).
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
     ssl:
       secret: gitlab-registry-postgresql-ssl # you will need to create this secret manually
       clientKey: client-key.pem
       clientCertificate: client-cert.pem
       serverCA: server-ca.pem
     migrations:
       enabled: true  # this option will execute the schema migration as part of the registry deployment
   ```

1. Optional. You can verify the schema migrations have been applied properly.
   You can either:
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

### Existing registries

You can migrate your existing container registry data in one step or three steps.
A few factors affect the duration of the migration:

- The size of your existing registry data.
- The specifications of your PostgresSQL instance.
- The number of registry pods running in your cluster.
- Network latency between the registry, PostgresSQL and your configured Object Storage.

NOTE:
Work to automate the migration process is being tracked in [issue 5293](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/5293).

#### One-step migration

When doing a one-step migration, be aware that:

- The registry must remain in `read-only` mode during the migration.
- If the Pod where the migration is being executed is terminated,
  you have to completely restart the process. The work to improve this process is tracked in
  [issue 5293](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/5293).

1. [Create the database and Kubernetes secret](#create-the-database).
1. Get the current Helm values for your release and save them into a file.
   For example, for a release named `gitlab` and a file named `values.yml`:

   ```shell
   helm get values gitlab > values.yml
   ```

1. Find the `registry:` section in the `values.yml` file and
   add the `database` section, set the `maintenance.readonly.enabled`
   flag to `true`, and `migrations.enabled` to `true`:

   ```yaml
   registry:
     priorityClassName: system-node-critical
     enabled: true
     maintenance:
       readonly:
         enabled: true  # must remain set to true while the migration is executed
     database:
       enabled: true
       name: registry  # must match the database name you created above
       user: registry  # must match the database username you created above
       password:
         secret: gitlab-registry-database-password # must match the secret name
         key: password  # must match the secret key to read the password from
           sslmode: verify-full
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

1. Update the registry configuration to disable read-only mode:

   ```yaml
   registry:
     enabled: true
     maintenance:
       readonly:
         enabled: false
     database:
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

#### Three-step migration

WARNING:
The three-step process is not yet available for Helm chart installations,
due to a [known limitation](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/5292).
