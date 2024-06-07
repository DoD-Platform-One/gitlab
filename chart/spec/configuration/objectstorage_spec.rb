require 'spec_helper'
require 'helm_template_helper'
require 'yaml'
require 'hash_deep_merge'

describe 'ObjectStorage configuration' do
  let(:services) do
    [
      'sidekiq',
      'webservice',
      'toolbox'
    ]
  end

  let(:init_secret_mounts) do
    {
      'test-sidekiq-all-in-1-v2' => 'init-sidekiq-secrets',
      'test-webservice-default' => 'init-webservice-secrets',
      'test-toolbox' => 'init-toolbox-secrets'
    }
  end

  let(:default_values) do
    HelmTemplate.defaults
  end

  let(:artifacts_cdn_file) { '/etc/gitlab/objectstorage/cdn/artifacts' }

  describe 'global.appConfig.object_store.enabled' do
    let(:object_store_config_file) { '/etc/gitlab/objectstorage/object_store' }

    let(:values_object_store_connection) do
      YAML.safe_load(%(
        global:
          appConfig:
            object_store:
              enabled: true
              connection:
                secret: gitlab-object-storage
                key: connection
            artifacts:
              bucket: artifacts-bucket
              proxy_download: false
              cdn:
                secret: gitlab-cdn-storage
                key: cdn
            lfs:
              bucket: lfs-bucket
              proxy_download: true
            uploads:
              bucket: uploads-bucket
            ciSecureFiles:
              enabled: true
              bucket: ci-secure-files-bucket
      )).deep_merge(default_values)
    end

    let(:object_types) { %w[artifacts lfs uploads ci_secure_files] }

    context 'with proxy_download configured' do
      it 'enables proxy_download for LFS' do
        t = HelmTemplate.new(values_object_store_connection)
        expect(t.exit_code).to eq(0)

        services.each do |cm|
          raw_config = t.dig("ConfigMap/test-#{cm}", 'data', 'gitlab.yml.erb')
          config = YAML.safe_load(raw_config)
          object_store_config = config.dig('production', 'object_store')

          expect(object_store_config['enabled']).to be true
          expect(object_store_config.dig('objects', 'proxy_download')).to be_nil
          expect(object_store_config.dig('objects', 'artifacts', 'proxy_download')).to be false
          expect(object_store_config.dig('objects', 'artifacts', 'bucket')).to eq('artifacts-bucket')
          expect(object_store_config.dig('objects', 'lfs', 'proxy_download')).to be true
          expect(object_store_config.dig('objects', 'lfs', 'bucket')).to eq('lfs-bucket')
          expect(object_store_config.dig('objects', 'uploads', 'proxy_download')).to be true
          expect(object_store_config.dig('objects', 'uploads', 'bucket')).to eq('uploads-bucket')
          expect(object_store_config.dig('objects', 'ci_secure_files', 'bucket')).to eq('ci-secure-files-bucket')

          object_types.each do |obj_type|
            expect(raw_config).not_to include("/etc/gitlab/objectstorage/#{obj_type}")
          end
        end
      end
    end

    context 'with CDN and connection configuration provided' do
      it 'populates CDN configuration' do
        t = HelmTemplate.new(values_object_store_connection)
        expect(t.exit_code).to eq(0)

        services.each do |cm|
          raw_config = t.dig("ConfigMap/test-#{cm}", 'data', 'gitlab.yml.erb')
          config = YAML.safe_load(raw_config)
          object_store_config = config.dig('production', 'object_store')

          expect(object_store_config['enabled']).to be true

          expect(object_store_config['connection']).to include(object_store_config_file)
          expect(object_store_config.dig('objects', 'artifacts', 'bucket')).to eq('artifacts-bucket')
          expect(object_store_config.dig('objects', 'lfs', 'bucket')).to eq('lfs-bucket')
          expect(object_store_config.dig('objects', 'artifacts', 'cdn')).to include(artifacts_cdn_file)

          expect(config.dig('production', 'artifacts')).to eq({ 'enabled' => true })
          expect(config.dig('production', 'lfs')).to eq({ 'enabled' => true })
        end

        init_secret_mounts.each do |deployment, mount|
          secret_names = t.projected_volume_sources("Deployment/#{deployment}", mount).map do |item|
            item['secret']['name']
          end

          expect(secret_names).to include('gitlab-object-storage', 'gitlab-cdn-storage')
        end
      end
    end
  end

  shared_examples 'storage-specific settings' do
    context 'when enabled' do
      it 'does not populate connection block' do
        t = HelmTemplate.new(enabled_settings)
        expect(t.exit_code).to eq(0)
        services.each do |cm|
          expect(t.dig("ConfigMap/test-#{cm}", 'data', 'gitlab.yml.erb')).not_to include(objectstorage_config_file)
        end
      end

      context 'with connection configuration provided' do
        it 'populates connection block' do
          t = HelmTemplate.new(enabled_settings.deep_merge(connection_settings))
          expect(t.exit_code).to eq(0)
          services.each do |cm|
            expect(t.dig("ConfigMap/test-#{cm}", 'data', 'gitlab.yml.erb')).to include(objectstorage_config_file)
          end
        end
      end
    end

    context 'when false' do
      it 'does not populate connection block' do
        t = HelmTemplate.new(disabled_settings)
        expect(t.exit_code).to eq(0)
        services.each do |cm|
          expect(t.dig("ConfigMap/test-#{cm}", 'data', 'gitlab.yml.erb')).not_to include(objectstorage_config_file)
        end
      end

      context 'with connection configuration provided' do
        it 'does not populate connection block' do
          t = HelmTemplate.new(disabled_settings.deep_merge(connection_settings))
          expect(t.exit_code).to eq(0)
          services.each do |cm|
            expect(t.dig("ConfigMap/test-#{cm}", 'data', 'gitlab.yml.erb')).not_to include(objectstorage_config_file)
          end
        end
      end
    end
  end

  describe 'global.appConfig.artifacts.enabled' do
    let(:artifacts_config_file) { '/etc/gitlab/objectstorage/artifacts' }

    let(:values_artifacts_enabled) do
      YAML.safe_load(%(
        global:
          appConfig:
            artifacts:
              enabled: true
      )).deep_merge(default_values)
    end

    let(:values_artifacts_disabled) do
      YAML.safe_load(%(
        global:
          appConfig:
            artifacts:
              enabled: false
      )).deep_merge(default_values)
    end

    let(:values_artifacts_connection) do
      YAML.safe_load(%(
        global:
          appConfig:
            artifacts:
              connection:
                secret: gitlab-object-storage
                key: connection
      )).deep_merge(default_values)
    end

    let(:values_artifacts_cdn) do
      YAML.safe_load(%(
        global:
          appConfig:
            artifacts:
              cdn:
                secret: gitlab-cdn-storage
                key: test-cdn
      )).deep_merge(values_artifacts_enabled)
        .deep_merge(values_artifacts_connection)
    end

    let(:objectstorage_config_file) { artifacts_config_file }
    let(:connection_settings) { values_artifacts_connection }
    let(:enabled_settings) { values_artifacts_enabled }
    let(:disabled_settings) { values_artifacts_disabled }

    it_behaves_like 'storage-specific settings'

    context 'when true' do
      context 'with CDN provided' do
        it 'populates CDN configuration' do
          t = HelmTemplate.new(values_artifacts_cdn)
          expect(t.exit_code).to eq(0)

          services.each do |cm|
            raw_config = t.dig("ConfigMap/test-#{cm}", 'data', 'gitlab.yml.erb')
            config = YAML.safe_load(raw_config)

            artifacts_config = config.dig('production', 'artifacts')

            expect(artifacts_config['enabled']).to be true
            expect(artifacts_config.dig('object_store', 'enabled')).to be true
            expect(artifacts_config.dig('object_store', 'remote_directory')).to eq('gitlab-artifacts')
            expect(artifacts_config.dig('object_store', 'connection')).to include(artifacts_config_file)
            expect(artifacts_config.dig('object_store', 'cdn')).to include(artifacts_cdn_file)
          end

          # Check the secret mounts
          init_secret_mounts.each do |deployment, mount|
            secret_names = t.projected_volume_sources("Deployment/#{deployment}", mount).map do |item|
              item['secret']['name']
            end

            expect(secret_names).to include('gitlab-object-storage', 'gitlab-cdn-storage')
          end
        end
      end
    end
  end

  describe 'global.appConfig.ciSecureFiles.enabled' do
    let(:objectstorage_config_file) { '/etc/gitlab/objectstorage/ci_secure_files' }

    let(:connection_settings) do
      YAML.safe_load(%(
        global:
          appConfig:
            ciSecureFiles:
              connection:
                secret: gitlab-object-storage
                key: connection
      )).deep_merge(default_values)
    end

    let(:enabled_settings) do
      YAML.safe_load(%(
        global:
          appConfig:
            ciSecureFiles:
              enabled: true
      )).deep_merge(default_values)
    end

    let(:disabled_settings) { default_values }

    it_behaves_like 'storage-specific settings'
  end

  describe 'global.appConfig.dependencyProxy.enabled' do
    let(:objectstorage_config_file) { '/etc/gitlab/objectstorage/dependency_proxy' }

    let(:connection_settings) do
      YAML.safe_load(%(
        global:
          appConfig:
            dependencyProxy:
              connection:
                secret: gitlab-object-storage
                key: connection
      )).deep_merge(default_values)
    end

    let(:enabled_settings) do
      YAML.safe_load(%(
        global:
          appConfig:
            dependencyProxy:
              enabled: true
      )).deep_merge(default_values)
    end

    let(:disabled_settings) { default_values }

    it_behaves_like 'storage-specific settings'
  end
end
