require 'spec_helper'
require 'helm_template_helper'
require 'yaml'
require 'hash_deep_merge'

describe 'Sidekiq configuration' do
  let(:default_values) do
    {
      # provide required setting
      'certmanager-issuer' => { 'email' => 'test@example.com' },
      # required to activate mailroom
      'gitlab' => {
        'sidekiq' => {
          'pods' => [
            { 'name' => 'pod-1', 'queues' => 'merge' },
            { 'name' => 'pod-2', 'negateQueues' => 'merge' },
          ]
        }
      }
    }
  end

  context 'when setting extraEnv' do
    def container_name(pod)
      "Deployment/test-sidekiq-#{pod}-v1"
    end

    context 'when the global value is set' do
      let(:global_values) do
        {
          'global' => {
            'extraEnv' => {
              'EXTRA_ENV_VAR_A' => 'global-a',
              'EXTRA_ENV_VAR_B' => 'global-b'
            }
          }
        }.deep_merge(default_values)
      end

      it 'sets those environment variables on each pod' do
        global_template = HelmTemplate.new(global_values)

        expect(global_template.exit_code).to eq(0)

        expect(global_template.env(container_name('pod-1'), 'sidekiq'))
          .to include(
                { 'name' => 'EXTRA_ENV_VAR_A', 'value' => 'global-a' },
                { 'name' => 'EXTRA_ENV_VAR_B', 'value' => 'global-b' }
              )

        expect(global_template.env(container_name('pod-2'), 'sidekiq'))
          .to include(
                { 'name' => 'EXTRA_ENV_VAR_A', 'value' => 'global-a' },
                { 'name' => 'EXTRA_ENV_VAR_B', 'value' => 'global-b' }
              )
      end

      context 'when the chart-level value is set' do
        let(:chart_values) do
          {
            'gitlab' => {
              'sidekiq' => {
                'extraEnv' => {
                  'EXTRA_ENV_VAR_A' => 'chart-a',
                  'EXTRA_ENV_VAR_C' => 'chart-c',
                  'EXTRA_ENV_VAR_D' => 'chart-d'
                }
              }
            }
          }
        end

        let(:chart_template) { HelmTemplate.new(global_values.deep_merge(chart_values)) }

        it 'sets those environment variables on each pod' do
          expect(chart_template.exit_code).to eq(0)

          expect(chart_template.env(container_name('pod-1'), 'sidekiq'))
            .to include(
                  { 'name' => 'EXTRA_ENV_VAR_C', 'value' => 'chart-c' },
                  { 'name' => 'EXTRA_ENV_VAR_D', 'value' => 'chart-d' }
                )

          expect(chart_template.env(container_name('pod-2'), 'sidekiq'))
            .to include(
                  { 'name' => 'EXTRA_ENV_VAR_C', 'value' => 'chart-c' },
                  { 'name' => 'EXTRA_ENV_VAR_D', 'value' => 'chart-d' }
                )
        end

        it 'overrides global values' do
          expect(chart_template.env(container_name('pod-1'), 'sidekiq'))
            .to include('name' => 'EXTRA_ENV_VAR_A', 'value' => 'chart-a')

          expect(chart_template.env(container_name('pod-2'), 'sidekiq'))
            .to include('name' => 'EXTRA_ENV_VAR_A', 'value' => 'chart-a')
        end

        context 'when the pod-level value is set' do
          let(:pod_values) do
            {
              'gitlab' => {
                'sidekiq' => {
                  'pods' => [
                    {
                      'name' => 'pod-1',
                      'queues' => 'merge',
                      'extraEnv' => {
                        'EXTRA_ENV_VAR_B' => 'pod-b',
                        'EXTRA_ENV_VAR_C' => 'pod-c',
                        'EXTRA_ENV_VAR_E' => 'pod-e'
                      }
                    },
                    {
                      'name' => 'pod-2',
                      'negateQueues' => 'merge',
                      'extraEnv' => {
                        'EXTRA_ENV_VAR_B' => 'pod-b',
                        'EXTRA_ENV_VAR_C' => 'pod-c',
                        'EXTRA_ENV_VAR_F' => 'pod-f'
                      }
                    },
                  ]
                }
              }
            }
          end

          let(:pod_template) do
            HelmTemplate.new(global_values.deep_merge(chart_values).deep_merge(pod_values))
          end

          it 'sets those environment variables on the relevant pods' do
            expect(pod_template.exit_code).to eq(0)

            expect(pod_template.env(container_name('pod-1'), 'sidekiq'))
              .to include('name' => 'EXTRA_ENV_VAR_E', 'value' => 'pod-e')
            expect(pod_template.env(container_name('pod-1'), 'sidekiq'))
              .not_to include('name' => 'EXTRA_ENV_VAR_F', 'value' => 'pod-f')

            expect(pod_template.env(container_name('pod-2'), 'sidekiq'))
              .not_to include('name' => 'EXTRA_ENV_VAR_E', 'value' => 'pod-e')
            expect(pod_template.env(container_name('pod-2'), 'sidekiq'))
              .to include('name' => 'EXTRA_ENV_VAR_F', 'value' => 'pod-f')
          end

          it 'overrides global values' do
            expect(pod_template.env(container_name('pod-1'), 'sidekiq'))
              .to include('name' => 'EXTRA_ENV_VAR_B', 'value' => 'pod-b')

            expect(pod_template.env(container_name('pod-2'), 'sidekiq'))
              .to include('name' => 'EXTRA_ENV_VAR_B', 'value' => 'pod-b')
          end

          it 'overrides chart-level values' do
            expect(pod_template.env(container_name('pod-1'), 'sidekiq'))
              .to include('name' => 'EXTRA_ENV_VAR_C', 'value' => 'pod-c')

            expect(pod_template.env(container_name('pod-2'), 'sidekiq'))
              .to include('name' => 'EXTRA_ENV_VAR_C', 'value' => 'pod-c')
          end
        end
      end
    end
  end

  context 'when configuring memoryKiller' do
    let(:default_values) do
      {
        'certmanager-issuer' => { 'email' => 'test@example.com' }
      }
    end

    let(:hard_limit) do
      {
        'gitlab' => {
          'sidekiq' => {
            'memoryKiller' => {
              'hardLimitRss' => 9_000_000
            }
          }
        }
      }.deep_merge(default_values)
    end

    it 'uses defaults or uses chart global values' do
      t = HelmTemplate.new(default_values)

      expect(t.exit_code).to eq(0)
      expect(t.env(
        'Deployment/test-sidekiq-all-in-1-v1',
        'sidekiq')).to include(
          { 'name' => 'SIDEKIQ_DAEMON_MEMORY_KILLER', 'value' => '1' },
          { 'name' => 'SIDEKIQ_MEMORY_KILLER_CHECK_INTERVAL', 'value' => '3' },
          { 'name' => 'SIDEKIQ_MEMORY_KILLER_MAX_RSS', 'value' => '2000000' },
          { 'name' => 'SIDEKIQ_MEMORY_KILLER_GRACE_TIME', 'value' => '900' },
          { 'name' => 'SIDEKIQ_MEMORY_KILLER_SHUTDOWN_WAIT', 'value' => '30' }
        )

      expect(t.env(
        'Deployment/test-sidekiq-all-in-1-v1',
        'sidekiq')).not_to include(
          { 'name' => 'SIDEKIQ_MEMORY_KILLER_HARD_LIMIT_RSS' }
        )
    end

    it 'configures the hard limit' do
      t = HelmTemplate.new(hard_limit)

      expect(t.exit_code).to eq(0)
      expect(t.env(
        'Deployment/test-sidekiq-all-in-1-v1',
        'sidekiq')).to include(
          { 'name' => 'SIDEKIQ_MEMORY_KILLER_HARD_LIMIT_RSS', 'value' => '9000000' }
        )
    end

    context 'uses pod level configurations' do
      let(:pod_zero) do
        {
          'name' => 's0',
          'queues' => 'zero'
        }
      end

      let(:pod_one) do
        {
          'name' => 's1',
          'queues' => 'one',
          'memoryKiller' => {
            'maxRss' => 9
          }
        }
      end

      let(:minimum_multi_pod_values) do
        {
          'certmanager-issuer' => { 'email' => 'test@example.com' },
          'gitlab' => {
            'sidekiq' => {
              'pods' => [
                pod_zero
              ]
            }
          }
        }
      end

      let(:override_multi_pod_values) do
        {
          'certmanager-issuer' => { 'email' => 'test@example.com' },
          'gitlab' => {
            'sidekiq' => {
              'pods' => [
                pod_zero,
                pod_one
              ]
            }
          }
        }
      end

      it 'with the chart defaults' do
        t = HelmTemplate.new(minimum_multi_pod_values)

        expect(t.exit_code).to eq(0)
        expect(t.env(
          'Deployment/test-sidekiq-s0-v1',
          'sidekiq')).to include(
            { 'name' => 'SIDEKIQ_DAEMON_MEMORY_KILLER', 'value' => '1' },
            { 'name' => 'SIDEKIQ_MEMORY_KILLER_CHECK_INTERVAL', 'value' => '3' },
            { 'name' => 'SIDEKIQ_MEMORY_KILLER_MAX_RSS', 'value' => '2000000' },
            { 'name' => 'SIDEKIQ_MEMORY_KILLER_GRACE_TIME', 'value' => '900' },
            { 'name' => 'SIDEKIQ_MEMORY_KILLER_SHUTDOWN_WAIT', 'value' => '30' }
          )

        expect(t.env(
          'Deployment/test-sidekiq-s0-v1',
          'sidekiq')).not_to include(
            { 'name' => 'SIDEKIQ_MEMORY_KILLER_HARD_LIMIT_RSS' }
          )
      end

      it 'with pod overrides' do
        t = HelmTemplate.new(override_multi_pod_values)

        expect(t.exit_code).to eq(0)
        expect(t.env(
          'Deployment/test-sidekiq-s0-v1',
          'sidekiq')).not_to include(
            { 'name' => 'SIDEKIQ_MEMORY_KILLER_HARD_LIMIT_RSS' }
          )

        expect(t.env(
          'Deployment/test-sidekiq-s1-v1',
          'sidekiq')).to include(
            { 'name' => 'SIDEKIQ_MEMORY_KILLER_MAX_RSS', 'value' => '9' },
          )
      end
    end
  end
end
