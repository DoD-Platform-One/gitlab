---
stage: GitLab Delivery
group: Self Managed
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: Troubleshooting the GitLab chart
---

## UPGRADE FAILED: Job failed: BackoffLimitExceeded

If you received this error when [upgrading to the 6.0 version of the chart](../releases/6_0.md#upgrade-path-from-5x),
then it's probably because you didn't follow the right upgrade path, as you first need to upgrade to the latest 5.10.x version:

1. List all your releases to identify your GitLab Helm release name (you will need to include `-n <namespace>` if your release was not deployed to the `default` K8s namespace):

   ```shell
   helm ls
   ```

1. Assuming that your GitLab Helm release is called `gitlab` you then need to look at the release history and identify the last successful revision (you can see the status of a revision under `DESCRIPTION`):

   ```shell
   helm history gitlab
   ```

1. Assuming your most recent successful revision is `1` use this command to roll back:

   ```shell
   helm rollback gitlab 1
   ```

1. Re-run the upgrade command by replacing `<x>` with the appropriate chart version:

   ```shell
   helm upgrade --version=5.10.<x>
   ```

1. At this point you can use the `--version` option to pass a specific 6.x.x chart version or remove the option for upgrading to the latest version of GitLab:

   ```shell
   helm upgrade --install gitlab gitlab/gitlab <other_options>
   ```

More information about command line arguments can be found in our [Deploy using Helm](../installation/deployment.md#deploy-using-helm) section.
For mappings between chart versions and GitLab versions, read [GitLab version mappings](../installation/version_mappings.md).

## UPGRADE FAILED: "$name" has no deployed releases

This error occurs on your second install/upgrade if your initial install failed.

If your initial install completely failed, and GitLab was never operational, you
should first purge the failed install before installing again.

```shell
helm uninstall <release-name>
```

If instead, the initial install command timed out, but GitLab still came up successfully,
you can add the `--force` flag to the `helm upgrade` command to ignore the error
and attempt to update the release.

Otherwise, if you received this error after having previously had successful deploys
of the GitLab chart, then you are encountering a bug. Please open an issue on our
[issue tracker](https://gitlab.com/gitlab-org/charts/gitlab/-/issues), and also check out
[issue #630](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/630) where we recovered our
CI server from this problem.

## Error: this command needs 2 arguments: release name, chart path

An error like this could occur when you run `helm upgrade`
and there are some spaces in the parameters. In the following
example, `Test Username` is the culprit:

```shell
helm upgrade gitlab gitlab/gitlab --timeout 600s --set global.email.display_name=Test Username ...
```

To fix it, pass the parameters in single quotes:

```shell
helm upgrade gitlab gitlab/gitlab --timeout 600s --set global.email.display_name='Test Username' ...
```

## Application containers constantly initializing

If you experience Sidekiq, Webservice, or other Rails based containers in a constant
state of Initializing, you're likely waiting on the `dependencies` container to
pass.

If you check the logs of a given Pod specifically for the `dependencies` container,
you may see the following repeated:

```plaintext
Checking database connection and schema version
WARNING: This version of GitLab depends on gitlab-shell 8.7.1, ...
Database Schema
Current version: 0
Codebase version: 20190301182457
```

This is an indication that the `migrations` Job has not yet completed. The purpose
of this Job is to both ensure that the database is seeded, as well as all
relevant migrations are in place. The application containers are attempting to
wait for the database to be at or above their expected database version. This is
to ensure that the application does not malfunction to the schema not matching
expectations of the codebase.

1. Find the `migrations` Job. `kubectl get job -lapp=migrations`
1. Find the Pod being run by the Job. `kubectl get pod -lbatch.kubernetes.io/job-name=<job-name>`
1. Examine the output, checking the `STATUS` column.

If the `STATUS` is `Running`, continue. If the `STATUS` is `Completed`, the application containers should start shortly after the next check passes.

Examine the logs from this pod. `kubectl logs <pod-name>`

Any failures during the run of this job should be addressed. These will block
the use of the application until resolved. Possible problems are:

- Unreachable or failed authentication to the configured PostgreSQL database
- Unreachable or failed authentication to the configured Redis services
- Failure to reach a Gitaly instance

## Applying configuration changes

The following command will perform the necessary operations to apply any updates made to `gitlab.yaml`:

```shell
helm upgrade <release name> <chart path> -f gitlab.yaml
```

## Included GitLab Runner failing to register

This can happen when the runner registration token has been changed in GitLab. (This often happens after you have restored a backup)

1. Find the new shared runner token located on the `admin/runners` webpage of your GitLab installation.
1. Find the name of existing runner token Secret stored in Kubernetes

   ```shell
   kubectl get secrets | grep gitlab-runner-secret
   ```

1. Delete the existing secret

   ```shell
   kubectl delete secret <runner-secret-name>
   ```

1. Create the new secret with two keys, (`runner-registration-token` with your shared token, and an empty `runner-token`)

   ```shell
   kubectl create secret generic <runner-secret-name> --from-literal=runner-registration-token=<new-shared-runner-token> --from-literal=runner-token=""
   ```

## Too many redirects

This can happen when you have TLS termination before the NGINX Ingress, and the tls-secrets are specified in the configuration.

1. Update your values to set `global.ingress.annotations."nginx.ingress.kubernetes.io/ssl-redirect": "false"`

   Via a values file:

   ```yaml
   # values.yaml
   global:
     ingress:
       annotations:
         "nginx.ingress.kubernetes.io/ssl-redirect": "false"
   ```

   Via the Helm CLI:

   ```shell
   helm ... --set-string global.ingress.annotations."nginx.ingress.kubernetes.io/ssl-redirect"=false
   ```

1. Apply the change.

{{< alert type="note" >}}

When using an external service for SSL termination, that service is responsible for redirecting to https (if so desired).

{{< /alert >}}

## Upgrades fail with Immutable Field Error

### spec.clusterIP

Prior to the 3.0.0 release of these charts, the `spec.clusterIP` property
[had been populated into several Services](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/1710)
despite having no actual value (`""`). This was a bug, and causes problems with Helm 3's three-way
merge of properties.

Once the chart was deployed with Helm 3, there would be _no possible upgrade path_ unless one
collected the `clusterIP` properties from the various Services and populated those into the values
provided to Helm, or the affected services are removed from Kubernetes.

The [3.0.0 release of this chart corrected this error](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/1710), but it requires manual correction.

This can be solved by simply removing all of the affected services.

1. Remove all affected services:

   ```shell
   kubectl delete services -lrelease=RELEASE_NAME
   ```

1. Perform an upgrade via Helm.
1. Future upgrades will not face this error.

{{< alert type="note" >}}

This will change any dynamic value for the `LoadBalancer` for NGINX Ingress from this chart, if in use.
See [global Ingress settings documentation](../charts/globals.md#configure-ingress-settings) for more
details regarding `externalIP`. You may be required to update DNS records!

{{< /alert >}}

### spec.selector

Sidekiq pods did not receive a unique selector prior to chart release
`3.0.0`. [The problems with this were documented in](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/663).

Upgrades to `3.0.0` using Helm will automatically delete the old Sidekiq deployments and create new ones by appending `-v1` to the
name of the Sidekiq `Deployments`,`HPAs`, and `Pods`.

If you continue to run into this error on the Sidekiq deployment when installing `3.0.0`, resolve these with the following
steps:

1. Remove Sidekiq services

   ```shell
   kubectl delete deployment --cascade -lrelease=RELEASE_NAME,app=sidekiq
   ```

1. Perform an upgrade via Helm.

### cannot patch "RELEASE-NAME-cert-manager" with kind Deployment

Upgrading from **CertManager** version `0.10` introduced a number of
breaking changes. The old Custom Resource Definitions must be uninstalled
and removed from Helm's tracking and then re-installed.

The Helm chart attempts to do this by default but if you encounter this error
you may need to take manual action.

If this error message was encountered, then upgrading requires one more step
than normal in order to ensure the new Custom Resource Definitions are
actually applied to the deployment.

1. Remove the old **CertManager** Deployment.

   ```shell
   kubectl delete deployments -l app=cert-manager --cascade
   ```

1. Run the upgrade again. This time install the new Custom Resource Definitions

   ```shell
   helm upgrade --install --values - YOUR-RELEASE-NAME gitlab/gitlab < <(helm get values YOUR-RELEASE-NAME)
   ```

### cannot patch `gitlab-kube-state-metrics` with kind Deployment

Upgrading from **Prometheus** version `11.16.9` to `15.0.4` changes the selector labels
used on the [kube-state-metrics Deployment](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-state-metrics),
which is disabled by default (`prometheus.kubeStateMetrics.enabled=false`).

If this error message is encountered, meaning `prometheus.kubeStateMetrics.enabled=true`, then upgrading
requires [an additional step](https://artifacthub.io/packages/helm/prometheus-community/prometheus#to-15-0):

1. Remove the old **kube-state-metrics** Deployment.

   ```shell
   kubectl delete deployments.apps -l app.kubernetes.io/instance=RELEASE_NAME,app.kubernetes.io/name=kube-state-metrics --cascade=orphan
   ```

1. Perform an upgrade via Helm.

## `ImagePullBackOff`, `Failed to pull image` and `manifest unknown` errors

If you are using [`global.gitlabVersion`](../charts/globals.md#gitlab-version),
start by removing that property.
Check the [version mappings between the chart and GitLab](../installation/version_mappings.md)
and specify a compatible version of the `gitlab/gitlab` chart in your `helm` command.

## UPGRADE FAILED: "cannot patch ..." after `helm 2to3 convert`

This is a known issue. After migrating a Helm 2 release to Helm 3, the subsequent upgrades may fail.
You can find the full explanation and workaround in [Migrating from Helm v2 to Helm v3](../installation/migration/helm.md#known-issues).

## UPGRADE FAILED: type mismatch on mailroom: `%!t(<nil>)`

An error like this can happen if you do not provide a valid map for a key that expects a map.

For example, the configuration below will cause this error:

```yaml
gitlab:
  mailroom:
```

To fix this, either:

1. Provide a valid map for `gitlab.mailroom`.
1. Remove the `mailroom` key entirely.

Note that for optional keys, an empty map (`{}`) is a valid value.

## Error: `cannot drop view pg_stat_statements because extension pg_stat_statements requires it`

You may face this error when restoring a backup on your Helm chart instance. Use the following steps as a workaround:

1. Inside your `toolbox` pod open the DB console:

   ```shell
   /srv/gitlab/bin/rails dbconsole -p
   ```

1. Drop the extension:

   ```shell
   DROP EXTENSION pg_stat_statements;
   ```

1. Perform the restoration process.
1. After the restoration is complete, re-create the extension in the DB console:

   ```shell
   CREATE EXTENSION pg_stat_statements;
   ```

If you encounter the same issue with the `pg_buffercache` extension,
follow the same steps above to drop and re-create it.

You can find more details about this error in issue [#2469](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/2469).

## Bundled PostgreSQL pod fails to start: `database files are incompatible with server`

The following error message may appear in the bundled PostgreSQL pod after upgrading to a new version of the GitLab Helm chart:

```plaintext
gitlab-postgresql FATAL:  database files are incompatible with server
gitlab-postgresql DETAIL:  The data directory was initialized by PostgreSQL version 11, which is not compatible with this version 12.7.
```

To address this, perform a [Helm rollback](https://helm.sh/docs/helm/helm_rollback/) to the previous
version of the chart and then follow the steps in the [upgrade guide](../installation/upgrade.md) to
upgrade the bundled PostgreSQL version. Once PostgreSQL is properly upgraded, try the GitLab Helm
chart upgrade again.

## Bundled NGINX Ingress pod fails to start: `Failed to watch *v1beta1.Ingress`

The following error message may appear in the bundled NGINX Ingress controller pod if running Kubernetes version 1.22 or later:

```plaintext
Failed to watch *v1beta1.Ingress: failed to list *v1beta1.Ingress: the server could not find the requested resource
```

To address this, ensure the Kubernetes version is 1.21 or older. See
[#2852](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/2852) for
more information regarding NGINX Ingress support for Kubernetes 1.22 or later.

## Increased load on `/api/v4/jobs/request` endpoint

You may face this issue if the option `workhorse.keywatcher` was set to `false` for the deployment servicing `/api/*`.
Use the following steps to verify:

1. Access the container `gitlab-workhorse` in the pod serving `/api/*`:

   ```shell
   kubectl exec -it --container=gitlab-workhorse <gitlab_api_pod> -- /bin/bash
   ```

1. Inspect the file `/srv/gitlab/config/workhorse-config.toml`. The `[redis]` configuration might be missing:

   ```shell
   grep '\[redis\]' /srv/gitlab/config/workhorse-config.toml
   ```

If the `[redis]` configuration is not present, the `workhorse.keywatcher` flag was set to `false` during deployment
thus causing the extra load in the `/api/v4/jobs/request` endpoint. To fix this, enable the `keywatcher` in the
`webservice` chart:

```yaml
workhorse:
  keywatcher: true
```

## Git over SSH: `the remote end hung up unexpectedly`

Git operations over SSH might fail intermittently with the following error:

```plaintext
fatal: the remote end hung up unexpectedly
fatal: early EOF
fatal: index-pack failed
```

There are a number of potential causes for this error:

- **Network timeouts**:

  Git clients sometimes open a connection and leave it idling, like when compressing objects.
  Settings like `timeout client` in HAProxy might cause these idle connections to be terminated.

  you can set a keepalive in `sshd`:

  ```yaml
  gitlab:
    gitlab-shell:
      config:
        clientAliveInterval: 15
  ```

- **`gitlab-shell` memory**:

  By default, the chart does not set a limit on GitLab Shell memory.
  If `gitlab.gitlab-shell.resources.limits.memory` is set too low, Git operations over SSH may fail with these errors.

  Run `kubectl describe nodes` to confirm that this is caused by memory limits rather than
  timeouts over the network.

  ```plaintext
  System OOM encountered, victim process: gitlab-shell
  Memory cgroup out of memory: Killed process 3141592 (gitlab-shell)
  ```

## Error: `kex_exchange_identification: Connection closed by remote host`

The following error can appear in the GitLab Shell logs:

```plaintext
subcomponent":"ssh","time":"2025-02-21T19:07:52Z","message":"kex_exchange_identification: Connection closed by remote host\r"}
```

This error is caused by OpenSSH `sshd` being unable to handle readiness and liveness probes. To resolve this error, use
[`gitlab-sshd`](../charts/gitlab/gitlab-shell/_index.md#configuration) instead by changing `sshDaemon: openssh` to `sshDaemon: gitlab-ssd` in configuration:

```yaml
gitlab:
  gitlab-shell: 
    sshDaemon: gitlab-sshd
```

## YAML configuration: `mapping values are not allowed in this context`

The following error message may appear when YAML configuration contains leading spaces:

```plaintext
template: /var/opt/gitlab/templates/workhorse-config.toml.tpl:16:98:
  executing \"/var/opt/gitlab/templates/workhorse-config.toml.tpl\" at <data.YAML>:
    error calling YAML:
      yaml: line 2: mapping values are not allowed in this context
```

To address this, ensure that there are no leading spaces in configuration.

For example, change this:

```yaml
  key1: value1
  key2: value2
```

... to this:

```yaml
key1: value1
key2: value2
```

## TLS and certificates

If your GitLab instance needs to trust a private TLS certificate authority, GitLab might
fail to handshake with other services like object storage, Elasticsearch, Jira, or Jenkins:

```plaintext
error: certificate verify failed (unable to get local issuer certificate)
```

Partial trust of certificates signed by private certificate authorities can occur if:

- The supplied certificates are not in separate files.
- The certificates init container doesn't perform all the required steps.

Also, GitLab is mostly written in Ruby on Rails and Go, and each language's
TLS libraries work differently. This difference can result in issues like job logs
failing to render in the GitLab UI but raw job logs downloading without issue.

Additionally, depending on the `proxy_download` configuration, your browser is
redirected to the object storage with no issues if the trust store is correctly configured.
At the same time, TLS handshakes by one or more GitLab components could still fail.

### Certificate trust setup and troubleshooting

As part of troubleshooting certificate issues, be sure to:

- Create secrets for each certificate you need to trust.
- Provide only one certificate per file.

  ```plaintext
  kubectl create secret generic custom-ca --from-file=unique_name=/path/to/cert
  ```

  In this example, the certificate is stored using the key name `unique_name`

If you supply a bundle or a chain, some GitLab components won't work.

Query secrets with `kubectl get secrets` and `kubectl describe secrets/secretname`,
which shows the key name for the certificate under `Data`.

Supply additional certificates to trust using `global.certificates.customCAs`
[in the chart globals](../charts/globals.md#custom-certificate-authorities).

When a pod is deployed, an init container mounts the certificates and sets them up so the GitLab
components can use them. The init container is`registry.gitlab.com/gitlab-org/build/cng/alpine-certificates`.

Additional certificates are mounted into the container at `/usr/local/share/ca-certificates`,
using the secret key name as the certificate filename.

The init container runs `/scripts/bundle-certificates` ([source](https://gitlab.com/gitlab-org/build/CNG-mirror/-/blob/master/certificates/scripts/bundle-certificates)).
In that script, `update-ca-certificates`:

1. Copies custom certificates from `/usr/local/share/ca-certificates` to `/etc/ssl/certs`.
1. Compiles a bundle `ca-certificates.crt`.
1. Generates hashes for each certificate and creates a symlink using the hash,
   which is required for Rails. Certificate bundles are skipped with a warning:

   ```plaintext
   WARNING: unique_name does not contain exactly one certificate or CRL: skipping
   ```

[Troubleshoot the init container's status and logs](https://kubernetes.io/docs/tasks/debug/debug-application/debug-init-containers/).
For example, to view the logs for the certificates init container and check for warnings:

```plaintext
kubectl logs gitlab-webservice-default-pod -c certificates
```

### Check on the Rails console

Use the toolbox pod to verify if Rails trusts the certificates you supplied.

1. Start a Rails console (replace `<namespace>` with the namespace where GitLab is installed):

   ```shell
   kubectl exec -ti $(kubectl get pod -n <namespace> -lapp=toolbox -o jsonpath='{.items[0].metadata.name}') -n <namespace> -- bash
   /srv/gitlab/bin/rails console
   ```

1. Verify the location Rails checks for certificate authorities:

   ```ruby
   OpenSSL::X509::DEFAULT_CERT_DIR
   ```

1. Execute an HTTPS query in the Rails console:

   ```ruby
   ## Configure a web server to connect to:
   uri = URI.parse("https://myservice.example.com")

   require 'openssl'
   require 'net/http'
   Rails.logger.level = 0
   OpenSSL.debug=1
   http = Net::HTTP.new(uri.host, uri.port)
   http.set_debug_output($stdout)
   http.use_ssl = true

   http.verify_mode = OpenSSL::SSL::VERIFY_PEER
   # http.verify_mode = OpenSSL::SSL::VERIFY_NONE # TLS verification disabled

   response = http.request(Net::HTTP::Get.new(uri.request_uri))
   ```

### Troubleshoot the init container

Run the certificates container using Docker.

1. Set up a directory structure and populate it with your certificates:

   ```shell
   mkdir -p etc/ssl/certs usr/local/share/ca-certificates

     # The secret name is: my-root-ca
     # The key name is: corporate_root

   kubectl get secret my-root-ca -ojsonpath='{.data.corporate_root}' | \
        base64 --decode > usr/local/share/ca-certificates/corporate_root

     # Check the certificate is correct:

   openssl x509 -in usr/local/share/ca-certificates/corporate_root -text -noout
   ```

1. Determine the correct container version:

   ```shell
   kubectl get deployment -lapp=webservice -ojsonpath='{.items[0].spec.template.spec.initContainers[0].image}'
   ```

1. Run container, which performs the preparation of `etc/ssl/certs` content:

   ```shell
   docker run -ti --rm \
        -v $(pwd)/etc/ssl/certs:/etc/ssl/certs \
        -v $(pwd)/usr/local/share/ca-certificates:/usr/local/share/ca-certificates \
        registry.gitlab.com/gitlab-org/build/cng/gitlab-base:v15.10.3
   ```

1. Check your certificates have been correctly built:

   - `etc/ssl/certs/corporate_root.pem` should have been created.
   - There should be a hashed filename, which is a symlink to the certificate itself (such as `etc/ssl/certs/1234abcd.0`).
   - The file and the symbolic link should display with:

     ```shell
     ls -l etc/ssl/certs/ | grep corporate_root
     ```

     For example:

     ```plaintext
     lrwxrwxrwx   1 root root      20 Oct  7 11:34 28746b42.0 -> corporate_root.pem
     -rw-r--r--   1 root root    1948 Oct  7 11:34 corporate_root.pem
     ```

## `308: Permanent Redirect` causing a redirect loop

`308: Permanent Redirect` can happen if your Load Balancer is configured to send unencrypted traffic (HTTP) to NGINX.
Because NGINX defaults to redirecting `HTTP` to `HTTPS`, you may end up in a "redirect loop".

To fix this, [enable NGINX's `use-forwarded-headers` setting](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/#use-forwarded-headers).

## "Invalid Word" errors in the `nginx-controller` logs and `404` errors

After upgrading to Helm chart 6.6 or later, you might experience `404` return
codes when visiting your GitLab or third-party domains for applications installed
in your cluster and are also seeing "invalid word" errors in the
`gitlab-nginx-ingress-controller` logs:

```console
gitlab-nginx-ingress-controller-899b7d6bf-688hr controller W1116 19:03:13.162001       7 store.go:846] skipping ingress gitlab/gitlab-minio: nginx.ingress.kubernetes.io/configuration-snippet annotation contains invalid word proxy_pass
gitlab-nginx-ingress-controller-899b7d6bf-688hr controller W1116 19:03:13.465487       7 store.go:846] skipping ingress gitlab/gitlab-registry: nginx.ingress.kubernetes.io/configuration-snippet annotation contains invalid word proxy_pass
gitlab-nginx-ingress-controller-899b7d6bf-lqcks controller W1116 19:03:12.233577       6 store.go:846] skipping ingress gitlab/gitlab-kas: nginx.ingress.kubernetes.io/configuration-snippet annotation contains invalid word proxy_pass
gitlab-nginx-ingress-controller-899b7d6bf-lqcks controller W1116 19:03:12.536534       6 store.go:846] skipping ingress gitlab/gitlab-webservice-default: nginx.ingress.kubernetes.io/configuration-snippet annotation contains invalid word proxy_pass
gitlab-nginx-ingress-controller-899b7d6bf-lqcks controller W1116 19:03:12.848844       6 store.go:846] skipping ingress gitlab/gitlab-webservice-default-smartcard: nginx.ingress.kubernetes.io/configuration-snippet annotation contains invalid word proxy_pass
gitlab-nginx-ingress-controller-899b7d6bf-lqcks controller W1116 19:03:13.161640       6 store.go:846] skipping ingress gitlab/gitlab-minio: nginx.ingress.kubernetes.io/configuration-snippet annotation contains invalid word proxy_pass
gitlab-nginx-ingress-controller-899b7d6bf-lqcks controller W1116 19:03:13.465425       6 store.go:846] skipping ingress gitlab/gitlab-registry: nginx.ingress.kubernetes.io/configuration-snippet annotation contains invalid word proxy_pass
```

In that case, review your GitLab values and any third-party Ingress objects for the use
of [configuration snippets](https://kubernetes.github.io/ingress-nginx/examples/customization/configuration-snippets/).
You may need to adjust or modify the `nginx-ingress.controller.config.annotation-value-word-blocklist`
setting.

See [Annotation value word blocklist](../charts/nginx/_index.md#annotation-value-word-blocklist) for additional details.

### Volume mount takes a long time

Mounting large volumes, such as the `gitaly` or `toolbox` chart volumes, can take a long time because Kubernetes
recursively changes the permissions of the volume's contents to match the Pod's `securityContext`.

Starting with Kubernetes 1.23 you can set the `securityContext.fsGroupChangePolicy` to `OnRootMismatch` to mitigate
this issue. This flag is supported by all GitLab subcharts.

For example for the Gitaly subchart:

```yaml
gitlab:
  gitaly:
    securityContext:
      fsGroupChangePolicy: "OnRootMismatch"
```

See the [Kubernetes documentation](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#configure-volume-permission-and-ownership-change-policy-for-pods),
for more details.

For Kubernetes versions not supporting `fsGroupChangePolicy` you can mitigate the
issue by changing or fully deleting the settings for the `securityContext`.

```yaml
gitlab:
  gitaly:
    securityContext:
      fsGroup: ""
      runAsUser: ""
```

{{< alert type="note" >}}

The example syntax eliminates the `securityContext` setting entirely.
Setting `securityContext: {}` or `securityContext:` does not work due
to the way Helm merges default values with user provided configuration.

{{< /alert >}}

### Intermittent 502 errors

When a request being handled by a Puma worker crosses the memory limit threshold, it is killed by the node's OOMKiller.
However, killing the request does not necessarily kill or restart the webservice pod itself. This situation causes the request to return a `502` timeout.
In the logs, this appears as a Puma worker being created shortly after the `502` error is logged.

```shell
2024-01-19T14:12:08.949263522Z {"correlation_id":"XXXXXXXXXXXX","duration_ms":1261,"error":"badgateway: failed to receive response: context canceled"....
2024-01-19T14:12:24.214148186Z {"component": "gitlab","subcomponent":"puma.stdout","timestamp":"2024-01-19T14:12:24.213Z","pid":1,"message":"- Worker 2 (PID: 7414) booted in 0.84s, phase: 0"}
```

To solve this problem, [raise memory limits for the webservice pods](../charts/gitlab/webservice/_index.md#memory-requestslimits).

### Upgrade failed - `cannot patch "gitlab-prometheus-server" with kind Deployment`

With chart 9.0 we updated the major version Prometheus subchart. The selector labels and version of Prometheus
were changes and need manual interaction.

Please follow the [migration guide](../releases/9_0.md#prometheus-upgrade) to upgrade
the Prometheus chart.

## Toolbox backup failing on upload

A backup may fail when trying to upload to the object storage with an error
like:

```plaintext
An error occurred (XAmzContentSHA256Mismatch) when calling the UploadPart operation: The Content-SHA256 you specified did not match what we received
```

This might be caused by an incompatibility of the `awscli` tool and your object
storage service. This issue has been reported when using Dell ECS S3 Storage.
To avoid this issue you can [disable data integrity protection](../backup-restore/backup.md#data-integrity-protection-with-awscli).
