# Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---
## [6.4.1-bb.0] - 2022-10-06
### Changed
- Updated to helm chart to 6.4.1 and appVersion to 15.4.1

## [6.3.2-bb.1] - 2022-09-20
### Changed
- documentation cleanup

## [6.3.2-bb.0] - 2022-09-14
### Changed
- Updated to helm chart to 6.3.2 and appVersion to 15.3.2

## [6.3.1-bb.0] - 2022-08-25
### Changed
- Updated to helm chart to 6.3.1 and appVersion to 15.3.1

## [6.2.1-bb.1] - 2022-08-18
### Changed
- Remove ServiceMonitor created by BigBang and enable upstream ones.

## [6.2.1-bb.0] - 2022-08-18
### Changed
- Updated to helm chart to 6.2.1 and appVersion to 15.2.1

## [6.1.2-bb.2] - 2022-07-19
### Added
- For bigbang CI, add keycloak sso integration cypress test

## [6.1.2-bb.1] - 2022-07-18
### Added
- Added mailroom image/repository/tag to gitlab in values.yaml

## [6.1.2-bb.0] - 2022-07-12
### Updated
- Updated to helm chart to 6.1.2 and appVersion to 15.1.2

## [6.0.1-bb.5] - 2022-07-06
### Updated
- Updated Redis image version from 6.2.7 to 7.0.0-debian-10-r3
- Updated MinIO client image version from RELEASE.2022-05-09T04-08-26Z to RELEASE.2022-06-26T18-51-48Z
- Updated MinIO image version from RELEASE.2022-06-03T01-40-53Z to RELEASE.2022-07-04T21-02-54Z

## [6.0.1-bb.4] - 2022-06-28
### Added
- Pod and Container SecurityContext values for redis installations in correct location

## [6.0.1-bb.3] - 2022-06-21
### Added
- Pod and Container SecurityContext values for redis installations

## [6.0.1-bb.2] - 2022-06-14
### Change
- Update conditionals for mTLS to lock them down further
- Fix label match for runner metrics mTLS exception and networkPolicies

## [6.0.1-bb.1] - 2022-06-13
### Updated
- Updated `tests/images.txt` to support airgap

## [6.0.1-bb.0] - 2022-06-07
### Updated
- Updated to helm chart to 6.0.1 and appVersion to 15.0.1
- ironbank/gitlab/gitlab/gitlab-webservice major update 14.10.1 -> 15.0.1
- ironbank/bitnami/analytics/redis-exporter minor 1.35.0 -> 1.37.0
- ironbank/bitnami/redis major 6.2.5 -> 7.0.0
- ironbank/gitlab/gitlab/alpine-certificates major 14.10.1 -> 15.0.1
- ironbank/gitlab/gitlab/gitaly major 14.10.1 -> 15.0.1
- ironbank/gitlab/gitlab/gitlab-container-registry major 14.10.1 -> 15.0.1
- ironbank/gitlab/gitlab/gitlab-exporter major 14.9.2 -> 15.0.1
- ironbank/gitlab/gitlab/gitlab-exporter major 14.10.1 -> 15.0.1
- ironbank/gitlab/gitlab/gitlab-shell major 14.10.1 -> 15.0.1
- ironbank/gitlab/gitlab/gitlab-sidekiq major 14.10.1 -> 15.0.1
- ironbank/gitlab/gitlab/gitlab-toolbox major 14.10.1 -> 15.0.1
- ironbank/gitlab/gitlab/gitlab-webservice major 14.10.1 -> 15.0.1
- ironbank/gitlab/gitlab/gitlab-workhorse major 14.10.1 -> 15.0.1
- ironbank/gitlab/gitlab/kubectl major 14.9.2 -> 15.0.1
- ironbank/gitlab/gitlab/kubectl major 14.10.1 -> 15.0.1
- ironbank/opensource/minio/mc minor RELEASE.2022-03-17T07-21-29Z -> RELEASE.2022-05-09T04-08-26Z
- ironbank/opensource/minio/minio minor RELEASE.2022-03-22T02-05-10Z -> RELEASE. 2022-06-03T01-40-53Z
- ironbank/opensource/postgres/postgresql12 minor 12.9 -> 12.11
- ironbank/redhat/ubi/ubi8 minor 8.5 -> 8.6

## [5.10.1-bb.3] - 2022-06-07
### Changed
- Make conditionals better for mTLS (exceptions only when in STRICT, all enabled only when injected)

## [5.10.1-bb.2] - 2022-05-19
### Changed
- Added mTLS for Istio
- Set mTLS exceptions for redis and postgresql

## [5.10.1-bb.1] - 2022-06-02
### Changed
- Added `postgresqlInitdbArgs` to set password encryption for the gitlab user to be `scram-sha-256`

