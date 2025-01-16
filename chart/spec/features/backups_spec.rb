require 'spec_helper'
require 'open-uri'
require 'features/test_project_helper'

describe "Backup and restore" do
  before(:all) do
    @project_helper = TestProjectHelper.new
    set_admin_token
  end

  describe "Create the backup" do
    before(:all) do
      @project_helper.create_test_project
      @project_helper.commit_dockerfile
      @project_helper.create_test_issue
      @project_helper.upload_test_container_image
    end

    after(:all) do
      @project_helper.delete_test_project
    end

    it 'Creates the backup' do
      stdout, status = backup_instance
      expect(status.success?).to be(true), "Error backing up instance: #{stdout}"
    end
  end

  describe "Restore the backup" do
    before(:all) do
      scale_rails_down
      wait_for_rails_rollout
    end

    after(:all) do
      scale_rails_up
      wait_for_rails_rollout
    end

    it 'Restore the backup' do
      stdout, status = restore_from_backup
      expect(status.success?).to be(true), "Error restoring instance: #{stdout}"
    end
  end

  describe 'Restored gitlab instance' do
    it 'Should have the testproject' do
      @project_helper.get_test_project
    end

    it 'Should have the Dockerfile' do
      @project_helper.get_test_project_tree
    end

    it 'Should have the test issue' do
      @project_helper.get_test_issue
    end

    it 'Should have the test contaner image' do
      @project_helper.pull_test_container_image
    end
  end
end
