#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PROJECT_ROOT="$(dirname -- "${SCRIPT_DIR}"/../../..)"
TEST_DIR="$SCRIPT_DIR/chart-info"

mkdir -p "$TEST_DIR"

# Usage:
#   test OLD_VERSION OLD_CHART_VERSION NEW_VERSION NEW_CHART_VERSION [SUFFIX]
test_runcheck() {
  echo "${1}" > "$TEST_DIR/gitlabVersion"
  echo "${2}" > "$TEST_DIR/gitlabChartVersion"

  docker run \
    --rm -t \
    -v ${PROJECT_ROOT}/templates/_runcheck.tpl:/scripts/runcheck \
    -v ${TEST_DIR}:/chart-info \
    -e GITLAB_VERSION="${3}" \
    -e CHART_VERSION="${4}" \
    "registry.gitlab.com/gitlab-org/build/cng/gitlab-base:master${5}" \
    /bin/sh /scripts/runcheck > /dev/stderr

  local retVal=$?
  if [ $retVal -ne 0 ]; then
      echo 'FAIL'
  else
    echo "PASS"
  fi
}


echo "Testing upgrade paths expected to pass"
test_runcheck '16.11.0' '7.11.0' '17.0.0' '8.0.0'
test_runcheck '16.11.1' '7.11.1' '17.0.0' '8.0.0'
test_runcheck '16.11.1' '7.11.1' '17.1.0' '17.1.0'

echo "Testing upgrade paths expected to fail"
test_runcheck '16.10.0' '7.10.0' '17.0.0' '8.0.0'
test_runcheck '16.10.3' '7.10.3' '17.0.0' '8.0.0'
test_runcheck '15.11.0' '6.11.0' '17.0.0' '8.0.0'
test_runcheck '16.11.0' '7.10.0' '17.0.0' '8.0.0'
