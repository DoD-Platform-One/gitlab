require 'spec_helper'
require 'helm_template_helper'
require 'yaml'

describe 'Redis configuration' do
  let(:default_values) do
    HelmTemplate.defaults
  end

  describe 'global.redis.auth.enabled' do
    let(:values) do
      YAML.safe_load(%(
        global:
          redis:
            auth:
              enabled: true
      )).merge(default_values)
    end

    context 'when true' do
      it 'populate password' do
        t = HelmTemplate.new(values)
        expect(t.exit_code).to eq(0)
        expect(t.dig('ConfigMap/test-webservice','data','resque.yml.erb')).to include("redis/redis-password")
      end
    end

    context 'when false' do
      let(:values) do
        YAML.safe_load(%(
          global:
            redis:
              auth:
                enabled: false
        )).merge(default_values)
      end

      it 'do not populate password' do
        t = HelmTemplate.new(values)
        expect(t.exit_code).to eq(0)
        expect(t.dig('ConfigMap/test-webservice','data','resque.yml.erb')).not_to include("redis/redis-password")
      end
    end
  end

  describe 'redis.yml override' do
    context 'when redisYmlOverride is set' do
      context 'when redisYmlOverrideSecrets contains invalid secrets' do
        let(:values) do
          YAML.safe_load(%(
            global:
              redis:
                redisYmlOverride:
                  chat:
                    secret: gitlab-redis-chat-credential-v2
                  cache:
                    password:
                      enabled: true
                      secret: gitlab-redis-cache-credential-v2
                      key: password

            redis:
              install: false
          )).merge(default_values)
        end

        it 'skips render only for invalid secret' do
          t = HelmTemplate.new(values)
          expect(t.exit_code).to eq(0)

          projected_volume = t.projected_volume_sources('Deployment/test-webservice-default', 'init-webservice-secrets')
          chat_mount =  projected_volume.select { |item| item['secret']['name'] == "gitlab-redis-chat-credential-v2" }
          cache_mount =  projected_volume.select { |item| item['secret']['name'] == "gitlab-redis-cache-credential-v2" }

          expect(chat_mount.size).to eq(0)
          expect(cache_mount.size).to eq(1)

          chat_mount =  projected_volume.select { |item| item['secret']['name'] == "test-redis-secret" }
          test_redis_secrets = YAML.safe_load(%(
            - secret:
                name: test-redis-secret
                items:
                - key: secret
                  path: redis/chat-override-password
            - secret:
                name: test-redis-secret
                items:
                - key: secret
                  path: redis/redis-password
          ))
          expect(chat_mount).to eq(test_redis_secrets)
        end
      end

      context 'when using both global.redis.redisYmlOverride.xxx and global.redis.xxx to define secrets' do
        let(:values) do
          YAML.safe_load(%(
            global:
              redis:
                host: placeholder
                cache:
                  host: gstg-redis-cache
                  password:
                    enabled: true
                    secret: gitlab-redis-cache-credential-v2
                    key: password
                redisYmlOverride:
                  cache:
                    host: gstg-redis-cache
                    password:
                      enabled: true
                      secret: gitlab-redis-cache-credential-v3
                      key: password
            redis:
              install: false
          )).merge(default_values)
        end

        it 'renders both secret without namespace clash' do
          t = HelmTemplate.new(values)
          expect(t.exit_code).to eq(0)

          projected_volume = t.projected_volume_sources('Deployment/test-webservice-default', 'init-webservice-secrets')
          cache_mount = projected_volume.select { |item| item['secret']['name'] == "gitlab-redis-cache-credential-v2" }
          override_mount = projected_volume.select { |item| item['secret']['name'] == "gitlab-redis-cache-credential-v3" }

          # 2 mounts to different paths but same secret key to avoid user having to repeatedly define secrets
          expect(cache_mount.size).to eq(1)
          expect(override_mount.size).to eq(1)
          expect(cache_mount.first['secret']['items'].first['path']).to eq("redis/cache-password")
          expect(override_mount.first['secret']['items'].first['path']).to eq("redis/cache-override-password")
        end
      end

      context 'when redisYmlOverride contains disabled secrets' do
        let(:values) do
          YAML.safe_load(%(
            global:
              redis:
                host: placeholder
                cache:
                  host: gstg-redis-cache
                  password:
                    enabled: true
                    secret: gitlab-redis-cache-credential-v2
                    key: password
                redisYmlOverride:
                  dbLoadBalancing:
                    password:
                      enabled: false
                      secret: gitlab-redis-db-loadbalancing-rails-credential-v2
                      key: password
                  chat:
                    password:
                      enabled: true
                      secret: gitlab-redis-cluster-chat-cache-rails-credential-v2
                      key: password
            redis:
              install: false
          )).merge(default_values)
        end

        it 'renders custom enabled secrets as a volume alongside other secrets' do
          t = HelmTemplate.new(values)
          expect(t.exit_code).to eq(0)

          projected_volume = t.projected_volume_sources('Deployment/test-webservice-default', 'init-webservice-secrets')
          cache_mount = projected_volume.select { |item| item['secret']['name'] == "gitlab-redis-cache-credential-v2" }
          chat_mount = projected_volume.select { |item| item['secret']['name'] == "gitlab-redis-cluster-chat-cache-rails-credential-v2" }
          dblb_mount = projected_volume.select { |item| item['secret']['name'] == "gitlab-redis-db-loadbalancing-rails-credential-v2" }

          expect(cache_mount.size).to eq(1) # override secrets show up in the same location
          expect(chat_mount.size).to eq(1) # enabled secret
          expect(dblb_mount.size).to eq(0) # disabled secret

          dblb_secret = projected_volume.select { |item| item['secret']['items'].first['path'] == "redis/dbLoadBalancing-override-password" }
          expect(dblb_secret.size).to eq(0) # there should be no secret mounted to this path, because password is disabled
        end
      end

      context 'when rendering redis.yml.erb' do
        let(:values) do
          YAML.safe_load(%(
          global:
            redis:
              redisYmlOverride:
                queues:
                  host: gprd-redis-queues
                  password: <%= ERB::Util::url_encode(File.read(\"/etc/gitlab/redis/some-password\").strip) %>
                chat:
                  host: gprd-redis-chat
                  password:
                    enabled: false
                    secret: gitlab-redis-chat-credentials-v2
                    key: password
                cache:
                  host: gprd-redis-cache
                  other_keys:
                  - node1
                  - node2
                  password:
                    enabled: true
                    secret: gitlab-redis-cache-credentials-v2
                    key: password

          redis:
            install: false
        )).merge(default_values)
        end

        it 'replaces password with ERB string where required' do
          t = HelmTemplate.new(values)
          expect(t.exit_code).to eq(0)

          actual = YAML.safe_load(t.dig('ConfigMap/test-webservice','data','redis.yml.erb'))
          expect(actual).to eq(
            {
              'production' => {
                # enabled secret
                'cache' => {
                  'host' => 'gprd-redis-cache',
                  'password' => "<%= ERB::Util::url_encode(File.read(\"/etc/gitlab/redis/cache-override-password\").strip) %>",
                  'other_keys' => %w[node1 node2]
                },
                # disabled secret
                'chat' => {
                  'host' => 'gprd-redis-chat'
                },
                # password being a string
                'queues' => {
                  'host' => 'gprd-redis-queues',
                  'password' => "<%= ERB::Util::url_encode(File.read(\"/etc/gitlab/redis/some-password\").strip) %>"
                }
              }
            })
        end
      end
    end

    context 'when redisYmlOverride is not set' do
      let(:values) { default_values }

      it 'does not render a file' do
        t = HelmTemplate.new(values)
        expect(t.exit_code).to eq(0)
        expect(t.dig('ConfigMap/test-webservice','data')).not_to include('redis.yml.erb')
      end
    end

    context 'When redis.install is true' do
      let(:values) do
        YAML.safe_load(%(
          global:
            redis:
              redisYmlOverride:
                foo: bar
          redis:
            install: true
        )).merge(default_values)
      end

      it 'fails to template (checkConfig)' do
        t = HelmTemplate.new(values)
        expect(t.exit_code).not_to eq(0)
      end
    end

    context 'when redis.install is false' do
      let(:values) do
        YAML.safe_load(%(
          global:
            redis:
              redisYmlOverride:
                foo:
                  bar: baz
                bar:
                  baz: [1, 2, 3]
                deeply:
                  nested: value
                # ERB should pass through Helm without being evaluated
                some:
                  password: <%= File.read('/path/to/password').chomp %>
          redis:
            install: false
        )).merge(default_values)
      end

      it 'renders arbitrary values' do
        t = HelmTemplate.new(values)
        expect(t.exit_code).to eq(0)
        actual = YAML.safe_load(t.dig('ConfigMap/test-webservice','data','redis.yml.erb'))
        expect(actual).to eq(
          {
            'production' => values["global"]["redis"]["redisYmlOverride"]
          }
        )
      end
    end
  end

  describe 'Split Redis queues' do
    context 'When redis.install is true' do
      let(:values) do
        YAML.safe_load(%(
          global:
            redis:
              host: resque.redis
              cache:
                host: cache.redis
          redis:
            install: true
        )).merge(default_values)
      end

      it 'fails to template (checkConfig)' do
        t = HelmTemplate.new(values)
        expect(t.exit_code).not_to eq(0)
      end
    end

    context 'When sub-queue does not define password' do
      let(:values) do
        YAML.safe_load(%(
          global:
            redis:
              host: resque.redis
              auth:
                secret: rspec-resque
              cache:
                host: cache.redis
          redis:
            install: false
        )).merge(default_values)
      end

      it 'sub-queue inherits all of password from global.redis' do
        t = HelmTemplate.new(values)
        expect(t.exit_code).to eq(0)
        expect(t.dig('ConfigMap/test-webservice','data','resque.yml.erb')).to include("redis/redis-password")
        expect(t.dig('ConfigMap/test-webservice','data','resque.yml.erb')).to include("resque.redis")
        expect(t.dig('ConfigMap/test-webservice','data','redis.cache.yml.erb')).to include("redis/cache-password")
        expect(t.dig('ConfigMap/test-webservice','data','redis.cache.yml.erb')).to include("cache.redis")
        secret_mounts =  t.projected_volume_sources('Deployment/test-webservice-default','init-webservice-secrets').select { |item|
          item['secret']['name'] == 'rspec-resque'
        }
        expect(secret_mounts.length).to eq(2)
      end
    end

    context 'When sub-queue defines password.secret, but not password.enabled' do
      let(:values) do
        YAML.safe_load(%(
          global:
            redis:
              host: resque.redis
              auth:
                secret: rspec-resque
              cache:
                host: cache.redis
                password:
                  secret: rspec-cache
          redis:
            install: false
        )).merge(default_values)
      end

      it 'sub-queue inherits from global' do
        t = HelmTemplate.new(values)
        expect(t.exit_code).to eq(0)
        projected_volume = t.projected_volume_sources('Deployment/test-webservice-default','init-webservice-secrets')
        redis_mount =  projected_volume.select { |item| item['secret']['name'] == "rspec-resque" }
        cache_mount =  projected_volume.select { |item| item['secret']['name'] == "rspec-cache" }
        # check that it gets consumed
        expect(t.dig('ConfigMap/test-webservice','data','resque.yml.erb')).to include("redis/redis-password")
        expect(t.dig('ConfigMap/test-webservice','data','redis.cache.yml.erb')).to include("redis/cache-password")
        # check that they are individually mounted.
        expect(redis_mount.length).to eq(1)
        expect(cache_mount.length).to eq(1)
      end
    end

    context 'When sub-queue defines password.enabled true, and redis.password.enabled is false' do
      let(:values) do
        YAML.safe_load(%(
          global:
            redis:
              host: resque.redis
              auth:
                enabled: false
                secret: rspec-resque
              cache:
                host: cache.redis
                password:
                  enabled: true
                  secret: rspec-cache
          redis:
            install: false
        )).merge(default_values)
      end

      it 'sub-queue uses password, global does not' do
        t = HelmTemplate.new(values)
        expect(t.exit_code).to eq(0)
        projected_volume = t.projected_volume_sources('Deployment/test-webservice-default','init-webservice-secrets')
        redis_mount =  projected_volume.select { |item| item['secret']['name'] == "rspec-resque" }
        cache_mount =  projected_volume.select { |item| item['secret']['name'] == "rspec-cache" }
        # check that it gets consumed
        expect(t.dig('ConfigMap/test-webservice','data','resque.yml.erb')).not_to include("redis/redis-password")
        expect(t.dig('ConfigMap/test-webservice','data','redis.cache.yml.erb')).to include("redis/cache-password")
        # check that they are individually mounted.
        expect(redis_mount.length).to eq(0)
        expect(cache_mount.length).to eq(1)
      end
    end

    context 'When sub-queue defines password.enabled false, and redis.password.enabled is true' do
      let(:values) do
        YAML.safe_load(%(
          global:
            redis:
              host: resque.redis
              auth:
                enabled: true
                secret: rspec-resque
              cache:
                host: cache.redis
                password:
                  enabled: false
                  secret: rspec-cache
          redis:
            install: false
        )).merge(default_values)
      end

      it 'sub-queue does not use password, global does' do
        t = HelmTemplate.new(values)
        expect(t.exit_code).to eq(0)
        projected_volume = t.projected_volume_sources('Deployment/test-webservice-default','init-webservice-secrets')
        redis_mount =  projected_volume.select { |item| item['secret']['name'] == "rspec-resque" }
        cache_mount =  projected_volume.select { |item| item['secret']['name'] == "rspec-cache" }
        # check that it gets consumed
        expect(t.dig('ConfigMap/test-webservice','data','resque.yml.erb')).to include("redis/redis-password")
        expect(t.dig('ConfigMap/test-webservice','data','redis.cache.yml.erb')).not_to include("redis/cache-password")
        # check that they are individually mounted.
        expect(redis_mount.length).to eq(1)
        expect(cache_mount.length).to eq(0)
      end
    end

    context 'When global defines user' do
      let(:values) do
        YAML.safe_load(%(
          global:
            redis:
              host: resque.redis
              user: resque-user
              auth:
                enabled: true
                secret: rspec-resque
              cache:
                host: cache.redis
          redis:
            install: false
        )).merge(default_values)
      end

      it 'global uses user' do
        t = HelmTemplate.new(values)
        expect(t.exit_code).to eq(0)
        # check that it gets correct hosts & port are used
        expect(t.dig('ConfigMap/test-webservice','data','resque.yml.erb')).to include("resque-user")
      end
    end

    context 'When sub-queue defines port, but not host' do
      let(:values) do
        YAML.safe_load(%(
          global:
            redis:
              host: resque.redis
              port: 6379
              cache:
                port: 9999
          redis:
            install: false
        )).merge(default_values)
      end

      it 'sub-queue uses port, global host' do
        t = HelmTemplate.new(values)
        expect(t.exit_code).to eq(0)
        # check that it gets correct hosts & port are used
        expect(t.dig('ConfigMap/test-webservice','data','resque.yml.erb')).to include("resque.redis:6379")
        expect(t.dig('ConfigMap/test-webservice','data','redis.cache.yml.erb')).to include("resque.redis:9999")
      end
    end

    context 'When global and sub-queue defines Sentinels' do
      let(:values) do
        YAML.safe_load(%(
          global:
            redis:
              host: resque.redis
              port: 6379
              sentinels:
              - host: s1.resque.redis
                port: 26379
              - host: s2.resque.redis
                port: 26379
              cache:
                host: cache.redis
                sentinels:
                - host: s1.cache.redis
                  port: 26379
                - host: s2.cache.redis
                  port: 26379
          redis:
            install: false
        )).merge(default_values)
      end

      it 'separate sentinels are populated' do
        t = HelmTemplate.new(values)
        expect(t.exit_code).to eq(0)
        # check that it they consumed only in sub-queue
        expect(t.dig('ConfigMap/test-webservice','data','resque.yml.erb')).to include("sentinels:")
        expect(t.dig('ConfigMap/test-webservice','data','resque.yml.erb')).to include("s1.resque.redis")
        expect(t.dig('ConfigMap/test-webservice','data','redis.cache.yml.erb')).to include("sentinels:")
        expect(t.dig('ConfigMap/test-webservice','data','redis.cache.yml.erb')).to include("s1.cache.redis")
      end
    end

    context 'When only sub-queue defines Sentinels' do
      let(:values) do
        YAML.safe_load(%(
          global:
            redis:
              host: resque.redis
              port: 6379
              cache:
                host: cache.redis
                sentinels:
                - host: s1.cache.redis
                  port: 26379
                - host: s2.cache.redis
                  port: 26379
          redis:
            install: false
        )).merge(default_values)
      end

      it 'sub-queue sentinels are populated' do
        t = HelmTemplate.new(values)
        expect(t.exit_code).to eq(0)
        # check that it they consumed only in sub-queue
        expect(t.dig('ConfigMap/test-webservice','data','resque.yml.erb')).not_to include("sentinels:")
        expect(t.dig('ConfigMap/test-webservice','data','redis.cache.yml.erb')).to include("sentinels:")
        expect(t.dig('ConfigMap/test-webservice','data','redis.cache.yml.erb')).to include("s1.cache.redis")
      end
    end
  end

  describe 'Redis Cluster' do
    context 'When only nested redis defines cluster' do
      let(:values) do
        YAML.safe_load(%(
          global:
            redis:
              host: resque.redis
              cache:
                host: cache.redis
                sentinels:
                - host: s1.cache.redis
                - host: s2.cache.redis
              clusterCache:
                cluster:
                - host: s1.cluster-cache.redis
                - host: s2.cluster-cache.redis
          redis:
            install: false
        )).merge(default_values)
      end

      it 'Only nested redis cluster is populated' do
        t = HelmTemplate.new(values)
        expect(t.exit_code).to eq(0)
        expect(t.dig('ConfigMap/test-webservice','data','redis.cache.yml.erb')).to include("sentinels:")
        expect(t.dig('ConfigMap/test-webservice','data','redis.cache.yml.erb')).to include("s1.cache.redis")
        expect(t.dig('ConfigMap/test-webservice','data','redis.cluster_cache.yml.erb')).to include("cluster:")
        expect(t.dig('ConfigMap/test-webservice','data','redis.cluster_cache.yml.erb')).to include("s1.cluster-cache.redis")
      end
    end

    context 'When only nested redis defines cluster, user, and password' do
      let(:values) do
        YAML.safe_load(%(
          global:
            redis:
              host: resque.redis
              auth:
                enabled: false
              clusterCache:
                user: cluster-cache-user
                password:
                  enabled: true
                cluster:
                - host: s1.cluster-cache.redis
                - host: s2.cluster-cache.redis
          redis:
            install: false
        )).merge(default_values)
      end

      it 'Only nested redis cluster is populated' do
        t = HelmTemplate.new(values)
        expect(t.exit_code).to eq(0)
        expect(t.dig('ConfigMap/test-webservice','data','resque.yml.erb')).not_to include("cluster-cache-user")
        expect(t.dig('ConfigMap/test-webservice','data','resque.yml.erb')).not_to include("redis/redis-password")
        expect(t.dig('ConfigMap/test-webservice','data','redis.cluster_cache.yml.erb')).to include("cluster:")
        expect(t.dig('ConfigMap/test-webservice','data','redis.cluster_cache.yml.erb')).to include("s1.cluster-cache.redis")
        expect(t.dig('ConfigMap/test-webservice','data','redis.cluster_cache.yml.erb')).to include("cluster-cache-user")
        expect(t.dig('ConfigMap/test-webservice','data','redis.cluster_cache.yml.erb')).to include("redis/clusterCache-password")
      end
    end

    context 'When top level user and password are defined' do
      let(:values) do
        YAML.safe_load(%(
          global:
            redis:
              host: resque.redis
              user: resque-user
              auth:
                enabled: true
              clusterCache:
                cluster:
                - host: s1.cluster-cache.redis
                - host: s2.cluster-cache.redis
          redis:
            install: false
        )).merge(default_values)
      end

      it 'No values are inherited by nested redis cluster' do
        t = HelmTemplate.new(values)
        expect(t.exit_code).to eq(0)
        expect(t.dig('ConfigMap/test-webservice','data','resque.yml.erb')).to include("resque-user")
        expect(t.dig('ConfigMap/test-webservice','data','resque.yml.erb')).to include("redis/redis-password")
        expect(t.dig('ConfigMap/test-webservice','data','redis.cluster_cache.yml.erb')).to include("cluster:")
        expect(t.dig('ConfigMap/test-webservice','data','redis.cluster_cache.yml.erb')).to include("s1.cluster-cache.redis")
        expect(t.dig('ConfigMap/test-webservice','data','redis.cluster_cache.yml.erb')).not_to include("resque-user")
        expect(t.dig('ConfigMap/test-webservice','data','redis.cluster_cache.yml.erb')).not_to include("redis/redis-password")
        expect(t.dig('ConfigMap/test-webservice','data','redis.cluster_cache.yml.erb')).not_to include("redis/cluster-cache-password")
      end
    end
  end

  describe 'Generated Kubernetes object names' do
    context 'Helm release name does not include "redis"' do
      it 'Objects are suffixed with "-redis", references match' do
        # run template, default release name is 'test'
        t = HelmTemplate.new(default_values)
        expect(t.exit_code).to eq(0)
        # check that Services are -redis-master
        expect(t.dig('Service/test-master')).to be_falsey
        expect(t.dig('Service/test-redis-master')).to be_truthy
        # check resque.yml
        expect(t.dig('ConfigMap/test-toolbox','data','resque.yml.erb')).to include('test-redis-master')
      end
    end

    context 'Helm release name includes "redis"' do
      it 'Objects are suffixed without "-redis", references match' do
        # run template, pass release name with "redis" in it
        t = HelmTemplate.new(default_values,'redis-test')
        expect(t.exit_code).to eq(0)
        # check that Services are -master
        expect(t.dig('Service/redis-test-master')).to be_truthy
        expect(t.dig('Service/redis-test-redis-master')).to be_falsey
        # check resque.yml is pointing to the right service.
        expect(t.dig('ConfigMap/redis-test-toolbox','data','resque.yml.erb')).to include('redis-test-master')
      end
    end
  end
end
