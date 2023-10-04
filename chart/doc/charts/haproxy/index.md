---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Using HAProxy **(FREE SELF)**

The [HAProxy Helm Chart](https://github.com/haproxytech/helm-charts/tree/main/kubernetes-ingress) can replace the
[bundled NGINX Helm chart](../nginx/index.md) as the Ingress controller, and is documented in Kubernetes'
[list of additional Ingress controllers](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/#additional-controllers).

HAProxy will also support Git over SSH.

We default to [NGINX](../nginx/index.md) mostly due to historical experience with the tool, but HAProxy is a valid alternative that may be
preferable to those who have more experience with HAProxy specifically. Additionally, it offers [FIPS compliance](#fips-compliant-haproxy)
while the [NGINX Ingress controller](https://github.com/kubernetes/ingress-nginx) currently does not.

## Configuring HAProxy

See the [HAProxy Helm chart documentation](https://www.haproxy.com/documentation/kubernetes/latest/community/configuration-reference/)
or the [Helm values file](https://github.com/haproxytech/helm-charts/blob/main/kubernetes-ingress/values.yaml).
for configuration details.

See the [HAProxy example configuration](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples/values-haproxy-ingress.yaml)
for detailed YAML for values tested with the GitLab Helm Charts.

### Global Settings

We share some common global settings among our charts. See the [Global Ingress documentation](../globals.md#configure-ingress-settings)
for common configuration options, such as GitLab and Registry hostnames.

### FIPS-compliant HAProxy

[HAProxy Enterprise](https://www.haproxy.com/products/haproxy-enterprise-kubernetes-ingress-controller) provides FIPS compliance.
Note that HAProxy Enterprise requires a license.

Following are links for more information on HAProxy Enterprise:

- [HAProxy Enterprise landing page](https://www.haproxy.com/products/haproxy-enterprise)
- [HAProxy FIPS compliance blog post](https://www.haproxy.com/blog/become-fips-compliant-with-haproxy-enterprise-on-red-hat-enterprise-linux-8)
- [Certified OpenShift Operator](https://catalog.redhat.com/software/container-stacks/detail/5ec3f9fc110f56bd24f2dd57)
- [How to use an image from a private registry](https://github.com/haproxytech/helm-charts/blob/kubernetes-ingress-1.22.0/haproxy/README.md#installing-from-a-private-registry)
- [How to find the HAProxy Enterprise image](https://www.haproxy.com/documentation/hapee/latest/getting-started/installation/docker/)
