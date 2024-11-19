---
stage: Systems
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
---

# Using certmanager-issuer for CertManager Issuer creation

DETAILS:
**Tier:** Free, Premium, Ultimate
**Offering:** Self-managed

This chart is a helper for [Jetstack's CertManager Helm chart](https://cert-manager.io/docs/installation/helm/).
It automatically provisions an Issuer object, used by CertManager when requesting TLS certificates for
GitLab Ingresses.

## Configuration

We describe all the major sections of the configuration below. When configuring
from the parent chart, these values are:

```yaml
certmanager-issuer:
  # Configure an ACME Issuer in cert-manager. Only used if global.ingress.configureCertmanager is true.
  server: https://acme-v02.api.letsencrypt.org/directory

  # Provide an email to associate with your TLS certificates
  # email:

  rbac:
    create: true

  resources:
    requests:
      cpu: 50m

  # Priority class assigned to pods
  priorityClassName: ""

  common:
    labels: {}
```

## Installation parameters

This table contains all the possible charts configurations that can be supplied
to the `helm install` command using the `--set` flags:

| Parameter                                           | Default                                          | Description                                                                                                                                                                        |
|-----------------------------------------------------|--------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `server`                                            | `https://acme-v02.api.letsencrypt.org/directory` | Let's Encrypt server for use with the [ACME CertManager Issuer](https://cert-manager.io/docs/configuration/acme/).                                                                 |
| `email`                                             |                                                  | You must provide an email to associate with your TLS certificates. Let's Encrypt uses this address to contact you about expiring certificates, and issues related to your account. |
| `rbac.create`                                       | `true`                                           | When `true`, creates RBAC-related resources to allow for manipulation of CertManager Issuer objects.                                                                               |
| `resources.requests.cpu`                            | `50m`                                            | Requested CPU resources for the Issuer creation Job.                                                                                                                               |
| `common.labels`                                     |                                                  | Common labels to apply to the ServiceAccount, Job, ConfigMap, and Issuer.                                                                                                          |
| `priorityClassName`                                 |                                                  | [Priority class](https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/) assigned to pods.                                                               |
| `containerSecurityContext`                          |                                                  | Override container [securityContext](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#securitycontext-v1-core) under which Certmanager is started              |
| `containerSecurityContext.runAsUser`                | `65534`                                          | User ID under which the container should be started                                                                                                                                |
| `containerSecurityContext.runAsGroup`               | `65534`                                          | Group ID under which the container should be started                                                                                                                               |
| `containerSecurityContext.allowPrivilegeEscalation` | `false`                                          | Controls whether a process can gain more privileges than its parent process                                                                                                        |
| `containerSecurityContext.runAsNonRoot`             | `true`                                           | Controls whether the container runs with a non-root user                                                                                                                           |
| `containerSecurityContext.capabilities.drop`        | `[ "ALL" ]`                                      | Removes [Linux capabilities](https://man7.org/linux/man-pages/man7/capabilities.7.html) for the container                                                                          |
