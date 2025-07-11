require 'spec_helper'
require 'helm_template_helper'
require 'yaml'
require 'hash_deep_merge'

describe 'gitlab.yml.erb configuration' do
  let(:default_values) do
    HelmTemplate.defaults
  end

  context 'when CSP is disabled' do
    it 'does not populate the gitlab.yml.erb' do
      t = HelmTemplate.new(default_values)
      expect(t.dig(
        'ConfigMap/test-webservice',
        'data',
        'gitlab.yml.erb'
      )).not_to include('content_security_policy')
    end
  end

  context 'when CSP is enabled' do
    let(:required_values) do
      YAML.safe_load(%(
        global:
          appConfig:
            contentSecurityPolicy:
              enabled: true
              report_only: false
              directives:
                connect_src: "'self'"
                frame_ancestors: "'self'"
                frame_src: "'self'"
                img_src: "* data: blob:"
                object_src: "'none'"
                script_src: "'self' 'unsafe-inline' 'unsafe-eval'"
                style_src: "'self'"
      )).deep_merge!(default_values)
    end

    let(:no_directives) do
      YAML.safe_load(%(
        global:
          appConfig:
            contentSecurityPolicy:
              enabled: true
      )).deep_merge!(default_values)
    end

    it 'populates the gitlab.yml.erb' do
      t = HelmTemplate.new(required_values)
      expect(t.dig(
        'ConfigMap/test-webservice',
        'data',
        'gitlab.yml.erb'
      )).to include('content_security_policy')
    end

    it 'populates the gitlab.yml.erb even when directives are not set' do
      t = HelmTemplate.new(no_directives)
      expect(t.dig(
        'ConfigMap/test-webservice',
        'data',
        'gitlab.yml.erb'
      )).to include('content_security_policy')
    end
  end

  context 'matomoDisableCookies' do
    let(:required_values) do
      YAML.safe_load(%(
        global:
          appConfig:
            extra:
              matomoDisableCookies: #{value}
      )).deep_merge!(default_values)
    end

    context 'when true' do
      let(:value) { true }

      it 'populates the gitlab.yml.erb with true' do
        t = HelmTemplate.new(required_values)
        expect(t.dig(
          'ConfigMap/test-webservice',
          'data',
          'gitlab.yml.erb'
        )).to include('matomo_disable_cookies: true')
      end
    end

    context 'when false' do
      let(:value) { false }

      it 'does not populate the gitlab.yml.erb' do
        t = HelmTemplate.new(required_values)

        expect(t.exit_code).to eq(0)
        expect(t.dig(
          'ConfigMap/test-webservice',
          'data',
          'gitlab.yml.erb'
        )).not_to include('matomo_disable_cookies')
      end
    end

    context 'when nil' do
      let(:value) { nil }

      it 'does not populate the gitlab.yml.erb' do
        t = HelmTemplate.new(required_values)

        expect(t.exit_code).to eq(0)
        expect(t.dig(
          'ConfigMap/test-webservice',
          'data',
          'gitlab.yml.erb'
        )).not_to include('matomo_disable_cookies')
      end
    end
  end

  context 'oneTrustId' do
    let(:required_values) do
      YAML.safe_load(%(
        global:
          appConfig:
            extra:
              oneTrustId: #{value}
      )).deep_merge!(default_values)
    end

    context 'when configured' do
      let(:value) { 'foo' }

      it 'populates the gitlab.yml.erb with id' do
        t = HelmTemplate.new(required_values)
        expect(t.dig(
          'ConfigMap/test-webservice',
          'data',
          'gitlab.yml.erb'
        )).to include('one_trust_id: "foo"')
      end
    end

    context 'when not configured' do
      let(:value) { nil }

      it 'does not populate the gitlab.yml.erb' do
        t = HelmTemplate.new(required_values)

        expect(t.exit_code).to eq(0)
        expect(t.dig(
          'ConfigMap/test-webservice',
          'data',
          'gitlab.yml.erb'
        )).not_to include('one_trust_id')
      end
    end
  end

  context 'bizible' do
    let(:required_values) do
      YAML.safe_load(%(
        global:
          appConfig:
            extra:
              bizible: #{value}
      )).deep_merge!(default_values)
    end

    context 'when true' do
      let(:value) { true }

      it 'populates the gitlab.yml.erb with true' do
        t = HelmTemplate.new(required_values)
        expect(t.dig(
          'ConfigMap/test-webservice',
          'data',
          'gitlab.yml.erb'
        )).to include('bizible: true')
      end
    end

    context 'when false' do
      let(:value) { false }

      it 'does not populate the gitlab.yml.erb' do
        t = HelmTemplate.new(required_values)

        expect(t.exit_code).to eq(0)
        expect(t.dig(
          'ConfigMap/test-webservice',
          'data',
          'gitlab.yml.erb'
        )).not_to include('bizible')
      end
    end

    context 'when nil' do
      let(:value) { nil }

      it 'does not populate the gitlab.yml.erb' do
        t = HelmTemplate.new(required_values)

        expect(t.exit_code).to eq(0)
        expect(t.dig(
          'ConfigMap/test-webservice',
          'data',
          'gitlab.yml.erb'
        )).not_to include('bizible')
      end
    end
  end

  context 'cdnHost' do
    let(:required_values) do
      YAML.safe_load(%(
        global:
          appConfig:
            cdnHost: #{value}
      )).deep_merge!(default_values)
    end

    context 'when configured' do
      let(:value) { 'https://cdn.example.com' }

      it 'populates the gitlab.yml.erb with cdn_host' do
        t = HelmTemplate.new(required_values)
        expect(t.dig(
          'ConfigMap/test-webservice',
          'data',
          'gitlab.yml.erb'
        )).to include('cdn_host: "https://cdn.example.com"')
      end
    end

    context 'when not configured' do
      let(:value) { nil }

      it 'does not populate the gitlab.yml.erb' do
        t = HelmTemplate.new(required_values)

        expect(t.exit_code).to eq(0)
        expect(t.dig(
          'ConfigMap/test-webservice',
          'data',
          'gitlab.yml.erb'
        )).not_to include('cdn_host')
      end
    end
  end

  context 'sidekiq.logging on web' do
    it 'populates the gitlab.yml.erb' do
      t = HelmTemplate.new(default_values)

      expect(t.stderr).to eq("")
      expect(t.exit_code).to eq(0)

      expect(YAML.safe_load(
        t.dig(
          'ConfigMap/test-webservice',
          'data',
          'gitlab.yml.erb'
        )
      )['production']).to include(YAML.safe_load(%(
        sidekiq:
          log_format: "json"
      )))
    end
  end

  context 'sidekiq.routingRules on web' do
    let(:required_values) do
      value.deep_merge!(default_values)
    end

    context 'when empty array' do
      let(:value) do
        YAML.safe_load(%(
          global:
            appConfig:
              sidekiq:
                routingRules: []
        ))
      end

      it 'does not populate the gitlab.yml.erb' do
        t = HelmTemplate.new(required_values)

        expect(t.stderr).to be_empty
        expect(t.exit_code).to eq(0)
        expect(YAML.safe_load(
          t.dig(
            'ConfigMap/test-webservice',
            'data',
            'gitlab.yml.erb'
          )
        )['production']).to have_key('sidekiq')
      end
    end

    context 'when an array of tuples' do
      let(:value) do
        YAML.safe_load(%(
          global:
            appConfig:
              sidekiq:
                log_format: "json"
                routingRules:
                  - ["resource_boundary=cpu", "cpu_boundary"]
                  - ["feature_category=pages", null]
                  - ["feature_category=search", '']
                  - ["feature_category=memory|resource_boundary=memory", 'memory']
                  - ["*", "default", "default"]
        ))
      end

      it 'populates the gitlab.yml.erb with corresponding array' do
        t = HelmTemplate.new(required_values)

        expect(t.exit_code).to eq(0)
        expect(YAML.safe_load(
          t.dig(
            'ConfigMap/test-webservice',
            'data',
            'gitlab.yml.erb'
          )
        )['production']).to include(YAML.safe_load(%(
          sidekiq:
            log_format: "json"
            routing_rules:
              - ["resource_boundary=cpu","cpu_boundary"]
              - ["feature_category=pages",null]
              - ["feature_category=search",""]
              - ["feature_category=memory|resource_boundary=memory","memory"]
              - ["*","default", "default"]
        )))
      end
    end
  end

  context 'sidekiq.routingRules on Sidekiq' do
    let(:required_values) do
      value.deep_merge!(default_values)
    end

    context 'when empty array' do
      let(:value) do
        YAML.safe_load(%(
          global:
            appConfig:
              sidekiq:
                routingRules: []
        ))
      end

      it 'does not populate the gitlab.yml.erb' do
        t = HelmTemplate.new(required_values)

        expect(t.stderr).to be_empty
        expect(t.exit_code).to eq(0)
        expect(YAML.safe_load(
          t.dig(
            'ConfigMap/test-sidekiq',
            'data',
            'gitlab.yml.erb'
          )
        )['production']['sidekiq']).to include(YAML.safe_load(%(
          log_format: "json"
        )))
      end
    end

    context 'when an array of tuples' do
      let(:value) do
        YAML.safe_load(%(
          global:
            appConfig:
              sidekiq:
                routingRules:
                  - ["resource_boundary=cpu", "cpu_boundary"]
                  - ["feature_category=pages", null]
                  - ["feature_category=search", '']
                  - ["feature_category=memory|resource_boundary=memory", 'memory']
                  - ["*", "default", "default"]
        ))
      end

      it 'populates the gitlab.yml.erb with corresponding array' do
        t = HelmTemplate.new(required_values)

        expect(t.exit_code).to eq(0)
        expect(YAML.safe_load(
          t.dig(
            'ConfigMap/test-sidekiq',
            'data',
            'gitlab.yml.erb'
          )
        )['production']['sidekiq']).to include(YAML.safe_load(%(
          log_format: "json"
          routing_rules:
            - ["resource_boundary=cpu","cpu_boundary"]
            - ["feature_category=pages",null]
            - ["feature_category=search",""]
            - ["feature_category=memory|resource_boundary=memory","memory"]
            - ["*","default", "default"]
        )))
      end
    end
  end

  context 'GraphQL timeout' do
    let(:values) { HelmTemplate.defaults }
    let(:template) { HelmTemplate.new(values) }
    let(:renderedGraphQlTimeout) do
      YAML.safe_load(
        template.dig('ConfigMap/test-sidekiq', 'data', 'gitlab.yml.erb')
      )['production']['gitlab']['graphql_timeout']
    end

    context 'is not configured' do
      it 'populates no value to gitlab.yml.erb' do
        expect(renderedGraphQlTimeout).to eq(nil)
      end
    end

    context 'not configured' do
      let(:values) do
        HelmTemplate.with_defaults(%(
        global:
          appConfig:
            graphQlTimeout: 120
        ))
      end

      it 'populates the value to gitlab.yml.erb' do
        expect(renderedGraphQlTimeout).to eq(120)
      end
    end
  end

  context 'OIDC provider token expiration' do
    it 'populates the gitlab.yml.erb' do
      t = HelmTemplate.new(default_values)

      expect(t.stderr).to eq("")
      expect(t.exit_code).to eq(0)

      expect(YAML.safe_load(
        t.dig(
          'ConfigMap/test-webservice',
          'data',
          'gitlab.yml.erb'
        )
      )['production']).to include(YAML.safe_load(%(
        oidc_provider:
          openid_id_token_expire_in_seconds: 120
      )))
    end
  end

  context 'OpenBao configuration' do
    context 'Not present when disabled' do
      it 'populates gitlab.yml.erb without OpenBao section' do
        t = HelmTemplate.new(default_values)

        expect(t.stderr).to eq("")
        expect(t.exit_code).to eq(0)

        expect(YAML.safe_load(
          t.dig(
            'ConfigMap/test-webservice',
            'data',
            'gitlab.yml.erb'
          )
        )['production']).not_to have_key('openbao')
      end
    end

    context 'When enabled' do
      it 'populates URL from global.hosts pattern' do
        t = HelmTemplate.new(HelmTemplate.with_defaults(%(
          global:
            openbao:
              enabled: true
        )))

        expect(t.stderr).to eq("")
        expect(t.exit_code).to eq(0)

        expect(YAML.safe_load(
          t.dig(
            'ConfigMap/test-webservice',
            'data',
            'gitlab.yml.erb'
          )
        )['production']).to include(
          'openbao' => { 'url' => 'https://openbao.example.com' }
        )

        expect(YAML.safe_load(
          t.dig(
            'ConfigMap/test-sidekiq',
            'data',
            'gitlab.yml.erb'
          )
        )['production']).to include(
          'openbao' => { 'url' => 'https://openbao.example.com' }
        )
      end

      it 'populates URL from openbao.host' do
        t = HelmTemplate.new(HelmTemplate.with_defaults(%(
          global:
            openbao:
              enabled: true
              host: 'openbao.external'
        )))

        expect(t.stderr).to eq("")
        expect(t.exit_code).to eq(0)

        expect(YAML.safe_load(
          t.dig(
            'ConfigMap/test-webservice',
            'data',
            'gitlab.yml.erb'
          )
        )['production']).to include(
          'openbao' => { 'url' => 'https://openbao.external' }
        )

        expect(YAML.safe_load(
          t.dig(
            'ConfigMap/test-sidekiq',
            'data',
            'gitlab.yml.erb'
          )
        )['production']).to include(
          'openbao' => { 'url' => 'https://openbao.external' }
        )
      end

      it 'populates URL from openbao.url when specified' do
        t = HelmTemplate.new(HelmTemplate.with_defaults(%(
          global:
            openbao:
              enabled: true
              url: http://insecure.openbao.test
        )))

        expect(t.stderr).to eq("")
        expect(t.exit_code).to eq(0)

        expect(YAML.safe_load(
          t.dig(
            'ConfigMap/test-webservice',
            'data',
            'gitlab.yml.erb'
          )
        )['production']).to include(
          'openbao' => { 'url' => 'http://insecure.openbao.test' }
        )

        expect(YAML.safe_load(
          t.dig(
            'ConfigMap/test-sidekiq',
            'data',
            'gitlab.yml.erb'
          )
        )['production']).to include(
          'openbao' => { 'url' => 'http://insecure.openbao.test' }
        )
      end
    end
  end
end
