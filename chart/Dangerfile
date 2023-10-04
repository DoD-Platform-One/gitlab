require "gitlab-dangerfiles"

# Documentation reference: https://gitlab.com/gitlab-org/ruby/gems/gitlab-dangerfiles
Gitlab::Dangerfiles.for_project(self, 'gitlab-chart') do |dangerfiles|
  # Import all plugins from the gem
  dangerfiles.import_plugins

  # Import a defined set of danger rules
  dangerfiles.import_dangerfiles(except: %w[changes_size commit_messages commits_counter])
end
