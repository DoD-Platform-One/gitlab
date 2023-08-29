require "gitlab-dangerfiles"

# Documentation reference: https://gitlab.com/gitlab-org/ruby/gems/gitlab-dangerfiles
Gitlab::Dangerfiles.for_project(self, 'gitlab-chart') do |dangerfiles|
  # Import all plugins from the gem
  dangerfiles.import_plugins

  # Import a defined set of danger rules
  dangerfiles.import_dangerfiles(only: %w[simple_roulette z_retry_link])

  # These custom files have the potential to be either discarded or simplified,
  # as the default rules available to us already provide much if not all of
  # of our customization. Still, let's investigate this in a follow-up.
  # For now, we can simply introduce the simple_roulette.
  danger.import_dangerfile(path: 'scripts/support/changelog')
  danger.import_dangerfile(path: 'scripts/support/metadata')
  danger.import_dangerfile(path: 'scripts/support/reviewers')
end
