---
stage: Systems
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: Our NGINX fork
---

{{< details >}}

- Tier: Free, Premium, Ultimate
- Offering: GitLab Self-Managed

{{< /details >}}

Our [fork](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/charts/nginx-ingress) of the NGINX chart was pulled from [GitHub](https://github.com/kubernetes/ingress-nginx).

## Adjustments to the NGINX fork

The following adjustments were made to the NGINX fork:

- `tcp-configmap.yaml`: is optional depending on new `tcpExternalConfig` setting
- Ability to use a templated TCP ConfigMap name from another chart
  - `controller-configmap-tcp.yaml`: `.metadata.name` is a template `ingress-nginx.tcp-configmap`
  - `controller-deployment.yaml`: `.spec.template.spec.containers[0].args` uses `ingress-nginx.tcp-configmap` template for ConfigMap name
  - GitLab chart overrides `ingress-nginx.tcp-configmap` so that `gitlab/gitlab-org/charts/gitlab-shell` can configure its TCP service
- Ability to use a templated Ingress name based on the release name
- Replace `controller.service.loadBalancerIP` with `externalIpTpl` (defaults to `global.hosts.externalIP` )
- Added support to add common labels through `common.labels` configuration option
- `controller-deployment.yaml`:
  - Add `podlabels` and `global.pod.labels` to `.spec.template.metadata.labels`
- `default-backend-deployment.yaml`:
  - Add `podlabels` and `global.pod.labels` to `.spec.template.metadata.labels`
- Disable NGINX's default nodeSelectors.
- Added support for PDB `maxUnavailable`.
- Remove NGINX's `isControllerTagValid` helper in `charts/nginx-ingress/templates/_helpers.tpl`
  - The check had not been updated since it was [implemented](https://github.com/kubernetes/ingress-nginx/pull/5252) in 2020.
  - As part of [#3383](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/3383), we need to refer to a tag that will contain `ubi`,
    meaning that the `semverCompare` would not work as expected anyway.
- Added support for autoscaling/v2beta2 and autoscaling/v2 APIs in HPAs and
  extended HPA settings to support memory and custom metrics, as well as
  behavior configuration.
- Added conditional support for API version of PodDisruptionBudget.
- Add the following booleans to enable/disable GitLab Shell (SSH access) independently for the external and internal (if enabled with `controller.service.internal.enabled`) services:
  - `controller.service.enableShell`.
  - `controller.service.internal.enableShell`.
  (follows the exisiting chart pattern of `controller.service.enableHttp(s)`)
- Add the template call `{{ include "ingress-nginx.automountServiceAccountToken" . }}` to `controller-serviceaccount.yaml`
- Add the template to `_helpers.tpl`:

  ```go
  {{/*
  Set if the default ServiceAccount token should be mounted by Kubernetes or not.

  Default is 'true'
  */}}
  {{- define "ingress-nginx.automountServiceAccountToken" -}}
  automountServiceAccountToken: {{ pluck "automountServiceAccountToken" .Values.serviceAccount .Values.global.serviceAccount | first }}
  {{- end -}}
  ```

- Add the template call `{{ include "ingress-nginx.defaultBackend.automountServiceAccountToken" . }}` to `default-backend-serviceaccount.yaml`
- Add the template to `_helpers.tpl`:

  ```go
  {{/*
  Set if the default ServiceAccount token should be mounted by Kubernetes or not.

  Default is 'true'
  */}}
  {{- define "ingress-nginx.defaultBackend.automountServiceAccountToken" -}}
  automountServiceAccountToken: {{ pluck "automountServiceAccountToken" .Values.defaultBackend.serviceAccount .Values.global.serviceAccount | first }}
  {{- end -}}
  ```

- Add the following attributes to comply with Pod Security Standards Profile Restricted:
  - `controller-deployment.yaml`
    - `spec.template.spec.containers[0].securityContext.runAsNonRoot`
    - `spec.template.spec.containers[0].securityContext.seccompProfile`
- Add the following new RBAC rules. This is necessary while our chart is on 4.0.6, but we've bumped the controller image to 1.11.2. Once we bring the chart to 4.11.2, we can remove this patch. It was required because the controller now uses endpointslices to track endpoints.
  This was added to both: `charts/nginx-ingress/templates/clusterrole.yaml` and `charts/nginx-ingress/templates/controller-role.yaml`:

  ```yaml
  - apiGroups:
      - discovery.k8s.io
    resources:
      - endpointslices
    verbs:
      - list
      - watch
      - get
  ```
  
  Additionally, to support migration from v1.3.1 to v1.11.2, for those users that set their own RBAC rules, we've also
  added these values which will be removed, once we drop the v1.3.1 fallback, which is scheduled for 8.8 release.

  ```yaml
  controller:
    image:
      fallbackTag: "v1.3.1"
      fallbackDigest: "sha256:54f7fe2c6c5a9db9a0ebf1131797109bb7a4d91f56b9b362bde2abd237dd1974"
      disableFallback: false
  ```
