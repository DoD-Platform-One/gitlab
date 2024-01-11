#!/bin/bash
set -e

# This script collects the current digest for each specified image
# and writes the results into a Helm values file. This allows us
# to ensure that each image is running from the same CNG image build,
# and are therefore aligned - especially in relation to the migrations.
#
# Dependencies:
# - skopeo
#
# Usage:
# $ bash ./scripts/ci/pin_image_digests.sh

function get_gitlab_app_version_for_branch() {
  git fetch origin "${1}"
  git show origin/"${1}":Chart.yaml | grep 'appVersion:' | awk '{print $2}'
}

function get_image_branch_for_gitlab_app_version() {
  # turn vX.Y.Z / X.Y.Z into X-Y-stable
  echo "${1}" | sed -E 's/^v?([0-9]+)\.([0-9]+)\.([0-9]+)$/\1-\2-stable/'
}

# Gets the correct image tag to use.
# Usage:
#   `get_tag gitlab-webservice-ee`
function get_tag() {
  # Use the gitlab version from the environment or use stable images when on the stable branch
  gitlab_app_version=$(grep 'appVersion:' Chart.yaml | awk '{ print $2}')
  if [[ -n "${GITLAB_VERSION}" ]]; then
    image_branch=$GITLAB_VERSION
  elif [[ "${CI_COMMIT_BRANCH}" =~ -stable$ ]] && [[ "${gitlab_app_version}" =~ ^v?[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    image_branch=$(get_image_branch_for_gitlab_app_version "${gitlab_app_version}")
  elif [[ "${CI_MERGE_REQUEST_TARGET_BRANCH_NAME}" =~ -stable$ ]]; then
    stable_gitlab_app_version=$(get_gitlab_app_version_for_branch "${CI_MERGE_REQUEST_TARGET_BRANCH_NAME}")
    image_branch=$(get_image_branch_for_gitlab_app_version "${stable_gitlab_app_version}")
  fi

  if [[ -n "$image_branch" ]]; then
    echo -n "$image_branch"
  else
    echo -n "$gitlab_app_version"
  fi
}

# Gets the current digest for the given image name and image tag.
# Usage:
#   `get_digest gitlab-webservice-ee master`
function get_digest() {
  component=$1
  tag=$2

  digest=$(skopeo inspect docker://registry.gitlab.com/gitlab-org/build/cng/$component:$tag --format "{{.Digest}}")

  echo -n "${digest}"
}

# Gets the tag and digest to use in `<component>.image.tag`.
# Usage:
#   `tag_and_digest gitlab-webservice-ee`
function tag_and_digest() {
  component=$1
  tag=$(get_tag $component)
  digest=$(get_digest $component $tag)

  echo -n "${tag}@${digest}"
}

rm -f ci.digests.yaml
cat << CIYAML > ci.digests.yaml
# generated: $(date)
global:
  gitlabBase:
    image:
      tag: "$(tag_and_digest gitlab-base)"
  certificates:
    image:
      tag: "$(tag_and_digest certificates)"
  kubectl:
    image:
      tag: "$(tag_and_digest kubectl)"
gitlab:
  gitaly:
    image:
      tag: "$(tag_and_digest gitaly)"
  gitlab-exporter:
    image:
      tag: "$(tag_and_digest gitlab-exporter)"
  gitlab-shell:
    image:
      tag: "$(tag_and_digest gitlab-shell)"
  kas:
    image:
      tag: "$(tag_and_digest gitlab-kas)"
  migrations:
    image:
      tag: "$(tag_and_digest gitlab-toolbox-ee)"
  sidekiq:
    image:
      tag: "$(tag_and_digest gitlab-sidekiq-ee)"
  toolbox:
    image:
      tag: "$(tag_and_digest gitlab-toolbox-ee)"
  webservice:
    image:
      tag: "$(tag_and_digest gitlab-webservice-ee)"
    workhorse:
      tag: "$(tag_and_digest gitlab-workhorse-ee)"
registry:
  image:
    tag: "$(tag_and_digest gitlab-container-registry)"
CIYAML

echo 'Finished writing ci.digests.yaml.'
