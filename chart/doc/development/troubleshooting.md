---
stage: Systems
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
---

# Troubleshooting GitLab chart development environment

All steps noted here are for **DEVELOPMENT ENVIRONMENTS ONLY**.
Administrators may find the information insightful, but the outlined fixes
are destructive and would have a major negative impact on production
systems.

## Passwords and secrets failing or unsynchronized

Developers commonly deploy, delete, and re-deploy a release into the same
cluster multiple times. Kubernetes secrets and persistent volume claims created by StatefulSets are
intentionally not removed by `helm delete RELEASE_NAME`.

Removing only the Kubernetes secrets leads to interesting problems. For
example, a new deployment's migration pod will fail because **GitLab Rails**
cannot connect to the database because it has the wrong password.

To completely wipe a release from a development environment including
secrets, a developer must remove both the secrets and the persistent volume
claims.

```shell
# DO NOT run these commands in a production environment. Disaster will strike.
kubectl delete secrets,pvc -lrelease=RELEASE_NAME
```

NOTE:
This deletes all Kubernetes secrets including TLS certificates and all data
in the database. This should not be performed in a production instance.

## Database is broken and needs reset

The database environment can be reset in a development environment by:

1. Delete the PostgreSQL StatefulSet
1. Delete the PostgreSQL PersistentVolumeClaim
1. Deploy GitLab again with `helm upgrade --install`

NOTE:
This will delete all data in the databases and should not be run in
production.

## CI clusters are low on available resources

You may notice one or more CI clusters run low on available resources like CPU
and memory. Our clusters are configured to automatically scale the available
nodes, but sometimes we hit the upper limit and therefore no more nodes can be
created. In this case, a good first step is to see if any installations of the
GitLab Helm Charts in the clusters can be removed.

Installations are usually cleaned up automatically by the Review Apps logic in
the pipeline, but this can fail for various reasons. See the following issues
for more details:

- [What can we do about cleaning up failed deploys in CI?](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/2076)
- [https://gitlab.com/gitlab-org/charts/gitlab/-/issues/5338](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/5338)

As a workaround, these installations can be manually deleted by running the associated
`stop_review` job(s) in CI. To make this easier, use the
[`helm_ci_triage.sh`](https://gitlab.com/gitlab-org/charts/gitlab/blob/master/scripts/ci/helm_ci_triage.sh)
script to get a list of running installations and open the associated pipeline to run
the `stop_review` job(s). Further usage details are available in the script.
