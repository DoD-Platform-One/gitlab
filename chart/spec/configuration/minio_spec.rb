require 'spec_helper'
require 'helm_template_helper'
require 'yaml'
require 'hash_deep_merge'

describe 'MinIO configuration' do
  context 'When customer provides additional persistence annotations' do
    let(:values) do
      HelmTemplate.with_defaults(%(
        minio:
          persistence:
            annotations:
              "helm.sh/resource-policy": keep
      ))
    end

    it 'Populates the additional annotations in the expected manner' do
      t = HelmTemplate.new(values)
      expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"
      expect(t.annotations('PersistentVolumeClaim/test-minio')).to include('helm.sh/resource-policy' => 'keep')
    end
  end
end
