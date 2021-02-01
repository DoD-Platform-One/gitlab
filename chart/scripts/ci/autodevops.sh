#!/bin/bash

# Auto DevOps variables and functions
[[ "$TRACE" ]] && set -x
auto_database_url=postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${CI_ENVIRONMENT_SLUG}-postgres:5432/${POSTGRES_DB}
export DATABASE_URL=${DATABASE_URL-$auto_database_url}
export CI_APPLICATION_REPOSITORY=$CI_REGISTRY_IMAGE/$CI_COMMIT_REF_SLUG
export CI_APPLICATION_TAG=$CI_COMMIT_SHA
export CI_CONTAINER_NAME=ci_job_build_${CI_JOB_ID}
export TILLER_NAMESPACE=$KUBE_NAMESPACE
export STABLE_REPO_URL=${STABLE_REPO_URL-https://charts.helm.sh/stable}

function previousDeployFailed() {
  set +e
  echo "Checking for previous deployment of $CI_ENVIRONMENT_SLUG"
  deployment_status=$(helm status $CI_ENVIRONMENT_SLUG >/dev/null 2>&1)
  status=$?
  # if `status` is `0`, deployment exists, has a status
  if [ $status -eq 0 ]; then
    echo "Previous deployment found, checking status"
    deployment_status=$(helm status $CI_ENVIRONMENT_SLUG | grep ^STATUS | cut -d' ' -f2)
    echo "Previous deployment state: $deployment_status"
    if [[ "$deployment_status" == "FAILED" || "$deployment_status" == "PENDING_UPGRADE" || "$deployment_status" == "PENDING_INSTALL" ]]; then
      status=0;
    else
      status=1;
    fi
  else
    echo "Previous deployment NOT found."
  fi
  set -e
  return $status
}

function crdExists() {
  echo "Checking for existing GitLab Operator CRD"
  kubectl get crd/gitlabs.${CI_ENVIRONMENT_SLUG}.gitlab.com >/dev/null 2>&1
  status=$?
  if [ $status -eq 0 ]; then
    echo "GitLab Operator CRD exists."
  else
    echo "GitLab Operator CRD does NOT exist."
  fi
  return $status
}

function deploy() {
  track="${1-stable}"
  name="$CI_ENVIRONMENT_SLUG"

  local enable_kas=()
  if [[ -n "$KAS_ENABLED" ]]; then
    enable_kas=("--set" "global.kas.enabled=true")
  fi

  if [[ "$track" != "stable" ]]; then
    name="$name-$track"
  fi

  replicas="1"
  service_enabled="false"
  postgres_enabled="$POSTGRES_ENABLED"
  # canary uses stable db
  [[ "$track" == "canary" ]] && postgres_enabled="false"

  env_track=$( echo $track | tr -s  '[:lower:]'  '[:upper:]' )
  env_slug=$( echo ${CI_ENVIRONMENT_SLUG//-/_} | tr -s  '[:lower:]'  '[:upper:]' )

  if [[ "$track" == "stable" ]]; then
    # for stable track get number of replicas from `PRODUCTION_REPLICAS`
    eval new_replicas=\$${env_slug}_REPLICAS
    service_enabled="true"
  else
    # for all tracks get number of replicas from `CANARY_PRODUCTION_REPLICAS`
    eval new_replicas=\$${env_track}_${env_slug}_REPLICAS
  fi
  if [[ -n "$new_replicas" ]]; then
    replicas="$new_replicas"
  fi

  # Use stable images when on the stable branch
  gitlab_version=$(grep 'appVersion:' Chart.yaml | awk '{ print $2}')
  gitlab_version_args=()
  if [[ $CI_COMMIT_BRANCH =~ -stable$ ]] && [[ $gitlab_version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    stable_branch=$(echo "${gitlab_version%.*}-stable" | tr '.' '-')
    gitlab_version_args=(
      "--set" "global.gitlabVersion=${stable_branch}"
      "--set" "global.certificates.image.tag=${stable_branch}"
      "--set" "global.kubectl.image.tag=${stable_branch}"
      "--set" "gitlab.gitaly.image.tag=${stable_branch}"
      "--set" "gitlab.gitlab-shell.image.tag=${stable_branch}"
      "--set" "gitlab.gitlab-exporter.image.tag=${stable_branch}"
      "--set" "registry.image.tag=${stable_branch}"
    )
  fi

  # Cleanup and previous installs, as FAILED and PENDING_UPGRADE will cause errors with `upgrade`
  if [ "$CI_ENVIRONMENT_SLUG" != "production" ] && previousDeployFailed ; then
    echo "Deployment in bad state, cleaning up $CI_ENVIRONMENT_SLUG"
    delete
    cleanup
  fi

  #ROOT_PASSWORD=$(cat /dev/urandom | LC_TYPE=C tr -dc "[:alpha:]" | head -c 16)
  #echo "Generated root login: $ROOT_PASSWORD"
  kubectl create secret generic "${CI_ENVIRONMENT_SLUG}-gitlab-initial-root-password" --from-literal=password=$ROOT_PASSWORD -o yaml --dry-run | kubectl replace --force -f -

  echo "${REVIEW_APPS_EE_LICENSE}" > /tmp/license.gitlab
  kubectl create secret generic "${CI_ENVIRONMENT_SLUG}-gitlab-license" --from-file=license=/tmp/license.gitlab -o yaml --dry-run | kubectl replace --force -f -

  # YAML_FILE=""${KUBE_INGRESS_BASE_DOMAIN//\./-}.yaml"

  if ! crdExists ; then scripts/crdctl create "${CI_ENVIRONMENT_SLUG}" ; fi

  helm repo add gitlab https://charts.gitlab.io/
  helm repo add jetstack https://charts.jetstack.io
  helm dep update .

  WAIT="--wait --timeout 900"

  # Only enable Prometheus on `master`
  PROMETHEUS_INSTALL="false"
  if [ "$CI_COMMIT_REF_NAME" == "master" ]; then
    PROMETHEUS_INSTALL="true"
  fi

  # helm's --set argument dislikes special characters, pass them as YAML
  cat << CIYAML > ci.details.yaml
  ci:
    title: |
      ${CI_COMMIT_TITLE}
    sha: "${CI_COMMIT_SHA}"
    branch: "${CI_COMMIT_REF_NAME}"
    job:
      url: "${CI_JOB_URL}"
    pipeline:
      url: "${CI_PIPELINE_URL}"
CIYAML

  helm upgrade --install \
    $WAIT \
    -f ci.details.yaml \
    --set releaseOverride="$CI_ENVIRONMENT_SLUG" \
    --set global.imagePullPolicy="Always" \
    --set global.hosts.hostSuffix="$HOST_SUFFIX" \
    --set global.hosts.domain="$KUBE_INGRESS_BASE_DOMAIN" \
    --set global.ingress.annotations."external-dns\.alpha\.kubernetes\.io/ttl"="10" \
    --set global.ingress.tls.secretName=helm-charts-win-tls \
    --set global.ingress.configureCertmanager=false \
    --set global.appConfig.initialDefaults.signupEnabled=false \
    --set certmanager.install=false \
    --set prometheus.install=$PROMETHEUS_INSTALL \
    --set gitlab.webservice.maxReplicas=3 \
    --set gitlab.sidekiq.maxReplicas=2 \
    --set gitlab.task-runner.enabled=true \
    --set gitlab.gitlab-shell.maxReplicas=3 \
    --set redis.resources.requests.cpu=100m \
    --set minio.resources.requests.cpu=100m \
    --set global.operator.enabled=true \
    --set gitlab.operator.crdPrefix="$CI_ENVIRONMENT_SLUG" \
    --set global.gitlab.license.secret="$CI_ENVIRONMENT_SLUG-gitlab-license" \
    "${enable_kas[@]}" \
    "${gitlab_version_args[@]}" \
    --namespace="$KUBE_NAMESPACE" \
    --version="$CI_PIPELINE_ID-$CI_JOB_ID" \
    $HELM_EXTRA_ARGS \
    "$name" \
    .
}

function check_kas_status() {
  iteration=0
  kasState=""

  while [ "${kasState[1]}" != "Running" ]; do
    if [ $iteration -eq 0 ]; then
      echo ""
      echo -n "Waiting for KAS deploy to complete.";
    else
      echo -n "."
    fi

    iteration=$((iteration+1))
    kasState=($(kubectl get pods -n "$KUBE_NAMESPACE" | grep "\-kas" | awk '{print $3}'))
    sleep 5;
  done
}

function wait_for_deploy {
  revision=0
  observedRevision=-1
  iteration=0
  while [ "$observedRevision" != "$revision" ]; do
    IFS=$','
    status=($(kubectl get gitlabs.${CI_ENVIRONMENT_SLUG}.gitlab.com "${CI_ENVIRONMENT_SLUG}-operator" -n ${KUBE_NAMESPACE} -o jsonpath='{.status.deployedRevision}{","}{.spec.revision}'))
    unset IFS
    observedRevision=${status[0]}
    revision=${status[1]}
    if [ $iteration -eq 0 ]; then
      echo -n "Waiting for deploy revision ${revision} to complete.";
    else
      echo -n "."
    fi
    iteration=$((iteration+1))
    sleep 5;
  done

  if [[ -n "$KAS_ENABLED" ]]; then
    check_kas_status
  fi

  echo ""
}

function restart_task_runner() {
  # restart the task-runner pods, by deleting them
  # the ReplicaSet of the Deployment will re-create them
  # this ensure we run up-to-date on tags like `master` when there
  # have been no changes to the configuration to warrant a restart
  # via metadata checksum annotations
  kubectl -n ${KUBE_NAMESPACE} delete pods -lapp=task-runner,release=${CI_ENVIRONMENT_SLUG}
  # always "succeed" so not to block.
  return 0
}

function download_chart() {
  mkdir -p chart/

  helm init --client-only --stable-repo-url=${STABLE_REPO_URL}
  helm repo add gitlab https://charts.gitlab.io
  helm repo add jetstack https://charts.jetstack.io

  helm dependency update chart/
  helm dependency build chart/
}

function ensure_namespace() {
  kubectl describe namespace "$KUBE_NAMESPACE" || kubectl create namespace "$KUBE_NAMESPACE"
}

function check_kube_domain() {
  if [ -z ${KUBE_INGRESS_BASE_DOMAIN+x} ]; then
    echo "In order to deploy, KUBE_INGRESS_BASE_DOMAIN must be set as a variable at the group or project level, or manually added in .gitlab-cy.yml"
    false
  else
    true
  fi
}

function check_domain_ip() {
  # Don't run on EKS clusters
  if [[ "$CI_ENVIRONMENT_SLUG" =~ ^eks.* ]]; then
    echo "Not running on EKS cluster"
    return 0
  fi

  # Expect the `DOMAIN` is a wildcard.
  domain_ip=$(nslookup gitlab$DOMAIN 2>/dev/null | grep "Address: \d" | awk '{print $2}')
  if [ -z $domain_ip ]; then
    echo "There was a problem resolving the IP of 'gitlab$DOMAIN'. Be sure you have configured a DNS entry."
    false
  else
    export DOMAIN_IP=$domain_ip
    echo "Found IP for gitlab$DOMAIN: $DOMAIN_IP"
    true
  fi
}

function install_tiller() {
  echo "Checking Tiller..."
  helm init --upgrade --service-account tiller --history-max=${TILLER_HISTORY_MAX} --stable-repo-url=${STABLE_REPO_URL}
  kubectl rollout status -n "$TILLER_NAMESPACE" -w "deployment/tiller-deploy"
  if ! helm version --debug; then
    echo "Failed to init Tiller."
    return 1
  fi
  echo ""
}

function install_external_dns() {
  local provider="${1}"
  local domain_filter="${2}"
  local helm_args=''

  echo "Checking External DNS..."
  release_name="gitlab-external-dns"
  if ! helm status --tiller-namespace "${TILLER_NAMESPACE}" "${release_name}" > /dev/null 2>&1 ; then
    case "${provider}" in
      google)
        # We need to store the credentials in a secret
        kubectl create secret generic "${release_name}-secret" --from-literal="credentials.json=${GOOGLE_CLOUD_KEYFILE_JSON}"
        helm_args=" --set google.project='${GOOGLE_PROJECT_ID}' --set google.serviceAccountSecret='${release_name}-secret'"
        ;;
      aws)
        echo "Installing external-dns, ensure the NodeGroup has the permissions specified in"
        echo "https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/aws.md#iam-permissions"
        ;;
    esac

    helm repo add bitnami https://charts.bitnami.com/bitnami

    helm install bitnami/external-dns \
      -n "${release_name}" \
      --namespace "${TILLER_NAMESPACE}" \
      --set provider="${provider}" \
      --set domainFilters[0]="${domain_filter}" \
      --set txtOwnerId="${TILLER_NAMESPACE}" \
      --set rbac.create="true" \
      --set policy='sync' \
      ${helm_args}
  fi
}

function create_secret() {
  kubectl create secret -n "$KUBE_NAMESPACE" \
    docker-registry gitlab-registry-docker \
    --docker-server="$CI_REGISTRY" \
    --docker-username="$CI_REGISTRY_USER" \
    --docker-password="$CI_REGISTRY_PASSWORD" \
    --docker-email="$GITLAB_USER_EMAIL" \
    -o yaml --dry-run | kubectl replace -n "$KUBE_NAMESPACE" --force -f -
}

function delete() {
  track="${1-stable}"
  name="$CI_ENVIRONMENT_SLUG"

  if [[ "$track" != "stable" ]]; then
    name="$name-$track"
  fi
  helm delete --purge "$name" || true
}

function cleanup() {
  gitlabs=''
  if crdExists ; then
    gitlabs=',gitlabs'
  fi

  kubectl -n "$KUBE_NAMESPACE" get ingress,svc,pdb,hpa,deploy,statefulset,job,pod,secret,configmap,pvc,secret,clusterrole,clusterrolebinding,role,rolebinding,sa,crd${gitlabs} 2>&1 \
    | grep "$CI_ENVIRONMENT_SLUG" \
    | awk '{print $1}' \
    | xargs kubectl -n "$KUBE_NAMESPACE" delete \
    || true
}
