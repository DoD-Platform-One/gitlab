#!/bin/sh

set -e

notify() {
  echo "$1"
  echo -n "$1 " >> /dev/termination-log
}

greater_version()
{
  test "$(printf '%s\n' "$@" | sort -V | tail -n 1)" = "$1";
}

is_semver()
{
  printf '%s' "$1" | grep -Eq "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}"
  return "$?"
}

# For the PostgreSQL upgrade, you either need both secrets, or no secrets.
# If there are no secrets, we will create them for you.
# If the secrets aren't in either of these states, we assume you are upgrading from an older version
# This is running ahead of version checks to ensure this always runs. This is to account for
# installations outside of the official helm repo.
secrets_dir="/etc/secrets/postgresql"
if [ -d "${secrets_dir}" ]; then
  if [ ! "$(ls -A ${secrets_dir}/..data/)" = "" ]; then
    if [ ! -f "${secrets_dir}/postgresql-postgres-password" ] || [ ! -f "${secrets_dir}/{{ include "gitlab.psql.password.key" . | trimAll "\"" }}" ]; then
      notify "You seem to be upgrading from a previous version of GitLab using the bundled PostgreSQL chart"
      notify "There are some manual steps which need to be performed in order to upgrade the database"
      notify "Please see the upgrade documentation for instructions on how to proceed:"
      notify "https://docs.gitlab.com/charts/installation/upgrade.html"
      exit 1
    fi
  fi
fi
MIN_VERSION=17.11
CHART_MIN_VERSION=8.11

# Remove 'v' prefix from GitLab version if present (set in Chart.yaml appVersions)
GITLAB_VERSION=${GITLAB_VERSION#v}

# Only run check for semver releases
if ! is_semver "$GITLAB_VERSION"; then
  exit 0
fi

NEW_MAJOR_VERSION=$(echo $GITLAB_VERSION | awk -F "." '{print $1}')
NEW_MINOR_VERSION=$(echo $GITLAB_VERSION | awk -F "." '{print $1"."$2}')

NEW_CHART_MAJOR_VERSION=$(echo $CHART_VERSION | awk -F "." '{print $1}')
NEW_CHART_MINOR_VERSION=$(echo $CHART_VERSION | awk -F "." '{print $1"."$2}')

if [ ! -f /chart-info/gitlabVersion ]; then
  notify "It seems you are attempting an unsupported upgrade path."
  notify "Please follow the upgrade documentation at https://docs.gitlab.com/update/#upgrade-paths"
  exit 1
fi

OLD_VERSION_STRING=$(cat /chart-info/gitlabVersion)
OLD_VERSION_STRING=${OLD_VERSION_STRING#v}
OLD_CHART_VERSION_STRING=$(cat /chart-info/gitlabChartVersion)

# Skip check if old version wasn't semver
if ! is_semver "$OLD_VERSION_STRING"; then
  exit 0
fi

OLD_MAJOR_VERSION=$(echo $OLD_VERSION_STRING | awk -F "." '{print $1}')
OLD_MINOR_VERSION=$(echo $OLD_VERSION_STRING | awk -F "." '{print $1"."$2}')
OLD_CHART_MAJOR_VERSION=$(echo $OLD_CHART_VERSION_STRING | awk -F "." '{print $1}')
OLD_CHART_MINOR_VERSION=$(echo $OLD_CHART_VERSION_STRING | awk -F "." '{print $1"."$2}')

# Checking Version
if ( ! greater_version "$OLD_MINOR_VERSION" "$MIN_VERSION" ) || ( ! greater_version "$OLD_CHART_MINOR_VERSION" "$CHART_MIN_VERSION" ); then
  notify "It seems you are upgrading the GitLab Helm Chart from ${OLD_CHART_VERSION_STRING} (GitLab ${OLD_VERSION_STRING}) to ${CHART_VERSION} (GitLab ${GITLAB_VERSION})."
  notify "It is required to upgrade to the latest ${CHART_MIN_VERSION}.x version first before proceeding."
  # Link to upgrade docs if it is a major version jump
  if [ "${OLD_MAJOR_VERSION}" -lt "${NEW_MAJOR_VERSION}" ] || [ "${OLD_CHART_MAJOR_VERSION}" -lt "${NEW_CHART_MAJOR_VERSION}" ]; then
    notify "Please follow the upgrade documentation at https://docs.gitlab.com/charts/releases/8_0.html"
    notify "and upgrade to GitLab Helm Chart version ${CHART_MIN_VERSION}.x before upgrading to ${CHART_VERSION}."
  fi
  exit 1
fi