require 'active_support'
require 'active_support/core_ext/object/blank'
require 'open-uri'
require 'base64'
require 'fugit'
require 'api_helper'

module Gitlab
  def self.included(klass)
    klass.extend(TestHelper)
  end

  module TestHelper
    KUBE_TIMEOUT_DEFAULT = '2m'.freeze

    def kube_timeout_parse(variable)
      timeout = ENV[variable] || KUBE_TIMEOUT_DEFAULT

      # Check the format, simplify.
      duration = Fugit::Duration.parse(timeout)

      # If invalid, return the error.
      raise "kube_timeout_parse: #{variable}: invalid duration '#{timeout}'" if duration.nil?

      duration.deflate.to_plain_s
    end

    def full_command(cmd, env = {})
      "kubectl exec -it #{pod_name} -- env #{env_hash_to_str(env)} #{cmd}"
    end

    def gitaly_full_command(cmd)
      "kubectl exec -it #{gitaly_pod_name} -- #{cmd}"
    end

    def env_hash_to_str(env)
      env.map { |key, value| "#{key}=#{value}" }.join(' ')
    end

    def wait_until_app_ready(retries:30, interval: 10)
      begin
        URI.parse(gitlab_url).read
      rescue
        sleep interval
        retries -= 1
        retry if retries > 0
        raise
      end
    end

    def wait(max: 60, time: 0.1, reload: true)
      start = Time.now

      while Time.now - start < max
        result = yield
        return result if result

        sleep(time)

        page.refresh if reload
      end

      false
    end

    def set_admin_token
      cmd = full_command(
        "gitlab-rails runner \"" \
        "unless PersonalAccessToken.find_by_token('#{ENV['GITLAB_ADMIN_TOKEN']}');" \
        "  user = User.find_by_username('root');" \
        "  token = user.personal_access_tokens.create(scopes: ['api'], name: 'Token for running specs', expires_at: 365.days.from_now, organization: Organizations::Organization.default_organization);" \
        "  token.set_token('#{ENV['GITLAB_ADMIN_TOKEN']}');" \
        "  token.save!;" \
        "end;" \
        "\""
      )
      stdout, status = Open3.capture2e(cmd)
      return [stdout, status]
    end

    def gitlab_url
      protocol = ENV['PROTOCOL'] || 'https'
      instance_url = ENV['GITLAB_URL'] || "gitlab.#{ENV['GITLAB_ROOT_DOMAIN']}"
      "#{protocol}://#{instance_url}"
    end

    def registry_url
      ENV['REGISTRY_URL'] || "registry.#{ENV['GITLAB_ROOT_DOMAIN']}"
    end

    def gitaly_purge_storage
      cmd = gitaly_full_command("find /home/git/repositories/ -mindepth 1 -maxdepth 1 -exec rm -rf {} \\;")
      stdout, status = Open3.capture2e(cmd)

      return [stdout, status]
    end

    def get_hpa_minreplicas(app)
      filters = "app=#{app}"

      if ENV['RELEASE_NAME']
        filters="#{filters},release=#{ENV['RELEASE_NAME']}"
      end

      stdout, status = Open3.capture2e("kubectl get hpa -l #{filters} -ojsonpath='{.items[0].spec.minReplicas}' ")
      return [stdout, status]
    end

    def scale_deployment(app, replicas)
      filters = "app=#{app}"

      if ENV['RELEASE_NAME']
        filters="#{filters},release=#{ENV['RELEASE_NAME']}"
      end

      puts "Scaling Deployment ('#{filters}') to #{replicas}."

      stdout, status = Open3.capture2e("kubectl scale deployment -l #{filters} --replicas=#{replicas}  --timeout=#{kube_timeout_parse('KUBE_SCALE_TIMEOUT')}")
      return [stdout, status]
    end

    def scale_rails_down
      %w[webservice sidekiq].each do |app|
        stdout, status = scale_deployment(app, 0)
        raise stdout unless status.success?
      end
    end

    def scale_rails_up
      %w[webservice sidekiq].each do |app|
        replicas, status = get_hpa_minreplicas(app)
        raise replicas unless status.success?

        stdout, status = scale_deployment(app, replicas)
        raise stdout unless status.success?
      end
    end

    def wait_for_rails_rollout
      wait_for_rollout(type: "deployment", filters: "app in (webservice, sidekiq)")
    end

    def wait_for_runner_rollout
      wait_for_rollout(type: "deployment", filters: "app=#{runner_app_label}")
    end

    def wait_for_rollout(type: nil, filters: nil)
      raise ArgumentError, "Must supply both 'type' and 'filters'" if type.nil? || filters.nil?

      if ENV['RELEASE_NAME']
        filters="#{filters},release=#{ENV['RELEASE_NAME']}"
      end

      cmd = "kubectl rollout status #{type} -l'#{filters}' --timeout=#{kube_timeout_parse('KUBE_ROLLOUT_TIMEOUT')}"
      puts "Executing in Namespace #{ENV['KUBE_NAMESPACE']}: #{cmd}"
      stdout, status = Open3.capture2e(cmd)
      raise stdout unless status.success?
    end

    def wait_for_runner_contact(retries: 5, interval: 30)
      uri = "runners/all?status=online"
      retries.times do
        response = ApiHelper.invoke_get_request(uri)

        if response.empty?
          sleep(interval)
          next
        end

        return
      end
      raise 'No Runner online'
    end

    def restore_from_backup(skip: [])
      skip_flags=''

      [skip].flatten.each do |skipped|
        skip_flags += " --skip #{skipped}"
      end

      cmd = full_command("backup-utility --restore -t #{backup_prefix} #{skip_flags}", { GITLAB_ASSUME_YES: "1" })
      stdout, status = Open3.capture2e(cmd)

      return [stdout, status]
    end

    def backup_instance
      cmd = full_command("backup-utility -t #{backup_prefix}", { GITLAB_ASSUME_YES: "1" })
      stdout, status = Open3.capture2e(cmd)

      return [stdout, status]
    end

    # Enable legacy runner registration.
    # CI/QA testing needs to migrate to the new runner registration workflow by 18.0.
    # https://docs.gitlab.com/administration/settings/continuous_integration/#allow-runner-registration-tokens
    def enable_legacy_runner_registration
      cmd = full_command(
        "gitlab-rails runner \"" \
        "settings = ApplicationSetting.current_without_cache; " \
        "settings.update_columns(allow_runner_registration_token: true); " \
        "settings.save!; " \
        "\""
      )

      stdout, status = Open3.capture2e(cmd)
      return [stdout, status]
    end

    def wait_for_dependencies
      cmd = full_command("/scripts/wait-for-deps")

      stdout, status = Open3.capture2e(cmd)
      return [stdout, status]
    end

    def find_pod_name(filters)
      if ENV['RELEASE_NAME']
        filters="#{filters},release=#{ENV['RELEASE_NAME']}"
      end

      `kubectl get pod -l #{filters} --field-selector=status.phase=Running -o jsonpath="{.items[0].metadata.name}"`
    end

    def pod_name
      filters = 'app=toolbox'

      @pod ||= find_pod_name(filters)
    end

    def gitaly_pod_name
      filters = 'app=gitaly'

      @gitaly_pod ||= find_pod_name(filters)
    end

    def runner_registration_token
      @runner_registration_token ||= Base64.decode64(
        IO.popen(%W[kubectl get secret -o jsonpath="{.data.runner-registration-token}" -- #{ENV['RELEASE_NAME']}-gitlab-runner-secret], &:read)
      )
    end

    def backup_prefix
      'test-backup'
    end

    def runner_app_label
      release = ENV['RELEASE_NAME'] || 'gitlab'
      "#{release}-gitlab-runner"
    end
  end
end
