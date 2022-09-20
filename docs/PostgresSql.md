## Postgres Setup

There are two ways to configure a production external Postgres database.

1. At install time the configuration can be introduced in the Helm command.

```
--set postgresql.install=false
--set global.psql.host=production.postgress.hostname.local
--set global.psql.password.secret=kubernetes_secret_name
--set global.psql.password.key=key_that_contains_postgres_password
```

2. You can change the values in values.yaml

First you must disable the automatic Postgres install done by the chart.

```
## Installation & configuration of stable/prostgresql
## See requirements.yaml for current version
postgresql:
  postgresqlUsername: gitlab
  # This just needs to be set. It will use a second entry in existingSecret for postgresql-postgres-password
  postgresqlPostgresPassword: bogus
  install: false  ## <- Change this here
  postgresqlDatabase: gitlabhq_production
  image:
    tag: 11.7.0
  usePasswordFile: true
  existingSecret: 'bogus'
  initdbScriptsConfigMap: 'bogus'
  master:
    extraVolumeMounts:
      - name: custom-init-scripts
        mountPath: /docker-entrypoint-preinitdb.d/init_revision.sh
        subPath: init_revision.sh
    podAnnotations:
      postgresql.gitlab/init-revision: "1"
  metrics:
    enabled: true
    ## Optionally define additional custom metrics
    ## ref: https://github.com/wrouesnel/postgres_exporter#adding-new-metrics-via-a-config-file
```

```
## doc/charts/globals.md#configure-postgresql-settings
  psql:
    password: {}
      # secret:
      # key:
    # host: postgresql.hostedsomewhere.else
    # port: 123
    # username: gitlab
    # database: gitlabhq_production
    # pool: 1
    # preparedStatements: false
```

[Gitlab](https://docs.gitlab.com/charts/advanced/external-db/) has documentation on doing this.