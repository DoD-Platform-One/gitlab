require 'spec_helper'
require 'check_config_helper'
require 'yaml'
require 'hash_deep_merge'

describe 'checkConfig template' do
  # This is not actually in _checkConfig.tpl, but it uses `required`, so
  # acts in a similar way
  describe 'certmanager-issuer.email' do
    let(:success_values) { default_required_values }
    let(:error_values) { {} }
    let(:error_output) { 'Please set certmanager-issuer.email' }

    include_examples 'config validation',
                     success_description: 'when set',
                     error_description: 'when unset'
  end

  describe 'multipleRedis' do
    let(:success_values) do
      YAML.safe_load(%(
        redis:
          install: true
      )).deep_merge!(default_required_values)
    end

    let(:error_values) do
      YAML.safe_load(%(
        redis:
          install: true
        global:
          redis:
            cache:
              host: foo
      )).deep_merge!(default_required_values)
    end

    let(:error_output) { 'If configuring multiple Redis servers, you can not use the in-chart Redis server' }

    include_examples 'config validation',
                     success_description: 'when Redis is set to install with a single Redis instance',
                     error_description: 'when Redis is set to install with multiple Redis instances'
  end

  describe 'serviceAccount' do
    let(:success_values) do
      YAML.safe_load(%(
        global:
          serviceAccount:
            enabled: true
            create: false
            name: myaccount
      )).deep_merge!(default_required_values)
    end

    let(:error_values) do
      YAML.safe_load(%(
        global:
          serviceAccount:
            enabled: true
            create: true
            name: myaccount
      )).deep_merge!(default_required_values)
    end

    let(:error_output) { 'Please set `global.serviceAccount.create=false`' }

    include_examples 'config validation',
                     success_description: 'when global ServiceAccount name is provided with `create=false`',
                     error_description: 'when global ServiceAccount name is provided with `create=true`'
  end

  describe 'clickHouse' do
    let(:success_values) do
      YAML.safe_load(%(
        global:
          clickhouse:
            enabled: true
            main:
              password:
                secret: clickhouse-password
                key: main_password
      )).deep_merge!(default_required_values)
    end

    let(:error_values) do
      YAML.safe_load(%(
        global:
          clickhouse:
            enabled: true
            main:
              key: main_password
              password:
                secret: clickhouse-password
      )).deep_merge!(default_required_values)
    end

    let(:error_output) { 'Please set `global.clickhouse.main.password.key` instead' }

    include_examples 'config validation',
                     success_description: 'when clickhouse password key is provided in main.password.key',
                     error_description: 'when clickhouse password key is provided in main.key'
  end
end
