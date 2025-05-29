require 'spec_helper'
require 'check_config_helper'
require 'yaml'
require 'hash_deep_merge'

describe 'checkConfig prometheus' do
  let(:success_values) do
    YAML.safe_load(%(
      prometheus:
        prometheus-pushgateway:
          foo: bar
    )).deep_merge!(default_required_values)
  end

  let(:error_values) do
    YAML.safe_load(%(
      prometheus:
        pushgateway:
          foo: bar
    )).deep_merge!(default_required_values)
  end

  let(:error_output) { 'Detected deprecated values for the Prometheus subchart.' }

  include_examples 'config validation',
                   success_description: 'when no deprecated Prometheus chart values are set',
                   error_description: 'when deprecated Prometheus values are set'
end
