---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Migrating from Helm v2 to Helm v3

You can use [Helm 2to3 plugin](https://github.com/helm/helm-2to3) to migrate Helm 2 GitLab releases to
Helm 3:

```shell
helm 2to3 convert YOUR-GITLAB-RELEASE
```

## Known Issues

### "UPGRADE FAILED: cannot patch" error is shown after the migration

After migration the **subsequent upgrades may fail** with an error similar to the following:

```shell
Error: UPGRADE FAILED: cannot patch "..." with kind Deployment: Deployment.apps "..." is invalid: spec.selector:
Invalid value: v1.LabelSelector{...}: field is immutable
```

or

```shell
Error: UPGRADE FAILED: cannot patch "..." with kind StatefulSet: StatefulSet.apps "..." is invalid:
spec: Forbidden: updates to statefulset spec for fields other than 'replicas', 'template', and 'updateStrategy' are forbidden
```

This is due to known issues with Helm 2 to 3 migration in [Cert Manager](https://github.com/jetstack/cert-manager/issues/2451)
and [Redis](https://github.com/bitnami/charts/issues/3482) dependencies. In a nutshell, the `heritage` label
on some Deployments and StatefulSets are immutable and can not be changed from `Tiller` (set by Helm 2) to `Helm`
(set by Helm 3). So they must be replaced _forcefully_.

To work around this use the following instructions:

NOTE:
These instructions _forcefully replace resources_, notably Redis StatefulSet.
You need to ensure that the attached data volume to this StatefulSet is safe and remains intact.

1. Replace cert-manager Deployments (when enabled).

```shell
kubectl get deployments -l app=cert-manager -o yaml | sed "s/Tiller/Helm/g" | kubectl replace --force=true -f -
kubectl get deployments -l app=cainjector -o yaml | sed "s/Tiller/Helm/g" | kubectl replace --force=true -f -
```

1. (Optional) Set `persistentVolumeReclaimPolicy` to `Retain` on the PV that is claimed by Redis StatefulSet.
   This is to ensure that the PV won't be deleted inadvertently.

```shell
kubectl patch pv <PV-NAME> -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
```

1. Set `heritage` label of the existing Redis PVC to `Helm`.

```shell
kubectl label pvc -l app=redis --overwrite heritage=Helm
```

1. Replace Redis StatefulSet **without cascading**.

```shell
kubectl get statefulsets.apps -l app=redis -o yaml | sed "s/Tiller/Helm/g" | kubectl replace --force=true --cascade=false -f -
```

### RBAC issues after the migration when running Helm upgrade

You may face the following error when running Helm upgrade after the conversion has been completed:

```shell
Error: UPGRADE FAILED: pre-upgrade hooks failed: warning: Hook pre-upgrade gitlab/templates/shared-secrets/rbac-config.yaml failed: roles.rbac.authorization.k8s.io "gitlab-shared-secrets" is forbidden: user "your-user-name@domain.tld" (groups=["system:authenticated"]) is attempting to grant RBAC permissions not currently held:
{APIGroups:[""], Resources:["secrets"], Verbs:["get" "list" "create" "patch"]}
```

Helm2 used the Tiller service account to perform such operations. Helm3 does not use Tiller anymore, and your user account should have proper RBAC permissions to run the command even if you are running `helm upgrade` as a cluster admin. To grant full RBAC permissions to yourself, run:

```shell
kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=your-user-name@domain.tld
```

After that, `helm upgrade` should work fine.
