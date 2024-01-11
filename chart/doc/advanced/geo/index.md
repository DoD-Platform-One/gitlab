---
stage: Systems
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
---

# Configure the GitLab chart with GitLab Geo

GitLab Geo provides the ability to have geographically distributed application
deployments.

While external database services can be used, these documents focus on
the use of the [Linux package](https://docs.gitlab.com/omnibus/) for PostgreSQL to provide the
most platform agnostic guide, and make use of the automation included in `gitlab-ctl`.

In this guide, both clusters have the same external URL. This feature is supported by the chart
since version 7.3. See [Set up a Unified URL for Geo sites](https://docs.gitlab.com/ee/administration/geo/secondary_proxy/index.html#set-up-a-unified-url-for-geo-sites). You can optionally [configure a separate URL for the secondary site](#configure-a-separate-url-for-the-secondary-site-optional).

NOTE:
See the [defined terms](https://docs.gitlab.com/ee/administration/geo/glossary.html)
to describe all aspects of Geo (mainly the distinction between `site` and `node`).

## Requirements

To use GitLab Geo with the GitLab Helm chart, the following requirements must be met:

- The use of [external PostgreSQL](../external-db/index.md) services, as the
  PostgresSQL included with the chart is not exposed to outside networks, and doesn't
  have WAL support required for replication.
- The supplied database must:
  - Support replication.
  - The primary database must be reachable by the primary site,
    and all secondary database nodes (for replication).
  - Secondary databases only need to be reachable by the secondary sites.
  - Support SSL between primary and secondary database nodes.
- The primary site must be reachable via HTTP(S) by all secondary sites.
  Secondary sites must be accessible to the primary site via HTTP(S).

## Overview

This guide uses 2 database nodes created by using the Linux package,
configuring only the PostgreSQL services needed, and 2 deployments of the
GitLab Helm chart. It is intended to be the _minimal_ required configuration.
This documentation does not include SSL from application to database, support
for other database providers, or
[promoting a secondary site to primary](https://docs.gitlab.com/ee/administration/geo/disaster_recovery/).

The outline below should be followed in order:

1. [Set up Linux package database nodes](#set-up-linux-package-database-nodes)
1. [Set up Kubernetes clusters](#set-up-kubernetes-clusters)
1. [Collect information](#collect-information)
1. [Configure Primary database](#configure-primary-database)
1. [Deploy chart as Geo Primary site](#deploy-chart-as-geo-primary-site)
1. [Set the Geo Primary site](#set-the-geo-primary-site)
1. [Configure Secondary database](#configure-secondary-database)
1. [Copy secrets from the primary site to the secondary site](#copy-secrets-from-the-primary-site-to-the-secondary-site)
1. [Deploy chart as Geo Secondary site](#deploy-chart-as-geo-secondary-site)
1. [Add Secondary Geo site via Primary](#add-secondary-geo-site-via-primary)
1. [Confirm Operational Status](#confirm-operational-status)
1. [Configure a separate URL for the secondary site (Optional)](#configure-a-separate-url-for-the-secondary-site-optional)
1. [Registry](#registry)
1. [Cert-manager and unified URL](#cert-manager-and-unified-url)

## Set up Linux package database nodes

For this process, two nodes are required. One is the Primary database node, the
other the Secondary database node. You may use any provider of machine
infrastructure, on-premise or from a cloud provider.

Bear in mind that communication is required:

- Between the two database nodes for replication.
- Between each database node and their respective Kubernetes deployments:
  - The primary needs to expose TCP port `5432`.
  - The secondary needs to expose TCP ports `5432` & `5431`.

Install an [operating system supported by the Linux package](https://docs.gitlab.com/ee/install/requirements.html#operating-systems), and then
[install the Linux package](https://about.gitlab.com/install/) onto it. Do not provide the
`EXTERNAL_URL` environment variable when installing, as we'll provide a minimal
configuration file before reconfiguring the package.

After you have installed the operating system, and the GitLab package, configuration
can be created for the services that will be used. Before we do that, information
must be collected.

## Set up Kubernetes clusters

For this process, two Kubernetes clusters should be used. These can be from any
provider, on-premise or from a cloud provider.

Bear in mind that communication is required:

- To the respective database nodes:
  - Primary outbound to TCP `5432`.
  - Secondary outbound to TCP `5432` and `5431`.
- Between both Kubernetes Ingress via HTTPS.

Each cluster that is provisioned should have:

- Enough resources to support a base-line installation of these charts.
- Access to persistent storage:
  - MinIO not required if using [external object storage](../external-object-storage/index.md).
  - Gitaly not required if using [external Gitaly](../external-gitaly/index.md).
  - Redis not required if using [external Redis](../external-redis/index.md).

## Collect information

To continue with the configuration, the following information needs to be
collected from the various sources. Collect these, and make notes for use through
the rest of this documentation.

- Primary database:
  - IP address
  - hostname (optional)
- Secondary database:
  - IP address
  - hostname (optional)
- Primary cluster:
  - External URL
  - Internal URL
  - IP addresses of nodes
- Secondary cluster:
  - Internal URL
  - IP addresses of nodes
- Database Passwords (_must pre-decide the passwords_):
  - `gitlab` (used in `postgresql['sql_user_password']`, `global.psql.password`)
  - `gitlab_geo` (used in `geo_postgresql['sql_user_password']`, `global.geo.psql.password`)
  - `gitlab_replicator` (needed for replication)
- Your GitLab license file

The Internal URL of each cluster must be unique to the cluster, so that all
clusters can make requests to all other clusters. For example:

- External URL of all clusters: `https://gitlab.example.com`
- Primary cluster's Internal URL: `https://london.gitlab.example.com`
- Secondary cluster's Internal URL: `https://shanghai.gitlab.example.com`

This guide does not cover setting up DNS.

The `gitlab` and `gitlab_geo` database user passwords must exist in two
forms: bare password, and PostgreSQL hashed password. To obtain the hashed form,
perform the following commands on one of the Linux package installation instances, which asks
you to enter and confirm the password before outputting an appropriate hash
value for you to make note of.

1. `gitlab-ctl pg-password-md5 gitlab`
1. `gitlab-ctl pg-password-md5 gitlab_geo`

## Configure Primary database

_This section is performed on the Primary Linux package installation database node._

To configure the Primary database node's Linux package installation, work from
this example configuration:

```ruby
### Geo Primary
external_url 'http://gitlab.example.com'
roles ['geo_primary_role']
# The unique identifier for the Geo node.
gitlab_rails['geo_node_name'] = 'London Office'
gitlab_rails['auto_migrate'] = false
## turn off everything but the DB
sidekiq['enable']=false
puma['enable']=false
gitlab_workhorse['enable']=false
nginx['enable']=false
geo_logcursor['enable']=false
grafana['enable']=false
gitaly['enable']=false
redis['enable']=false
gitlab_kas['enable']=false
prometheus_monitoring['enable'] = false
## Configure the DB for network
postgresql['enable'] = true
postgresql['listen_address'] = '0.0.0.0'
postgresql['sql_user_password'] = 'gitlab_user_password_hash'
# !! CAUTION !!
# This list of CIDR addresses should be customized
# - primary application deployment
# - secondary database node(s)
postgresql['md5_auth_cidr_addresses'] = ['0.0.0.0/0']
```

We must replace several items:

- `external_url` must be updated to reflect the host name of our Primary site.
- `gitlab_rails['geo_node_name']` must be replaced with a unique name for your
  site. See the Name field in
  [Common settings](https://docs.gitlab.com/ee/administration/geo_sites.html#common-settings).
- `gitlab_user_password_hash` must be replaced with the hashed form of the
  `gitlab` password.
- `postgresql['md5_auth_cidr_addresses']` can be update to be a list of
  explicit IP addresses, or address blocks in CIDR notation.

The `md5_auth_cidr_addresses` should be in the form of
`[ '127.0.0.1/24', '10.41.0.0/16']`. It is important to include `127.0.0.1` in
this list, as the automation in the Linux package connects using this. The
addresses in this list should include the IP address (not hostname) of your
Secondary database, and all nodes of your primary Kubernetes cluster. This _can_
be left as `['0.0.0.0/0']`, however _it is not best practice_.

After the configuration above is prepared:

1. Place the content into `/etc/gitlab/gitlab.rb`
1. Run `gitlab-ctl reconfigure`. If you experience any issues in regards to the
   service not listening on TCP, try directly restarting it with
   `gitlab-ctl restart postgresql`.
1. Run `gitlab-ctl set-replication-password` to set the password for
   the `gitlab_replicator` user.
1. Retrieve the Primary database node's public certificate, this is needed
   for the Secondary database to be able to replicate (save this output):

   ```shell
   cat ~gitlab-psql/data/server.crt
   ```

## Deploy chart as Geo Primary site

_This section is performed on the Primary site's Kubernetes cluster._

To deploy this chart as a Geo Primary, start [from this example configuration](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples/geo/primary.yaml):

1. Create a secret containing the database password for the
   chart to consume. Replace `PASSWORD` below with the password for the `gitlab`
   database user:

   ```shell
   kubectl --namespace gitlab create secret generic geo --from-literal=postgresql-password=PASSWORD
   ```

1. Create a `primary.yaml` file based on the [example configuration](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples/geo/primary.yaml)
   and update the configuration to reflect the correct values:

   ```yaml
   ### Geo Primary
   global:
     # See docs.gitlab.com/charts/charts/globals
     # Configure host & domain
     hosts:
       domain: example.com
       # optionally configure a static IP for the default LoadBalancer
       # externalIP: 
       # optionally configure a static IP for the Geo LoadBalancer
       # externalGeoIP:
     # configure DB connection
     psql:
       host: geo-1.db.example.com
       port: 5432
       password:
         secret: geo
         key: postgresql-password
     # configure geo (primary)
     geo:
       nodeName: London Office
       enabled: true
       role: primary
   # configure Geo Nginx Controller for internal Geo site traffic
   nginx-ingress-geo:
     enabled: true
   gitlab:
     webservice:
       # Use the Geo NGINX controller.
       ingress:
         useGeoClass: true
       # Configure an Ingress for internal Geo traffic
       extraIngress:
         enabled: true
         hostname: gitlab.london.example.com
         useGeoClass: true
   # External DB, disable
   postgresql:
     install: false
   ```

   <!-- markdownlint-disable MD044 -->
   - [global.hosts.domain](../../charts/globals.md#configure-host-settings)
   - [global.psql.host](../../charts/globals.md#configure-postgresql-settings)
   - global.geo.nodeName must match
     [the Name field of a Geo site in the Admin Area](https://docs.gitlab.com/ee/administration/geo_sites.html#common-settings)
   - [nginx-ingress-geo](../../charts/nginx/index.md#gitlab-geo) enables a Ingress controller for Geo traffic forwarded from secondaries
   - configure the primary Geo site's [gitlab.webservice](../../charts/gitlab/webservice/index.md#ingress-settings) Ingresses for Geo traffic
   - Also configure any additional settings, such as:
     - [Configuring SSL/TLS](../../installation/tools.md#tls-certificates)
     - [Using external Redis](../external-redis/index.md)
     - [using external Object Storage](../external-object-storage/index.md)
   <!-- markdownlint-enable MD044 -->

1. Deploy the chart using this configuration:

   ```shell
   helm upgrade --install gitlab-geo gitlab/gitlab --namespace gitlab -f primary.yaml
   ```

   NOTE:
   This assumes you are using the `gitlab` namespace. If you want to use a different namespace,
   you should also replace it in `--namespace gitlab` throughout the rest of this document.

1. Wait for the deployment to complete, and the application to come online. When
   the application is reachable, log in.

1. Sign in to GitLab, and [activate your GitLab subscription](https://docs.gitlab.com/ee/administration/license.html).

   NOTE:
   **This step is required for Geo to function.**

## Set the Geo Primary site

Now that the chart has been deployed, and a license uploaded, we can configure
this as the Primary site. We will do this via the Toolbox Pod.

1. Find the Toolbox Pod

   ```shell
   kubectl --namespace gitlab get pods -lapp=toolbox
   ```

1. Run `gitlab-rake geo:set_primary_node` with `kubectl exec`:

   ```shell
   kubectl --namespace gitlab exec -ti gitlab-geo-toolbox-XXX -- gitlab-rake geo:set_primary_node
   ```

1. Set the primary site's Internal URL with a Rails runner command. Replace `https://primary.gitlab.example.com` with the actual Internal URL:

   ```shell
   kubectl --namespace gitlab exec -ti gitlab-geo-toolbox-XXX -- gitlab-rails runner "GeoNode.primary_node.update!(internal_url: 'https://primary.gitlab.example.com')"
   ```

1. Check the status of Geo configuration:

   ```shell
   kubectl --namespace gitlab exec -ti gitlab-geo-toolbox-XXX -- gitlab-rake gitlab:geo:check
   ```

   You should see output similar to below:

   ```plaintext
   WARNING: This version of GitLab depends on gitlab-shell 10.2.0, but you're running Unknown. Please update gitlab-shell.
   Checking Geo ...

   GitLab Geo is available ... yes
   GitLab Geo is enabled ... yes
   GitLab Geo secondary database is correctly configured ... not a secondary node
   Database replication enabled? ... not a secondary node
   Database replication working? ... not a secondary node
   GitLab Geo HTTP(S) connectivity ... not a secondary node
   HTTP/HTTPS repository cloning is enabled ... yes
   Machine clock is synchronized ... Exception: getaddrinfo: Servname not supported for ai_socktype
   Git user has default SSH configuration? ... yes
   OpenSSH configured to use AuthorizedKeysCommand ... no
     Reason:
     Cannot find OpenSSH configuration file at: /assets/sshd_config
     Try fixing it:
     If you are not using our official docker containers,
     make sure you have OpenSSH server installed and configured correctly on this system
     For more information see:
     doc/administration/operations/fast_ssh_key_lookup.md
   GitLab configured to disable writing to authorized_keys file ... yes
   GitLab configured to store new projects in hashed storage? ... yes
   All projects are in hashed storage? ... yes

   Checking Geo ... Finished
   ```

   - Don't worry about `Exception: getaddrinfo: Servname not supported for ai_socktype`, as Kubernetes containers don't have access to the host clock. _This is OK_.
   - `OpenSSH configured to use AuthorizedKeysCommand ... no` _is expected_. This
     Rake task is checking for a local SSH server, which is actually present in the
     `gitlab-shell` chart, deployed elsewhere, and already configured appropriately.

## Configure Secondary database

_This section is performed on the Secondary Linux package installation database node._

To configure the Secondary database node's Linux package installation, work from
this example configuration:

```ruby
### Geo Secondary
# external_url must match the Primary cluster's external_url
external_url 'http://gitlab.example.com'
roles ['geo_secondary_role']
gitlab_rails['enable'] = true
# The unique identifier for the Geo node.
gitlab_rails['geo_node_name'] = 'Shanghai Office'
gitlab_rails['auto_migrate'] = false
geo_secondary['auto_migrate'] = false
## turn off everything but the DB
sidekiq['enable']=false
puma['enable']=false
gitlab_workhorse['enable']=false
nginx['enable']=false
geo_logcursor['enable']=false
grafana['enable']=false
gitaly['enable']=false
redis['enable']=false
prometheus_monitoring['enable'] = false
gitlab_kas['enable']=false
## Configure the DBs for network
postgresql['enable'] = true
postgresql['listen_address'] = '0.0.0.0'
postgresql['sql_user_password'] = 'gitlab_user_password_hash'
# !! CAUTION !!
# This list of CIDR addresses should be customized
# - secondary application deployment
# - secondary database node(s)
postgresql['md5_auth_cidr_addresses'] = ['0.0.0.0/0']
geo_postgresql['listen_address'] = '0.0.0.0'
geo_postgresql['sql_user_password'] = 'gitlab_geo_user_password_hash'
# !! CAUTION !!
# This list of CIDR addresses should be customized
# - secondary application deployment
# - secondary database node(s)
geo_postgresql['md5_auth_cidr_addresses'] = ['0.0.0.0/0']
gitlab_rails['db_password']='gitlab_user_password'
```

We must replace several items:

- `gitlab_rails['geo_node_name']` must be replaced with a unique name for your site. See the Name field in
  [Common settings](https://docs.gitlab.com/ee/administration/geo_sites.html#common-settings).
- `gitlab_user_password_hash` must be replaced with the hashed form of the
  `gitlab` password.
- `postgresql['md5_auth_cidr_addresses']` should be updated to be a list of
  explicit IP addresses, or address blocks in CIDR notation.
- `gitlab_geo_user_password_hash` must be replaced with the hashed form of the
  `gitlab_geo` password.
- `geo_postgresql['md5_auth_cidr_addresses']` should be updated to be a list of
  explicit IP addresses, or address blocks in CIDR notation.
- `gitlab_user_password` must be updated, and is used here to allow the Linux package
  to automate the PostgreSQL configuration.

The `md5_auth_cidr_addresses` should be in the form of
`[ '127.0.0.1/24', '10.41.0.0/16']`. It is important to include `127.0.0.1` in
this list, as the automation in the Linux package connects using this. The
addresses in this list should include the IP addresses of all nodes of your
Secondary Kubernetes cluster. This _can_ be left as `['0.0.0.0/0']`, however
_it is not best practice_.

After configuration above is prepared:

1. Check TCP connectivity to the **primary** site's PostgreSQL node:

   ```shell
   openssl s_client -connect <primary_node_ip>:5432 </dev/null
   ```

   The output should show the following:

   ```plaintext
   CONNECTED(00000003)
   write:errno=0
   ```

   NOTE:
   If this step fails, you may be using the wrong IP address, or a firewall may
   be preventing access to the server. Check the IP address, paying close
   attention to the difference between public and private addresses and ensure
   that, if a firewall is present, the **secondary** PostgreSQL node is
   permitted to connect to the **primary** PostgreSQL node on TCP port 5432.

1. Place the content into `/etc/gitlab/gitlab.rb`
1. Run `gitlab-ctl reconfigure`. If you experience any issues in regards to the
   service not listening on TCP, try directly restarting it with
   `gitlab-ctl restart postgresql`.
1. Place the Primary PostgreSQL node's certificate content from above into `primary.crt`
1. Set up PostgreSQL TLS verification on the **secondary** PostgreSQL node:

   Install the `primary.crt` file:

   ```shell
   install \
      -D \
      -o gitlab-psql \
      -g gitlab-psql \
      -m 0400 \
      -T primary.crt ~gitlab-psql/.postgresql/root.crt
   ```

   PostgreSQL will now only recognize that exact certificate when verifying TLS
   connections. The certificate can only be replicated by someone with access
   to the private key, which is **only** present on the **primary** PostgreSQL
   node.

1. Test that the `gitlab-psql` user can connect to the **primary** site's PostgreSQL
   (the default Linux package database name is `gitlabhq_production`):

   ```shell
   sudo \
      -u gitlab-psql /opt/gitlab/embedded/bin/psql \
      --list \
      -U gitlab_replicator \
      -d "dbname=gitlabhq_production sslmode=verify-ca" \
      -W \
      -h <primary_database_node_ip>
   ```

   When prompted enter the password collected earlier for the
   `gitlab_replicator` user. If all worked correctly, you should see
   the list of **primary** PostgreSQL node's databases.

   A failure to connect here indicates that the TLS configuration is incorrect.
   Ensure that the contents of `~gitlab-psql/data/server.crt` on the
   **primary** PostgreSQL node
   match the contents of `~gitlab-psql/.postgresql/root.crt` on the
   **secondary** PostgreSQL node.

1. Replicate the databases. Replace `PRIMARY_DATABASE_HOST` with the IP or hostname
of your Primary PostgreSQL node:

   ```shell
   gitlab-ctl replicate-geo-database --slot-name=geo_2 --host=PRIMARY_DATABASE_HOST --sslmode=verify-ca
   ```

1. After replication has finished, we must reconfigure the Linux package one last time
   to ensure `pg_hba.conf` is correct for the secondary PostgreSQL node:

   ```shell
   gitlab-ctl reconfigure
   ```

## Copy secrets from the primary site to the secondary site

Now copy a few secrets from the Primary site's Kubernetes deployment to the
Secondary site's Kubernetes deployment:

- `gitlab-geo-gitlab-shell-host-keys`
- `gitlab-geo-rails-secret`
- `gitlab-geo-registry-secret`, if Registry replication is enabled.

1. Change your `kubectl` context to that of your Primary.
1. Collect these secrets from the Primary deployment:

   ```shell
   kubectl get --namespace gitlab -o yaml secret gitlab-geo-gitlab-shell-host-keys > ssh-host-keys.yaml
   kubectl get --namespace gitlab -o yaml secret gitlab-geo-rails-secret > rails-secrets.yaml
   kubectl get --namespace gitlab -o yaml secret gitlab-geo-registry-secret > registry-secrets.yaml
   ```

1. Change your `kubectl` context to that of your Secondary.
1. Apply these secrets:

   ```shell
   kubectl --namespace gitlab apply -f ssh-host-keys.yaml
   kubectl --namespace gitlab apply -f rails-secrets.yaml
   kubectl --namespace gitlab apply -f registry-secrets.yaml
   ```

Next create a secret containing the database passwords. Replace the
passwords below with the appropriate values:

```shell
kubectl --namespace gitlab create secret generic geo \
   --from-literal=postgresql-password=gitlab_user_password \
   --from-literal=geo-postgresql-password=gitlab_geo_user_password
```

## Deploy chart as Geo Secondary site

_This section is performed on the Secondary site's Kubernetes cluster._

To deploy this chart as a Geo Secondary site, start [from this example configuration](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples/geo/secondary.yaml).

1. Create a `secondary.yaml` file based on the [example configuration](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples/geo/secondary.yaml)
   and update the configuration to reflect the correct values:

   ```yaml
   ## Geo Secondary
   global:
     # See docs.gitlab.com/charts/charts/globals
     # Configure host & domain
     hosts:
       domain: shanghai.example.com
       # use a unified URL (same external URL as the primary site)
       gitlab:
         name: gitlab.example.com
     # configure DB connection
     psql:
       host: geo-2.db.example.com
       port: 5432
       password:
         secret: geo
         key: postgresql-password
     # configure geo (secondary)
     geo:
       enabled: true
       role: secondary
       nodeName: Shanghai Office
       psql:
         host: geo-2.db.example.com
         port: 5431
         password:
           secret: geo
           key: geo-postgresql-password
   gitlab:
     webservice:
       # Configure a Ingress for internal Geo traffic
       extraIngress:
         enabled: true
         hostname: shanghai.gitlab.example.com
   # External DB, disable
   postgresql:
     install: false
   ```

   <!-- markdownlint-disable MD044 -->
   - [`global.hosts.domain`](../../charts/globals.md#configure-host-settings)
   - [`global.psql.host`](../../charts/globals.md#configure-postgresql-settings)
   - [`global.geo.psql.host`](../../charts/globals.md#configure-postgresql-settings)
   - global.geo.nodeName must match
     [the Name field of a Geo site in the Admin Area](https://docs.gitlab.com/ee/administration/geo_sites.html#common-settings)
   - [nginx-ingress-geo](../../charts/nginx/index.md#gitlab-geo) enables a ingress controller pre-configured for traffic
   - Also configure any additional settings, such as:
     - [Configuring SSL/TLS](../../installation/tools.md#tls-certificates)
     - [Using external Redis](../external-redis/index.md)
     - [using external Object Storage](../external-object-storage/index.md)
   - For external databases, `global.psql.host` is the secondary, read-only replica database, while `global.geo.psql.host` is the Geo tracking database
   <!-- markdownlint-enable MD044 -->

1. Deploy the chart using this configuration:

   ```shell
   helm upgrade --install gitlab-geo gitlab/gitlab --namespace gitlab -f secondary.yaml
   ```

1. Wait for the deployment to complete, and the application to come online.

## Add Secondary Geo site via Primary

Now that both databases are configured and applications are deployed, we must tell
the Primary site that the Secondary site exists:

1. Visit the **primary** site.
1. On the left sidebar, at the bottom, select **Admin Area**.
1. Select **Geo > Add site**.
1. Add the **secondary** site. Use the full GitLab URL for the URL.
1. Enter a Name with the `global.geo.nodeName` of the Secondary site. These values must always match exactly, character for character.
1. Enter Internal URL, for example `https://shanghai.gitlab.example.com`.
1. Optionally, choose which groups or storage shards should be replicated by the
   **secondary** site. Leave blank to replicate all.
1. Select **Add node**.

After the **secondary** site is added to the administration panel, it automatically starts
replicating missing data from the **primary** site. This process is known as "backfill".
Meanwhile, the **primary** site starts to notify each **secondary** site of any changes, so
that the **secondary** site can replicate those changes promptly.

## Confirm Operational Status

The final step is to double check the Geo configuration on the secondary site once fully
configured, via the Toolbox Pod.

1. Find the Toolbox Pod:

   ```shell
   kubectl --namespace gitlab get pods -lapp=toolbox
   ```

1. Attach to the Pod with `kubectl exec`:

   ```shell
   kubectl --namespace gitlab exec -ti gitlab-geo-toolbox-XXX -- bash -l
   ```

1. Check the status of Geo configuration:

   ```shell
   gitlab-rake gitlab:geo:check
   ```

   You should see output similar to below:

   ```plaintext
   WARNING: This version of GitLab depends on gitlab-shell 10.2.0, but you're running Unknown. Please update gitlab-shell.
   Checking Geo ...

   GitLab Geo is available ... yes
   GitLab Geo is enabled ... yes
   GitLab Geo secondary database is correctly configured ... yes
   Database replication enabled? ... yes
   Database replication working? ... yes
   GitLab Geo HTTP(S) connectivity ...
   * Can connect to the primary node ... yes
   HTTP/HTTPS repository cloning is enabled ... yes
   Machine clock is synchronized ... Exception: getaddrinfo: Servname not supported for ai_socktype
   Git user has default SSH configuration? ... yes
   OpenSSH configured to use AuthorizedKeysCommand ... no
     Reason:
     Cannot find OpenSSH configuration file at: /assets/sshd_config
     Try fixing it:
     If you are not using our official docker containers,
     make sure you have OpenSSH server installed and configured correctly on this system
     For more information see:
     doc/administration/operations/fast_ssh_key_lookup.md
   GitLab configured to disable writing to authorized_keys file ... yes
   GitLab configured to store new projects in hashed storage? ... yes
   All projects are in hashed storage? ... yes

   Checking Geo ... Finished
   ```

   - Don't worry about `Exception: getaddrinfo: Servname not supported for ai_socktype`,
     as Kubernetes containers do not have access to the host clock. _This is OK_.
   - `OpenSSH configured to use AuthorizedKeysCommand ... no` _is expected_. This
     Rake task is checking for a local SSH server, which is actually present in the
     `gitlab-shell` chart, deployed elsewhere, and already configured appropriately.

## Configure a separate URL for the secondary site (Optional)

A single, unified URL for the primary and secondary site is usually more convenient for users. For example, you can:

- Place both sites behind a load balancer.
- Route users to the closest site using your cloud provider's DNS features.

In some cases, you may want to give users control over which site they visit. For this purpose, you can configure the secondary Geo site to use a unique external URL. For example:

- Primary cluster's External URL: `https://gitlab.example.com`
- Secondary cluster's External URL: `https://shanghai.gitlab.example.com`

1. Edit `secondary.yaml` and update the secondary cluster's external URL so that the `webservice` chart can process those requests:

   ```yaml
   global:
     # See docs.gitlab.com/charts/charts/globals
     # Configure host & domain
     hosts:
       domain: example.com
       # use a unique external URL for the secondary site
       gitlab:
         name: shanghai.gitlab.example.com
   ```

1. Update the secondary site's External URL in GitLab so that it can use the URL wherever it's needed:
   - Using the Admin UI:
     1. Visit the **primary** site.
     1. On the left sidebar, at the bottom, select **Admin Area**.
     1. Select **Geo > Sites**.
     1. Select the pencil icon to **Edit the secondary site**.
     1. Edit the External URL, for example `https://shanghai.gitlab.example.com`.
     1. Select **Save changes**.
   - Using a Rails runner command:
     1. In a toolbox container in the primary site:

        ```shell
        kubectl --namespace gitlab exec -ti gitlab-geo-toolbox-XXX -- gitlab-rails runner "GeoNode.secondary_nodes.last.update!(url: 'https://shanghai.gitlab.example.com')"
        ```

1. Redeploy the secondary site's chart:

   ```shell
   helm upgrade --install gitlab-geo gitlab/gitlab --namespace gitlab -f secondary.yaml
   ```

1. Wait for the deployment to complete, and the application to come online.

## Registry

To sync the secondary registry with the primary registry you can configure
[registry replication](https://docs.gitlab.com/ee/administration/geo/replication/container_registry.html#configure-container-registry-replication)
using a  [notification secret](../../charts/registry/index.md#notification-secret).

## Cert-manager and unified URL

Geo's unified URL is often used with geolocation-aware routing (for example, using Amazon Route 53 or Google Cloud DNS), which can
cause problems if the [HTTP01 challenge](https://letsencrypt.org/docs/challenge-types/#http-01-challenge) is used to validate that the
domain name is under your control.

When you request a certificate for one Geo site, Let's Encrypt must resolve the DNS name to the requesting Geo site. If the DNS resolves
to a different Geo site, the certificate for the unified URL will not be issued or refreshed.

To reliably create and refresh certificates with cert-manager, either [set the challenge nameserver](https://cert-manager.io/docs/configuration/acme/http01/#setting-nameservers-for-http-01-solver-propagation-checks)
to a server that is known to resolve the unified hostname to the Geo sites IP address or configure
a [DNS01](https://letsencrypt.org/docs/challenge-types/#dns-01-challenge) [Issuer](https://cert-manager.io/docs/configuration/acme/dns01/).