## [5.10.1-bb.0] - 2022-05-04
### Changed
- Update GitLab to app version 14.10.1 and helm chart to version v5.10.1
- Removed sidecar injection from several jobs
### Added
- Maintenance documentation for how to upgrade and test

## [5.9.2-bb.2] - 2022-04-26
### Added
- Added Oscal Component

## [5.9.2-bb.1] - 2022-04-05
### Changed
- Fix port name in exporter servicemonitor

## [5.9.2-bb.0] - 2022-04-04
### Changed
- Update GitLab to app version 14.9.2 and helm chart to version v5.9.2

## [5.8.2-bb.5] - 2022-03-30
### Changed
- Remove postgres persistence subpath and removed postgres permissions job
- Upgrade from `5.8.2-bb.2` or previous requires dumping/restoring PG data

## [5.8.2-bb.4] - 2022-03-29
### Added
- Added Tempo Zipkin Egress Policy

## [5.8.2-bb.3] - 2022-03-29
### Updated
- Switched postgres to IB image

## [5.8.2-bb.2] - 2022-03-08
### Updated
- registry1.dso.mil/ironbank/opensource/minio/mc    patch RELEASE.2022-02-16T05-54-01Z -> RELEASE.2022-02-26T03-58-31Z
- registry1.dso.mil/ironbank/opensource/minio/minio minor RELEASE.2022-02-18T01-50-10Z -> RELEASE.2022-03-05T06-32-39Z

## [5.8.2-bb.1] - 2022-03-03
### Added
- Added network policy for Redis clients

## [5.8.2-bb.0] - 2022-03-01
### Changed
- Update GitLab to app version 14.8.2 and helm chart to version v5.8.2

## [5.7.1-bb.0] - 2022-02-22
### Changed
- Update GitLab to app version 14.7.1 and helm chart to version v5.7.1

## [5.6.2-bb.5] - 2022-02-14
### Updated
- registry1.dso.mil/ironbank/bitnami/analytics/redis-exporter minor 1.18.0 -> 1.35.0
- registry1.dso.mil/ironbank/gitlab/gitlab/gitlab-exporter minor 14.3.1 -> 14.6.2
- registry1.dso.mil/ironbank/opensource/minio/mc major RELEASE.2021-03-23T05-46-11Z -> RELEASE.2022-02-07T09-25-34Z
- registry1.dso.mil/ironbank/opensource/minio/minio major RELEASE.2021-04-06T23-11-00Z -> RELEASE.2022-02-07T08-17-33Z
- registry1.dso.mil/ironbank/opensource/redis/redis5 patch 5.0.9 -> 5.0.14
- registry1.dso.mil/ironbank/redhat/ubi/ubi8 minor 8.4 -> 8.5
- redis 5 to redis 6
- updated test/images.txt versions

## [5.6.2-bb.4] - 2022-02-09
### Changed
- Updated `renovate.json` to track all images in `tests/images.txt`
- Added images to `tests/images.txt` for new packaging CI

## [5.6.2-bb.3] - 2022-01-31
### Updated
- Update Chart.yaml to follow new standardization for release automation
- Added renovate check to update new standardization

## [5.6.2-bb.2] - 2022-01-19
### Changed
- disable istio proxy sidecar injection for the migration job

## [5.6.2-bb.1] - 2022-01-19
### Changed
- Disable istio sidecar on backup-job.jaml

## [5.6.2-bb.0] - 2022-01-14
### Changed
- Update GitLab to app version 14.6.2 and helm chart to version v5.6.2

## [5.6.0-bb.0] - 2022-01-06
### Changed
- Update GitLab to app version 14.6.0 and helm chart to version v5.6.0

## [5.3.1-bb.11] - 2022-01-05
### Added
- `allow-prometheus-ingress-redis` NetworkPolicy template added for redis metrics scraping

## [5.3.1-bb.10] - 2021-12-21
### Changed
- Update DoD approved CA certificates

## [5.3.1-bb.9] - 2021-11-10
### Changed
- improvements for istio sidecar proxy injection

## [5.3.1-bb.8] - 2021-11-04
### Changed
- add istio injection for upgrade job
### Removed
- remove rolling upgade job.

## [5.3.1-bb.7] - 2021-11-04
### Changed
- add istio injection for shared-secrets jobs

## [5.3.1-bb.6] - 2021-11-03
### Changed
- add istio injection for migrations job

## [5.3.1-bb.5] - 2021-11-01
### Fixed
- Fixed CI for upgrades

## [5.3.1-bb.4] - 2021-10-29
### Fixed
- Add check for AWS IAM profile to update the egress-kube-api network policy to allow access to AWS metadata endpoint
- Add specific NetworkPolicy templates for 4 pods to hit AWS metadata endpoint to use IAM Role

