## What does this MR do?

<!-- Briefly describe what this MR is about. -->

%{first_multiline_commit}

## Related issues

<!-- Link related issues below. Insert the issue link or reference after the word "Closes" if merging this should automatically close it. -->

## Author checklist

See [Definition of done](https://gitlab.com/gitlab-org/charts/gitlab/-/blob/master/CONTRIBUTING.md#definition-of-done).

For anything in this list which will not be completed, please provide a reason in the MR discussion.

### Required
- [ ] Merge Request Title and Description are up to date, accurate, and descriptive
- [ ] MR targeting the appropriate branch
- [ ] MR has a green pipeline on GitLab.com
- [ ] When ready for review, follow the instructions in the "Reviewer Roulette" section of the Danger Bot MR comment, as per the [Distribution experimental MR workflow](https://about.gitlab.com/handbook/engineering/development/enablement/systems/distribution/merge_requests.html)

For merge requests from forks, consider the following options for Danger to work properly:

- Consider using our [community forks](https://gitlab.com/gitlab-community/meta) instead of forking
   your own project. These community forks have the GitLab API token preconfigured.
- Alternatively, see our documentation on
  [configuring Danger for personal forks](https://docs.gitlab.com/ee/development/dangerbot.html#configuring-danger-for-personal-forks).

### Expected (please provide an explanation if not completing)
- [ ] Test plan indicating conditions for success has been posted and passes
- [ ] Documentation created/updated
- [ ] Tests added/updated
- [ ] Integration tests added to [GitLab QA](https://gitlab.com/gitlab-org/gitlab-qa)
- [ ] Equivalent MR/issue for [omnibus-gitlab](https://gitlab.com/gitlab-org/omnibus-gitlab) opened
- [ ] Equivalent MR/issue for [Gitlab Operator project](https://gitlab.com/gitlab-org/cloud-native/gitlab-operator) opened (see [Operator documentation on impact of Charts changes](https://docs.gitlab.com/operator/developer/charts_dependency))
- [ ] Validate potential values for new configuration settings. Formats such as integer `10`, duration `10s`, URI `scheme://user:passwd@host:port` may require quotation or other special handling when rendered in a template and written to a configuration file.

<!-- template sourced from https://gitlab.com/gitlab-org/charts/gitlab/-/blob/master/.gitlab/merge_request_templates/Default.md -->
