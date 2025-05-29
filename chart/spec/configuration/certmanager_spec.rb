# frozen_string_literal: true

require 'spec_helper'
require 'hash_deep_merge'
require 'helm_template_helper'
require 'yaml'

describe 'certmanager installation' do
  let(:values) { HelmTemplate.defaults }
  let(:template) { HelmTemplate.new(values) }
  let(:deployment) { template['Deployment/test-certmanager'] }

  shared_examples 'certmanager is installed' do
    it 'renders the Deployment' do
      expect(deployment).not_to be_nil
    end
  end

  shared_examples 'certmanager is not installed' do
    it 'does not render the Deployment' do
      expect(deployment).to be_nil
    end
  end

  context 'without the deprecated setting' do
    context 'enabled' do
      let(:values) do
        HelmTemplate.with_defaults(%(
        installCertmanager: false
        ))
      end

      include_examples 'certmanager is not installed'
    end

    context 'disabled' do
      let(:values) do
        HelmTemplate.with_defaults(%(
        installCertmanager: true
        ))
      end

      include_examples 'certmanager is installed'
    end
  end

  context 'with the deprecated setting' do
    context 'takes presedence when enabled' do
      let(:values) do
        YAML.safe_load(%(
          certmanager:
            install: true
          installCertmanager: false
        )).deep_merge(HelmTemplate.defaults)
      end

      include_examples 'certmanager is installed'
    end

    context 'takes presedence when disabled' do
      let(:values) do
        YAML.safe_load(%(
          certmanager:
            install: false
          installCertmanager: true
        )).deep_merge(HelmTemplate.defaults)
      end

      include_examples 'certmanager is not installed'
    end
  end
end
