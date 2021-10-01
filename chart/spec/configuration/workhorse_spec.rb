require 'spec_helper'
require 'helm_template_helper'
require 'yaml'
require 'hash_deep_merge'

describe 'Workhorse configuration' do
  let(:default_values) do
    YAML.safe_load(%(
      certmanager-issuer:
        email: test@example.com
    ))
  end
  let(:template) { HelmTemplate.new(default_values) }

  it 'renders a TOML configuration file' do
    raw_toml = template.dig('ConfigMap/test-workhorse-default', 'data', 'workhorse-config.toml.erb')

    expect(raw_toml).to match /^shutdown_timeout = "61s"/
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

  context 'with custom values' do
    let(:custom_values) do
      YAML.safe_load(%(
        gitlab:
          webservice:
            workhorse:
              shutdownTimeout: "30s"
        certmanager-issuer:
          email: test@example.com
     ))
    end

    let(:template) { HelmTemplate.new(custom_values) }

    it 'renders a TOML configuration file' do
      raw_toml = template.dig('ConfigMap/test-workhorse-default', 'data', 'workhorse-config.toml.erb')

      expect(raw_toml).to match /^shutdown_timeout = "30s"/
    end
  end
end
