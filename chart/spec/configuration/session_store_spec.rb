require 'spec_helper'
require 'helm_template_helper'
require 'yaml'
require 'hash_deep_merge'

describe 'Session store configuration' do
  let(:template) { HelmTemplate.new(values) }

  shared_examples 'session store ConfigMap' do |prefix|
    let(:charts) { %w[webservice sidekiq toolbox] }

    it 'renders the template' do
      expect(template.exit_code).to eq(0), "Unexpected error code #{template.exit_code} -- #{template.stderr}"
    end

    it 'generates the session_store.yml' do
      charts.each do |chart|
        session_store_erb = template.dig("ConfigMap/test-#{chart}", 'data', 'session_store.yml.erb')
        session_store_config = YAML.safe_load(session_store_erb)['production']
        expect(session_store_config).to eq({ "session_cookie_token_prefix" => prefix })
      end
    end
  end

  context 'with no set values' do
    let(:values) do
      HelmTemplate.with_defaults({})
    end

    include_examples 'session store ConfigMap', ''
  end

  context 'with default values' do
    let(:values) do
      HelmTemplate.with_defaults(%(
        global:
          rails:
            sessionStore:
              sessionCookieTokenPrefix: ''
      ))
    end

    include_examples 'session store ConfigMap', ''
  end

  context 'with custom session_store configuration' do
    let(:values) do
      HelmTemplate.with_defaults(%(
           global:
             rails:
               sessionStore:
                 sessionCookieTokenPrefix: 'custom_prefix_'
      ))
    end

    include_examples 'session store ConfigMap', 'custom_prefix_'
  end
end
