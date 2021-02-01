require 'spec_helper'
require 'helm_template_helper'
require 'yaml'
require 'hash_deep_merge'

describe 'gitlab.yml.erb configuration' do
  let(:default_values) do
    {
      'certmanager-issuer' => { 'email' => 'test@example.com' }
    }
  end

  context 'when CSP is disabled' do
    it 'does not populate the gitlab.yml.erb' do
      t = HelmTemplate.new(default_values)
      expect(t.dig(
        'ConfigMap/test-webservice',
        'data',
        'gitlab.yml.erb'
      )).not_to include('content_security_policy')
    end
  end

  context 'when CSP is enabled' do
    let(:required_values) do
      {
        'global' => {
          'appConfig' => {
            'contentSecurityPolicy' => {
              'enabled' => true,
              'report_only' => false,
              'directives' => {
                'connect_src' => "'self'",
                'frame_acestors' => "'self'",
                'frame_src' => "'self'",
                'img_src' => "* data: blob:",
                'object_src' => "'none'",
                'script_src' => "'self' 'unsafe-inline' 'unsafe-eval'",
                'style_src' => "'self'"
              }
            }
          }
        }
      }.merge(default_values)
    end

    let(:missing_values) do
      {
        'global' => {
          'appConfig' => {
            'contentSecurityPolicy' => {
              'enabled' => true
            }
          }
        }
      }.merge(default_values)
    end

    it 'populates the gitlab.yml.erb' do
      t = HelmTemplate.new(required_values)
      expect(t.dig(
        'ConfigMap/test-webservice',
        'data',
        'gitlab.yml.erb'
      )).to include('content_security_policy')
    end

    it 'fails when we are missing a required value' do
      t = HelmTemplate.new(missing_values)
      expect(t.exit_code).not_to eq(0)
      expect(t.stderr).to include(
        'set `global.appConfig.contentSecurityPolicy.directives'
      )
    end
  end
end
