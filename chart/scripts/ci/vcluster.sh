#!/bin/bash

function cluster_connect() {
  if [ -z ${AGENT_NAME+x} ] || [ -z ${AGENT_PROJECT_PATH+x} ]; then
    echo "No AGENT_NAME or AGENT_PROJECT_PATH set, using the default"
  else
    kubectl config get-contexts
    kubectl config use-context ${AGENT_PROJECT_PATH}:${AGENT_NAME}
  fi
}

function vcluster_install() {
  if [ -z "${VCLUSTER_VERSION}" ] || [ "${VCLUSTER_VERSION,,}" == "default" ]; then
    echo "No version specified, using default image version"
  else
    echo "Install vcluster version ${VCLUSTER_VERSION}"
    curl -Lo /tmp/vcluster "https://github.com/loft-sh/vcluster/releases/download/v${VCLUSTER_VERSION}/vcluster-linux-amd64"
    install -c -m 0755 /tmp/vcluster /usr/local/bin
  fi
  vcluster version
}

function vcluster_name() {
  printf ${VCLUSTER_NAME:0:52}
}

function vcluster_create() {
  envsubst '$VCLUSTER_K8S_VERSION' < ./scripts/ci/vcluster.template.yaml > ./vcluster.yaml
  cat vcluster.yaml

  local vcluster_name=$(vcluster_name)
  vcluster create ${vcluster_name} \
    --upgrade \
    --namespace=${vcluster_name} \
    --connect=false \
    --values ./vcluster.yaml

  kubectl annotate namespace ${vcluster_name} janitor/ttl=2d
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
  vcluster delete $(vcluster_name) --delete-configmap --delete-namespace --ignore-not-found
}

function vcluster_info() {
  echo "To connect to the virtual cluster:"
  echo "1. Connect to host cluster via kubectl: ${AGENT_NAME}"
  echo "2. Connect to virtual cluster: vcluster connect $(vcluster_name)"
  echo "3. Open a separate terminal window and run your kubectl and helm commands."
}
