require 'spec_helper'
require 'helm_template_helper'
require 'yaml'
require 'hash_deep_merge'

describe 'webservice configuration' do
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
  let(:default_ingress) { template['Ingress/test-webservice-default'] }
  let(:extra_ingress) { template['Ingress/test-webservice-default-extra'] }
  let(:template) { HelmTemplate.new(values) }

  context 'extraIngress and certmanager are enabled' do
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
    end

    it 'postfixes the TLS secret' do
      expect(extra_ingress['spec']['tls'][0]['secretName']).to eql('test-gitlab-tls-extra')
    end
  end

  context 'extraIngress is enabled with a wildcard TLS secret' do
    let(:values) do
      YAML.safe_load(%(
        global:
          ingress:
            configureCertmanager: false
      )).deep_merge(super())
    end

    it 'does not postfix the TLS secret' do
      expect(extra_ingress['spec']['tls'][0]['secretName']).to eql('test-wildcard-tls')
    end
  end

  context 'extraIngress is enabled with a custom TLS secret' do
    let(:values) do
      YAML.safe_load(%(
        global:
          ingress:
            configureCertmanager: false
        gitlab:
          webservice:
            ingress:
              tls:
                secretName: local-tls
            extraIngress:
              tls:
                secretName: another-local-tls
      )).deep_merge(super())
    end

    it 'does not postfix the TLS secret' do
      expect(default_ingress['spec']['tls'][0]['secretName']).to eql('local-tls')
      expect(extra_ingress['spec']['tls'][0]['secretName']).to eql('another-local-tls')
    end
  end

  context 'setting nginx service-upstream annotation' do
    let(:values) do
      YAML.safe_load(%(
        gitlab:
          webservice:
            ingress:
              serviceUpstream: true
      )).deep_merge(super())
    end

    it 'nginx service-upstream annotation is added' do
      expect(default_ingress["metadata"]["annotations"]).to include(
        "nginx.ingress.kubernetes.io/service-upstream" => "true"
      )
    end
  end

  context 'providing own nginx annotation' do
    let(:values) do
      YAML.safe_load(%(
        gitlab:
          webservice:
            ingress:
              serviceUpstream: true
              annotations:
                nginx.ingress.kubernetes.io/service-upstream: "false"
      )).deep_merge(super())
    end

    it 'provided annotation takes precedence over local setting' do
      expect(default_ingress["metadata"]["annotations"]).to include(
        "nginx.ingress.kubernetes.io/service-upstream" => "false"
      )
    end
  end

  context 'using traefik as ingress provider' do
    let(:values) do
      YAML.safe_load(%(
        global:
          ingress:
            provider: traefik
      )).deep_merge(super())
    end

    it 'does not contain any nginx.ingress annotations' do
      nginx_annotations = default_ingress["metadata"]["annotations"].keys.select { |key| key.include?("nginx.ingress") }
      expect(nginx_annotations).to be_empty
    end
  end
end
