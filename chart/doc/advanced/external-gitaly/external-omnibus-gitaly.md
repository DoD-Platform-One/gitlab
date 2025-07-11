---
stage: GitLab Delivery
group: Self Managed
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: Setup standalone Gitaly
---

The instructions here make use of the [Linux package](https://about.gitlab.com/install/#ubuntu) for Ubuntu.
This package provides versions of the services that are guaranteed to be compatible with the charts' services.

## Create VM with the Linux package

Create a VM on your provider of choice, or locally. This was tested with VirtualBox, KVM, and Bhyve.
Ensure that the instance is reachable from the cluster.

Install Ubuntu Server onto the VM that you have created. Ensure that `openssh-server` is installed, and that all packages are up to date.
Configure networking and a hostname. Make note of the hostname/IP, and ensure it is both resolvable and reachable from your Kubernetes cluster.
Be sure firewall policies are in place to allow traffic.

Follow the installation instructions for the [Linux package](https://about.gitlab.com/install/#ubuntu). When you perform
the Linux package installation, **_do not_** provide the `EXTERNAL_URL=` value. We do not want automatic configuration to occur, as we'll provide a very specific configuration in the next step.

## Configure Linux package installation

Create a minimal `gitlab.rb` file to be placed at `/etc/gitlab/gitlab.rb`. Be
_very_ explicit about what's enabled on this node, using the following contents
based on the documentation for
[running Gitaly on its own server](https://docs.gitlab.com/administration/gitaly/configure_gitaly/#run-gitaly-on-its-own-server).

_**NOTE**: The values below should be replaced_

- `AUTH_TOKEN` should be replaced with the value in the [`gitaly-secret` secret](../../installation/secrets.md#gitaly-secret)
- `GITLAB_URL` should be replaced with the URL of the GitLab instance
- `SHELL_TOKEN` should be replaced with the value in the [`gitlab-shell-secret` secret](../../installation/secrets.md#gitlab-shell-secret)

<!--
Updates to example must be made at:
- https://gitlab.com/gitlab-org/charts/gitlab/blob/master/doc/advanced/external-gitaly/external-omnibus-gitaly.md#configure-omnibus-gitlab
- https://gitlab.com/gitlab-org/gitlab/blob/master/doc/administration/gitaly/index.md#gitaly-server-configuration
- all reference architecture pages
-->

```ruby
# Avoid running unnecessary services on the Gitaly server
postgresql['enable'] = false
redis['enable'] = false
nginx['enable'] = false
puma['enable'] = false
sidekiq['enable'] = false
gitlab_workhorse['enable'] = false
gitlab_exporter['enable'] = false
gitlab_kas['enable'] = false

# If you run a seperate monitoring node you can disable these services
prometheus['enable'] = false
alertmanager['enable'] = false

# If you don't run a separate monitoring node you can
# Enable Prometheus access & disable these extra services
# This makes Prometheus listen on all interfaces. You must use firewalls to restrict access to this address/port.
# prometheus['listen_address'] = '0.0.0.0:9090'
# prometheus['monitor_kubernetes'] = false

# If you don't want to run monitoring services uncomment the following (not recommended)
# node_exporter['enable'] = false

# Prevent database connections during 'gitlab-ctl reconfigure'
gitlab_rails['auto_migrate'] = false

# Configure the gitlab-shell API callback URL. Without this, `git push` will
# fail. This can be your 'front door' GitLab URL or an internal load
# balancer.
gitlab_rails['internal_api_url'] = 'GITLAB_URL'
# Token used by Gitaly and GitLab shell to authenticate with GitLab
gitaly['gitlab_secret'] = 'SHELL_TOKEN'

gitaly['configuration'] = {
    # Make Gitaly accept connections on all network interfaces. You must use
    # firewalls to restrict access to this address/port.
    # Comment out following line if you only want to support TLS connections
    listen_addr: '0.0.0.0:8075',
    # Authentication token to ensure only authorized servers can communicate with
    # Gitaly server
    auth: {
        token: 'AUTH_TOKEN',
    },
}

git_data_dirs({
 'default' => {
   'path' => '/var/opt/gitlab/git-data'
 },
 'storage1' => {
   'path' => '/mnt/gitlab/git-data'
 },
})

# To use TLS for Gitaly you need to add
gitaly['tls_listen_addr'] = "0.0.0.0:8076"
gitaly['certificate_path'] = "path/to/cert.pem"
gitaly['key_path'] = "path/to/key.pem"
```

After creating `gitlab.rb`, reconfigure the package with `gitlab-ctl reconfigure`.
Once the task has completed, check the running processes with `gitlab-ctl status`.
The output should appear as such:

```plaintext
# gitlab-ctl status
run: gitaly: (pid 30562) 77637s; run: log: (pid 30561) 77637s
run: logrotate: (pid 4856) 1859s; run: log: (pid 31262) 77460s
```
