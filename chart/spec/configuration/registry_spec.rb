require 'spec_helper'
require 'helm_template_helper'
require 'yaml'
require 'hash_deep_merge'
require 'runtime_template_helper'

describe 'registry configuration' do
  let(:default_values) do
    HelmTemplate.defaults
  end

  let(:sentinel_password) { SecureRandom.hex }

  def render_yaml(raw_template, env = {})
    files = { '/config/redis-sentinel/redis-sentinel-password' => sentinel_password }

    yaml = RuntimeTemplate.gomplate(raw_template: raw_template, files: files, env: env)

    # Strings like :5000 get loaded as Symbols, so allow this for now
    YAML.safe_load(yaml, permitted_classes: [Symbol])
  end

  context 'When customer provides additional labels' do
    let(:values) do
      YAML.safe_load(%(
        global:
          common:
            labels:
              global: global
              foo: global
          pod:
            labels:
              global_pod: true
          service:
            labels:
              global_service: true
        registry:
          common:
            labels:
              global: registry
              registry: registry
          networkpolicy:
            enabled: true
          podLabels:
            pod: true
            global: pod
          serviceAccount:
            create: true
            enabled: true
          serviceLabels:
            service: true
            global: service
      )).deep_merge(default_values)
    end

    it 'Populates the additional labels in the expected manner' do
      t = HelmTemplate.new(values)
      expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"
      expect(t.dig('ConfigMap/test-registry', 'metadata', 'labels')).to include('global' => 'registry')
      expect(t.dig('Deployment/test-registry', 'metadata', 'labels')).to include('foo' => 'global')
      expect(t.dig('Deployment/test-registry', 'metadata', 'labels')).to include('global' => 'registry')
      expect(t.dig('Deployment/test-registry', 'metadata', 'labels')).not_to include('global' => 'pod')
      expect(t.dig('Deployment/test-registry', 'metadata', 'labels')).not_to include('global' => 'global')
      expect(t.dig('Deployment/test-registry', 'spec', 'template', 'metadata', 'labels')).to include('global' => 'pod')
      expect(t.dig('Deployment/test-registry', 'spec', 'template', 'metadata', 'labels')).to include('pod' => 'true')
      expect(t.dig('Deployment/test-registry', 'spec', 'template', 'metadata', 'labels')).to include('global_pod' => 'true')
      expect(t.dig('HorizontalPodAutoscaler/test-registry', 'metadata', 'labels')).to include('global' => 'registry')
      expect(t.dig('Ingress/test-registry', 'metadata', 'labels')).to include('global' => 'registry')
      expect(t.dig('NetworkPolicy/test-registry-v1', 'metadata', 'labels')).to include('global' => 'registry')
      expect(t.dig('PodDisruptionBudget/test-registry-v1', 'metadata', 'labels')).to include('global' => 'registry')
      expect(t.dig('Service/test-registry', 'metadata', 'labels')).to include('global' => 'service')
      expect(t.dig('Service/test-registry', 'metadata', 'labels')).to include('global_service' => 'true')
      expect(t.dig('Service/test-registry', 'metadata', 'labels')).to include('service' => 'true')
      expect(t.dig('Service/test-registry', 'metadata', 'labels')).not_to include('global' => 'global')
      expect(t.dig('ServiceAccount/test-registry', 'metadata', 'labels')).to include('global' => 'registry')
    end
  end

  describe 'service TLS is configured' do
    let(:tls_values) do
      YAML.safe_load(%(
        global:
          hosts:
            registry:
              protocol: https
        registry:
          tls:
            enabled: true
      )).deep_merge(default_values)
    end

    context 'when enabled without configuration' do
      it 'renders default configuration, volume content, ingress annotations, port definitions' do
        t = HelmTemplate.new(tls_values)
        expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"

        expect(t.dig('ConfigMap/test-registry', 'data', 'config.yml.tpl')).to include(
          <<~TLS_CONFIG
          http:
            addr: :5000
            # `host` is not configurable
            # `prefix` is not configurable
            tls:
              certificate: /etc/docker/registry/tls/tls.crt
              key: /etc/docker/registry/tls/tls.key
              minimumTLS: "tls1.2"
          TLS_CONFIG
        )

        tls_crt = t.find_projected_secret_key('Deployment/test-registry', 'registry-secrets', 'test-registry-tls', 'tls.crt')
        expect(tls_crt).not_to be_empty

        ingress_annotations = t.annotations('Ingress/test-registry')
        expect(ingress_annotations).to include(YAML.safe_load(%(
          nginx.ingress.kubernetes.io/backend-protocol: https
          nginx.ingress.kubernetes.io/proxy-ssl-verify: "on"
          nginx.ingress.kubernetes.io/proxy-ssl-name: test-registry.default.svc
        )))

        service_ports = t.dig('Service/test-registry', 'spec', 'ports')
        expect(service_ports[0]['targetPort']).to eq('https')

        container_ports = t.find_container('Deployment/test-registry', 'registry')['ports']
        expect(container_ports).to include({ 'containerPort' => 5000, 'name' => 'https' })
      end
    end

    context 'when provided internal TLS configuration' do
      let(:values) do
        YAML.safe_load(%(
          registry:
            tls:
              secretName: internal-hosts-tls
        )).deep_merge(tls_values)
      end

      it 'renders deployment as expected' do
        t = HelmTemplate.new(values)
        expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"

        expect(t.find_projected_secret('Deployment/test-registry', 'registry-secrets', 'internal-hosts-tls')).to be true
      end
    end

    context 'when provided global TLS configuration' do
      let(:values) do
        YAML.safe_load(%(
          global:
            registry:
              tls:
                secretName: global-tls
        )).deep_merge(tls_values)
      end

      it 'renders deployment with global TLS configuration' do
        t = HelmTemplate.new(values)
        expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"

        expect(t.find_projected_secret('Deployment/test-registry', 'registry-secrets', 'global-tls')).to be true
      end
    end

    context 'when provided global and internal TLS configuration' do
      let(:values) do
        YAML.safe_load(%(
          global:
            registry:
              tls:
                secretName: global-tls
          registry:
            tls:
              secretName: internal-hosts-tls
        )).deep_merge(tls_values)
      end

      it 'renders deployment with internal TLS configuration' do
        t = HelmTemplate.new(values)
        expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"

        expect(t.find_projected_secret('Deployment/test-registry', 'registry-secrets', 'internal-hosts-tls')).to be true
      end
    end

    context 'when provided extended TLS configuration' do
      let(:values) do
        YAML.safe_load(%(
          global:
            host:
              registry:
                protocol: https
          registry:
            tls:
              secretName: registry-service-tls
              clientCAs: [one, two, three]
              minimumTLS: "tls1.3"
              caSecretName: service-tls-ca
        )).deep_merge(tls_values)
      end

      it 'renders configuration, ingress as expected' do
        t = HelmTemplate.new(values)
        expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"

        expect(t.dig('ConfigMap/test-registry', 'data', 'config.yml.tpl')).to include(
          <<~TLS_CONFIG
          http:
            addr: :5000
            # `host` is not configurable
            # `prefix` is not configurable
            tls:
              certificate: /etc/docker/registry/tls/tls.crt
              key: /etc/docker/registry/tls/tls.key
              clientCAs:
                - one
                - two
                - three
              minimumTLS: "tls1.3"
          TLS_CONFIG
        )

        ingress_annotations = t.annotations('Ingress/test-registry')
        expect(ingress_annotations).to include(
          'nginx.ingress.kubernetes.io/proxy-ssl-secret' => 'default/service-tls-ca'
        )
      end
    end
  end

  describe 'templates/configmap.yaml' do
    describe 'database config' do
      context 'when primary is provided' do
        let(:values) do
          YAML.safe_load(%(
            registry:
              database:
                enabled: true
                primary: "primary.record.fqdn"
          )).deep_merge(default_values)
        end

        it 'populates the database primary settings correctly' do
          t = HelmTemplate.new(values)
          expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"

          expect(t.dig('ConfigMap/test-registry', 'data', 'config.yml.tpl')).to include(
            <<~CONFIG
            database:
              enabled: true
              host: "test-postgresql.default.svc"
              port: 5432
              user: registry
              password: "DB_PASSWORD_FILE"
              dbname: registry
              sslmode: disable
              primary: primary.record.fqdn
            CONFIG
          )
        end
      end

      context 'when extraEnv and extraEnvFrom are set' do
        let(:values) do
          YAML.safe_load(%(
            global:
              extraEnv:
                EXTRA_ENV_VAR_A: global-a
                EXTRA_ENV_VAR_B: global-b
              extraEnvFrom:
                EXTRA_ENV_VAR_C:
                  secretKeyRef:
                    key: "keyC"
                    name: "nameC"
            registry:
              database:
                enabled: true
                primary: "primary.record.fqdn"
          )).deep_merge(default_values)
        end

        let(:template) { HelmTemplate.new(values) }
        let(:deployment) { template['Deployment/test-registry'] }
        let(:configmap) { template['ConfigMap/test-registry'] }
        let(:init_containers) { deployment.dig('spec', 'template', 'spec', 'initContainers') }
        let(:configure_init_container) { init_containers.find { |container| container['name'] == 'configure' } }
        let(:env) { deployment.dig('spec', 'template', 'spec', 'containers').first['env'] }

        it 'renders the config files' do
          expect(template.exit_code).to eq(0), "Unexpected error code #{template.exit_code} -- #{template.stderr}"
          expect(init_containers.length).to eq(3)
          expect(configure_init_container['env']).to include(
            { "name" => "CONFIG_TEMPLATE_DIRECTORY", "value" => "/templates" },
            { "name" => "CONFIG_DIRECTORY", "value" => "/registry" },
            { 'name' => 'EXTRA_ENV_VAR_A', 'value' => 'global-a' },
            { 'name' => 'EXTRA_ENV_VAR_B', 'value' => 'global-b' },
            { 'name' => 'EXTRA_ENV_VAR_C', 'valueFrom' => { "secretKeyRef" => { "name" => "nameC", "key" => "keyC" } } }
          )
          expect(env).to include(
            { 'name' => 'EXTRA_ENV_VAR_A', 'value' => 'global-a' },
            { 'name' => 'EXTRA_ENV_VAR_B', 'value' => 'global-b' },
            { 'name' => 'EXTRA_ENV_VAR_C', 'valueFrom' => { "secretKeyRef" => { "name" => "nameC", "key" => "keyC" } } }
          )

          registry_yml = render_yaml(configmap.dig('data', 'config.yml.tpl'))
          expect(registry_yml.dig('database', 'enabled')).to eq(true)
          expect(registry_yml.dig('database', 'primary')).to eq('primary.record.fqdn')

          migrations_yml = render_yaml(configmap.dig('data', 'migrations-config.yml.tpl'))
          expect(migrations_yml.dig('database', 'enabled')).to eq(true)
          expect(migrations_yml.dig('database', 'primary')).to eq('primary.record.fqdn')
        end
      end

      context "when database configuration is required" do
        using RSpec::Parameterized::TableSyntax

        # rubocop:disable Lint/BinaryOperatorWithIdenticalOperands
        where(:enabled, :configure, :include_db_config) do
          false | false | false
          true  | false | true # Backwards compatibility with .registry.database.enabled.
          false | true  | true
          true  | true  | true
        end
        # rubocop:enable Lint/BinaryOperatorWithIdenticalOperands

        with_them do
          let(:values) do
            YAML.safe_load(%(
            registry:
              database:
                configure: #{configure}
                enabled: #{enabled}
          )).deep_merge(default_values)
          end

          let(:config) do
            <<~CONFIG
            database:
              enabled: #{enabled}
              host: "test-postgresql.default.svc"
              port: 5432
              user: registry
              password: "DB_PASSWORD_FILE"
              dbname: registry
              sslmode: disable
            CONFIG
          end

          it 'populates the database settings correctly' do
            t = HelmTemplate.new(values)
            expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"

            if include_db_config
              expect(t.dig('ConfigMap/test-registry', 'data', 'config.yml.tpl')).to include(config)
              expect(t.dig('ConfigMap/test-registry', 'data', 'migrations-config.yml.tpl')).to include(config)
            else
              expect(t.dig('ConfigMap/test-registry', 'data', 'config.yml.tpl')).not_to include(config)
              expect(t.dig('ConfigMap/test-registry', 'data', 'migrations-config.yml.tpl')).not_to include(config)
            end
          end
        end
      end
    end

    describe 'redis cache config' do
      context 'when cache is enabled using global settings' do
        let(:values) do
          YAML.safe_load(%(
            global:
              redis:
                host: global.redis.example.com
                port: 16379
            registry:
              database:
                enabled: true
              redis:
                cache:
                  enabled: true
          )).deep_merge(default_values)
        end

        it 'populates the redis address with the global setting' do
          t = HelmTemplate.new(values)
          expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"

          expect(t.dig('ConfigMap/test-registry', 'data', 'config.yml.tpl')).to include(
            <<~CONFIG
            redis:
              cache:
                enabled: true
                addr: "global.redis.example.com:16379"
            CONFIG
          )
        end
      end

      context 'when customer provides a custom redis cache configuration with a single host' do
        let(:values) do
          YAML.safe_load(%(
            registry:
              database:
                enabled: true
              redis:
                cache:
                  enabled: true
                  host: redis.example.com
                  port: 12345
                  db: 0
                  password:
                    enabled: true
                    secret: registry-redis-cache-secret
                    key: password
                  dialtimeout: 10ms
                  readtimeout: 10ms
                  writetimeout: 10ms
                  tls:
                    enabled: true
                    insecure: true
                  pool:
                    size: 10
                    maxlifetime: 1h
                    idletimeout: 300s
          )).deep_merge(default_values)
        end

        it 'populates the redis cache settings in the expected manner' do
          t = HelmTemplate.new(values)
          expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"
          expect(t.dig('ConfigMap/test-registry', 'data', 'config.yml.tpl')).to include(
            <<~CONFIG
            redis:
              cache:
                enabled: true
                addr: "redis.example.com:12345"
                password: "REDIS_CACHE_PASSWORD"
                db: 0
                dialtimeout: 10ms
                readtimeout: 10ms
                writetimeout: 10ms
                tls:
                  enabled: true
                  insecure: true
                pool:
                  size: 10
                  maxlifetime: 1h
                  idletimeout: 300s
            CONFIG
          )

          cache_secret = t.find_projected_secret_key('Deployment/test-registry', 'registry-secrets', 'registry-redis-cache-secret', 'password')
          expect(cache_secret).not_to be_empty
        end
      end

      context 'when customer provides a custom redis cache configuration with a single host without port' do
        let(:values) do
          YAML.safe_load(%(
            registry:
              database:
                enabled: true
              redis:
                cache:
                  enabled: true
                  host: redis.example.com
          )).deep_merge(default_values)
        end

        it 'populates the redis cache settings with the default port' do
          t = HelmTemplate.new(values)
          expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"
          expect(t.dig('ConfigMap/test-registry', 'data', 'config.yml.tpl')).to include(
            <<~CONFIG
            redis:
              cache:
                enabled: true
                addr: "redis.example.com:6379"
            CONFIG
          )
        end
      end

      context 'when customer provides a custom redis cache configuration with global sentinels' do
        let(:values) do
          YAML.safe_load(%(
            global:
              redis:
                host: redis.example.com
                sentinels:
                  - host: sentinel1.example.com
                    port: 26379
                  - host: sentinel2.example.com
                    port: 26379
            registry:
              database:
                enabled: true
              redis:
                cache:
                  enabled: true
        )).deep_merge(default_values)
        end

        it 'populates the redis cache settings in the expected manner' do
          t = HelmTemplate.new(values)
          expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"
          expect(t.dig('ConfigMap/test-registry', 'data', 'config.yml.tpl')).to include(
            <<~CONFIG
            redis:
              cache:
                enabled: true
                addr: "sentinel1.example.com:26379,sentinel2.example.com:26379"
                mainname: redis.example.com
            CONFIG
          )
        end
      end

      context 'when customer provides a custom redis cache configuration with local sentinels' do
        let(:values) do
          YAML.safe_load(%(
            registry:
              database:
                enabled: true
              redis:
                cache:
                  enabled: true
                  host: redis.example.com
                  sentinels:
                    - host: sentinel1.example.com
                      port: 26379
                    - host: sentinel2.example.com
                      port: 26379
        )).deep_merge(default_values)
        end

        it 'populates the redis cache settings in the expected manner' do
          t = HelmTemplate.new(values)
          expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"
          expect(t.dig('ConfigMap/test-registry', 'data', 'config.yml.tpl')).to include(
            <<~CONFIG
            redis:
              cache:
                enabled: true
                addr: "sentinel1.example.com:26379,sentinel2.example.com:26379"
                mainname: redis.example.com
            CONFIG
          )
        end
      end

      context 'when customer provides a custom redis cache configuration with local and global sentinels' do
        let(:values) do
          YAML.safe_load(%(
            global:
              redis:
                host: redis.example.com
                sentinels:
                  - host: global1.example.com
                    port: 26379
                  - host: global2.example.com
                    port: 26379
            registry:
              database:
                enabled: true
              redis:
                cache:
                  enabled: true
                  host: local.example.com
                  sentinels:
                    - host: local1.example.com
                      port: 26379
                    - host: local2.example.com
                      port: 26379
        )).deep_merge(default_values)
        end

        it 'populates the redis cache settings with the local sentinels' do
          t = HelmTemplate.new(values)
          expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"
          expect(t.dig('ConfigMap/test-registry', 'data', 'config.yml.tpl')).to include(
            <<~CONFIG
            redis:
              cache:
                enabled: true
                addr: "local1.example.com:26379,local2.example.com:26379"
                mainname: local.example.com
            CONFIG
          )
        end
      end

      context 'when customer provides a custom redis cache configuration with a registry Sentinel password' do
        let(:values) do
          YAML.safe_load(%(
            global:
              redis:
                host: redis.example.com
                sentinels:
                  - host: sentinel1.example.com
                    port: 26379
                  - host: sentinel2.example.com
                    port: 26379
                sentinelAuth:
                  enabled: true
                  secret: global-redis-sentinel-secret
                  key: password
            registry:
              database:
                enabled: true
              redis:
                cache:
                  enabled: true
                  sentinelpassword:
                    enabled: true
                    secret: local-redis-sentinel-secret
                    key: password
        )).deep_merge(default_values)
        end

        it 'populates the redis cache settings in the expected manner' do
          t = HelmTemplate.new(values)
          expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"

          registry_yml = render_yaml(t.dig('ConfigMap/test-registry', 'data', 'config.yml.tpl'))
          redis = registry_yml.dig('redis', 'cache')
          expect(redis['enabled']).to eq(true)
          expect(redis['addr']).to eq("sentinel1.example.com:26379,sentinel2.example.com:26379")
          expect(redis['mainname']).to eq('redis.example.com')
          expect(redis['sentinelpassword']).to eq(sentinel_password)

          projected_secret = t.get_projected_secret('Deployment/test-registry', 'registry-secrets', 'local-redis-sentinel-secret')
          expect(projected_secret).to eql(
            "name" => "local-redis-sentinel-secret",
            "items" => [
              {
                "key" => "password",
                "path" => "redis-sentinel/redis-sentinel-password"
              }
            ]
          )
        end
      end

      context 'when customer provides a custom redis cache configuration with global Sentinel password' do
        let(:values) do
          YAML.safe_load(%(
            global:
              redis:
                host: redis.example.com
                sentinels:
                  - host: sentinel1.example.com
                    port: 26379
                  - host: sentinel2.example.com
                    port: 26379
                sentinelAuth:
                  enabled: true
                  secret: global-redis-sentinel-secret
                  key: password
            registry:
              database:
                enabled: true
              redis:
                cache:
                  enabled: true
        )).deep_merge(default_values)
        end

        it 'populates the redis cache settings in the expected manner' do
          t = HelmTemplate.new(values)
          expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"

          registry_yml = render_yaml(t.dig('ConfigMap/test-registry', 'data', 'config.yml.tpl'))
          redis = registry_yml.dig('redis', 'cache')
          expect(redis['enabled']).to eq(true)
          expect(redis['addr']).to eq("sentinel1.example.com:26379,sentinel2.example.com:26379")
          expect(redis['mainname']).to eq('redis.example.com')
          expect(redis['sentinelpassword']).to eq(sentinel_password)

          projected_secret = t.get_projected_secret('Deployment/test-registry', 'registry-secrets', 'global-redis-sentinel-secret')
          expect(projected_secret).to eql(
            "name" => "global-redis-sentinel-secret",
            "items" => [
              {
                "key" => "password",
                "path" => "redis-sentinel/redis-sentinel-password"
              }
            ]
          )
        end
      end
    end

    describe 'redis rate-limiter config' do
      context 'when rate-limiter is enabled using redis global settings' do
        let(:values) do
          YAML.safe_load(%(
            global:
              redis:
                host: global.redis.example.com
                port: 16379
            registry:
              redis:
                rateLimiting:
                  enabled: true
          )).deep_merge(default_values)
        end

        it 'populates the redis address with the global setting' do
          t = HelmTemplate.new(values)
          expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"

          expect(t.dig('ConfigMap/test-registry', 'data', 'config.yml.tpl')).to include(
            <<~CONFIG
            redis:
              ratelimiter:
                enabled: true
                addr: "global.redis.example.com:16379"
            CONFIG
          )
        end
      end

      context 'when customer provides a custom redis rate-limiter configuration with a single host' do
        let(:values) do
          YAML.safe_load(%(
            registry:
              redis:
                rateLimiting:
                  enabled: true
                  host: redis.example.com
                  port: 12345
                  username: registry
                  db: 0
                  password:
                    enabled: true
                    secret: registry-redis-rate-limiter-secret
                    key: password
                  dialtimeout: 10ms
                  readtimeout: 10ms
                  writetimeout: 10ms
                  tls:
                    enabled: true
                    insecure: true
                  pool:
                    size: 10
                    maxlifetime: 1h
                    idletimeout: 300s
          )).deep_merge(default_values)
        end

        it 'populates the redis rate-limiter settings in the expected manner' do
          t = HelmTemplate.new(values)
          expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"
          expect(t.dig('ConfigMap/test-registry', 'data', 'config.yml.tpl')).to include(
            <<~CONFIG
            redis:
              ratelimiter:
                enabled: true
                addr: "redis.example.com:12345"
                username: registry
                password: "REDIS_RATE_LIMITING_PASSWORD"
                db: 0
                dialtimeout: 10ms
                readtimeout: 10ms
                writetimeout: 10ms
                tls:
                  enabled: true
                  insecure: true
                pool:
                  size: 10
                  maxlifetime: 1h
                  idletimeout: 300s
            CONFIG
          )

          rate_limiter_secret = t.find_projected_secret_key('Deployment/test-registry', 'registry-secrets', 'registry-redis-rate-limiter-secret', 'password')
          expect(rate_limiter_secret).not_to be_empty
        end
      end

      context 'when customer provides a custom redis rate-limiter configuration with a single host without port' do
        let(:values) do
          YAML.safe_load(%(
            registry:
              redis:
                rateLimiting:
                  enabled: true
                  host: redis.example.com
          )).deep_merge(default_values)
        end

        it 'populates the redis rate-limiter settings with the default port' do
          t = HelmTemplate.new(values)
          expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"
          expect(t.dig('ConfigMap/test-registry', 'data', 'config.yml.tpl')).to include(
            <<~CONFIG
            redis:
              ratelimiter:
                enabled: true
                addr: "redis.example.com:6379"
            CONFIG
          )
        end
      end

      context 'when customer provides a custom redis rate-limiter configuration with global sentinels' do
        let(:values) do
          YAML.safe_load(%(
            global:
              redis:
                host: redis.example.com
                sentinels:
                  - host: sentinel1.example.com
                    port: 26379
                  - host: sentinel2.example.com
                    port: 26379
            registry:
              redis:
                rateLimiting:
                  enabled: true
        )).deep_merge(default_values)
        end

        it 'populates the redis rate-limiter settings in the expected manner' do
          t = HelmTemplate.new(values)
          expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"
          expect(t.dig('ConfigMap/test-registry', 'data', 'config.yml.tpl')).to include(
            <<~CONFIG
            redis:
              ratelimiter:
                enabled: true
                addr: "sentinel1.example.com:26379,sentinel2.example.com:26379"
                mainname: redis.example.com
            CONFIG
          )
        end
      end

      context 'when customer provides a custom redis rate-limiter configuration with local sentinels' do
        let(:values) do
          YAML.safe_load(%(
            registry:
              redis:
                rateLimiting:
                  enabled: true
                  host: redis.example.com
                  sentinels:
                    - host: sentinel1.example.com
                      port: 26379
                    - host: sentinel2.example.com
                      port: 26379
        )).deep_merge(default_values)
        end

        it 'populates the redis rate-limiter settings in the expected manner' do
          t = HelmTemplate.new(values)
          expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"
          expect(t.dig('ConfigMap/test-registry', 'data', 'config.yml.tpl')).to include(
            <<~CONFIG
            redis:
              ratelimiter:
                enabled: true
                addr: "sentinel1.example.com:26379,sentinel2.example.com:26379"
                mainname: redis.example.com
            CONFIG
          )
        end
      end

      context 'when customer provides a custom redis rate-limiter configuration with local and global sentinels' do
        let(:values) do
          YAML.safe_load(%(
            global:
              redis:
                host: redis.example.com
                sentinels:
                  - host: global1.example.com
                    port: 26379
                  - host: global2.example.com
                    port: 26379
            registry:
              redis:
                rateLimiting:
                  enabled: true
                  host: local.example.com
                  sentinels:
                    - host: local1.example.com
                      port: 26379
                    - host: local2.example.com
                      port: 26379
        )).deep_merge(default_values)
        end

        it 'populates the redis rate-limiter settings with the local sentinels' do
          t = HelmTemplate.new(values)
          expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"
          expect(t.dig('ConfigMap/test-registry', 'data', 'config.yml.tpl')).to include(
            <<~CONFIG
            redis:
              ratelimiter:
                enabled: true
                addr: "local1.example.com:26379,local2.example.com:26379"
                mainname: local.example.com
            CONFIG
          )
        end
      end

      context 'when customer provides a custom redis cache and rate-limiter configuration with global sentinels' do
        let(:values) do
          YAML.safe_load(%(
            global:
              redis:
                host: redis.example.com
                sentinels:
                  - host: global1.example.com
                    port: 26379
                  - host: global2.example.com
                    port: 26379
            registry:
              database:
                enabled: true
              redis:
                cache:
                  enabled: true
                rateLimiting:
                  enabled: true
        )).deep_merge(default_values)
        end

        it 'populates the redis cache and rate-limiter settings with the global sentinels' do
          t = HelmTemplate.new(values)
          expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"
          expect(t.dig('ConfigMap/test-registry', 'data', 'config.yml.tpl')).to include(
            <<~CONFIG
            redis:
              cache:
                enabled: true
                addr: "global1.example.com:26379,global2.example.com:26379"
                mainname: redis.example.com
              ratelimiter:
                enabled: true
                addr: "global1.example.com:26379,global2.example.com:26379"
                mainname: redis.example.com
            CONFIG
          )
        end
      end

      context 'when customer provides a redis rate-limiting cluster configuration' do
        let(:values) do
          YAML.safe_load(%(
            registry:
              redis:
                rateLimiting:
                  enabled: true
                  cluster:
                    - host: redis1.cluster.example.com
                      port: 16379
                    - host: redis2.cluster.example.com
        )).deep_merge(default_values)
        end

        it 'populates the redis rate-limiter settings with the list of host:port' do
          t = HelmTemplate.new(values)
          expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"
          expect(t.dig('ConfigMap/test-registry', 'data', 'config.yml.tpl')).to include(
            <<~CONFIG
            redis:
              ratelimiter:
                enabled: true
                addr: "redis1.cluster.example.com:16379,redis2.cluster.example.com:6379"
            CONFIG
          )
        end
      end

      context 'when customer provides a redis rate-limiting cluster configuration in presense of global sentinels' do
        let(:values) do
          YAML.safe_load(%(
            global:
              redis:
                host: redis.example.com
                sentinels:
                  - host: global1.example.com
                    port: 26379
                  - host: global2.example.com
                    port: 26379
            registry:
              redis:
                rateLimiting:
                  enabled: true
                  cluster:
                    - host: redis1.cluster.example.com
                      port: 16379
                    - host: redis2.cluster.example.com
        )).deep_merge(default_values)
        end

        it 'populates the redis rate-limiter settings with the local cluster host:port instead of global.redis.sentinels' do
          t = HelmTemplate.new(values)
          expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"
          expect(t.dig('ConfigMap/test-registry', 'data', 'config.yml.tpl')).to include(
            <<~CONFIG
            redis:
              ratelimiter:
                enabled: true
                addr: "redis1.cluster.example.com:16379,redis2.cluster.example.com:6379"
            CONFIG
          )
        end
      end

      context 'when customer provides a custom redis rate-limiter and cache configuration' do
        let(:values) do
          YAML.safe_load(%(
            registry:
              database:
                enabled: true
              redis:
                cache:
                  enabled: true
                  host: redis.cache.example.com
                  port: 12345
                  db: 0
                  password:
                    enabled: true
                    secret: registry-redis-cache-secret
                    key: password
                  dialtimeout: 10ms
                  readtimeout: 10ms
                  writetimeout: 10ms
                  tls:
                    enabled: true
                    insecure: true
                  pool:
                    size: 10
                    maxlifetime: 1h
                    idletimeout: 300s
                rateLimiting:
                  enabled: true
                  host: redis.rate-limiter.example.com
                  port: 54321
                  db: 1
                  password:
                    enabled: true
                    secret: registry-redis-rate-limiting-secret
                    key: password
                  dialtimeout: 20ms
                  readtimeout: 20ms
                  writetimeout: 20ms
                  tls:
                    enabled: true
                    insecure: false
                  pool:
                    size: 30
                    maxlifetime: 2h
                    idletimeout: 100s
          )).deep_merge(default_values)
        end

        it 'populates the redis rate-limiter and cache settings in the expected manner' do
          t = HelmTemplate.new(values)
          expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"
          expect(t.dig('ConfigMap/test-registry', 'data', 'config.yml.tpl')).to include(
            <<~CONFIG
            redis:
              cache:
                enabled: true
                addr: "redis.cache.example.com:12345"
                password: "REDIS_CACHE_PASSWORD"
                db: 0
                dialtimeout: 10ms
                readtimeout: 10ms
                writetimeout: 10ms
                tls:
                  enabled: true
                  insecure: true
                pool:
                  size: 10
                  maxlifetime: 1h
                  idletimeout: 300s
              ratelimiter:
                enabled: true
                addr: "redis.rate-limiter.example.com:54321"
                password: "REDIS_RATE_LIMITING_PASSWORD"
                db: 1
                dialtimeout: 20ms
                readtimeout: 20ms
                writetimeout: 20ms
                tls:
                  enabled: true
                  insecure: false
                pool:
                  size: 30
                  maxlifetime: 2h
                  idletimeout: 100s
            CONFIG
          )

          rate_limiting_secret = t.find_projected_secret_key('Deployment/test-registry', 'registry-secrets', 'registry-redis-rate-limiting-secret', 'password')
          expect(rate_limiting_secret).not_to be_nil
          cache_secret = t.find_projected_secret_key('Deployment/test-registry', 'registry-secrets', 'registry-redis-cache-secret', 'password')
          expect(cache_secret).not_to be_empty
        end
      end
    end
  end

  describe 'debug TLS is configured' do
    context 'when enabled without required configuration' do
      let(:test_values) do
        YAML.safe_load(%(
          registry:
            debug:
              tls:
                enabled: true
        )).deep_merge(default_values)
      end

      it 'fails to render' do
        expect(HelmTemplate.new(test_values).exit_code).not_to eq(0)
      end
    end

    context 'when enabled and service tls is configured' do
      let(:test_values) do
        YAML.safe_load(%(
          global:
            hosts:
              registry:
                protocol: https
          registry:
            tls:
              enabled: true
              secretName: registry-service-tls
            debug:
              tls:
                enabled: true
        )).deep_merge(default_values)
      end

      it 'renders default debug tls configuration and sets healthcheck scheme to HTTPS' do
        t = HelmTemplate.new(test_values)

        expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"

        expect(t.dig('ConfigMap/test-registry', 'data', 'config.yml.tpl')).to include(
          <<~DEBUG_TLS_CONFIG
          http:
            addr: :5000
            # `host` is not configurable
            # `prefix` is not configurable
            tls:
              certificate: /etc/docker/registry/tls/tls.crt
              key: /etc/docker/registry/tls/tls.key
              minimumTLS: "tls1.2"
            debug:
              addr: :5001
              prometheus:
                enabled: false
                path: /metrics
              tls:
                enabled: true
          DEBUG_TLS_CONFIG
        )

        tls_crt = t.find_projected_secret_key('Deployment/test-registry', 'registry-secrets', 'registry-service-tls', 'tls.crt')
        expect(tls_crt).not_to be_empty

        liveness_probe = t.find_container('Deployment/test-registry', 'registry')['livenessProbe']['httpGet']
        expect(liveness_probe['scheme']).to eq('HTTPS')

        readiness_probe = t.find_container('Deployment/test-registry', 'registry')['readinessProbe']['httpGet']
        expect(readiness_probe['scheme']).to eq('HTTPS')
      end
    end

    context 'when minimum required configuration provided' do
      let(:test_values) do
        YAML.safe_load(%(
          registry:
            debug:
              tls:
                enabled: true
                secretName: registry-debug-tls
        )).deep_merge(default_values)
      end

      it 'renders default debug tls configuration and sets healthcheck scheme to HTTPS' do
        t = HelmTemplate.new(test_values)

        expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"

        expect(t.dig('ConfigMap/test-registry', 'data', 'config.yml.tpl')).to include(
          <<~DEBUG_TLS_CONFIG
          http:
            addr: :5000
            # `host` is not configurable
            # `prefix` is not configurable
            debug:
              addr: :5001
              prometheus:
                enabled: false
                path: /metrics
              tls:
                enabled: true
                certificate: /etc/docker/registry/tls/tls-debug.crt
                key: /etc/docker/registry/tls/tls-debug.key
                minimumTLS: "tls1.2"
          DEBUG_TLS_CONFIG
        )

        tls_crt = t.find_projected_secret_key('Deployment/test-registry', 'registry-secrets', 'registry-debug-tls', 'tls.crt')
        expect(tls_crt).not_to be_empty

        liveness_probe = t.find_container('Deployment/test-registry', 'registry')['livenessProbe']['httpGet']
        expect(liveness_probe['scheme']).to eq('HTTPS')

        readiness_probe = t.find_container('Deployment/test-registry', 'registry')['readinessProbe']['httpGet']
        expect(readiness_probe['scheme']).to eq('HTTPS')
      end
    end

    context 'when provided extended TLS configuration' do
      let(:test_values) do
        YAML.safe_load(%(
          registry:
            debug:
              tls:
                enabled: true
                secretName: registry-debug-tls
                clientCAs: [one, two, three]
                minimumTLS: "tls1.3"
        )).deep_merge(default_values)
      end

      it 'renders configuration as expected' do
        t = HelmTemplate.new(test_values)

        expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"

        expect(t.dig('ConfigMap/test-registry', 'data', 'config.yml.tpl')).to include(
          <<~DEBUG_TLS_CONFIG
          http:
            addr: :5000
            # `host` is not configurable
            # `prefix` is not configurable
            debug:
              addr: :5001
              prometheus:
                enabled: false
                path: /metrics
              tls:
                enabled: true
                certificate: /etc/docker/registry/tls/tls-debug.crt
                key: /etc/docker/registry/tls/tls-debug.key
                clientCAs:
                  - one
                  - two
                  - three
                minimumTLS: "tls1.3"
          DEBUG_TLS_CONFIG
        )
      end
    end
  end

  describe 'Registry tokenIssuer references' do
    context 'when tokenIssuer set globally' do
      let(:test_values) do
        YAML.safe_load(%(
          global:
            registry:
              tokenIssuer: substitute-issuer
        )).deep_merge(default_values)
      end

      it 'renders configuration as expected' do
        t = HelmTemplate.new(test_values)

        expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"

        configmaps = ['sidekiq', 'webservice', 'toolbox']
        configmaps.each do |configname|
          expect(t.dig("ConfigMap/test-#{configname}", 'data', 'gitlab.yml.erb')).to include("issuer: substitute-issuer")
        end

        expect(t.dig('ConfigMap/test-registry', 'data', 'config.yml.tpl')).to include("issuer: substitute-issuer")
        expect(t.dig('ConfigMap/test-shared-secrets', 'data', 'generate-secrets')).to include("CN=substitute-issuer")
      end
    end
  end

  describe 'Registry enablement' do
    context 'when registry is enabled' do
      let(:registry_values) do
        YAML.safe_load(%(
          registry:
            enabled: true
        )).deep_merge(default_values)
      end

      it 'deploys registry service' do
        t = HelmTemplate.new(registry_values)
        # working around rubocop defficiency
        expect(t.resource_exists?('Deployment/test-registry')).to be true
      end

      context 'when registry integration enabled globally' do
        let(:test_values) do
          YAML.safe_load(%(
            global:
              registry:
                enabled: true
                host: regtest
          )).deep_merge(registry_values)
        end

        it 'configures components to use registry' do
          t = HelmTemplate.new(test_values)

          expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"
          configmaps = ['sidekiq', 'webservice']
          configmaps.each do |configname|
            gitlab_yml_erb = t.dig("ConfigMap/test-#{configname}", 'data', 'gitlab.yml.erb')
            gye = YAML.safe_load(gitlab_yml_erb)
            expect(gye.dig('production', 'registry', 'enabled')).to eq(true)
            expect(gye.dig('production', 'registry', 'host')).to eq('regtest')
          end
        end
      end

      context 'when registry integration disabled globally' do
        let(:test_values) do
          YAML.safe_load(%(
            global:
              registry:
                enabled: false
          )).deep_merge(registry_values)
        end

        it 'disables registry integration for components' do
          t = HelmTemplate.new(test_values)

          expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"
          configmaps = ['sidekiq', 'webservice']
          configmaps.each do |configname|
            gitlab_yml_erb = t.dig("ConfigMap/test-#{configname}", 'data', 'gitlab.yml.erb')
            gye = YAML.safe_load(gitlab_yml_erb)
            expect(gye.dig('production', 'registry', 'enabled')).to eq(false)
          end
        end
      end
    end

    context 'when registry is disabled' do
      let(:registry_values) do
        YAML.safe_load(%(
          registry:
            enabled: false
        )).deep_merge(default_values)
      end

      it 'registry service is not deployed' do
        t = HelmTemplate.new(registry_values)
        # working around rubocop defficiency
        # expect(t.dig('Deployment/test-registry', 'metadata')).to eq(nil)
        expect(t.resource_exists?('Deployment/test-registry')).to be false
      end

      context 'when registry integration enabled only locally' do
        let(:test_values) do
          YAML.safe_load(%(
            global:
              registry:
                enabled: false
            gitlab:
              webservice:
                registry:
                  enabled: true
                  host: regtest
              sidekiq:
                registry:
                  enabled: true
                  host: regtest
              toolbox:
                registry:
                  enabled: true
                  host: regtest
          )).deep_merge(registry_values)
        end

        it 'renders configuration as expected' do
          t = HelmTemplate.new(test_values)

          expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"
          configmaps = ['sidekiq', 'webservice', 'toolbox']
          configmaps.each do |configname|
            gitlab_yml_erb = t.dig("ConfigMap/test-#{configname}", 'data', 'gitlab.yml.erb')
            gye = YAML.safe_load(gitlab_yml_erb)
            expect(gye.dig('production', 'registry', 'enabled')).to eq(true)
            expect(gye.dig('production', 'registry', 'host')).to eq('regtest')
          end
        end
      end
    end
  end
end
