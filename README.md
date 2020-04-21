# Gitlab

```

# Modify gitlab URL

# Remove webhooks
```

1. helm template gitlab gitlab/gitlab -f values.yaml --namespace gitlab --set global.hosts.gitlab.name=CHANGEME
update gitlab runner URL to use internal unicorn service http://gitlab-unicorn.gitlab.svc.cluster.local:8181
All helm hooks were removed from gitlab-template.yaml


1. Generate helm template from values:

```
helm template gitlab gitlab/gitlab -f generated/values.yaml --namespace gitlab > generated/generated.yaml
```

2. Modify gitlab runner to use internal hostname

```
CI_SERVER_URL: http://gitlab-unicorn.gitlab.svc.cluster.local:8181
```

3. Remove all helm hooks

4. update connection string

```
connection_string: dbname=gitlab user='<%= File.read("/etc/gitlab/postgres/psql-user").strip.gsub(/[\'\\]/) { |esc| '\\' + esc } %>' host='<%= File.read("/etc/gitlab/postgres/psql-host").strip.gsub(/[\'\\]/) { |esc| '\\' + esc } %>' port=5432 password='<%= File.read("/etc/gitlab/postgres/psql-password").strip.gsub(/[\'\\]/) { |esc| '\\' + esc } %>'
```

5. Add gitlab-credentials secrets where to all pods that use them

```
          - secret:
              name: "gitlab-credentials"
              items:
                - key: "PGHOST"
                  path: postgres/psql-host
          - secret:
              name: "gitlab-credentials"
              items:
                - key: "PGUSER"
                  path: postgres/psql-user
```

6. Update other host/user strings

```
      username: "<%= File.read("/etc/gitlab/postgres/psql-user").strip.dump[1..-2] %>"
      password: "<%= File.read("/etc/gitlab/postgres/psql-password").strip.dump[1..-2] %>"
      host: "<%= File.read("/etc/gitlab/postgres/psql-host").strip.dump[1..-2] %>"
```
