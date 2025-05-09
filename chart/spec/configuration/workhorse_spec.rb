require 'spec_helper'
require 'fileutils'
require 'helm_template_helper'
require 'tomlrb'
require 'yaml'
require 'hash_deep_merge'
require 'runtime_template_helper'

describe 'Workhorse configuration' do
  let(:default_values) do
    HelmTemplate.defaults
  end
  let(:template) { HelmTemplate.new(default_values) }
  let(:raw_toml) { template.dig('ConfigMap/test-workhorse-default', 'data', 'workhorse-config.toml.tpl') }
  let(:global_redis_password) { SecureRandom.hex }
  let(:global_redis_sentinel_password) { SecureRandom.hex }
  let(:workhorse_redis_password) { SecureRandom.hex }

  def render_toml(raw_template, object_store_config = nil)
    Dir.mktmpdir do |tmpdir|
      raw_template.gsub!(%r{/etc/gitlab}, tmpdir)
      input_file = File.join(tmpdir, 'input.tpl')
      File.write(input_file, raw_template)

      directories = %w[redis redis-sentinel objectstorage]
      directories.each { |dir| FileUtils.mkdir(File.join(tmpdir, dir)) }
      # Write bogus redis password
      File.write(File.join(tmpdir, "redis", "redis-password"), global_redis_password)
      File.write(File.join(tmpdir, "redis", "workhorse-password"), workhorse_redis_password)
      File.write(File.join(tmpdir, "redis-sentinel", "redis-sentinel-password"), global_redis_sentinel_password)
      File.write(File.join(tmpdir, "objectstorage", "object_store"), object_store_config) if object_store_config

      cmd = "gomplate --left-delim '{%' --right-delim '%}' --file #{input_file}"
      result = Open3.capture3(cmd)
      stdout, stderr, exit_code = result

      raise "Unable to call gomplate: #{stderr}" if exit_code != 0

      Tomlrb.parse(stdout)
    end
  end

  def render_erb(raw_template)
    files = {
      '/etc/gitlab/redis/workhorse-password' => workhorse_redis_password,
      '/etc/gitlab/redis-sentinel/redis-sentinel-password' => global_redis_sentinel_password
    }

    yaml = RuntimeTemplate.erb(raw_template: raw_template, files: files)
    YAML.safe_load(yaml)
  end

  it 'renders a TOML configuration file' do
    toml = render_toml(raw_toml)

    expect(toml.keys).to match_array(%w[shutdown_timeout listeners image_resizer redis])
    expect(toml['shutdown_timeout']).to eq('61s')
  end

  it 'disabled archive cache' do
    expect(template.exit_code).to eq(0)
    # check the deployment of webservice for the WORKHORSE_ARCHVE_CACHE_DISABLED
    # env var. This is set on webserver and workhorse retrives the setting
    # from internal API. Also note that the value is irrevelent as the rails
    # code only checks for the existance of the variable not the value.
    containers = template.dig('Deployment/test-webservice-default', 'spec', 'template', 'spec', 'containers')
    found = false
    containers.each do |c|
      if c['name'] == 'webservice'
        vars = c['env'].map {|entry| entry['name']}
        if vars.include? 'WORKHORSE_ARCHIVE_CACHE_DISABLED'
          found = true
        end
      end
    end
    expect(found).to eq(true)
  end

  context 'with trusted CIDRs and zip_reader_limit_bytes' do
    let(:custom_values) do
      HelmTemplate.with_defaults(%(
        gitlab:
          webservice:
            workhorse:
              shutdownTimeout: "30s"
              trustedCIDRsForPropagation: ["127.0.0.1/32", "192.168.0.1/32"]
              trustedCIDRsForXForwardedFor: ["1.2.3.4/32", "5.6.7.8/32"]
              metadata:
                zipReaderLimitBytes: 10485760
     ))
    end

    let(:template) { HelmTemplate.new(custom_values) }

    it 'renders a TOML configuration file' do
      toml = render_toml(raw_toml)

      expect(toml.keys).to match_array(%w[shutdown_timeout listeners image_resizer redis trusted_cidrs_for_propagation trusted_cidrs_for_x_forwarded_for metadata])
      expect(toml['shutdown_timeout']).to eq('30s')
      expect(toml['trusted_cidrs_for_propagation']).to eq(["127.0.0.1/32", "192.168.0.1/32"])
      expect(toml['trusted_cidrs_for_x_forwarded_for']).to eq(["1.2.3.4/32", "5.6.7.8/32"])
      expect(toml['metadata']['zip_reader_limit_bytes']).to eq(10485760)
    end
  end

  describe 'object storage configuration' do
    context 'with S3 configured' do
      let(:s3_config) { File.read('examples/objectstorage/rails.s3.yaml') }

      it 'renders a TOML configuration file' do
        toml = render_toml(raw_toml, s3_config)

        expect(toml.keys).to match_array(%w[shutdown_timeout listeners object_storage image_resizer redis])

        object_storage = toml['object_storage']
        expect(object_storage.keys).to match_array(%w[provider s3])
        expect(object_storage['s3'].keys).to match_array(%w[aws_access_key_id aws_secret_access_key])
        expect(object_storage['s3']['aws_access_key_id']).to eq('AWS_ACCESS_KEY')
        expect(object_storage['s3']['aws_secret_access_key']).to eq('AWS_SECRET_KEY')
      end
    end

    context 'with AzureRM configured' do
      let(:azure_config) { File.read('examples/objectstorage/rails.azurerm.yaml') }

      it 'renders a TOML configuration file' do
        toml = render_toml(raw_toml, azure_config)

        expect(toml.keys).to match_array(%w[shutdown_timeout listeners object_storage image_resizer redis])

        object_storage = toml['object_storage']
        expect(object_storage.keys).to match_array(%w[provider azurerm])
        expect(object_storage['azurerm'].keys).to match_array(%w[azure_storage_account_name azure_storage_access_key])
        expect(object_storage['azurerm']['azure_storage_account_name']).to eq('YOUR_AZURE_STORAGE_ACCOUNT_NAME')
        expect(object_storage['azurerm']['azure_storage_access_key']).to eq('YOUR_AZURE_STORAGE_ACCOUNT_KEY')
      end

      context 'with a blank access key' do
        let(:azure_config) do
          <<CFG
