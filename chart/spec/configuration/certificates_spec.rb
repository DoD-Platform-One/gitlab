require 'spec_helper'
require 'helm_template_helper'
require 'yaml'
require 'hash_deep_merge'

describe 'Certificates configuration' do
  # we're skipping anything not using this feature
  let(:skip_items) do
    [
      'minio', 'nginx', 'postgresql', 'redis',
      'gitlab-runner',
      # cert-manager Pods (2)
      'cainjector',
      'cert-manager',
      'prometheus'
    ]
  end

  let(:default_values) do
    YAML.safe_load(%(
      certmanager-issuer:
        email: test@example.com
    ))
  end

  context 'Custom CA certificates' do
    context 'When present' do
      let(:single_ca) do
        YAML.safe_load(%(
          global:
            certificates:
              customCAs:
              - secret: rspec-custom-ca
        )).deep_merge(default_values)
      end

      subject(:present) { HelmTemplate.new(single_ca) }

      it 'templates successfully' do
        expect(present.exit_code).to eq(0)
      end

      it 'populates volumes with extra Secret'  do
        present.resources_by_kind('Deployment').each do |resource|
          next if skip_items.any? { |i| resource[0].include? i }
          sources = present.projected_volume_sources(resource[0],'custom-ca-certificates')
          expect(sources).to be_truthy, "unable to locate 'custom-ca-certificates' volume for #{resource[0]}"
          expect(sources[0]['secret']['name']).to eq('rspec-custom-ca')
        end

        present.resources_by_kind('StatefulSet').each do |resource|
          next if skip_items.any? { |i| resource[0].include? i }
          sources = present.projected_volume_sources(resource[0],'custom-ca-certificates')
          expect(sources).to be_truthy, "unable to locate 'custom-ca-certificates' volume for #{resource[0]}"
          expect(sources[0]['secret']['name']).to eq('rspec-custom-ca')
        end
      end

      it 'populates volumeMounts with extra volume'  do
        present.resources_by_kind('Deployment').each do |resource|
          next if skip_items.any? { |i| resource[0].include? i }
          volume_mount = present.find_volume_mount(resource[0],'certificates', 'custom-ca-certificates', true)
          expect(volume_mount).to be_truthy, "unable to locate 'custom-ca-certificates' mount in 'certificates' container of #{resource[0]}"
        end

        present.resources_by_kind('StatefulSet').each do |resource|
          next if skip_items.any? { |i| resource[0].include? i }
          volume_mount = present.find_volume_mount(resource[0],'certificates', 'custom-ca-certificates', true)
          expect(volume_mount).to be_truthy, "unable to locate 'custom-ca-certificates' mount in 'certificates' container of #{resource[0]}"
        end
      end
    end
  end
end
