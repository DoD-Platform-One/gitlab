#!/bin/sh

set -e

notify() {
  echo "$1"
  echo -n "$1 " >> /dev/termination-log
}

OLD_VERSION_STRING=$(cat /chart-info/gitlabVersion)
OLD_CHART_VERSION_STRING=$(cat /chart-info/gitlabChartVersion)

echo "old gitlab version " $OLD_VERSION_STRING
echo "old chart version " $OLD_CHART_VERSION_STRING
echo "new gitlab version: " $GITLAB_VERSION
echo "new chart version: " $CHART_VERSION
echo

if [[ ${OLD_VERSION_STRING} == "13.12.9" && ${GITLAB_VERSION} == "14.3.1" ]]; then
  echo  "Rolling upgrades to 14.0.5 and then to 14.3.1 will be attempted."
  echo  "Please wait about 10 minutes for the upgrades to start..."
  kubectl patch gitrepository gitlab -n bigbang --type=merge -p '{"spec":{"ref":{"tag":"5.0.5-bb.0"}}}'
  
  # wait for helmrelease lastAppliedRevision to be 5.0.5
  while true; do
    version=$(kubectl get helmrelease gitlab -n bigbang -o jsonpath='{.status.lastAppliedRevision}')
    echo "lastAppliedRevision : ${version}"
    if [[ ${version} == "5.0.5-bb.0" ]]; then
      echo "auto upgrade to chart version 5.0.5-bb.0 completed"
      break
    fi

    echo "waiting for last lastAppliedRevision chart version to be: 5.0.5-bb.0..."
    sleep 10

  done

  # then patch gitrepository ref to new chart version 5.3.1
  echo  "Rolling upgrade to application version 14.3.1 chart version 5.3.1 is starting now..."
  kubectl patch gitrepository gitlab -n bigbang --type=merge -p '{"spec":{"ref":{"tag":"'$CHART_VERSION'"}}}'

  # for testing
  # TEST_BRANCH=105-update-rolling-upgrade-job-with-new-tag
  # kubectl patch gitrepository gitlab -n bigbang --type=merge -p '{"spec":{"ref":{"tag":"","branch":"'$TEST_BRANCH'"}}}'

else
  echo "No rolling upgrade will be performed."
fi
