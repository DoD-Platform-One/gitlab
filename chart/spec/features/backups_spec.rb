require 'spec_helper'
require 'open-uri'

describe "Restoring a backup" do
  before(:all) do
    stdout, status = wait_for_dependencies
    fail stdout unless status.success?

    wait_until_app_ready
    ensure_backups_on_object_storage

    stdout, status = gitaly_purge_storage
    fail stdout unless status.success?

    stdout, status = restore_from_backup(skip: 'repositories')
    fail stdout unless status.success?

    # scale the Rails deployments to 0
    scale_rails_down
    # wait for rollout to complete (change in replicas)
    wait_for_rails_rollout

    # We run migrations once early to get the db into a place where we can set the runner token and restore repos
    # Ignore errors, we will run the migrations again after the token
    stdout, status = run_migrations
    warn "WARNING: Migrations did not succeed:\n#{stdout}" unless status.success?

    stdout, status = restore_from_backup(skip: 'db')
    fail stdout unless status.success?

    stdout, status = set_runner_token
    fail stdout unless status.success?

    stdout, status = run_migrations
    fail stdout unless status.success?

    stdout, status = enforce_root_password(ENV['GITLAB_PASSWORD']) if ENV['GITLAB_PASSWORD']
    fail stdout unless status.success?

    stdout, status = set_admin_token
    fail stdout unless status.success?

    # scale the Rails code deployments up
    scale_rails_up
    # wait for rollout to complete (change in replicas)
    wait_for_rails_rollout

    # Wait for the site to come up after the restore/migrations
    wait_until_app_ready

    # Have the gitlab-runner re-register after the restore
    restart_gitlab_runner
    wait_for_runner_rollout
  end

  describe 'Restored gitlab instance' do

    it 'Project testproject1 should exist' do
      uri = "search?scope=projects&search=testproject1"
      response = ApiHelper.invoke_get_request(uri)
      expect(response.collect { |item| item["name_with_namespace"] }).to have_content 'Administrator / testproject1'
    end

    it 'Issue under testproject1 should exist' do
      uri = "search?scope=issues&search=test"
      response = ApiHelper.invoke_get_request(uri)
      expect(response.collect { |item| item["title"] }).to have_content 'This is a test issue with attachment'
    end

    it 'Test project repository should have Dockerfile' do
      uri = "projects/1/repository/tree"
      response = ApiHelper.invoke_get_request(uri)
      expect(response.collect { |item| item["name"] })
        .to have_content('Dockerfile')
    end

    it 'Should have at least 1 runner registered' do
      uri = "runners/all"
      response = ApiHelper.invoke_get_request(uri)
      expect(response.collect { |item| item["status"] }).to have_content('online', minimum: 1)
      expect(response.collect { |item| item["online"] }).to have_content('true', minimum: 1)
    end

    it 'Issue contains attachment in the description' do
      uri = "issues"
      response = ApiHelper.invoke_get_request(uri)
      expect(response.collect { |item| item["description"] }).to have_content '![Screen_Shot_2018-05-01_at_2.53.34_PM](/uploads/90701344e9ebb53fa9ebac83d43afdcc/Screen_Shot_2018-05-01_at_2.53.34_PM.png)'
    end

    it 'Could pull image from registry' do
      stdout, status = Open3.capture2e("docker login #{registry_url} --username root --password #{ENV['GITLAB_PASSWORD']}")
      expect(status.success?).to be(true), "Login failed: #{stdout}"

      stdout, status = Open3.capture2e("docker pull #{registry_url}/root/testproject1/master:d88102fe7cf105b72643ecb9baf41a03070c9f1b")
      expect(status.success?).to be(true), "Pulling image failed: #{stdout}"
    end

  end

  describe 'Backups' do
    it 'Should be able to backup an identical tar' do
      stdout, status = backup_instance
      expect(status.success?).to be(true), "Error backing up instance: #{stdout}"

      object_storage.get_object(
        response_target: "/tmp/#{original_backup_name}",
        bucket: 'gitlab-backups',
        key: original_backup_name
      )

      cmd = "mkdir -p /tmp/#{original_backup_prefix} && tar -xf /tmp/#{original_backup_name} -C /tmp/#{original_backup_prefix}"
      stdout, status = Open3.capture2e(cmd)
      expect(status.success?).to be(true), "Error unarchiving original backup: #{stdout}"

      object_storage.get_object(
        response_target: "/tmp/#{new_backup_name}",
        bucket: 'gitlab-backups',
        key: new_backup_name
      )

      cmd = "mkdir -p /tmp/#{new_backup_prefix} && tar -xf /tmp/#{new_backup_name} -C /tmp/#{new_backup_prefix}"
      stdout, status = Open3.capture2e(cmd)
      expect(status.success?).to be(true), "Error unarchiving generated backup: #{stdout}"

      Dir.glob("/tmp/#{original_backup_prefix}/*") do |file|
        file_path = "/tmp/#{new_backup_prefix}/#{File.basename(file)}"
        expect(File.exist?(file_path)).to be_truthy, "#{File.basename(file)} exists in original backup but not in test ( #{file_path} )"
        # extract every tar file
        if File.extname(file) == 'tar'
          cmd = "tar -xf #{file} -C /tmp/#{original_backup_prefix}"
          stdout, status = Open3.capture2e(cmd)
          expect(status.success?).to be(true), "Error extracting tar #{file}: #{stdout}"

          f_name = file.gsub(original_backup_prefix, new_backup_prefix)
          cmd = "tar -xf #{f_name} -C /tmp/#{new_backup_prefix}"
          stdout, status = Open3.capture2e(cmd)
          expect(status.success?).to be(true), "Error extracting tar #{f_name}: #{stdout}"
        end
      end

      # Remove timestamp information from directory structure
      ## Find nested repo LATEST files to locate a repo directory
      ## Find all dirs within that directory, and rename them to increments rather than date
      Dir.glob(["/tmp/#{original_backup_prefix}/repositories/@hashed/*/*/*/LATEST", "/tmp/#{new_backup_prefix}/repositories/@hashed/*/*/*/LATEST"]) do |latest_file|
        repo_dir = File.dirname(latest_file)
        backup_id_directories = Dir.glob(File.join(repo_dir, '*')).select { |f| File.directory?(f) }

        backup_id_directories.sort.each_with_index do |directory, index|
          parent_dir = File.dirname(directory)

          File.rename(directory, File.join(parent_dir, index.to_s))
        end
      end

      Dir.glob("/tmp/#{original_backup_prefix}/**/*") do |file|
        next if ['tar', '.gz'].include? File.extname(file)
        next if File.directory?(file)
        next if ['backup_information.yml', 'LATEST'].include? File.basename(file)
        next if File.dirname(file).include?('manifest')

        test_counterpart = file.gsub(original_backup_prefix, new_backup_prefix)

        expect(File.exist?(test_counterpart)).to be_truthy, "Expected #{test_counterpart} to exist"

        original_content = File.read(file)
        test_content = File.read(test_counterpart)

        # Strip the ref list header from bundle as its sort order may not be guaranteed
        if File.extname(file) == '.bundle'
          original_content = original_content.slice(original_content.index("PACK\u0000")..-1)
          test_content = test_content.slice(test_content.index("PACK\u0000")..-1)
        end

        expect(OpenSSL::Digest::SHA256.hexdigest(original_content)).to eq(OpenSSL::Digest::SHA256.hexdigest(test_content)),
          "Expected #{file} to equal #{test_counterpart}"
      end
    end
  end
end
