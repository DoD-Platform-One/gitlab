require 'spec_helper'
require 'helm_template_helper'
require 'yaml'
require 'hash_deep_merge'

describe 'Praefect configuration' do
  let(:default_values) do
    { 'certmanager-issuer' => { 'email' => 'test@example.com' } }
  end

  let(:praefect_resources) do
    [
      'Service/test-praefect',
      'ConfigMap/test-praefect',
      'ConfigMap/test-praefect-scripts',
      'PodDisruptionBudget/test-praefect',
      'StatefulSet/test-praefect'
    ]
  end

  context 'wtih Praefect disabled' do
    let(:values_praefect_disabled) do
      {
        'global' => {
          'praefect' => {
            'enabled' => false
          }
        }
      }.deep_merge(default_values)
    end

    let(:template) { HelmTemplate.new(values_praefect_disabled) }

    it 'templates successfully' do
      expect(template.exit_code).to eq(0)
    end

    it 'does not render Praefect resources' do
      praefect_resources.each do |r|
        expect(template.dig(r)).to be_falsey
      end
    end
  end

  context 'with Praefect enabled' do
    let(:values_praefect_enabled) do
      {
        'global' => {
          'praefect' => {
            'enabled' => true
          }
        }
      }.deep_merge(default_values)
    end

    let(:gitaly_resources) do
      [
        'PodDisruptionBudget/test-gitaly-default',
        'ConfigMap/test-gitaly',
        'Service/test-gitaly-default',
        'StatefulSet/test-gitaly-default'
      ]
    end

    let(:template) { HelmTemplate.new(values_praefect_enabled) }

    it 'templates successfully' do
      expect(template.exit_code).to eq(0)
    end

    it 'renders Praefect resources' do
      praefect_resources.each do |r|
        expect(template.dig(r)).to be_truthy
      end
    end

    it 'renders Gitaly resources' do
      gitaly_resources.each do |r|
        expect(template.dig(r)).to be_truthy
      end
    end

    context 'with multiple virtual storages' do
      let(:values_multiple_virtual_storages) do
        {
          'global' => {
            'praefect' => {
              'virtualStorages' => [
                {
                  'name' => 'default',
                  'gitalyReplicas' => 3
                },
                {
                  'name' => 'vs2',
                  'gitalyReplicas' => 3
                }
              ]
            }
          }
        }.deep_merge(values_praefect_enabled)
      end

      let(:gitaly_resources_with_multiple_storages) do
        [
          'PodDisruptionBudget/test-gitaly-vs2',
          'Service/test-gitaly-vs2',
          'StatefulSet/test-gitaly-vs2'
        ].concat(gitaly_resources)
      end

      let(:template) { HelmTemplate.new(values_multiple_virtual_storages) }

      it 'templates successfully' do
        expect(template.exit_code).to eq(0)
      end

      it 'generates Gitaly resources per virtual storage' do
        gitaly_resources_with_multiple_storages.each do |r|
          expect(template.dig(r)).to be_truthy
        end
      end

      context 'with operator enabled' do
        let(:values_operator_enabled) do
          {
            'global' => {
              'operator' => { 'enabled' => true }
            }
          }.deep_merge(values_multiple_virtual_storages)
        end

        let(:operator_resources) do
          [
            'ServiceAccount/test-gitaly-pause',
            'Role/test-gitaly-pause',
            'RoleBinding/test-gitaly-pause',
            'Job/test-gitaly-pause'
          ]
        end

        let(:template) { HelmTemplate.new(values_operator_enabled) }

        it 'templates successfully' do
          expect(template.exit_code).to eq(0)
        end

        it 'generates operator-related resources' do
          operator_resources.each do |r|
            expect(template.dig(r)).to be_truthy
          end
        end
      end
    end
  end
end
