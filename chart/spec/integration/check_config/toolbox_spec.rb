require 'spec_helper'
require 'check_config_helper'
require 'hash_deep_merge'

describe 'checkConfig toolbox' do
  describe 'gitaly.toolbox.replicas' do
    let(:success_values) do
      YAML.safe_load(%(
        gitlab:
          toolbox:
            replicas: 1
            persistence:
              enabled: true
      )).deep_merge!(default_required_values)
    end

    let(:error_values) do
      YAML.safe_load(%(
        gitlab:
          toolbox:
            replicas: 2
            persistence:
              enabled: true
      )).deep_merge!(default_required_values)
    end

    let(:error_output) { 'more than 1 replica, but also with a PersistentVolumeClaim' }

    include_examples 'config validation',
                     success_description: 'when toolbox has persistence enabled and one replica',
                     error_description: 'when toolbox has persistence enabled and more than one replica'
  end

  describe 'gitlab.toolbox.backups.objectStorage.config.secret' do
    describe 'gitlab.toolbox.enabled (the default value)' do
      let(:success_values) do
        YAML.safe_load(%(
          gitlab:
            toolbox:
              enabled: true
              backups:
                objectStorage:
                  config:
                    secret: s3cmd-config
                    key: config
        )).deep_merge!(default_required_values)
      end

      let(:error_values) do
        YAML.safe_load(%(
          gitlab:
            toolbox:
              enabled: true
              backups:
                objectStorage:
                  config:
                    # secret: s3cmd-config
                    key: config
        )).deep_merge!(default_required_values)
      end

      let(:error_output) { 'A valid object storage config secret is needed for backups.' }

      include_examples 'config validation',
                       success_description: 'when toolbox has a valid object storage backup secret configured',
                       error_description: 'when toolbox does not have a valid object storage backup secret configured'

      context 'with Google Cloud Storage backend' do
        let(:success_values) do
          YAML.safe_load(%(
            gitlab:
              toolbox:
                enabled: true
                backups:
                  objectStorage:
                    backend: gcs
                    config:
                      # secret: s3cmd-config
                      key: config
          )).deep_merge!(default_required_values)
        end

        include_examples 'config validation',
                         success_description: 'when toolbox uses GCS for backup with no secret configured'
      end
    end

    describe 'gitlab.toolbox.enabled (set to false)' do
      let(:success_values) do
        YAML.safe_load(%(
          gitlab:
            toolbox:
              enabled: false
              backups:
                objectStorage:
                  config:
                    # secret: s3cmd-config
                    key: config
        )).deep_merge!(default_required_values)
      end

      include_examples 'config validation',
                       success_description: 'when toolbox is disabled and does not have a valid object storage backup secret configured'
    end
  end
end
