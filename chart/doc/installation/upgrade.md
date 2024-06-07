---
stage: Systems
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
---

# Upgrade the GitLab chart

DETAILS:
**Tier:** Free, Premium, Ultimate
**Offering:** Self-managed

Before upgrading your GitLab installation, you need to check the
[changelog](https://gitlab.com/gitlab-org/charts/gitlab/blob/master/CHANGELOG.md)
corresponding to the specific release you want to upgrade to and look for any
[release notes](version_mappings.md#release-notes-for-each-version) that might pertain to the new GitLab chart
version.

Upgrades have to follow a supported [upgrade path](https://docs.gitlab.com/ee/update/#upgrade-paths).
Because the GitLab chart versions don't follow the same numbering as GitLab versions,
see the [version mappings](version_mappings.md) between them.

NOTE:
**Zero-downtime upgrades** are not available with the GitLab charts.
Ongoing work to support this feature can be tracked via
[the GitLab Operator epic](https://gitlab.com/groups/gitlab-org/cloud-native/-/epics/52).

We also recommend that you take a [backup](../backup-restore/index.md) first. Also note that you
must provide all values using `helm upgrade --set key=value` syntax or `-f values.yaml` instead of
using `--reuse-values`, because some of the current values might be deprecated.

You can retrieve your previous `--set` arguments cleanly, with
`helm get values <release name>`. If you direct this into a file
(`helm get values <release name> > gitlab.yaml`), you can safely pass this
file via `-f`. Thus `helm upgrade gitlab gitlab/gitlab -f gitlab.yaml`.
This safely replaces the behavior of `--reuse-values`

## Steps

NOTE:
If you're upgrading to the `7.0` version of the chart, follow the [manual upgrade steps for 7.0](#upgrade-to-version-70).
If you're upgrading to the `6.0` version of the chart, follow the [manual upgrade steps for 6.0](#upgrade-to-version-60).
If you're upgrading to an older version of the chart, follow the [upgrade steps for older versions](upgrade_old.md).

Before you upgrade, reflect on your set values and if you've possibly "over-configured" your settings. We expect you to maintain a small list of modified values, and leverage most of the chart defaults. If you've explicitly set a large number of settings by:

- Copying computed settings
- Copying all settings and explicitly defining values that are actually the same as the default values

This will almost certainly cause issues during the upgrade as the configuration structure could have changed across versions, and that will cause problems applying the settings. We cover how to check this in the following steps.

The following are the steps to upgrade GitLab to a newer version:

1. Check the [change log](https://gitlab.com/gitlab-org/charts/gitlab/blob/master/CHANGELOG.md) for the specific version you would like to upgrade to.
1. Go through the [deployment documentation](deployment.md) step by step.
1. Extract your previously provided values:

   ```shell
   helm get values gitlab > gitlab.yaml
   ```

1. Decide on all the values you need to carry through as you upgrade. GitLab has reasonable default values, and while upgrading, you can attempt to pass in all values from the above command, but it could create a scenario where a configuration has changed across chart versions and it might not map cleanly. We advise keeping a minimal set of values that you want to explicitly set, and passing those during the upgrade process.
1. Perform the upgrade, with values extracted in the previous step:

   ```shell
   helm upgrade gitlab gitlab/gitlab \
     --version <new version> \
     -f gitlab.yaml \
     --set gitlab.migrations.enabled=true \
     --set ...
   ```

During a major database upgrade, we ask you to set `gitlab.migrations.enabled` set to `false`.
Ensure that you explicitly set it back to `true` for future updates.

## Upgrade the bundled PostgreSQL chart

NOTE:
If you aren't using the bundled PostgreSQL chart (`postgresql.install` is false), you do not need to
perform this step.

### Upgrade the bundled PostgreSQL to version 13

PostgreSQL 13 is supported by GitLab 14.1 and later. [PostgreSQL 13 brings significant performance improvements](https://www.postgresql.org/about/news/postgresql-13-released-2077/).

To upgrade the bundled PostgreSQL to version 13, the following steps are required:

1. [Prepare the existing database](database_upgrade.md#prepare-the-existing-database).
1. [Delete existing PostgreSQL data](database_upgrade.md#delete-existing-postgresql-data).
1. Update the `postgresql.image.tag` value to `13.6.0` and [reinstall the chart](database_upgrade.md#upgrade-gitlab) to create a new PostgreSQL 13 database.
1. [Restore the database](database_upgrade.md#restore-the-database).

## Upgrade to version 7.0

WARNING:
If you are upgrading from the `6.x` version of the chart to the latest `7.0` release, you need
to first update to the latest `6.11.x` patch release in order for the upgrade to work.
The [7.0 release notes](../releases/7_0.md) describe the supported upgrade path.

The `7.0.x` release may require manual steps in order to perform the upgrade.

- If using the bundled [`bitnami/Redis`](https://artifacthub.io/packages/helm/bitnami/redis) sub-chart
  to provide an in-cluster Redis service - you'll need to manually delete the StatefulSet for
  Redis prior to upgrading to version 7.0 of the GitLab chart. Follow the setups in [Upgrade the bundled Redis sub-chart](#update-the-bundled-redis-sub-chart) below.

### Update the bundled Redis sub-chart

Release 7.0 of the GitLab chart updates the bundled [`bitnami/Redis`](https://artifacthub.io/packages/helm/bitnami/redis)
sub-chart to version `16.13.2` from the previously installed `11.3.4`. Due to
changes in `matchLabels` applied to the `redis-master` StatefulSet in the sub-chart,
upgrading without manually deleting the StatefulSet will result in the following error:

```shell
Error: UPGRADE FAILED: cannot patch "gitlab-redis-master" with kind StatefulSet: StatefulSet.apps "gitlab-redis-master" is invalid: spec: Forbidden: updates to statefulset spec for fields other than 'replicas', 'template', 'updateStrategy' and 'minReadySeconds' are forbidden
```

To delete the StatefulSet for `RELEASE-redis-master`:

1. Scale down the replicas to `0` for the `webservice`, `sidekiq`, `kas`, and `gitlab-exporter` deployments:

   ```shell
   kubectl scale deployment --replicas 0 --selector 'app in (webservice, sidekiq, kas, gitlab-exporter)' --namespace <namespace>
   ```

1. Delete the `RELEASE-redis-master` StatefulSet:

   ```shell
   kubectl delete statefulset RELEASE-redis-master --namespace <namespace>
   ```

   - `<namespace>` should be replaced with the namespace where you installed the GitLab chart.

Then follow the [standard upgrade steps](#steps). Due to how Helm merges changes, you may need to scale up the deployments
you scaled down in step one manually.

### Use of `global.redis.password`

In order to mitigate a configuration type conflict with the use of `global.redis.password`
we've deprecated the use of `global.redis.password` in favor of `global.redis.auth`.

In addition to displaying a deprecation notice - if you see the following warning
message from `helm upgrade`:

```plaintext
coalesce.go:199: warning: destination for password is a table. Ignoring non-table value
```

This is an indication that you are setting `global.redis.password` in your values file.

### `useNewIngressForCerts` on Ingresses

If you are upgrading an existing chart from `7.x` to a later version, and are changing
`global.ingress.useNewIngressForCerts` to `true`, you must also update any existing
cert-manager `Certificate` objects to delete the `acme.cert-manager.io/http01-override-ingress-name` annotation.

You must make this change because with this attribute set to `false` (default),
this annotation is added by default to the Certificates, and cert-manager uses
it to identify which Ingress method to use for that certificate. The annotation
is not automatically removed by only changing this attribute to `false`.
A manual action is needed otherwise cert-manager keeps using the old
behavior for pre-existing Ingresses.

## Upgrade to version 6.0

WARNING:
If you are upgrading from the `5.x` version of the chart to the latest `6.0` release, you need
to first update to the latest `5.10.x` patch release in order for the upgrade to work.
The [6.0 release notes](../releases/6_0.md) describe the supported upgrade path.

To upgrade to the `6.0` release you must first be on the latest `5.10.x` patch release. There isn't any additional manual changes required in `6.0` so you can [follow the regular release upgrade steps](#steps).
