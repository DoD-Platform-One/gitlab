---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#designated-technical-writers
---

# Decision Making

Changes to this repository are first reviewed using the [merge request workflow](https://handbook.gitlab.com/handbook/engineering/infrastructure/core-platform/systems/distribution/merge_requests/) then merged by project maintainers.

Architectural decisions (such as those that would appear on the [architecture](architecture.md) or [decisions](decisions.md) pages) require the review of the project's senior technical leadership. Senior technical leadership are individuals identified by the Engineering Manager of the team responsible for the project, as well as that team's Staff+ leadership as mentioned in the [architecture handbook](https://handbook.gitlab.com/handbook/engineering/architecture/#architecture-as-a-practice-is-everyones-responsibility) and any current working group formed around a goal specific to the project.

## Maintainers

Project maintainers can be found on the [GitLab projects page](https://handbook.gitlab.com/handbook/engineering/projects/#gitlab-chart), or located using the [review workload dashboard](https://gitlab-org.gitlab.io/gitlab-roulette/?currentProject=gitlab-chart&mode=hide).

Maintainers are responsible for merging changes within their domain, and having an understanding of the whole project and how changes may impact areas outside their expertise.

Reviewers can assign to any maintainer and the maintainer will engage the appropriate domain expert if it does not fall within their own.

In order to continue to expand their expertise maintainers are empowered to merge changes outside their domain but that they are **highly confident** in unless:

- The change cannot be reverted later
- The change has an established process that needs to be followed (JiHu review, security, legal/license changes)
- The change clearly requires an architectural decision

When urgent changes are required, maintainers should have a bias-for action, and can make decisions as long as the decisions are later reversible and compliant with known project process requirements.

### Dependency Maintainers

A dependency maintainer has the same responsibilities as a regular maintainer, but the ability to merge is tightly scoped to changes related to dependency versioning only for a specific domain. If any change aside from a dependency versioning is present in the merge request, a regular maintainer is required to perform the maintainer review.

All changes need to result in a working chart, and the impact of the change in dependency versions needs to be fully understood by the dependency maintainer. Individuals that are already chart reviewers are good candidates to become dependency maintainers.

| Username | Scope |
| -- | -- |
| @DylanGriffith | `gitlab-zoekt` |
| @dgruzd | `gitlab-zoekt` |
| @terrichu | `gitlab-zoekt` |
| @johnmason | `gitlab-zoekt` |

## Project Leadership

| Username | Role |
| -- | -- |
| @WarheadsSE | Staff Engineer, Distribution Deploy |
| @twk3 | Engineering Manager, Distribution Build |
| @ayufan | Distinguished Engineer, Enablement |
| @stanhu | Engineering Fellow |
