require 'spec_helper'
require 'helm_template_helper'
require 'yaml'
require 'hash_deep_merge'

describe 'Webservice monitoring/metrics configuration' do
  context 'web_exporter configuration' do
    let(:values) { HelmTemplate.defaults }
    let(:template) { HelmTemplate.new(values) }
    let(:gitlab_yml) { YAML.safe_load(template.dig('ConfigMap/test-webservice', 'data', 'gitlab.yml.erb')) }
    let(:monitoring) { gitlab_yml.dig('production', 'monitoring') }

    context 'when not configured' do
      it 'uses default settings' do
        expect(monitoring).to include(
          'web_exporter' => {
            'enabled' => true,
            'address' => '0.0.0.0',
            'port' => 8083
          }
        )
      end
    end

    context 'when disabled' do
      let(:values) do
        HelmTemplate.with_defaults(%(
          gitlab:
            webservice:
              metrics:
                enabled: false
        ))
      end

      it 'sets enabled to false' do
        expect(monitoring).to include(
          'web_exporter' => {
            'enabled' => false,
            'address' => '0.0.0.0',
            'port' => 8083
          }
        )
      end
    end

    shared_examples 'TLS is enabled' do
      let(:tls_cert_path) { '/etc/gitlab/webservice-metrics/webservice-metrics.crt' }
      let(:tls_key_path) { '/etc/gitlab/webservice-metrics/webservice-metrics.key' }

      it 'populates the gitlab.yml.erb web_exporter tls settings' do
        expect(monitoring['web_exporter']).to include(
          'tls_enabled' => true,
          'tls_cert_path' => tls_cert_path.to_s,
          'tls_key_path' => tls_key_path.to_s
        )
      end
    end

    shared_examples 'TLS is disabled' do
      it 'does not populates the gitlab.yml.erb web_exporter tls settings' do
        expect(monitoring['web_exporter']).to_not include(
          'tls_enabled' => true
        )
      end
    end

    context 'TLS is directly enabled' do
      let(:values) do
        HelmTemplate.with_defaults(%(
          gitlab:
            webservice:
              metrics:
                enabled: true
                tls:
                  enabled: true
        ))
      end
      it_behaves_like 'TLS is enabled'
    end

    context 'TLS is enabled via inheritance' do
      let(:values) do
        HelmTemplate.with_defaults(%(
          gitlab:
            webservice:
              tls:
                enabled: true
              metrics:
                enabled: true
        ))
      end
      it_behaves_like 'TLS is enabled'
    end

    context 'TLS is disabled via inheritance' do
      let(:values) do
        HelmTemplate.with_defaults(%(
          gitlab:
            webservice:
              tls:
                enabled: false
              metrics:
                enabled: true
        ))
      end
      it_behaves_like 'TLS is disabled'
    end
  end
end
