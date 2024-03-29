#!/bin/bash
set -e

# This script tests the behavior of the pin_image_digests.sh
# script using bats
#
# Dependencies:
# - skopeo  # from script being tested
# - bats
# - helm
#
# Usage:
# $ bats scripts/ci/pin_image_digests_test.sh

PROJECT_ROOT="$(dirname -- "$BATS_TEST_FILENAME")/../.."

setup() {
  unset GITLAB_VERSION # set by CNG-triggered pipelines
  unset CI_MERGE_REQUEST_TARGET_BRANCH_NAME # backports to stable branches use the stable branch tag
}

@test "tag_and_digest, on master branch" {
  CHART_FILE='Chart.master.yaml'
  echo 'appVersion: master' > $CHART_FILE

  expected='^master@sha256:[[:xdigit:]]{64}$'

  source scripts/ci/pin_image_digests.sh
  run tag_and_digest 'gitlab-webservice-ee'

  [ "$status" -eq 0 ]
  [[ "$output" =~ $expected ]]
}

@test "tag_and_digest, with GITLAB_VERSION" {
  GITLAB_VERSION='v16.8.0'

  expected="^$GITLAB_VERSION@sha256:[[:xdigit:]]{64}$"

  source scripts/ci/pin_image_digests.sh
  run tag_and_digest 'gitlab-webservice-ee'

  [ "$status" -eq 0 ]
  [[ "$output" =~ $expected ]]
}

@test "tag_and_digest, on stable branch" {
  CI_COMMIT_BRANCH='7-8-stable'
  CHART_FILE='Chart.stable.yaml'
  echo 'appVersion: v16.8.0' > $CHART_FILE

  expected='^[0-9]+-[0-9]+-stable@sha256:[[:xdigit:]]{64}$'

  source scripts/ci/pin_image_digests.sh
  run tag_and_digest 'gitlab-webservice-ee'

  [ "$status" -eq 0 ]
  [[ "$output" =~ $expected ]]
}

@test "tag_and_digest, on merge request branch targeting stable" {
  CI_MERGE_REQUEST_TARGET_BRANCH_NAME='7-8-stable'

  expected='^[0-9]+-[0-9]+-stable@sha256:[[:xdigit:]]{64}$'

  source scripts/ci/pin_image_digests.sh
  run tag_and_digest 'gitlab-webservice-ee'

  [ "$status" -eq 0 ]
  [[ "$output" =~ $expected ]]
}

@test "rendering digests file with helm template" {
  DIGESTS_FILE="$PROJECT_ROOT/ci.digests.test.yaml"

  source scripts/ci/pin_image_digests.sh

  image_tag="$(tag_and_digest gitlab-base)"

  expected="image: \"registry.gitlab.com/gitlab-org/build/cng/gitlab-base:$image_tag\""

  cat << CIYAML > $DIGESTS_FILE
certmanager-issuer:
  email: ci@gitlab.com
global:
  gitlabBase:
    image:
      tag: "$image_tag"
CIYAML

  helm dependency build
  run helm template . -f $DIGESTS_FILE

  [ "$status" -eq 0 ]
  [[ "$output" =~ $expected ]]
}
