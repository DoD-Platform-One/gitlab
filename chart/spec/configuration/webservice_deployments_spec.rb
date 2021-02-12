require 'spec_helper'
require 'helm_template_helper'
require 'yaml'
require 'hash_deep_merge'

describe 'Webservice Deployments configuration' do
  def item_key(kind, name)
    "#{kind}/test-webservice-#{name}"
  end

  let(:default_values) do
    { 'certmanager-issuer' => { 'email' => 'test@example.com' } }
  end

  context 'gitlab.webservice.deployments not set' do
    let(:chart_defaults) { HelmTemplate.new(default_values) }

    it 'templates successfully' do
      expect(chart_defaults.exit_code).to eq(0)
    end

    it 'creates only Deployment/test-webservice-default' do
      expect(chart_defaults.dig(item_key('Deployment', 'default'))).to be_truthy
      expect(chart_defaults.dig(item_key('Deployment', 'other'))).to be_falsey
    end
  end

  context 'gitlab.webservice.deployments has entries' do
    let(:deployments_values) do
      YAML.safe_load(%(
      gitlab:
        webservice:
          deployments:
            default:
              ingress:
                path: /
            api:
              ingress:
                path: /api
            internal:
               ingress:
                  path:
      )).deep_merge(default_values)
    end

    let(:chart_deployments) { HelmTemplate.new(deployments_values) }

    it 'creates resources expected for 3 entries, one without an Ingress' do
      expect(chart_deployments.exit_code).to eq(0)

      items = chart_deployments.resources_by_kind('Deployment').select { |key, _| key.start_with? "Deployment/test-webservice-" }
      expect(items.length).to eq(3)
      expect(items.dig(item_key('Deployment', 'default'))).to be_truthy
      expect(items.dig(item_key('Deployment', 'api'))).to be_truthy
      expect(items.dig(item_key('Deployment', 'internal'))).to be_truthy

      items = chart_deployments.resources_by_kind('PodDisruptionBudget').select { |key, _| key.start_with? "PodDisruptionBudget/test-webservice-" }
      expect(items.length).to eq(3)
      expect(items.dig(item_key('PodDisruptionBudget', 'default'))).to be_truthy
      expect(items.dig(item_key('PodDisruptionBudget', 'api'))).to be_truthy
      expect(items.dig(item_key('PodDisruptionBudget', 'internal'))).to be_truthy

      items = chart_deployments.resources_by_kind('HorizontalPodAutoscaler').select { |key, _| key.start_with? "HorizontalPodAutoscaler/test-webservice-" }
      expect(items.length).to eq(3)
      expect(items.dig(item_key('HorizontalPodAutoscaler', 'default'))).to be_truthy
      expect(items.dig(item_key('HorizontalPodAutoscaler', 'api'))).to be_truthy
      expect(items.dig(item_key('HorizontalPodAutoscaler', 'internal'))).to be_truthy

      items = chart_deployments.resources_by_kind('Service').select { |key, _| key.start_with? "Service/test-webservice-" }
      expect(items.length).to eq(3)
      expect(items.dig(item_key('Service', 'default'))).to be_truthy
      expect(items.dig(item_key('Service', 'api'))).to be_truthy
      expect(items.dig(item_key('Service', 'internal'))).to be_truthy

      items = chart_deployments.resources_by_kind('Ingress').select { |key, _| key.start_with? "Ingress/test-webservice-" }
      expect(items.length).to eq(2)
      expect(items.dig(item_key('Ingress', 'default'))).to be_truthy
      expect(items.dig(item_key('Ingress', 'api'))).to be_truthy

      items = chart_deployments.resources_by_kind('ConfigMap').select { |key, _| key.start_with? "ConfigMap/test-webservice" }
      expect(items.length).to eq(2)
      expect(items.dig('ConfigMap/test-webservice')).to be_truthy
      expect(items.dig(item_key('ConfigMap', 'tests'))).to be_truthy
    end
  end

  context 'deployments datamodel' do
    def env_value(name, value)
      { 'name' => name, 'value' => value.to_s }
    end

    let(:test_values) do
      YAML.safe_load(%(
      gitlab:
        webservice:
          deployments:
            test:
              ingress:
                path: /
      )).deep_merge(default_values)
    end

    let(:datamodel) { HelmTemplate.new(test_values) }

    context 'when no Ingress has "path: /"' do
      let(:test_values) do
        YAML.safe_load(%(
        gitlab:
          webservice:
            deployments:
              test:
                ingress:
                  path:
        )).deep_merge(default_values)
      end

      it 'template fails' do
        expect(datamodel.exit_code).not_to eq(0)
      end
    end

    context 'value inheritance and merging' do
      let(:test_values) do
        YAML.safe_load(%(
        global:
          extraEnv:
            GLOBAL: present
        gitlab:
          webservice:
            # "base" configuration
            minReplicas: 1
            maxReplicas: 2
            puma:
              disableWorkerKiller: true
            pdb:
              maxUnavailable: 0
            deployment:
              annotations:
                some: "thing"
            serviceLabels:
              some: "thing"
            podLabels:
              some: "thing"
            ingress:
              annotations:
                some: "thing"
            nodeSelector:
              workload: "webservice"
            tolerations:
              - key: "node_label"
                operator: "Equal"
                value: "true"
                effect: "NoSchedule"
            extraEnv:
              CHART: "present"
            # individual configurations
            deployments:
              a:
                ingress:
                  path: /
                deployment:
                  annotations:
                    thing: "one"
                nodeSelector: # disable nodeSelector
                tolerations: null # disable tolerations
              b:
                puma:
                  threads:
                    min: 3
                hpa:
                  minReplicas: 10
                  maxReplicas: 20
                nodeSelector: # replace nodeSelector
                  section: "b"
                tolerations: # specify tolerations
                  - key: "node_label"
                    operator: "Equal"
                    value: "true"
                    effect: "NoExecute"
                extraEnv:
                  DEPLOYMENT: "b"
              c:
                puma:
                  threads:
                    min: 2
                    max: 8
                  workerMaxMemory: 2048
                  disableWorkerKiller: false
                extraEnv:
                  DEPLOYMENT: "c"
                  CHART: "overridden"
        )).deep_merge(default_values)
      end

      it 'templates successfully' do
        expect(datamodel.exit_code).to eq(0)
      end

      context 'Puma settings' do
        it 'override only those set (int, string, bool)' do
          env_1 = datamodel.env(item_key('Deployment', 'a'), 'webservice')
          env_2 = datamodel.env(item_key('Deployment', 'b'), 'webservice')
          env_3 = datamodel.env(item_key('Deployment', 'c'), 'webservice')

          expect(env_1).to include(env_value('PUMA_THREADS_MIN', 4))
          expect(env_2).to include(env_value('PUMA_THREADS_MIN', 3))
          expect(env_3).to include(env_value('PUMA_THREADS_MIN', 2))

          expect(env_1).to include(env_value('PUMA_THREADS_MAX', 4))
          expect(env_2).to include(env_value('PUMA_THREADS_MAX', 4))
          expect(env_3).to include(env_value('PUMA_THREADS_MAX', 8))

          expect(env_1).to include(env_value('PUMA_WORKER_MAX_MEMORY', 1024))
          expect(env_2).to include(env_value('PUMA_WORKER_MAX_MEMORY', 1024))
          expect(env_3).to include(env_value('PUMA_WORKER_MAX_MEMORY', 2048))

          expect(env_1).to include(env_value('DISABLE_PUMA_WORKER_KILLER', true))
          expect(env_2).to include(env_value('DISABLE_PUMA_WORKER_KILLER', true))
          expect(env_3).to include(env_value('DISABLE_PUMA_WORKER_KILLER', false))
        end
      end

      context 'extraEnv settings (map)' do
        # deployment(X)/spec/template/spec/nodeSelector
        it 'inherits when not present' do
          env_1 = datamodel.env(item_key('Deployment', 'a'), 'webservice')
          expect(env_1).to include(env_value('GLOBAL', 'present'))
          expect(env_1).to include(env_value('CHART', 'present'))
          expect(env_1).not_to include(env_value('DEPLOYMENT', 'a'))
        end

        it 'merges when present' do
          env_1 = datamodel.env(item_key('Deployment', 'b'), 'webservice')
          expect(env_1).to include(env_value('GLOBAL', 'present'))
          expect(env_1).to include(env_value('CHART', 'present'))
          expect(env_1).to include(env_value('DEPLOYMENT', 'b'))
        end

        it 'override when present' do
          env_1 = datamodel.env(item_key('Deployment', 'c'), 'webservice')
          expect(env_1).to include(env_value('GLOBAL', 'present'))
          expect(env_1).to include(env_value('CHART', 'overridden'))
          expect(env_1).to include(env_value('DEPLOYMENT', 'c'))
        end
      end

      context 'nodeSelector settings (map)' do
        # deployment(X)/spec/template/spec/nodeSelector
        it 'removes when nil' do
          pod_template_spec = datamodel.dig(item_key('Deployment', 'a'), 'spec', 'template', 'spec')
          expect(pod_template_spec['nodeSelector']).to be_falsey
        end

        it 'merges when present' do
          pod_template_spec = datamodel.dig(item_key('Deployment', 'b'), 'spec', 'template', 'spec')
          expect(pod_template_spec['nodeSelector']).to be_truthy
          expect(pod_template_spec['nodeSelector']).to eql({ 'section' => 'b', 'workload' => 'webservice' })
        end

        it 'inherits when not present' do
          expect(datamodel.exit_code).to eq(0)
          pod_template_spec = datamodel.dig(item_key('Deployment', 'c'), 'spec', 'template', 'spec')

          expect(pod_template_spec['nodeSelector']).to be_truthy
          expect(pod_template_spec['nodeSelector']).to eql({ 'workload' => 'webservice' })
        end
      end

      context 'toleration settings (array)' do
        # deployment(X)/spec/template/spec/tolerations
        it 'removes when nil' do
          pod_template_spec = datamodel.dig(item_key('Deployment', 'a'), 'spec', 'template', 'spec')
          expect(pod_template_spec['tolerations']).to be_falsey
        end

        it 'overwrites when present' do
          pod_template_spec = datamodel.dig(item_key('Deployment', 'b'), 'spec', 'template', 'spec')
          expect(pod_template_spec['tolerations']).to be_truthy
          expect(pod_template_spec['tolerations'][0]['effect']).to eql("NoExecute")
        end

        it 'inherits when not present' do
          expect(datamodel.exit_code).to eq(0)
          pod_template_spec = datamodel.dig(item_key('Deployment', 'c'), 'spec', 'template', 'spec')

          expect(pod_template_spec['tolerations']).to be_truthy
          expect(pod_template_spec['tolerations'][0]['effect']).to eql("NoSchedule")
        end
      end
    end
  end
end
