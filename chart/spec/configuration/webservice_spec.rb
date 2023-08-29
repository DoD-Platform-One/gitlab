require 'spec_helper'
require 'helm_template_helper'
require 'yaml'
require 'hash_deep_merge'

describe 'webservice configuration' do
  context 'extraIngress is enabled' do
    let(:default_ingress) { template['Ingress/test-webservice-default'] }
    let(:extra_ingress) { template['Ingress/test-webservice-default-extra'] }
    let(:values) do
      HelmTemplate.with_defaults(%(
      gitlab:
        webservice:
          ingress:
            proxyBodySize: 256M
          extraIngress:
            enabled: true
            proxyBodySize: 1024M
            hostname: extra.example.com
    ))
    end
    let(:template) { HelmTemplate.new(values) }

    it 'configures the default Ingress' do
      expect(default_ingress["spec"]["rules"][0]["host"]).to eql("gitlab.example.com")
      expect(default_ingress["metadata"]["annotations"]).to include(
        "nginx.ingress.kubernetes.io/proxy-body-size" => "256M"
      )
      expect(default_ingress['spec']['tls'][0]['secretName']).to eql('test-gitlab-tls')
    end

    it 'configures the extra Ingress' do
      expect(extra_ingress["spec"]["rules"][0]["host"]).to eql("extra.example.com")
      expect(extra_ingress["metadata"]["annotations"]).to include(
        "nginx.ingress.kubernetes.io/proxy-body-size" => "1024M"
      )
      expect(extra_ingress['spec']['tls'][0]['secretName']).to eql('test-gitlab-tls-extra')
    end
  end
end
