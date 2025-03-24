#!/bin/bash

source scripts/ci/autodevops.sh

echo "CI_ENVIRONMENT_SLUG=${CI_ENVIRONMENT_SLUG}"
echo "CI_COMMIT_SHORT_SHA=${CI_COMMIT_SHORT_SHA}"
echo "HOST_SUFFIX=${HOST_SUFFIX}"
echo "KUBE_INGRESS_BASE_DOMAIN=${KUBE_INGRESS_BASE_DOMAIN}"
echo "DOMAIN=${DOMAIN}"
echo "VARIABLES_FILE=${VARIABLES_FILE}"
echo "KUBE_NAMESPACE=${KUBE_NAMESPACE}"
echo "NAMESPACE=${NAMESPACE}"
echo "RELEASE_NAME=${RELEASE_NAME}"
echo "VCLUSTER_NAME=${VCLUSTER_NAME}"
echo "VCLUSTER_K8S_VERSION=${VCLUSTER_K8S_VERSION}"

create_secret
deploy
wait_for_deploy
check_domain_ip

# Generate variables file
echo "export GITLAB_URL=gitlab-${HOST_SUFFIX}.${KUBE_INGRESS_BASE_DOMAIN}" >> "${VARIABLES_FILE}"
echo "export GITLAB_ROOT_DOMAIN=${HOST_SUFFIX}.${KUBE_INGRESS_BASE_DOMAIN}" >> "${VARIABLES_FILE}"
echo "export REGISTRY_URL=registry-${HOST_SUFFIX}.${KUBE_INGRESS_BASE_DOMAIN}" >> "${VARIABLES_FILE}"
echo "export S3_ENDPOINT=https://minio-${HOST_SUFFIX}.${KUBE_INGRESS_BASE_DOMAIN}" >> "${VARIABLES_FILE}"
kubectl wait pods -n ${NAMESPACE} -l app=toolbox,release=${RELEASE_NAME} --for condition=Ready --timeout=60s
echo "export QA_GITLAB_REVISION=`kubectl exec -i $(kubectl get pods -lrelease=${RELEASE_NAME},app=toolbox -o custom-columns=":metadata.name") -c toolbox -- cat /srv/gitlab/REVISION`" >> "${VARIABLES_FILE}"
