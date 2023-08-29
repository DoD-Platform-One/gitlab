require 'spec_helper'
require 'helm_template_helper'
require 'yaml'
require 'hash_deep_merge'

describe 'SMTP configuration' do
  let(:values) do
    HelmTemplate.with_defaults(%(
      global:
        smtp:
          enabled: true
          password:
            secret: gitlab-smtp
            key: password
    ))
  end
  let(:template) { HelmTemplate.new values }
  let(:smtp_secret) do
    template.get_projected_secret('Deployment/test-webservice-default', 'init-webservice-secrets', 'gitlab-smtp')
  end

  context 'authentication enabled' do
    let(:values) do
      YAML.safe_load(%(
        global:
          smtp:
            authentication: plain
      )).deep_merge(super())
    end

    it 'does mount the password secret' do
      expect(smtp_secret).to_not eq(nil)
      expect(smtp_secret['items'][0]['key']).to eq('password')
      expect(smtp_secret['items'][0]['path']).to eq('smtp/smtp-password')
    end
  end

  context 'authentication disabled' do
    context 'via empty string' do
      let(:values) do
        YAML.safe_load(%(
          global:
            smtp:
              authentication: ""
        )).deep_merge(super())
      end

      it 'does not mount the password secret' do
        expect(smtp_secret).to eq(nil)
      end
    end

    context 'via none string' do
      let(:values) do
        YAML.safe_load(%(
          global:
            smtp:
              authentication: "none"
      )).deep_merge(super())
      end

      it 'does not mount the password secret' do
        expect(smtp_secret).to eq(nil)
      end
    end
  end
end
