require 'spec_helper'
require 'helm_template_helper'
require 'yaml'
require 'hash_deep_merge'

describe 'Mailroom configuration' do
  let(:default_values) do
    {
      # provide required setting
      'certmanager-issuer' => { 'email' => 'test@example.com' },
      # required to activate mailroom
      'global' => {
        'appConfig' => {
          'incomingEmail' => {
            'enabled' => true,
            'password' => { 'secret' => 'mailroom-password'}
          }
        },
      },
    }
  end

  context 'When using all defaults' do
    it 'Populate internal Redis service' do
      t = HelmTemplate.new(default_values)
      expect(t.exit_code).to eq(0)
      # check the default service name & password are used
      expect(t.dig('ConfigMap/test-mailroom','data','mail_room.yml')).to include("test-redis-master.default.svc:6379")
      # check the default secret is mounted
      projected_volume = t.projected_volume_sources('Deployment/test-mailroom','init-mailroom-secrets')
      redis_mount =  projected_volume.select { |item| item['secret']['name'] == "test-redis-secret" }
      expect(redis_mount.length).to eq(1)
      # check there are no Sentinels
      expect(t.dig('ConfigMap/test-mailroom','data','mail_room.yml')).not_to include(":sentinels:")
    end
  end

  context 'When global.redis is present' do
    let(:values) do
      {
        'global' => {
          'redis' => {
            'host' => 'external-redis',
            'port' => 9999,
            'password' => {
              'enable' => true,
              'secret' => 'external-redis-secret',
              'key' => 'external-redis-key'
            }
          }
        }
      }.deep_merge(default_values)
    end

    it 'Populates configured external host, port, password' do
      t = HelmTemplate.new(values)
      expect(t.exit_code).to eq(0)
      # configure the external-redis server, port, secret
      expect(t.dig('ConfigMap/test-mailroom','data','mail_room.yml')).to include("external-redis:9999")
      projected_volume = t.projected_volume_sources('Deployment/test-mailroom','init-mailroom-secrets')
      redis_mount =  projected_volume.select { |item| item['secret']['name'] == "external-redis-secret" }
      expect(redis_mount.length).to eq(1)
      expect(t.dig('ConfigMap/test-mailroom','data','mail_room.yml')).not_to include(":sentinels:")
    end

    it 'Populates Sentinels, when configured' do
      local = {
        'global' => {
          'redis' => {
            'sentinels' => [
              {'host' => 's1.resque.redis', 'port' => 26379},
              {'host' => 's2.resque.redis', 'port' => 26379}
            ],
          }
        }
      }
      t = HelmTemplate.new(values.deep_merge(local))
      expect(t.exit_code).to eq(0)
      # check that global.sentinels populate
      expect(t.dig('ConfigMap/test-mailroom','data','mail_room.yml')).to include(":sentinels:")
      expect(t.dig('ConfigMap/test-mailroom','data','mail_room.yml')).to include("s1.resque.redis")
    end
  end

  context 'When global.redis.queues is present' do
    let(:values) do
      {
        'global' => {
          'redis' => {
            'host' => 'resque.redis',
            'sentinels' => [
              {'host' => 's1.resque.redis', 'port' => 26379},
              {'host' => 's2.resque.redis', 'port' => 26379}
            ],
            'queues' => {
              'host' => 'queue.redis',
              'password' => {
                'secret' => 'redis-queues-secret',
                'key' => 'redis-queues-key'
              }
            }
          }
        },
        'redis' => { 'install' => false }
      }.deep_merge(default_values)
    end

    it 'populates the Queues host, port, password (without Sentinels)' do
      t = HelmTemplate.new(values)
      expect(t.exit_code).to eq(0)
      # check the `queue.redis` is populated instead of `resque.redis`
      expect(t.dig('ConfigMap/test-mailroom','data','mail_room.yml')).not_to include("resque.redis")
      expect(t.dig('ConfigMap/test-mailroom','data','mail_room.yml')).to include("queue.redis")
      # check mount of the secret
      projected_volume = t.projected_volume_sources('Deployment/test-mailroom','init-mailroom-secrets')
      redis_mount =  projected_volume.select { |item| item['secret']['name'] == "redis-queues-secret" }
      expect(redis_mount.length).to eq(1)
      # no Sentinels present
      expect(t.dig('ConfigMap/test-mailroom','data','mail_room.yml')).not_to include(":sentinels:")
    end

    it 'separate sentinels are populated, when present' do
      local = { 'global' => { 'redis' => { 'queues' => {
            'sentinels' => [
              {'host' => 's1.queue.redis', 'port' => 26379},
              {'host' => 's2.queue.redis', 'port' => 26379}
            ] } } }
      }
      t = HelmTemplate.new(values.deep_merge(local))
      expect(t.exit_code).to eq(0)
      # check that queues.sentinels are used instead of global.sentinels
      expect(t.dig('ConfigMap/test-mailroom','data','mail_room.yml')).to include(":sentinels:")
      expect(t.dig('ConfigMap/test-mailroom','data','mail_room.yml')).to include("s1.queue.redis")
      expect(t.dig('ConfigMap/test-mailroom','data','mail_room.yml')).not_to include("s1.resque.redis")
    end
  end

  context 'When customer provides additional labels' do
    let(:values) do
      {
        'global' => {
          'common' => {
            'labels' => {
              'global' => 'global',
              'foo' => 'global'
            }
          },
          'pod' => {
            'labels' => {
              'global_pod' => true
            }
          }
        },
        'gitlab' => {
          'mailroom' => {
            'common' => {
              'labels' => {
                'global' => 'mailroom',
                'mailroom' => 'mailroom'
              }
            },
            'networkpolicy' => {
              'enabled' => true
            },
            'podLabels' => {
              'pod' => true,
              'global' => 'pod'
            },
            'serviceAccount' => {
              'create' => true,
              'enabled' => true
            }
          }
        }
      }.deep_merge(default_values)
    end
    it 'Populates the additional labels in the expected manner' do
      t = HelmTemplate.new(values)
      expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"
      expect(t.dig('ConfigMap/test-mailroom', 'metadata', 'labels')).to include('global' => 'mailroom')
      expect(t.dig('Deployment/test-mailroom', 'metadata', 'labels')).to include('foo' => 'global')
      expect(t.dig('Deployment/test-mailroom', 'metadata', 'labels')).to include('global' => 'mailroom')
      expect(t.dig('Deployment/test-mailroom', 'metadata', 'labels')).not_to include('global' => 'global')
      expect(t.dig('Deployment/test-mailroom', 'spec', 'template', 'metadata', 'labels')).to include('global' => 'pod')
      expect(t.dig('Deployment/test-mailroom', 'spec', 'template', 'metadata', 'labels')).to include('pod' => true)
      expect(t.dig('Deployment/test-mailroom', 'spec', 'template', 'metadata', 'labels')).to include('global_pod' => true)
      expect(t.dig('HorizontalPodAutoscaler/test-mailroom', 'metadata', 'labels')).to include('global' => 'mailroom')
      expect(t.dig('NetworkPolicy/test-mailroom-v1', 'metadata', 'labels')).to include('global' => 'mailroom')
      expect(t.dig('ServiceAccount/test-mailroom', 'metadata', 'labels')).to include('global' => 'mailroom')
    end
  end
end