provider: AzureRM
azure_storage_account_name: YOUR_AZURE_STORAGE_ACCOUNT_NAME
CFG
        end

        it 'renders a TOML configuration file' do
          toml = render_toml(raw_toml, azure_config)

          expect(toml.keys).to match_array(%w[shutdown_timeout listeners object_storage image_resizer redis])

          object_storage = toml['object_storage']
          expect(object_storage.keys).to match_array(%w[provider azurerm])
          expect(object_storage['azurerm'].keys).to match_array(%w[azure_storage_account_name azure_storage_access_key])
          expect(object_storage['azurerm']['azure_storage_account_name']).to eq('YOUR_AZURE_STORAGE_ACCOUNT_NAME')
          expect(object_storage['azurerm']['azure_storage_access_key']).to be_empty
        end
      end
    end

    context 'with GCS configured' do
      let(:s3_config) { File.read('examples/objectstorage/rails.gcs.yaml') }

      it 'renders a TOML configuration file' do
        toml = render_toml(raw_toml, s3_config)
        yaml = YAML.safe_load(s3_config)

        expect(toml.keys).to match_array(%w[shutdown_timeout listeners object_storage image_resizer redis])

        object_storage = toml['object_storage']
        expect(object_storage.keys).to match_array(%w[provider google])
        expect(object_storage['google'].keys).to match_array(%w[google_project google_json_key_string])
        expect(object_storage['google']['google_project']).to eq(yaml['google_project'])
        # here, we `rstrip` the YAML string, because it has an extra `\n` on the end as opposed to the rendered TOML
        expect(object_storage['google']['google_json_key_string']).to eq(yaml['google_json_key_string'].rstrip)
      end
    end
  end

  context 'configuring dedicated redis' do
    let(:template) { HelmTemplate.new(values) }

    context 'with default redis database' do
      let(:values) do
        YAML.safe_load(%(
          global:
            redis:
              host: global.redis
              auth:
                enabled: true
                secret: global-secret
          redis:
            install: false
        )).deep_merge!(default_values)
      end

      it 'renders the global redis config' do
        toml = render_toml(raw_toml)

        expect(toml.keys).to match_array(%w[shutdown_timeout listeners image_resizer redis])

        redis_config = toml['redis']

        expect(redis_config.keys).to match_array(%w[URL Password DB])
        expect(redis_config['URL']).to eq('redis://global.redis:6379')
        expect(redis_config['DB']).to eq(0)
        expect(redis_config['Password']).to eq(global_redis_password)

        expect(template.dig("ConfigMap/test-workhorse-default", 'data', 'workhorse-config.toml.tpl')).to include('redis/redis-password')
        expect(template.dig('ConfigMap/test-workhorse-default', 'data', 'configure')).to include('init-config/redis/redis-password')
      end
    end

    context 'with global redis' do
      let(:values) do
        YAML.safe_load(%(
          global:
            redis:
              host: global.redis
              database: 3
              auth:
                enabled: true
                secret: global-secret
          redis:
            install: false
        )).deep_merge!(default_values)
      end

      it 'renders the global redis config' do
        toml = render_toml(raw_toml)

        expect(toml.keys).to match_array(%w[shutdown_timeout listeners image_resizer redis])

        redis_config = toml['redis']

        expect(redis_config.keys).to match_array(%w[URL Password DB])
        expect(redis_config['URL']).to eq('redis://global.redis:6379')
        expect(redis_config['DB']).to eq(3)
        expect(redis_config['Password']).to eq(global_redis_password)

        expect(template.dig("ConfigMap/test-workhorse-default", 'data', 'workhorse-config.toml.tpl')).to include('redis/redis-password')
        expect(template.dig('ConfigMap/test-workhorse-default', 'data', 'configure')).to include('init-config/redis/redis-password')
      end
    end

    context 'with standalone redis' do
      let(:values) do
        YAML.safe_load(%(
          global:
            redis:
              host: global.redis
              auth:
                enabled: true
                secret: global-secret
              workhorse:
                host: workhorse.redis
                password:
                  enabled: true
                  secret: workhorse
          redis:
            install: false
        )).deep_merge!(default_values)
      end

      it 'overrides global redis config' do
        toml = render_toml(raw_toml)

        expect(toml.keys).to match_array(%w[shutdown_timeout listeners image_resizer redis])

        redis_config = toml['redis']
        expect(redis_config.keys).to match_array(%w[URL Password DB])
        expect(redis_config['URL']).to eq('redis://workhorse.redis:6379')
        expect(redis_config['DB']).to eq(0)
        expect(redis_config['Password']).to eq(workhorse_redis_password)
        expect(template.dig("ConfigMap/test-workhorse-default", 'data', 'workhorse-config.toml.tpl')).to include('redis/workhorse-password')
        expect(template.dig('ConfigMap/test-workhorse-default', 'data', 'configure')).to include('init-config/redis/workhorse-password')
      end

      context 'when workhorse redis does not have password' do
        before do
          values["global"]["redis"]["workhorse"]["password"]["enabled"] = false
        end

        it 'overrides global redis config' do
          toml = render_toml(raw_toml)

          expect(toml.keys).to match_array(%w[shutdown_timeout listeners image_resizer redis])

          redis_config = toml['redis']
          expect(redis_config.keys).to match_array(%w[URL DB])
          expect(redis_config['URL']).to eq('redis://workhorse.redis:6379')
          expect(redis_config['DB']).to eq(0)
        end
      end
    end

    context 'with global Redis user' do
      let(:values) do
        YAML.safe_load(%(
          global:
            redis:
              host: global.redis
              auth:
                enabled: true
                secret: global-secret
              user: redis-user
          redis:
            install: false
        )).deep_merge!(default_values)

        it "adds the username to the URL" do
          toml = render_toml(raw_toml)

          expect(toml.keys).to match_array(%w[shutdown_timeout listeners image_resizer redis])

          redis_config = toml['redis']
          expect(redis_config.keys).to match_array(%w[URL Password DB])
          expect(redis_config['URL']).to eq('redis://redis-user@workhorse.redis:6379')
          expect(redis_config['DB']).to eq(0)
          expect(redis_config['Password']).to eq(workhorse_redis_password)
          expect(template.dig("ConfigMap/test-workhorse-default", 'data', 'workhorse-config.toml.tpl')).to include('redis/workhorse-password')
          expect(template.dig('ConfigMap/test-workhorse-default', 'data', 'configure')).to include('init-config/redis/workhorse-password')
        end
      end
    end

    context 'with Workhorse Redis user' do
      let(:values) do
        YAML.safe_load(%(
          global:
            redis:
              host: global.redis
              database: 7
              auth:
                enabled: true
                secret: global-secret
              user: redis-user
              workhorse:
                host: workhorse.redis
                password:
                  enabled: true
                  secret: workhorse
                user: workhorse-redis-user
          redis:
            install: false
        )).deep_merge!(default_values)
      end

      it "overrides global redis config" do
        toml = render_toml(raw_toml)

        expect(toml.keys).to match_array(%w[shutdown_timeout listeners image_resizer redis])

        redis_config = toml['redis']
        expect(redis_config.keys).to match_array(%w[URL Password DB])
        expect(redis_config['URL']).to eq('redis://workhorse-redis-user@workhorse.redis:6379')
        expect(redis_config['DB']).to eq(7)
        expect(redis_config['Password']).to eq(workhorse_redis_password)
        expect(template.dig("ConfigMap/test-workhorse-default", 'data', 'workhorse-config.toml.tpl')).to include('redis/workhorse-password')
        expect(template.dig('ConfigMap/test-workhorse-default', 'data', 'configure')).to include('init-config/redis/workhorse-password')
      end
    end

    context 'with redis sentinel and database' do
      let(:values) do
        YAML.safe_load(%(
          global:
            redis:
              host: global.redis
              database: 9
              auth:
                enabled: true
                secret: global-secret
              workhorse:
                host: workhorse.redis
                sentinels:
                - host: s1.workhorse.redis
                  port: 26379
                - host: s2.workhorse.redis
                  port: 26379
                password:
                  enabled: true
                  secret: workhorse
          redis:
            install: false
        )).deep_merge!(default_values)
      end

      let(:webservice_config) { template.dig('ConfigMap/test-webservice', 'data') }
      let(:redis_workhorse_raw_yml) { webservice_config['redis.workhorse.yml.erb'] }
      let(:redis_workhorse_yml) { render_erb(redis_workhorse_raw_yml) }

      it 'overrides global redis config' do
        expect(template.exit_code).to eq(0), "Unexpected error code #{template.exit_code} -- #{template.stderr}"

        toml = render_toml(raw_toml)

        expect(toml.keys).to match_array(%w[shutdown_timeout listeners image_resizer redis])

        redis_config = toml['redis']
        expect(redis_config.keys).to match_array(%w[Password SentinelMaster Sentinel DB])
        expect(redis_config['SentinelMaster']).to eq('workhorse.redis')
        # Workhorse sentinels don't use global rediss scheme
        expect(redis_config['Sentinel']).to match_array(%w[redis://s1.workhorse.redis:26379 redis://s2.workhorse.redis:26379])
        expect(redis_config['Password']).to eq(workhorse_redis_password)
        expect(redis_config['DB']).to eq(9)
        expect(template.dig("ConfigMap/test-workhorse-default", "data", 'workhorse-config.toml.tpl')).to include('redis/workhorse-password')
        expect(template.dig('ConfigMap/test-workhorse-default', 'data', 'configure')).to include('init-config/redis/workhorse-password')
      end

      context 'with workhorse rediss scheme' do
        before do
          values["global"]["redis"]["workhorse"]["scheme"] = 'rediss'
        end

        it 'uses the rediss scheme' do
          expect(template.exit_code).to eq(0), "Unexpected error code #{template.exit_code} -- #{template.stderr}"

          toml = render_toml(raw_toml)
          redis_config = toml['redis']
          expect(redis_config['Sentinel']).to match_array(%w[rediss://s1.workhorse.redis:26379 rediss://s2.workhorse.redis:26379])
        end
      end

      context 'when workhorse redis does not have password' do
        before do
          values["global"]["redis"]["workhorse"]["password"]["enabled"] = false
        end

        it 'overrides global redis config' do
          toml = render_toml(raw_toml)

          expect(toml.keys).to match_array(%w[shutdown_timeout listeners image_resizer redis])

          redis_config = toml['redis']
          expect(redis_config.keys).to match_array(%w[SentinelMaster Sentinel DB])
          expect(redis_config['SentinelMaster']).to eq('workhorse.redis')
          expect(redis_config['Sentinel']).to match_array(%w[redis://s1.workhorse.redis:26379 redis://s2.workhorse.redis:26379])
        end
      end

      context 'with redis sentinel authentication' do
        let(:values) do
          YAML.safe_load(%(
            global:
              redis:
                host: global.redis
                auth:
                  enabled: true
                  secret: global-secret
                sentinelAuth:
                  enabled: true
                  secret: redis-sentinel-secret
                  key: password
                workhorse:
                  host: workhorse.redis
                  sentinels:
                  - host: s1.workhorse.redis
                    port: 26379
                  - host: s2.workhorse.redis
                    port: 26379
                  password:
                    enabled: true
                    secret: workhorse
                  sentinelAuth: # Unsupported, so test that the override doesn't do anything
                    enabled: true
                    secret: workhorse-redis-sentinel-secret
                    key: password
            redis:
              install: false
          )).deep_merge!(default_values)
        end

        it 'uses global redis config' do
          toml = render_toml(raw_toml)

          expect(toml.keys).to match_array(%w[shutdown_timeout listeners image_resizer redis])

          redis_config = toml['redis']
          expect(redis_config.keys).to match_array(%w[Password SentinelMaster Sentinel SentinelPassword DB])
          expect(redis_config['SentinelMaster']).to eq('workhorse.redis')
          expect(redis_config['Sentinel']).to match_array(%w[redis://s1.workhorse.redis:26379 redis://s2.workhorse.redis:26379])
          expect(redis_config['Password']).to eq(workhorse_redis_password)
          expect(redis_config['SentinelPassword']).to eq(global_redis_sentinel_password)
          expect(redis_config['DB']).to eq(0)

          expect(template.exit_code).to eq(0), "Unexpected error code #{template.exit_code} -- #{template.stderr}"

          expect(template.dig("ConfigMap/test-workhorse-default", "data", 'workhorse-config.toml.tpl')).to include('redis/workhorse-password')
          expect(template.dig('ConfigMap/test-workhorse-default', 'data', 'configure')).to include('init-config/redis/workhorse-password')

          expect(redis_workhorse_yml['production']['sentinel_password']).to eq(global_redis_sentinel_password)
        end
      end
    end
  end

  context 'TLS support' do
    let(:global_workhorse_tls_enabled) { false }
    let(:tls_verify) {}
    let(:monitoring_enabled) { true }
    let(:monitoring_tls_enabled) {}
    let(:tls_secret_name) {}
    let(:tls_ca_secret_name) {}
    let(:tls_custom_ca) {}

    let(:tls_values) do
      values = HelmTemplate.with_defaults(%(
        global:
          certificates:
            customCAs: [#{tls_custom_ca}]
          workhorse:
            tls:
              enabled: #{global_workhorse_tls_enabled}
        gitlab:
          webservice:
            workhorse:
              monitoring:
                exporter:
                  enabled: #{monitoring_enabled}
              tls:
                verify: #{tls_verify}
                secretName: #{tls_secret_name}
                caSecretName: #{tls_ca_secret_name}
      ))

      values.deep_merge!(YAML.safe_load(%(
        gitlab:
          webservice:
            workhorse:
              monitoring:
                exporter:
                  tls:
                    enabled: #{monitoring_tls_enabled}
      ))) unless monitoring_tls_enabled.nil?

      values
    end

    let(:template) { HelmTemplate.new(tls_values) }

    shared_examples 'TLS is enabled' do
      it 'renders a TOML configuration file' do
        expect(template.exit_code).to eq(0), "Unexpected error code #{template.exit_code} -- #{template.stderr}"
        expect(raw_toml).to include %([[listeners]]\n)
        expect(raw_toml).to include %(addr = "0.0.0.0:8181"\n)
        expect(raw_toml).to include %([listeners.tls]\n)
      end
      it 'annotates Ingress for TLS backend' do
        ingress_annotations = template.dig('Ingress/test-webservice-default', 'metadata', 'annotations')

        expect(ingress_annotations).to include('nginx.ingress.kubernetes.io/backend-protocol' => 'https')
      end
    end

    shared_examples 'monitoring TLS is enabled' do
      it 'renders a TOML configuration file' do
        expect(raw_toml).to include %([metrics_listener]\n)
        expect(raw_toml).to include %(addr = "0.0.0.0:9229"\n)
        expect(raw_toml).to include %([metrics_listener.tls]\n)
      end
    end

    shared_examples 'TLS is disabled' do
      it 'renders a TOML configuration file without TLS listener' do
        expect(raw_toml).not_to include %([listeners.tls]\n)
      end
    end

    shared_examples 'monitoring TLS is disabled' do
      it 'renders a TOML configuration file without TLS listener' do
        expect(raw_toml).not_to include %([metrics_listener.tls]\n)
      end
    end

    shared_examples 'TLS is verified' do
      it 'uses specified secret in the volumes' do
        webservice_secret_volumes = template
          .dig('Deployment/test-webservice-default', 'spec', 'template', 'spec', 'volumes')
          .collect { |v| v.dig('projected', 'sources')&.collect { |p| p.dig('secret', 'name') } }.compact.flatten

        expect(webservice_secret_volumes).to include('webservice-tls-secret')
        expect(webservice_secret_volumes).to include('custom-ca-secret')
      end
      it 'annotates Ingress for TLS backend' do
        ingress_annotations = template.dig('Ingress/test-webservice-default', 'metadata', 'annotations')

        expect(ingress_annotations).to include('nginx.ingress.kubernetes.io/proxy-ssl-verify' => 'on')
        expect(ingress_annotations).to include('nginx.ingress.kubernetes.io/proxy-ssl-secret' => 'default/custom-ca-secret')
      end
    end

    context 'when TLS is enabled and verified' do
      let(:global_workhorse_tls_enabled) { true }
      let(:tls_verify) { true }
      let(:tls_secret_name) { 'webservice-tls-secret' }
      let(:tls_ca_secret_name) { 'custom-ca-secret' }
      let(:tls_custom_ca) { 'secret: custom-ca-secret' }
      let(:monitoring_tls_enabled) { true }

      it_behaves_like 'TLS is enabled'
      it_behaves_like 'monitoring TLS is enabled'
      it_behaves_like 'TLS is verified'
    end

    context 'when TLS is enabled but not verified and monitoring is disabled' do
      let(:global_workhorse_tls_enabled) { true }
      let(:tls_verify) { false }
      let(:tls_secret_name) { 'webservice-tls-secret' }
      let(:tls_ca_secret_name) { 'custom-ca-secret' }
      let(:tls_custom_ca) { 'secret: custom-ca-secret' }
      let(:monitoring_enabled) { false }
      let(:monitoring_tls_enabled) { false }

      it_behaves_like 'TLS is enabled'
      it_behaves_like 'monitoring TLS is disabled'

      it 'renders a TOML configuration file' do
        toml = render_toml(raw_toml)

        expect(toml.keys).to match_array(%w[shutdown_timeout listeners image_resizer redis])

        listeners = toml['listeners']
        expect(listeners.count).to eq(1)
        expect(listeners.first.keys).to match_array(%w[network addr tls])
        expect(listeners.first['addr']).to eq('0.0.0.0:8181')
      end

      it 'does not annotate Ingress for TLS verify' do
        ingress_annotations = template.dig('Ingress/test-webservice-default', 'metadata', 'annotations')

        expect(ingress_annotations).not_to include('nginx.ingress.kubernetes.io/proxy-ssl-verify')
      end
    end

    context 'when monitoring TLS inherits disabled TLS' do
      let(:global_workhorse_tls_enabled) { false }
      let(:monitoring_tls_enabled) { nil }

      it_behaves_like 'TLS is disabled'
      it_behaves_like 'monitoring TLS is disabled'
    end

    context 'when monitoring inherits enabled TLS' do
      let(:global_workhorse_tls_enabled) { true }
      let(:monitoring_tls_enabled) { nil }

      it_behaves_like 'TLS is enabled'
      it_behaves_like 'monitoring TLS is enabled'
    end

    context 'TLS is enabled and monitoring TLS is disabled' do
      let(:global_workhorse_tls_enabled) { true }
      let(:monitoring_tls_enabled) { false }

      it_behaves_like 'TLS is enabled'
      it_behaves_like 'monitoring TLS is disabled'
    end
  end
end
