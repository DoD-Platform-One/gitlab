# frozen_string_literal: true

require 'spec_helper'
require 'hash_deep_merge'
require 'helm_template_helper'
require 'yaml'

describe 'OpenBao installation' do
  let(:values) do
    HelmTemplate.with_defaults(%(
    openbao:
      install: true
    ))
  end

  let(:template) { HelmTemplate.new(values) }
  let(:openbao_psql_config) do
    config = template.dig("ConfigMap/test-openbao-config", 'data', 'config.json')

    JSON.parse(config)['storage']['postgresql']
  end

  describe 'by default' do
    it 'uses the main PostgreSQL database' do
      expect(openbao_psql_config['connection_url'])
        .to start_with('postgres://gitlab@test-postgresql.default.svc:5432/gitlabhq_production')
    end
  end

  describe 'with a custom DB' do
    let(:values) do
      HelmTemplate.with_defaults(%(
      global:
        psql:
          keepalivesInterval: 10
          keepalivesIdle: 2
      openbao:
        install: true
        config:
          storage:
            postgresql:
              connection:
                host: psql.openbao.example.com
                port: 5555
                database: baodb
                username: baouser
                keepalivesIdle: 3
      ))
    end

    it 'uses the custom PostgreSQL database' do
      expect(openbao_psql_config['connection_url'])
        .to start_with('postgres://baouser@psql.openbao.example.com:5555/baodb')
    end

    it 'merges connection arguments' do
      expect(openbao_psql_config['connection_url']).to include(
        'keepalives_interval=10',
        'keepalives_idle=3'
      )
    end
  end
end
