---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Using Traefik **(FREE SELF)**

The [Traefik Helm chart](https://artifacthub.io/packages/helm/traefik/traefik) can replace the
[bundled NGINX Helm chart](../nginx/index.md) as the Ingress controller.

Traefik will [translate the native Kubernetes Ingress](https://doc.traefik.io/traefik/providers/kubernetes-ingress/) objects into
[IngressRoute](https://doc.traefik.io/traefik/routing/providers/kubernetes-crd/#kind-ingressroute) objects.

Traefik also supports Git over SSH via
[IngressRouteTCP](https://doc.traefik.io/traefik/routing/providers/kubernetes-crd/#kind-ingressroutetcp)
objects, which are deployed by the GitLab Shell chart when [`global.ingress.provider`](../globals.md#configure-ingress-settings) is configured as `traefik`.

## Configuring Traefik

See the [Traefik Helm chart documentation](https://github.com/traefik/traefik-helm-chart/tree/master/traefik)
for configuration details.

See the [Traefik example configuration](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples/values-traefik-ingress.yaml)
for detailed YAML for values tested with the GitLab Helm Charts.

### Global Settings

We share some common global settings among our charts. See the [Global Ingress documentation](../globals.md#configure-ingress-settings)
for common configuration options, such as GitLab and Registry hostnames.

### FIPS-compliant Traefik

[Traefik Enterprise](https://doc.traefik.io/traefik-enterprise/) provides FIPS compliance. Note that Traefik Enterprise requires
a license, which is not included as part of this chart.

Following are links for more information on Traefik Enterprise:

- [Traefik Enterprise features](https://doc.traefik.io/traefik/providers/kubernetes-ingress/)
- [Traefik Enterprise FIPS image](https://doc.traefik.io/traefik-enterprise/operations/fips-image/)
- [Traefik Enterprise Helm chart](https://doc.traefik.io/traefik-enterprise/installing/kubernetes/helm/)
- [Traefik Enterprise Operator on ArtifactHub](https://artifacthub.io/packages/olm/community-operators/traefikee-operator)
- [Traefik Enterprise Certified OpenShift Operator on RedHat Catalog](https://catalog.redhat.com/software/operators/detail/5e98745a6c5dcb34dfbb1a0a)
