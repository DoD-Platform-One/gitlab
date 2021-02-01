---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Our NGINX fork

Our [fork](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/charts/nginx-ingress) of the NGINX chart was pulled from [GitHub](https://github.com/kubernetes/ingress-nginx).

## Adjustments to the NGINX fork

The following adjustments were made to the NGINX fork:

- `tcp-configmap.yaml`: is optional depending on new `tcpExternalConfig` setting
- Ability to use a templated tcp configmap name from another chart
  - `controller-configmap-tcp.yaml`: `.metadata.name` is a template `ingress-nginx.tcp-configmap`
  - `controller-deployment.yaml`: `.spec.template.spec.containers[0].args` uses `ingress-nginx.tcp-configmap` template for configmap name
  - GitLab chart overrides `ingress-nginx.tcp-configmap` so that `gitlab/gitlab-org/charts/gitlab-shell` can configure its tcp service
- Ability to use a templated Ingress name based on the release name
  - `controller-deployment.yaml`: `.spec.template.spec.containers[0].args` uses `ingress-nginx.controller.ingress-class`
  - `role.yaml`: rule for editing leader configmap uses `ingress-nginx.controller.ingress-class`
- Replace `controller.service.loadBalancerIP` with `global.hosts.externalIP`
