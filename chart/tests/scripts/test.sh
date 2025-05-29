#!/bin/bash
set -euo pipefail

##############################################################
# Colorized logging functions
#

GREEN="\e[32m"
YELLOW="\e[33m"
MAGENTA="\e[35m"
CYAN="\e[36m"
ENDCOLOR="\e[0m"

slug="${MAGENTA}[test log]${ENDCOLOR} | "

# Basic info-level colorized logging.
function info {
  local text=${1}
  echo -e "${slug}${YELLOW}${text}${ENDCOLOR}"
}

# Formatted test descriptor log:
# > Can we.... do a testable thing here ?
function canwe {
  local text=${1}
  echo -e "${slug}${CYAN}Can we... ${YELLOW}${text}${CYAN}?${ENDCOLOR}"
}

# Formatted test success log:
# > ✅ test succeeded.
function success {
  local text=${1}
  echo -e "${slug}✅\t${GREEN}${text}${ENDCOLOR}"
}

#############################################################
# General shell helper functions
#

### Sample PAT value: glpat-bigbangtest-9ae6aca43f841f89f7d08b212d2fa009
function generate_pat {
  # generate random 32-char string and then add glpat-bigbangtest- to it
  head -c 128 /dev/urandom \
    | sha256sum \
    | head -c 32 \
    | awk '{ print "glpat-bigbangtest-" $1 }'
}

#############################################################
# GitLab accessors and mutators
#

# fetch a gitlab project's ID by project name
function get_project_id {
  local token=${1}
  local api_host=${2}
  local project_name=${3}

  curl --fail --request GET \
    --header "PRIVATE-TOKEN: ${token}" \
    "http://${api_host}/api/v4/projects?search=${project_name}" \
      | jq '.[].id' --raw-output
}

# delete a gitlab project by project ID
function delete_project {
  local token=${1}
  local api_host=${2}
  local project_id=${3}

  curl --fail --request DELETE --header "PRIVATE-TOKEN: ${token}" "http://${api_host}/api/v4/projects/${project_id}"
}

# Creates a 24-hour personal access token (PAT) for gitlab's root user.
# ⚠️ Sets the token value to the second argument here rather than letting
# gitlab randomize one for us. This makes it a bit easier to pass the token
# around in these test scripts.
function create_pat {
  local pat_name=${1}
  local pat_value=${2}

  SETUP_CMD="t=User.find_by!(username: 'root').personal_access_tokens.new(name: '${pat_name}', scopes:[:api], expires_at: 1.day.from_now.utc); t.set_token('${pat_value}'); t.save!"
  kubectl -n gitlab exec -ti deploy/gitlab-toolbox -- gitlab-rails runner "${SETUP_CMD}"
}

# Deactivate the supplied gitlab personal access token.
function deactivate_pat {
  local token=${1}
  local api_host=${2}

  curl --fail --request DELETE --header "PRIVATE-TOKEN: ${token}" "http://${api_host}/api/v4/personal_access_tokens/self"
}

function main {
  export HOME=/test
  export project_name="${GITLAB_PROJECT}-${RANDOM}"
  export base_branch=main
  export test_branch="test-${RANDOM}"
  export reference_image=registry1.dso.mil/ironbank/opensource/alpinelinux/alpine:latest


  ####################################################
  # COPY REGISTRY1 CREDS TO AUTHFILE FOR SKOPEO
  cat /.docker/auth.json > /test/auth.json


  ####################################################
  # CREATE TEMPORARY TEST TOKEN (PAT) FOR ROOT USER

  export pat_name="bb-test-automation-pat_value-${RANDOM}"
  pat_value=$(generate_pat)
  export pat_value


  canwe "create a temporary PAT for gitlab user root via gitlab-rails runner"
  create_pat "${pat_name}" "${pat_value}"
  info "temporary PAT created."


  ####################################################
  # CREATE LOCAL GIT REPO

  canwe "create a new local git repository"

  rm -rf "${project_name}"
  mkdir -p "${project_name}"
  pushd "${project_name}"

  echo "Hi from a new bigbang test repository!" >> README.md
  git init --initial-branch=$base_branch

  git config --local user.email "${GITLAB_EMAIL}"
  git config --local user.name "${GITLAB_USER}"
  git config --local user.password "${pat_value}"

  git add README.md
  git commit -m "initial commit to a new bigbang test repository"

  info "local git repository created: [${project_name}]"


  ####################################################
  # PUSH LOCAL GIT REPO AS NEW GITLAB PROJECT

  canwe "push a local git repository to gitlab as a new project"
  git remote add origin "http://${GITLAB_USER}:${pat_value}@${GITLAB_HOST}/${GITLAB_USER}/${project_name}.git"
  git push -u origin $base_branch
  success "pushed a new project to Gitlab."

  canwe "fetch a gitlab project ID by project name using cURL"
  project_id=$(get_project_id "${pat_value}" "${GITLAB_HOST}" "${project_name}")
  export project_id
  success "project ID fetched: [${project_id}]"

  #################################################################
  # PUSH IMAGE TO CONTAINER REGISTRY UNDER OUR GITLAB PROJECT

  # skopeo needs to save registry auth to a writeable folder
  # see https://github.com/containers/skopeo/blob/main/docs/skopeo-login.1.md

  canwe "log in to a gitlab container registry with our new PAT"
  skopeo login --tls-verify=false --authfile=${HOME}/auth.json "${GITLAB_REGISTRY}" --username "${GITLAB_USER}" --password "${pat_value}"
  success "logged in to gitlab container registry using our PAT."



  canwe "push local changes to our new project"
  echo "FROM ${reference_image}" > ./Dockerfile
  git add Dockerfile
  git commit -m "adds new Dockerfile from ${reference_image}" --allow-empty
  git checkout -b $test_branch
  git push -u origin $test_branch
  success "pushed local changes to our new project."

  canwe "push a copy of [${reference_image}] to a gitlab container registry under our new project"
  skopeo sync --authfile=${HOME}/auth.json --dest-tls-verify=false --src docker --dest docker $reference_image "${GITLAB_REGISTRY}/${GITLAB_USER}/${project_name}/"
  success "pushed a copy of ${reference_image} to a new container repository under project ${project_name}."


  ####################################################
  # CLEANUP

  # delete project
#  canwe "delete our new gitlab project [${project_name}] via cURL"
#  delete_project "${pat_value}" "${GITLAB_HOST}" "${project_id}"
#  success "deleted project."

  # deactivate PAT
  canwe "deactivate our new gitlab PAT [${pat_name}] via cURL"
  deactivate_pat "${pat_value}" "${GITLAB_HOST}"
  success "deactivated PAT ${pat_name}]"

  # remove our kubectl exec test's Role
  #
  # 💡 n.b. we can't delete *both* the Role and the RoleBinding because removing either
  # one drops our ability to remove the other.
  # even a `kubectl delete roles,rolebindings` command appears to delete them serially
  # rather than in parallel.
  canwe "delete the kubeapi role that enabled us to run kubectl exec"
  kubectl -n gitlab delete roles -l bigbang.dso.mil/purpose=gitlab-gluon-script
  success "role and rolebinding removed."

  popd
  rm -rf "${project_name}"

  info "All tests completed successfully."
}

main
