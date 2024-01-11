#!/bin/bash

function cluster_connect() {
  if [ -z ${AGENT_NAME+x} ] || [ -z ${AGENT_PROJECT_PATH+x} ]; then
    echo "No AGENT_NAME or AGENT_PROJECT_PATH set, using the default"
  else
    kubectl config get-contexts
    kubectl config use-context ${AGENT_PROJECT_PATH}:${AGENT_NAME}
  fi
}

function vcluster_name() {
  printf ${VCLUSTER_NAME:0:52}
}

function vcluster_create() {
  local vcluster_name=$(vcluster_name)
  vcluster create ${vcluster_name} \
    --upgrade \
    --namespace=${vcluster_name} \
    --kubernetes-version=${VCLUSTER_K8S_VERSION} \
    --connect=false \
    --update-current=false
}

function vcluster_run() {
  vcluster connect $(vcluster_name) -- $@
}

function vcluster_helm_deploy() {
  helm dependency update

  vcluster_run helm upgrade --install \
    gitlab \
    --wait --timeout 600s \
    -f ./scripts/ci/vcluster_helm_values.yaml \
    -f ci.digests.yaml \
    .
}

function vcluster_helm_rollout_status() {
  vcluster_run kubectl rollout status statefulset -l release=gitlab --timeout=300s
  vcluster_run kubectl rollout status deployments -l release=gitlab --timeout=300s
}

function vcluster_delete() {
  vcluster delete $(vcluster_name)
}

function vcluster_info() {
  echo "To connect to the virtual cluster:"
  echo "1. Connect to host cluster via kubectl: ${AGENT_NAME}"
  echo "2. Connect to virtual cluster: vcluster connect $(vcluster_name)"
  echo "3. Open a separate terminal window and run your kubectl and helm commands."
}
