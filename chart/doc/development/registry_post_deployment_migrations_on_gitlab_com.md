---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: Container registry post deployment migrations on gitlab.com
---

## Container Registry post deployment migrations on GitLab.com

{{< alert type="warning" >}}

**This procedure is ONLY for GitLab.com infrastructure and should NOT be used by external users.**
This approach is complex, error-prone, and designed specifically for GitLab.com's unique infrastructure requirements.

Instead, use the [standard manual migration procedure](../charts/registry/metadata_database.md#apply-database-migrations) which is:

- Safer
- Fully supported and documented
- The recommended approach for all GitLab installations

{{< /alert >}}

Executing Container Registry post deployment migrations after the Container Registry application starts is recommended,
to reduce downtime during upgrades.

However, the [recommended procedure](../charts/registry/metadata_database.md#apply-database-migrations) is to execute
them manually by connecting to a registry pod.

On GitLab.com, there is a need to automate the execution of post-deployment migrations. The newly introduced
[`registry.api.enabled`](../charts/registry/_index.md#enable-resources-required-for-the-application)
value will be used to do this. However, this procedure is sufficiently complex and error-prone that we are not recommending
it for general consumption. Read the [future plans](#future-plans) section for an automation procedure that will be
recommended in the future.

### GitLab.com specific automation

The first step is to perform the Container Registry deployment with `SKIP_POST_DEPLOYMENT_MIGRATIONS` set to `true`
as described in the [registry documentation](../charts/registry/metadata_database.md#apply-database-migrations).
This skips post deployment migrations during the deployment, and allows us to execute them after the application starts.

After upgrading the Container Registry application, we apply pending post-deployment migrations by setting
`SKIP_POST_DEPLOYMENT_MIGRATIONS` to false and setting `registry.api.enabled` to `false`.

Note that this is executed as a separate "migrations" Helm release from the release that deploys the application.

Executing post-deploy migrations using the same Helm release used to deploy the application, and setting `registry.api.enabled`
to `false` will remove the Service, Deployment and other resources. The Service, Deployment and other resources
should already exist from a prior installation of the chart, in a different namespace. Setting `registry.api.enabled`
to `false` in the migrations Helm release prevents duplicate resources from being created in the "migrations" namespace.

```yaml
registry:
  api:
    enabled: false
  extraEnv:
    SKIP_POST_DEPLOYMENT_MIGRATIONS: false
```

### Future plans

This procedure isn't ideal and is planned to be deprecated and removed once we refactor migration execution for the Registry
chart into a sub-chart. This is being tracked in <https://gitlab.com/gitlab-org/charts/gitlab/-/issues/6107>.
