require 'spec_helper'
require 'check_config_helper'
require 'hash_deep_merge'

describe 'checkConfig workhorse' do
  describe 'monitoring TLS' do
    let(:success_values) do
      YAML.safe_load(%(
        global:
          workhorse:
            tls:
              enabled: true
        gitlab:
          webservice:
            workhorse:
              monitoring:
                exporter:
                  tls:
                    enabled: true
        )).merge(default_required_values)
    end

    let(:error_values) do
      YAML.safe_load(%(
        global:
          workhorse:
            tls:
              enabled: false
        gitlab:
          webservice:
            workhorse:
              monitoring:
                exporter:
                  tls:
                    enabled: true
        )).merge(default_required_values)
    end

    let(:error_output) { 'The monitoring exporter TLS depends on the main workhorse listener using TLS.' }

    include_examples 'config validation',
                     success_description: 'when main and exporter TLS is enabled',
                     error_description: 'when main TLS is not enabled but exporter TLS is'
  end
end
