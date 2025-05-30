require 'spec_helper'
require 'check_config_helper'
require 'yaml'
require 'hash_deep_merge'

describe 'checkConfig registry' do
  describe 'registry.database (PG version)' do
    let(:success_values) do
      YAML.safe_load(%(
        postgresql:
          image:
            tag: 16

        registry:
          database:
            enabled: true
      )).deep_merge!(default_required_values)
    end

    let(:error_values) do
      YAML.safe_load(%(
        postgresql:
          image:
            tag: 15

        registry:
          database:
            enabled: true
      )).deep_merge!(default_required_values)
    end

    let(:error_output) { 'PostgreSQL 16 is the minimum required version' }

    include_examples 'config validation',
                     success_description: 'when postgresql.image.tag is >= 16',
                     error_description: 'when postgresql.image.tag is < 15'
  end

  describe 'registry.database (sslmode)' do
    let(:success_values) do
      YAML.safe_load(%(
        registry:
          database:
            enabled: true
            sslmode: disable
      )).deep_merge!(default_required_values)
    end

    let(:error_values) do
      YAML.safe_load(%(
        registry:
          database:
            enabled: true
            sslmode: testing
      )).deep_merge!(default_required_values)
    end

    let(:error_output) { 'Invalid SSL mode' }

    include_examples 'config validation',
                     success_description: 'when database.sslmode is valid',
                     error_description: 'when when database.sslmode is not valid'
  end

  describe 'registry.database.loadBalancing (record)' do
    let(:success_values) do
      YAML.safe_load(%(
        postgresql:
          image:
            tag: 16

        registry:
          redis:
            loadBalancing:
              enabled: true
          database:
            enabled: true
            loadBalancing:
              enabled: true
              record: db-replica-registry.service.consul
      )).deep_merge!(default_required_values)
    end

    let(:error_values) do
      YAML.safe_load(%(
        postgresql:
          image:
            tag: 16

        registry:
          redis:
            loadBalancing:
              enabled: true
          database:
            enabled: true
            loadBalancing:
              enabled: true
      )).deep_merge!(default_required_values)
    end

    let(:error_output) { '`database.loadBalancing` requires `record` to be provided' }

    include_examples 'config validation',
                     success_description: 'when database load balancing is enabled, with record',
                     error_description: 'when database load balancing is enabled, with no record'
  end

  describe 'registry.database.loadBalancing requires database.enabled to be true' do
    let(:success_values) do
      YAML.safe_load(%(
        postgresql:
          image:
            tag: 16

        registry:
          redis:
            loadBalancing:
              enabled: true
          database:
            enabled: true
            loadBalancing:
              enabled: true
              record: db-replica-registry.service.consul
      )).deep_merge!(default_required_values)
    end

    let(:error_values) do
      YAML.safe_load(%(
        postgresql:
          image:
            tag: 16

        registry:
          redis:
            loadBalancing:
              enabled: true
          database:
            enabled: false
            loadBalancing:
              enabled: true
              record: db-replica-registry.service.consul
      )).deep_merge!(default_required_values)
    end

    let(:error_output) { 'Enabling database load balancing requires the metadata database to be enabled.' }

    include_examples 'config validation',
                     success_description: 'when database load balancing is enabled, with database enabled',
                     error_description: 'when database load balancing is enabled, with database disabled'
  end

  describe 'registry.database.loadBalancing requires redis.loadbalancing.enabled to be true' do
    let(:success_values) do
      YAML.safe_load(%(
        postgresql:
          image:
            tag: 16

        registry:
          redis:
            loadBalancing:
              enabled: true
          database:
            enabled: true
            loadBalancing:
              enabled: true
              record: db-replica-registry.service.consul
      )).deep_merge!(default_required_values)
    end

    let(:error_values) do
      YAML.safe_load(%(
        postgresql:
          image:
            tag: 16

        registry:
          redis:
            loadBalancing:
              enabled: false
          database:
            enabled: true
            loadBalancing:
              enabled: true
              record: db-replica-registry.service.consul
      )).deep_merge!(default_required_values)
    end

    let(:error_output) { 'Enabling database load balancing requires a Redis connection to be enabled.' }

    include_examples 'config validation',
                     success_description: 'when database load balancing is enabled, with redis connection enabled',
                     error_description: 'when database load balancing is enabled, with redis connection disabled'
  end

  describe 'gitlab.checkConfig.registry.sentry.dsn' do
    let(:success_values) do
      YAML.safe_load(%(
        registry:
          reporting:
            sentry:
              enabled: true
              dsn: somedsn
      )).deep_merge!(default_required_values)
    end

    let(:error_values) do
      YAML.safe_load(%(
        registry:
          reporting:
            sentry:
              enabled: true
      )).deep_merge!(default_required_values)
    end

    let(:error_output) { 'When enabling sentry, you must configure at least one DSN.' }

    include_examples 'config validation',
                     success_description: 'when Sentry is enabled and DSN is defined',
                     error_description: 'when Sentry is enabled but DSN is undefined'
  end

  describe 'registry.redis.cache (enabled)' do
    let(:success_values) do
      YAML.safe_load(%(
        registry:
          database:
            enabled: true
          redis:
            cache:
              enabled: true
      )).deep_merge!(default_required_values)
    end

    let(:error_values) do
      YAML.safe_load(%(
        registry:
          database:
            enabled: false
          redis:
            cache:
              enabled: true
      )).deep_merge!(default_required_values)
    end

    let(:error_output) { 'Enabling the Redis cache requires the metadata database to be enabled' }

    include_examples 'config validation',
                     success_description: 'when redis cache enabled is true, with database enabled',
                     error_description: 'when redis cache enabled is true, with database disabled'
  end

  describe 'registry.redis.cache (host)' do
    let(:success_values) do
      YAML.safe_load(%(
        postgresql:
          image:
            tag: 16

        registry:
          database:
            enabled: true
          redis:
            cache:
              enabled: true
              host: 'localhost'
      )).deep_merge!(default_required_values)
    end

    let(:error_values) do
      YAML.safe_load(%(
        postgresql:
          image:
            tag: 16

        registry:
          database:
            enabled: true
          redis:
            cache:
              enabled: true
              host: ''
      )).deep_merge!(default_required_values)
    end

    let(:error_output) { 'Enabling the Redis cache requires the host to not be empty' }

    include_examples 'config validation',
                     success_description: 'when redis cache is enabled, with host',
                     error_description: 'when redis cache is enabled, with empty host'
  end

  describe 'registry.redis.cache (sentinels)' do
    let(:success_values) do
      YAML.safe_load(%(
        postgresql:
          image:
            tag: 16

        registry:
          database:
            enabled: true
          redis:
            cache:
              enabled: true
              host: 'localhost'
              sentinels:
                - host: sentinel1.example.com
                  port: 26379
                - host: sentinel2.example.com
                  port: 26379
      )).deep_merge!(default_required_values)
    end

    let(:error_values) do
      YAML.safe_load(%(
        postgresql:
          image:
            tag: 16

        registry:
          database:
            enabled: true
          redis:
            cache:
              enabled: true
              host: ''
              sentinels:
              - host: sentinel1.example.com
                port: 26379
              - host: sentinel2.example.com
                port: 26379
      )).deep_merge!(default_required_values)
    end

    let(:error_output) { 'Enabling the Redis cache with sentinels requires the registry.redis.cache.host to be set.' }

    include_examples 'config validation',
                     success_description: 'when redis cache is enabled, with sentinels',
                     error_description: 'when redis cache is enabled, with sentinels and empty host'
  end

  describe 'registry.redis.cache.password (secret)' do
    let(:success_values) do
      YAML.safe_load(%(
        postgresql:
          image:
            tag: 16

        registry:
          database:
            enabled: true
          redis:
            cache:
              enabled: true
              host: 'localhost'
              password:
                enabled: true
                secret: registry-redis-cache-secret
                key: password
      )).deep_merge!(default_required_values)
    end

    let(:error_values) do
      YAML.safe_load(%(
        postgresql:
          image:
            tag: 16

        registry:
          database:
            enabled: true
          redis:
            cache:
              enabled: true
              host: ''
              password:
                enabled: true
                secret: ''
      )).deep_merge!(default_required_values)
    end

    let(:error_output) { ' Enabling the Redis cache password requires \'registry.redis.cache.password.secret\' to be set.' }

    include_examples 'config validation',
                     success_description: 'when redis cache password is enabled, with secret and key',
                     error_description: 'when redis cache password is enabled, with empty secret'
  end

  describe 'registry.redis.cache.password (key)' do
    let(:success_values) do
      YAML.safe_load(%(
        postgresql:
          image:
            tag: 16

        registry:
          database:
            enabled: true
          redis:
            cache:
              enabled: true
              host: 'localhost'
              password:
                enabled: true
                secret: registry-redis-cache-secret
                key: password
      )).deep_merge!(default_required_values)
    end

    let(:error_values) do
      YAML.safe_load(%(
        postgresql:
          image:
            tag: 16

        registry:
          database:
            enabled: true
          redis:
            cache:
              enabled: true
              host: ''
              password:
                enabled: true
                secret: registry-redis-cache-secret
                key: ''
      )).deep_merge!(default_required_values)
    end

    let(:error_output) { ' Enabling the Redis cache password requires \'registry.redis.cache.password.key\' to be set.' }

    include_examples 'config validation',
                     success_description: 'when redis cache password is enabled, with secret and key',
                     error_description: 'when redis cache password is enabled, with empty key'
  end

  describe 'registry.redis.rateLimiting (host)' do
    let(:success_values) do
      YAML.safe_load(%(
        postgresql:
          image:
            tag: 16

        registry:
          redis:
            rateLimiting:
              enabled: true
              host: 'localhost'
      )).deep_merge!(default_required_values)
    end

    let(:error_values) do
      YAML.safe_load(%(
        postgresql:
          image:
            tag: 16

        registry:
          redis:
            rateLimiting:
              enabled: true
              host: ''
      )).deep_merge!(default_required_values)
    end

    let(:error_output) { 'Enabling the Redis rate-limiter requires the host to not be empty' }

    include_examples 'config validation',
                     success_description: 'when redis rate-limiter is enabled, with host',
                     error_description: 'when redis rate-limiter is enabled, with empty host'
  end

  describe 'registry.redis.rateLimiting (sentinels)' do
    let(:success_values) do
      YAML.safe_load(%(
        postgresql:
          image:
            tag: 16

        registry:
          redis:
            rateLimiting:
              enabled: true
              host: 'localhost'
              sentinels:
                - host: sentinel1.example.com
                  port: 26379
                - host: sentinel2.example.com
                  port: 26379
      )).deep_merge!(default_required_values)
    end

    let(:error_values) do
      YAML.safe_load(%(
        postgresql:
          image:
            tag: 16

        registry:
          redis:
            rateLimiting:
              enabled: true
              host: ''
              sentinels:
              - host: sentinel1.example.com
                port: 26379
              - host: sentinel2.example.com
                port: 26379
      )).deep_merge!(default_required_values)
    end

    let(:error_output) { 'Enabling the Redis rate-limiter with sentinels requires the registry.redis.rateLimiting.host to be set.' }

    include_examples 'config validation',
                     success_description: 'when redis rate-limiter is enabled, with sentinels',
                     error_description: 'when redis rate-limiter is enabled, with sentinels and empty host'
  end

  describe 'registry.redis.rateLimiting.password (secret)' do
    let(:success_values) do
      YAML.safe_load(%(
        postgresql:
          image:
            tag: 16

        registry:
          redis:
            rateLimiting:
              enabled: true
              host: 'localhost'
              password:
                enabled: true
                secret: registry-redis-cache-secret
                key: password
      )).deep_merge!(default_required_values)
    end

    let(:error_values) do
      YAML.safe_load(%(
        postgresql:
          image:
            tag: 16

        registry:
          redis:
            rateLimiting:
              enabled: true
              host: ''
              password:
                enabled: true
                secret: ''
      )).deep_merge!(default_required_values)
    end

    let(:error_output) { ' Enabling the Redis rate-limiter password requires \'registry.redis.rateLimiting.password.secret\' to be set.' }

    include_examples 'config validation',
                     success_description: 'when redis rate-limiter password is enabled, with secret and key',
                     error_description: 'when redis rate-limiter password is enabled, with empty secret'
  end

  describe 'registry.redis.rateLimiting.password (key)' do
    let(:success_values) do
      YAML.safe_load(%(
        postgresql:
          image:
            tag: 16

        registry:
          redis:
            rateLimiting:
              enabled: true
              host: 'localhost'
              password:
                enabled: true
                secret: registry-redis-cache-secret
                key: password
      )).deep_merge!(default_required_values)
    end

    let(:error_values) do
      YAML.safe_load(%(
        postgresql:
          image:
            tag: 16

        registry:
          redis:
            rateLimiting:
              enabled: true
              host: ''
              password:
                enabled: true
                secret: registry-redis-cache-secret
                key: ''
      )).deep_merge!(default_required_values)
    end

    let(:error_output) { ' Enabling the Redis rate-limiter password requires \'registry.redis.rateLimiting.password.key\' to be set.' }

    include_examples 'config validation',
                     success_description: 'when redis rate-limiter password is enabled, with secret and key',
                     error_description: 'when redis rate-limiter password is enabled, with empty key'
  end

  describe 'registry.redis.loadBalancing (host)' do
    let(:success_values) do
      YAML.safe_load(%(
        registry:
          redis:
            loadBalancing:
              enabled: true
              host: 'localhost'
      )).deep_merge!(default_required_values)
    end

    let(:error_values) do
      YAML.safe_load(%(
        registry:
          redis:
            loadBalancing:
              enabled: true
              host: ''
      )).deep_merge!(default_required_values)
    end

    let(:error_output) { 'Enabling the load balancing Redis connection requires the host to not be empty' }

    include_examples 'config validation',
                     success_description: 'when the load balancing Redis connection is enabled, with host',
                     error_description: 'when the load balancing Redis connection is enabled, with empty host'
  end

  describe 'registry.redis.loadBalancing (sentinels)' do
    let(:success_values) do
      YAML.safe_load(%(
        registry:
          redis:
            loadBalancing:
              enabled: true
              host: 'localhost'
              sentinels:
                - host: sentinel1.example.com
                  port: 26379
                - host: sentinel2.example.com
                  port: 26379
      )).deep_merge!(default_required_values)
    end

    let(:error_values) do
      YAML.safe_load(%(
        registry:
          redis:
            loadBalancing:
              enabled: true
              host: ''
              sentinels:
              - host: sentinel1.example.com
                port: 26379
              - host: sentinel2.example.com
                port: 26379
      )).deep_merge!(default_required_values)
    end

    let(:error_output) { 'Enabling the load balancing Redis connection with sentinels requires the registry.redis.loadBalancing.host to be set.' }

    include_examples 'config validation',
                     success_description: 'when the load balancing Redis connection is enabled, with sentinels',
                     error_description: 'when the load balancing Redis connection is enabled, with sentinels and empty host'
  end

  describe 'registry.redis.loadBalancing.password (secret)' do
    let(:success_values) do
      YAML.safe_load(%(
        registry:
          redis:
            loadBalancing:
              enabled: true
              host: 'localhost'
              password:
                enabled: true
                secret: registry-redis-cache-secret
                key: password
      )).deep_merge!(default_required_values)
    end

    let(:error_values) do
      YAML.safe_load(%(
        registry:
          redis:
            loadBalancing:
              enabled: true
              host: 'localhost'
              password:
                enabled: true
                secret: ''
      )).deep_merge!(default_required_values)
    end

    let(:error_output) { ' Enabling the load balancing Redis connection with password requires \'registry.redis.loadBalancing.password.secret\' to be set.' }

    include_examples 'config validation',
                     success_description: 'when the load balancing Redis connection password is enabled, with secret and key',
                     error_description: 'when the load balancing Redis connection password is enabled, with empty secret'
  end

  describe 'registry.redis.loadBalancing.password (key)' do
    let(:success_values) do
      YAML.safe_load(%(
        registry:
          redis:
            loadBalancing:
              enabled: true
              host: 'localhost'
              password:
                enabled: true
                secret: registry-redis-cache-secret
                key: password
      )).deep_merge!(default_required_values)
    end

    let(:error_values) do
      YAML.safe_load(%(
        registry:
          redis:
            loadBalancing:
              enabled: true
              host: 'localhost'
              password:
                enabled: true
                secret: registry-redis-cache-secret
                key: ''
      )).deep_merge!(default_required_values)
    end

    let(:error_output) { ' Enabling the load balancing Redis connection with password requires \'registry.redis.loadBalancing.password.key\' to be set.' }

    include_examples 'config validation',
                     success_description: 'when the load balancing Redis connection password is enabled, with secret and key',
                     error_description: 'when the load balancing Redis connection password is enabled, with empty key'
  end

  describe 'registry.tls (hosts.protocol)' do
    let(:success_values) do
      YAML.safe_load(%(
        global:
          hosts:
            registry:
              protocol: https
        registry:
          tls:
            enabled: true
      )).deep_merge!(default_required_values)
    end

    let(:error_values) do
      YAML.safe_load(%(
        registry:
          tls:
            enabled: true
      )).deep_merge!(default_required_values)
    end

    let(:error_output) { 'Enabling the service level TLS requires \'global.hosts.registry.protocol\'' }

    include_examples 'config validation',
                     success_description: 'when tls is enabled, with global.hosts.protocol',
                     error_description: 'when tls is enabled, without global.hosts.protocol'
  end

  describe 'gitlab.checkConfig.registry.debug.tls' do
    let(:success_values) do
      YAML.safe_load(%(
        registry:
          debug:
            tls:
              enabled: true
              secretName: example-tls
      )).deep_merge!(default_required_values)
    end

    let(:error_values) do
      YAML.safe_load(%(
        registry:
          debug:
            tls:
              enabled: true
      )).deep_merge!(default_required_values)
    end

    let(:error_output) { 'secret is required when not enabling TLS for the non-debug Registry endpoint.' }

    include_examples 'config validation',
                     success_description: 'when debug TLS is enabled and secretName is defined',
                     error_description: 'when debug TLS is enabled but secretName is undefined'
  end
end