## [5.3.1-bb.3] - 2021-10-29
### Fixed
- increase resoures for gitaly
- conditionally disable istio injection for the upgrade-check job
- modify minio sub-chart to conditionally disable istio injection for the create-buckets job

## [5.3.1-bb.2] - 2021-10-17
### Fixed
- Update rolling upgrade job with variable for release tag

## [5.3.1-bb.1] - 2021-10-15
### Changed
- Updated README.md
- Renamed docs/README.md to docs/overview.md

## [5.3.1-bb.0] - 2021-10-08
### Changed
- upgrade Gitlab to application version 14.3.1 helm chart version v5.3.1
- If upgrading from 13.12.9 to 14.3.1 must first upgrade to 14.0.5 see Gitlab documentation
   https://docs.gitlab.com/ee/update/#upgrade-paths

## [5.0.5-bb.0] - 2021-10-01
### Changed
- upgrade Gitlab to application version 14.0.5 helm chart version v5.0.5
- notice: this upgrade requires postgresql 12 or higher

## [4.12.9-bb.6] - 2021-09-16
### Changed
- Updated test.sh with ENV variables from test-values
- Updated Cypress tests with ENV variables from test-values
- Added bbtest conditional for test-services

## [4.12.9-bb.5] - 2021-09-09
### Changed
- Updated tests to add labels for `app: gitlab`, workaround for a bug (likely) in gluon
- Updated to latest gluon

## [4.12.9-bb.4] - 2021-09-08
### Fixed
- Fix helmignore issue with scripts/ folder

## [4.12.9-bb.3] - 2021-08-31
### Changed
- VirtualService modifications to optionally allow use of multiple hosts

## [4.12.9-bb.2] - 2021-08-30
### Changed
- Set resource limits and make requests and limis equal to achive quality of service

## [4.12.9-bb.1] - 2021-08-12
### Changed
- update change log.

## [4.12.9-bb.0] - 2021-08-12
### Changed
- upgrade Gitlab to application version 13.12.9 helm chart version 4.12.9

## [4.10.3-bb.14] - 2021-07-15
### Added
- add openshift toggle. conditionally modify networkpolicy for dns

## [4.10.3-bb.13] - 2021-07-15
### Fixed
- fix networkPolicies to allow egress to kube api server

## [4.10.3-bb.12] - 2021-07-01
### Fixed
- fix networkPolicies to allow monitoring for gitlab-runner

## [4.10.3-bb.11] - 2021-07-01
### Fixed
- fix flux helmrelease errors because gitlab chart duplicates lables

## [4.10.3-bb.10] - 2021-06-18
### Changed
- more restrictive network policies to limit by podSelector

## [4.10.3-bb.9] - 2021-06-16
### Changed
- updated Iron Bank UBI from 8.3 to 8.4

## [4.10.3-bb.8] - 2021-06-04
### Changed
- network policy to allow sso egress
- turn off ingress in subcharts by default

## [4.10.3-bb.7] - 2021-06-01
### Changed
- more network policy updates
- upgrade test library

## [4.10.3-bb.6] - 2021-05-27
### Changed
- more network policy updates

## [4.10.3-bb.5] - 2021-05-26
### Changed
- add optional network policies

## [4.10.3-bb.4] - 2021-05-26
### Changed
- limit default user permissions

## [4.10.3-bb.3] - 2021-05-25
### Changed
- no code changes

## [4.10.3-bb.2] - 2021-05-10
### Changed
- add helm tests for CI pipelines
- remove unneeded registry.host key in values.yaml
- documentation about backing up the gitlab-rails secret
- ironbank image for praefect (praefect is disabled by default)
## [4.10.3-bb.1] - 2021-05-03
### Fixed
- add ServiceMonitor to fix prometheus monitoring

## [4.10.3-bb.0] - 2021-04-21
### Changed
- upgrade Gitlab to application version 13.10.3 chart version 4.10.3

## [4.8.0-bb.3] - 2021-03-09
### Changed
- add support for CAC signed commits with DoD certificate authorities
- update changelog

## [4.8.0-bb.2] - 2021-03-04
### Changed
- increment chart version in Chart.yaml

## [4.8.0-bb.1] - 2021-03-04
### Changed
- use correct IronBank image for certificates

## [4.8.0-bb.0] - 2021-02-12
### Changed
- upgrade Gitlab to application version 13.8.0 chart version 4.8.0

## [4.7.2-bb.0] - 2021-01-20
### Changed
- upgrade Gitlab to application version 13.7.2 chart version 4.7.2

## [4.2.0-bb.0] - 2021-01-16
### Added
- initial release with support for BigBang

## [0.0.0-bb.0] - 2020-12-22
### Added
- pre-bigbang
- Upstream gitlab version - v4.2.0
