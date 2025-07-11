---
stage: GitLab Delivery
group: Self Managed
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: Set up standalone PostgreSQL database
---

We'll make use of the [Linux package](https://about.gitlab.com/install/#ubuntu) for Ubuntu. This package provides versions of the services that are guaranteed to be compatible with the charts' services.

## Create VM with the Linux package

Create a VM on your provider of choice, or locally. This was tested with VirtualBox, KVM, and Bhyve.
Ensure that the instance is reachable from the cluster.

Install Ubuntu Server onto the VM that you have created. Ensure that `openssh-server` is installed, and that all packages are up to date.
Configure networking and a hostname. Make note of the hostname/IP, and ensure it is both resolvable and reachable from your Kubernetes cluster.
Be sure firewall policies are in place to allow traffic.

Follow the installation instructions for the [Linux package](https://about.gitlab.com/install/#ubuntu). When you perform the package installation, **_do not_** provide the `EXTERNAL_URL=` value. We do not want automatic configuration to occur, as we'll provide a very specific configuration in the next step.

## Configure Linux package installation

Create a minimal `gitlab.rb` file to be placed at `/etc/gitlab/gitlab.rb`. Be very explicit about what is enabled on this node, use the contents below.

_Note_: This example is not intended to provide [PostgreSQL for scaling](https://docs.gitlab.com/administration/postgresql/).

_**NOTE**: The values below should be replaced_

- `DB_USERNAME` default username is `gitlab`
- `DB_PASSSWORD` unencoded value
- `DB_ENCODED_PASSWORD` encoded value of `DB_PASSWORD`. Can be generated by replacing `DB_USERNAME` and `DB_PASSWORD` with real values in: `echo -n 'DB_PASSSWORDDB_USERNAME' | md5sum - | cut -d' ' -f1`
- `AUTH_CIDR_ADDRESS` configure the CIDRs for MD5 authentication, should be the smallest possible subnets of your cluster or it's gateway. For minikube, this value is `192.168.100.0/12`

```ruby
# Change the address below if you do not want PG to listen on all available addresses
postgresql['listen_address'] = '0.0.0.0'
# Set to approximately 1/4 of available RAM.
postgresql['shared_buffers'] = "512MB"
# This password is: `echo -n '${password}${username}' | md5sum - | cut -d' ' -f1`
# The default username is `gitlab`
postgresql['sql_user_password'] = "DB_ENCODED_PASSWORD"
# Configure the CIDRs for MD5 authentication
postgresql['md5_auth_cidr_addresses'] = ['AUTH_CIDR_ADDRESSES']
# Configure the CIDRs for trusted authentication (passwordless)
postgresql['trust_auth_cidr_addresses'] = ['127.0.0.1/24']

## Configure gitlab_rails
gitlab_rails['auto_migrate'] = false
gitlab_rails['db_username'] = "gitlab"
gitlab_rails['db_password'] = "DB_PASSSWORD"


## Disable everything else
sidekiq['enable'] = false
puma['enable'] = false
registry['enable'] = false
gitaly['enable'] = false
gitlab_workhorse['enable'] = false
nginx['enable'] = false
prometheus_monitoring['enable'] = false
redis['enable'] = false
gitlab_kas['enable'] = false
```

After creating `gitlab.rb`, we'll reconfigure the package with `gitlab-ctl reconfigure`. Once the task has completed, check the running processes with `gitlab-ctl status`. The output should appear as such:

```plaintext
# gitlab-ctl status
run: logrotate: (pid 4856) 1859s; run: log: (pid 31262) 77460s
run: postgresql: (pid 30562) 77637s; run: log: (pid 30561) 77637s
```
