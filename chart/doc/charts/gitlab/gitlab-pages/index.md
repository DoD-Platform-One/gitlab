---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Using the GitLab Pages chart

The `gitlab-pages` subchart provides a daemon for serving static websites from
GitLab projects.

## Requirements

This chart depends on access to the Workhorse services, either as part of the
complete GitLab chart or provided as an external service reachable from the Kubernetes
cluster this chart is deployed onto.

## Configuration

The `gitlab-pages` chart is configured as follows: [Global
Settings](#global-settings) and [Chart Settings](#chart-settings).

## Global Settings

We share some common global settings among our charts. See the
[Globals Documentation](../../globals.md#configure-gitlab-pages) for details.

## Chart settings

The tables in following two sections contains all the possible chart
configurations that can be supplied to the `helm install` command using the
`--set` flags.

### General settings

| Parameter                                 | Default           | Description                                              |
| ----------------------------------------- | ----------------- | -------------------------------------------------------- |
| `annotations`                             |                   | Pod annotations                                          |
| `common.labels`                           | `{}`              | Supplemental labels that are applied to all objects created by this chart. |
| `deployment.strategy`                     | `{}`              | Allows one to configure the update strategy used by the deployment. When not provided, the cluster default is used. |
| `extraEnv`                                |                   | List of extra environment variables to expose            |
| `image.pullPolicy`                        | `IfNotPresent`    | GitLab image pull policy                                 |
| `image.pullSecrets`                       |                   | Secrets for the image repository                         |
| `image.repository`                        | `registry.gitlab.com/gitlab-org/build/cng/gitlab-exporter` | GitLab Exporter image repository |
| `image.tag`                               |                   | image tag                                                |
| `init.image.repository`                   |                   | initContainer image                                      |
| `init.image.tag`                          |                   | initContainer image tag                                  |
| `metrics.enabled`                         | `true`            | Toggle Prometheus metrics exporter                       |
| `metrics.port`                            | `9235`            | Listen port for the Prometheus metrics exporter          |
| `podLabels`                               |                   | Supplemental Pod labels. Will not be used for selectors. |
| `resources.requests.cpu`                  | `75m`             | GitLab Pages minimum CPU                                 |
| `resources.requests.memory`               | `100M`            | GitLab Pages minimum memory                              |
| `securityContext.fsGroup`                 | `1000`            | Group ID under which the pod should be started           |
| `securityContext.runAsUser`               | `1000`            | User ID under which the pod should be started            |
| `service.externalPort`                    | `8090`            | GitLab Pages exposed port                                |
| `service.internalPort`                    | `8090`            | GitLab Pages internal port                               |
| `service.name`                            | `gitlab-pages`    | GitLab Pages service name                                |
| `service.customDomains.type`              | `LoadBalancer`    | Type of service created for handling custom domains      |
| `service.customDomains.internalHTTPSPort` | `8091`            | Port where Pages daemon listens for HTTPS requests       |
| `service.customDomains.nodePort.http`     |                   | Node Port to be opened for HTTP connections. Valid only if `service.customDomains.type` is `NodePort` |
| `service.customDomains.nodePort.https`    |                   | Node Port to be opened for HTTPS connections. Valid only if `service.customDomains.type` is `NodePort` |
| `serviceLabels`                           | `{}`              | Supplemental service labels                              |
| `tolerations`                             | `[]`              | Toleration labels for pod assignment                     |

### Pages specific settings

| Parameter                        | Default               | Description                                          |
| -------------------------------- | --------------------- | ---------------------------------------------------- |
| `artifactsServerTimeout`         | `10`                  | Timeout (in seconds) for a proxied request to the artifacts server |
| `artifactsServerUrl`             |                       | API URL to proxy artifact requests to                |
| `domainConfigSource`             | `gitlab`              | Domain configuration source                          |
| `extraVolumeMounts`              |                       | List of extra volumes mounts to add                  |
| `extraVolumes`                   |                       | List of extra volumes to create                      |
| `gitlabClientHttpTimeout`        |                       | GitLab API HTTP client connection timeout in seconds |
| `gitlabClientJwtExpiry`          |                       | JWT Token expiry time in seconds                     |
| `gitlabServer`                   |                       | GitLab server FQDN                                   |
| `headers`                        | `[]`                  | The additional http header(s) that should be send to the client |
| `insecureCiphers`                | `false`               | Use default list of cipher suites, may contain insecure ones like 3DES and RC4 |
| `internalGitlabServer`           |                       | Internal GitLab server used for API requests         |
| `logFormat`                      | `json`                | Log output format                                    |
| `logVerbose`                     | `false`               | Verbose logging                                      |
| `maxConnections`                 |                       | Limit on the number of concurrent connections to the HTTP, HTTPS or proxy listeners |
| `redirectHttp`                   | `false`               | Redirect pages from HTTP to HTTPS                    |
| `sentry.enabled`                 | `false`               | Enable Sentry reporting                              |
| `sentry.dsn`                     |                       | The address for sending Sentry crash reporting to    |
| `sentry.environment`             |                       | The environment for Sentry crash reporting           |
| `statusUri`                      |                       | The URL path for a status page                       |
| `tls.minVersion`                 |                       | Specifies the minimum SSL/TLS version                |
| `tls.maxVersion`                 |                       | Specifies the maximum SSL/TLS version                |
| `useHttp2`                       | `true`                | Enable HTTP2 support                                 |

## Chart configuration examples

### extraVolumes

`extraVolumes` allows you to configure extra volumes chart-wide.

Below is an example use of `extraVolumes`:

```yaml
extraVolumes: |
  - name: example-volume
    persistentVolumeClaim:
      claimName: example-pvc
```

### extraVolumeMounts

`extraVolumeMounts` allows you to configure extra volumeMounts on all containers chart-wide.

Below is an example use of `extraVolumeMounts`:

```yaml
extraVolumeMounts: |
  - name: example-volume
    mountPath: /etc/example
```
