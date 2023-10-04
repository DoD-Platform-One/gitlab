require 'spec_helper'
require 'check_config_helper'
require 'yaml'
require 'hash_deep_merge'

describe 'checkConfig omniauth' do
  describe 'providers' do
    let(:success_values) do
      YAML.safe_load(%(
        global:
          appConfig:
            omniauth:
              providers:
                - secret: oauth
                - secret: oauth2
                  key: config
                - name: kerberos
                  label: Kerberos
                  icon: "https://example.org/kerberos.png"
      )).merge(default_required_values)
    end

    let(:error_values) do
      YAML.safe_load(%(
        global:
          appConfig:
            omniauth:
              providers:
                - name: oauth2_generic
                  app_id: id
                  app_secret: secret
      )).merge(default_required_values)
    end

    let(:error_output) { "each provider should only contain either:" }

    include_examples 'config validation',
                     success_description: 'when omniauth providers are configured in the expected format',
                     error_description: 'when omniauth providers are configured in a not supported format'
  end
end
