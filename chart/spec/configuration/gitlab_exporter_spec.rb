require 'spec_helper'
require 'helm_template_helper'
require 'runtime_template_helper'
require 'hash_deep_merge'
require 'tomlrb'
require 'yaml'

describe 'gitlab-exporter configuration' do
  let(:default_values) do
    HelmTemplate.with_defaults(%(
      global: {}
      gitlab:
        gitlab-exporter:
          serviceAccount:
            enabled: true
            create: true
    ))
  end
  let(:template) { HelmTemplate.new(values) }
  let(:raw_erb) { template.dig('ConfigMap/test-gitlab-exporter', 'data', 'gitlab-exporter.yml.erb') }
  let(:rendered_erb) { render_erb(raw_erb) }
  let(:sidekiq_config) { rendered_erb['probes']['sidekiq'] }
  let(:password) { ERB::Util.url_encode(RuntimeTemplate::JUNK_PASSWORD) }

  def render_erb(raw_template)
    yaml = RuntimeTemplate.erb(raw_template: raw_template, files: RuntimeTemplate.mock_files)
    YAML.safe_load(yaml, aliases: true)
  end

  context 'with default values' do
    let(:values) { default_values }

    it 'configures Redis' do
      expect(template.exit_code).to eq(0), "Unexpected error code #{template.exit_code} -- #{template.stderr}"
      expect(sidekiq_config['opts']['redis_url']).to eq("redis://:#{password}@test-redis-master.default.svc:6379")
      expect(sidekiq_config['opts']).not_to include('redis_sentinels')
    end
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
        gitlab:
          gitlab-exporter:
            common:
              labels:
                global: exporter
                exporter: exporter
            podLabels:
              pod: true
              global: pod
            serviceLabels:
              service: true
              global: service
      )).deep_merge(default_values)
    end

    it 'Populates the additional labels in the expected manner' do
      t = HelmTemplate.new(values)
      expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"
      expect(t.dig('ConfigMap/test-gitlab-exporter', 'metadata', 'labels')).to include('global' => 'exporter')
      expect(t.dig('Deployment/test-gitlab-exporter', 'metadata', 'labels')).to include('foo' => 'global')
      expect(t.dig('Deployment/test-gitlab-exporter', 'metadata', 'labels')).to include('global' => 'exporter')
      expect(t.dig('Deployment/test-gitlab-exporter', 'metadata', 'labels')).not_to include('global' => 'global')
      expect(t.dig('Deployment/test-gitlab-exporter', 'spec', 'template', 'metadata', 'labels')).to include('global' => 'pod')
      expect(t.dig('Deployment/test-gitlab-exporter', 'spec', 'template', 'metadata', 'labels')).to include('global_pod' => 'true')
      expect(t.dig('Deployment/test-gitlab-exporter', 'spec', 'template', 'metadata', 'labels')).to include('pod' => 'true')
      expect(t.dig('Service/test-gitlab-exporter', 'metadata', 'labels')).to include('global' => 'service')
      expect(t.dig('Service/test-gitlab-exporter', 'metadata', 'labels')).to include('global_service' => 'true')
      expect(t.dig('Service/test-gitlab-exporter', 'metadata', 'labels')).to include('service' => 'true')
      expect(t.dig('Service/test-gitlab-exporter', 'metadata', 'labels')).not_to include('global' => 'global')
      expect(t.dig('ServiceAccount/test-gitlab-exporter', 'metadata', 'labels')).to include('global' => 'exporter')
    end
  end

  context 'with redis sentinel' do
    let(:values) do
      YAML.safe_load(%(
        global:
          redis:
            host: global.host
            sentinels:
            - host: sentinel1.example.com
              port: 26379
            - host: sentinel2.example.com
              port: 26379
      )).deep_merge(default_values)
    end

    it 'configures Sentinels' do
      expect(template.exit_code).to eq(0), "Unexpected error code #{template.exit_code} -- #{template.stderr}"
      expect(sidekiq_config['opts']['redis_url']).to eq("redis://:#{password}@global.host:6379")
      expect(sidekiq_config['opts']['redis_sentinels']).to eq(
        [
          { 'host' => 'sentinel1.example.com', 'port' => 26379 },
          { 'host' => 'sentinel2.example.com', 'port' => 26379 }
        ])
    end

    context 'with Sentinel password as secret' do
      let(:values) do
        YAML.safe_load(%(
          global:
            redis:
              host: global.host
              sentinels:
              - host: sentinel1.example.com
                port: 26379
              - host: sentinel2.example.com
                port: 26379
              sentinelAuth:
                enabled: true
                secret: test-redis-sentinel-secret
                key: password
        )).deep_merge(default_values)
      end

      let(:volumes) { template.dig('Deployment/test-gitlab-exporter', 'spec', 'template', 'spec', 'volumes') }
      let(:secret_volumes) { volumes.find { |volume| volume['name'] == 'init-gitlab-exporter-secrets' } }
      let(:secret_names) { secret_volumes.dig('projected', 'sources').map { |source| source['secret'] }.map { |secret| secret['name'] } }

      it 'configures Sentinels with password' do
        expect(template.exit_code).to eq(0), "Unexpected error code #{template.exit_code} -- #{template.stderr}"
        expect(sidekiq_config['opts']['redis_url']).to eq("redis://:#{password}@global.host:6379")
        expect(sidekiq_config['opts']['redis_sentinel_password']).to eq(RuntimeTemplate::JUNK_PASSWORD)
        expect(sidekiq_config['opts']['redis_sentinels']).to eq(
          [
            { 'host' => 'sentinel1.example.com', 'port' => 26379 },
            { 'host' => 'sentinel2.example.com', 'port' => 26379 }
          ])

        expect(secret_names).to include('test-redis-sentinel-secret')
      end
    end
  end

  context 'When customer enables TLS' do
    let(:template) do
      values = YAML.safe_load(%(
      gitlab:
        gitlab-exporter:
          tls:
            enabled: true
            secretName: exporter-tls-secret
      )).deep_merge(default_values)
      HelmTemplate.new values
    end

    it 'should render the template without error' do
      expect(template.exit_code).to eq(0), "Unexpected error code #{template.exit_code} -- #{template.stderr}"
    end

    it 'should mount the TLS certificates' do
      volumes = template.dig('Deployment/test-gitlab-exporter', 'spec', 'template', 'spec', 'volumes')
      init_secrets = volumes.find { |v| v["name"] == "init-gitlab-exporter-secrets" }
      tls_secret = init_secrets.dig("projected", "sources").find { |s| s.dig("secret", "name") == "exporter-tls-secret" }

      expect(tls_secret).not_to be_nil
      expect(tls_secret["secret"]["items"]).to include({ 'key' => 'tls.crt', 'path' => 'gitlab-exporter/tls.crt' })
      expect(tls_secret["secret"]["items"]).to include({ 'key' => 'tls.key', 'path' => 'gitlab-exporter/tls.key' })
    end

    it 'should configure TLS usage' do
      config = template.dig('ConfigMap/test-gitlab-exporter', 'data', 'gitlab-exporter.yml.erb')
      expect(config).to include 'tls_enabled: true'
    end
  end
end
