---
stage: Systems
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
---

# ClickHouse database

The GitLab chart can be configured to set up GitLab with an external ClickHouse database via the HTTP interface. Required parameters:

| Parameter | Description |
| ------- | ------ |
| `global.clickhouse.main.url` | URL for the database |
| `global.clickhouse.main.username` | Database Username |
| `global.clickhouse.main.password.secret` | Name of the configured secret |
| `global.clickhouse.main.password.key` | Which key to use as the password within the secret |
| `global.clickhouse.main.database` | Database name |

WARNING:
Using ClickHouse is intended for experimenting and testing purposes only at the moment.

## Configuring the password

The password can be set manually using the `kubectl` CLI tool:

```shell
kubectl create secret generic gitlab-clickhouse-password --from-literal="main_password=PASSWORD_HERE"
```

## Starting a chart with ClickHouse

You can fill in the details related to the ClickHouse server in the `examples/kind/enable-clickhouse.yaml` file.

Start the chart:

```shell
helm upgrade --install gitlab . \
  --timeout 600s \
  --set global.image.pullPolicy=Always \
  --set global.hosts.domain=YOUR_IP.nip.io \
  --set global.hosts.externalIP=YOUR_IP \
  -f examples/kind/values-base.yaml \
  -f examples/kind/values-no-ssl.yaml \
  -f examples/clickhouse/enable-clickhouse.yaml
```
