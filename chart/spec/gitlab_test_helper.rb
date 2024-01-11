require 'active_support'
require 'open-uri'
require 'base64'
require 'fugit'

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

    def sign_in
      # DRY CSS selector for finding the user avatar
      qa_avatar_selector = 'img[data-testid="user-avatar-content"]'

      visit '/users/sign_in'

      # Give time for the app to fully load
      wait(max: 600, time: 3) do
        has_css?('.login-page') || has_css?(qa_avatar_selector)
      end

      # Return if already signed in
      return if has_selector?(qa_avatar_selector)
      raise 'GITLAB_PASSWORD environment variable not set' if ENV['GITLAB_PASSWORD'].blank?

      # Operate specifically within the user login form, avoiding registation form
      within('div#login-pane') do
        fill_in 'Username or primary email', with: 'root'
        fill_in 'Password', with: ENV['GITLAB_PASSWORD']
      end
      click_button 'Sign in'

      # Check the login was a success
      wait(reload: false) do
        has_current_path?('/', ignore_query: true) && has_css?(qa_avatar_selector)
      end

      expect(page).to have_current_path('/', ignore_query: true)
      expect(page).to have_selector(qa_avatar_selector)
    end

    def enforce_root_password(password)
      cmd = full_command("gitlab-rails runner \"user = User.find(1); user.user_type = :human ; user.password='#{password}'; user.password_confirmation='#{password}'; user.save!\"")

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

    def wait_for_rollout(type: nil, filters: nil)
      raise ArgumentError, "Must supply both 'type' and 'filters'" if type.nil? || filters.nil?

      if ENV['RELEASE_NAME']
        filters="#{filters},release=#{ENV['RELEASE_NAME']}"
      end

      stdout, status = Open3.capture2e("kubectl rollout status #{type} -l'#{filters}' --timeout=#{kube_timeout_parse('KUBE_ROLLOUT_TIMEOUT')}")
      raise stdout unless status.success?
    end

    def restore_from_backup(skip: [])
      skip_flags=''

      [skip].flatten.each do |skipped|
        skip_flags += " --skip #{skipped}"
      end

      cmd = full_command("backup-utility --restore -t #{original_backup_prefix} #{skip_flags}", { GITLAB_ASSUME_YES: "1" })
      stdout, status = Open3.capture2e(cmd)

      return [stdout, status]
    end

    def backup_instance
      cmd = full_command("backup-utility -t #{new_backup_prefix}", { GITLAB_ASSUME_YES: "1" })
      stdout, status = Open3.capture2e(cmd)

      return [stdout, status]
    end

    def run_migrations
      cmd = full_command("gitlab-rake db:migrate")

      stdout, status = Open3.capture2e(cmd)
      return [stdout, status]
    end

    def restart_gitlab_runner
      release = ENV['RELEASE_NAME'] || 'gitlab'
      filters = "app=#{release}-gitlab-runner"

      if ENV['RELEASE_NAME']
        filters="#{filters},release=#{ENV['RELEASE_NAME']}"
      end

      stdout, status = Open3.capture2e("kubectl delete pods -l #{filters} --wait=true")
      return [stdout, status]
    end

    def set_runner_token
      cmd = full_command(
        "gitlab-rails runner \"" \
        "settings = ApplicationSetting.current_without_cache; " \
        "settings.update_columns(encrypted_customers_dot_jwt_signing_key_iv: nil, encrypted_customers_dot_jwt_signing_key: nil, encrypted_ci_jwt_signing_key_iv: nil, encrypted_ci_jwt_signing_key: nil, error_tracking_access_token_encrypted: nil); " \
        "settings.set_runners_registration_token('#{runner_registration_token}'); " \
        "settings.save!; " \
        "Ci::Runner.delete_all" \
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

    def object_storage
      return @object_storage if @object_storage

      if ENV['S3_CONFIG_PATH']
        s3_access_key = File.read("#{ENV['S3_CONFIG_PATH']}/accesskey")
        s3_secret_key = File.read("#{ENV['S3_CONFIG_PATH']}/secretkey")
      end

      s3_access_key ||= ENV['S3_ACCESS_KEY']
      s3_secret_key ||= ENV['S3_SECRET_KEY']

      conf = {
        region: ENV['S3_REGION'] || 'us-east-1',
        access_key_id: s3_access_key,
        secret_access_key: s3_secret_key,
        endpoint: ENV['S3_ENDPOINT'],
        force_path_style: true
      }

      @object_storage = Aws::S3::Client.new(conf)
    end

    def ensure_backups_on_object_storage
      file = URI.open(original_backup_source_url).read
      object_storage.put_object(
        bucket: 'gitlab-backups',
        key: original_backup_name,
        body: file
      )
      puts "Uploaded #{original_backup_name}"
    end

    def original_backup_prefix
      ENV['TEST_BACKUP_PREFIX']
    end

    def original_backup_name
      "#{original_backup_prefix}_gitlab_backup.tar"
    end

    def original_backup_source_url
      "https://storage.googleapis.com/gitlab-charts-ci/test-backups/#{original_backup_name}"
    end

    def new_backup_prefix
      'test-backup'
    end

    def new_backup_name
      "#{new_backup_prefix}_gitlab_backup.tar"
    end
  end
end
