## What does this MR do?

<!-- Briefly describe what this MR is about. -->

## Related issues

<!-- Link related issues below. -->

## Author's checklist

- [ ] Ensure the branch name starts with `docs-`, `docs/` or ends with `-docs`, so only the docs-related CI jobs are included
- [ ] Consider taking [the GitLab Technical Writing Fundamentals course](https://gitlab.edcast.com/pathways/ECL-02528ee2-c334-4e16-abf3-e9d8b8260de4)
- [ ] Follow the:
  - [Documentation process](https://docs.gitlab.com/development/documentation/workflow/).
  - [Documentation guidelines](https://docs.gitlab.com/development/documentation/).
  - [Style Guide](https://docs.gitlab.com/development/documentation/styleguide/).
- [ ] Merge Request Title and Description are up to date, accurate, and descriptive
- [ ] MR targeting the appropriate branch
- [ ] MR has a green pipeline on GitLab.com
- [ ] When ready for review, MR is labeled "~workflow::ready for review" per the [Distribution MR workflow](https://handbook.gitlab.com/handbook/engineering/infrastructure-platforms/gitlab-delivery/distribution/merge_requests/)

If you are only adding documentation, do not add any of the following labels:

- `~"feature"`
- `~"frontend"`
- `~"backend"`
- `~"bug"`
- `~"database"`

These labels cause the MR to be added to code verification QA issues.

## Review checklist

Documentation-related MRs should be reviewed by a Technical Writer for a non-blocking review, based on [Documentation Guidelines](https://docs.gitlab.com/development/documentation/) and the [Style Guide](https://docs.gitlab.com/development/documentation/styleguide/).

- [ ] If the content requires it, ensure the information is reviewed by a subject matter expert.
- Technical writer review items:
  - [ ] Ensure docs metadata is present and up-to-date.
  - [ ] Ensure the appropriate [labels](https://docs.gitlab.com/development/documentation/workflow/#labels) are added to this MR.
  - If relevant to this MR, ensure [content topic type](https://docs.gitlab.com/development/documentation/topic_types/) principles are in use, including:
    - [ ] The headings should be something you'd do a Google search for. Instead of `Default behavior`, say something like `Default behavior when you close an issue`.
    - [ ] The headings (other than the page title) should be active. Instead of `Configuring GDK`, say something like `Configure GDK`.
    - [ ] Any task steps should be written as a numbered list.
    - If the content still needs to be edited for topic types, you can create a follow-up issue with the ~"docs-technical-debt" label.
- [ ] Review by assigned maintainer, who can always request/require the above reviews. Maintainer's review can occur before or after a technical writer review.
- [ ] Ensure a release milestone is set.

/label ~documentation ~"section::infrastructure platforms" ~"devops::gitlab delivery" ~"group::Self Managed" ~"type::maintenance" ~"maintenance::refactor"  ~"workflow::in dev"
/assign me
