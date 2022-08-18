---
stage: Systems
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
type: reference
---

# Kubernetes cheat sheet **(FREE SELF)**

This is a list of useful information regarding Kubernetes that the GitLab Support
Team sometimes uses while troubleshooting. GitLab is making this public, so that anyone
can make use of the Support team's collected knowledge

WARNING:
These commands **can alter or break** your Kubernetes components so use these at your own risk.

If you are on a [paid tier](https://about.gitlab.com/pricing/) and are not sure how
to use these commands, it is best to [contact Support](https://about.gitlab.com/support/)
and they will assist you with any issues you are having.

## Generic Kubernetes commands

- How to authorize to your GCP project (can be especially useful if you have projects
  under different GCP accounts):

  ```shell
  gcloud auth login
  ```

- How to access Kubernetes dashboard:

  ```shell
  # for minikube:
  minikube dashboard —url
  # for non-local installations if access via Kubectl is configured:
  kubectl proxy
  ```

- How to SSH to a Kubernetes node and enter the container as root
  <https://github.com/kubernetes/kubernetes/issues/30656>:

  - For GCP, you may find the node name and run `gcloud compute ssh node-name`.
  - List containers using `docker ps`.
  - Enter container using `docker exec --user root -ti container-id bash`.

- How to copy a file from local machine to a pod:

  ```shell
  kubectl cp file-name pod-name:./destination-path
  ```

- What to do with pods in `CrashLoopBackoff` status:

  - Check logs via Kubernetes dashboard.
  - Check logs via Kubectl:

    ```shell
    kubectl logs <webservice pod> -c dependencies
    ```

- How to tail all Kubernetes cluster events in real time:

  ```shell
  kubectl get events -w --all-namespaces
  ```

- How to get logs of the previously terminated pod instance:

  ```shell
  kubectl logs <pod-name> --previous
  ```

  No logs are kept in the containers/pods themselves. Everything is written to `stdout`.
  This is the principle of Kubernetes, read [Twelve-factor app](https://12factor.net/)
  for details.

- How to get cron jobs configured on a cluster

  ```shell
  kubectl get cronjobs
  ```

  When one configures [cron-based backups](../backup-restore/backup.md#cron-based-backup),
  you will be able to see the new schedule here. Some details about the schedules can be found
  in [Running Automated Tasks with a CronJob](https://kubernetes.io/docs/tasks/job/automated-tasks-with-cron-jobs/#creating-a-cron-job)

## GitLab-specific Kubernetes information

- Minimal configuration that can be used to [test a Kubernetes Helm chart](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/620).

- Tailing logs of a separate pod. An example for a `webservice` pod:

  ```shell
  kubectl logs gitlab-webservice-54fbf6698b-hpckq -c webservice
  ```

- Tail and follow all pods that share a label (in this case, `webservice`):

  ```shell
  # all containers in the webservice pods
  kubectl logs -f -l app=webservice --all-containers=true --max-log-requests=50

  # only the webservice containers in all webservice pods
  kubectl logs -f -l app=webservice -c webservice --max-log-requests=50
  ```

- One can stream logs from all containers at once, similar to the Omnibus
  command `gitlab-ctl tail`:

  ```shell
  kubectl logs -f -l release=gitlab --all-containers=true --max-log-requests=100
  ```

- Check all events in the `gitlab` namespace (the namespace name can be different if you
  specified a different one when deploying the Helm chart):

  ```shell
  kubectl get events -w --namespace=gitlab
  ```

- Most of the useful GitLab tools (console, Rake tasks, etc) are found in the toolbox
  pod. You may enter it and run commands inside or run them from the outside.

  NOTE:
  The `task-runner` pod was renamed to `toolbox` in GitLab 14.2 (charts 5.2).

  ```shell
  # find the pod
  kubectl --namespace gitlab get pods -lapp=toolbox

  # enter it
  kubectl exec -it <toolbox-pod-name> -- bash

  # open rails console
  # rails console can be also called from other GitLab pods
  /srv/gitlab/bin/rails console

  # source-style commands should also work
  cd /srv/gitlab && bundle exec rake gitlab:check RAILS_ENV=production

  # run GitLab check. The output can be confusing and invalid because of the specific structure of GitLab installed via helm chart
  /usr/local/bin/gitlab-rake gitlab:check

  # open console without entering pod
  kubectl exec -it <toolbox-pod-name> -- /srv/gitlab/bin/rails console

  # check the status of DB migrations
  kubectl exec -it <toolbox-pod-name> -- /usr/local/bin/gitlab-rake db:migrate:status
  ```

  You can also use `gitlab-rake`, instead of `/usr/local/bin/gitlab-rake`.

- Troubleshooting **Infrastructure > Kubernetes clusters** integration:

  - Check the output of `kubectl get events -w --all-namespaces`.
  - Check the logs of pods within `gitlab-managed-apps` namespace.
  - On the side of GitLab check Sidekiq log and Kubernetes log. When GitLab is installed
    via Helm Chart, `kubernetes.log` can be found inside the Sidekiq pod.

- How to get your initial administrator password <https://docs.gitlab.com/charts/installation/deployment.html#initial-login>:

  ```shell
  # find the name of the secret containing the password
  kubectl get secrets | grep initial-root
  # decode it
  kubectl get secret <secret-name> -ojsonpath={.data.password} | base64 --decode ; echo
  ```

- How to connect to a GitLab PostgreSQL database.

  NOTE:
  The `task-runner` pod was renamed to `toolbox` in GitLab 14.2 (charts 5.2).

  In GitLab 14.2 (chart 5.2) and later:

  ```shell
  kubectl exec -it <toolbox-pod-name> -- /srv/gitlab/bin/rails dbconsole --include-password --database main
  ```

  In GitLab 14.1 (chart 5.1) and earlier:

  ```shell
  kubectl exec -it <task-runner-pod-name> -- /srv/gitlab/bin/rails dbconsole --include-password
  ```

- How to get information about Helm installation status:

  ```shell
  helm status name-of-installation
  ```

- How to update GitLab installed using Helm Chart:

  ```shell
  helm repo upgrade

  # get current values and redirect them to yaml file (analogue of gitlab.rb values)
  helm get values <release name> > gitlab.yaml

  # run upgrade itself
  helm upgrade <release name> <chart path> -f gitlab.yaml
  ```

  See also [Updating GitLab using the Helm Chart](../installation/upgrade.md).

- How to apply changes to GitLab configuration:

  - Modify the `gitlab.yaml` file.
  - Run the following command to apply changes:

    ```shell
    helm upgrade <release name> <chart path> -f gitlab.yaml
    ```

- How to get the manifest for a release. It can be useful because it contains the information about
all Kubernetes resources and dependent charts:

  ```shell
  helm get manifest <release name>
  ```

## Installation of minimal GitLab configuration via minikube on macOS

This section is based on [Developing for Kubernetes with minikube](../development/minikube/index.md)
and [Helm](../installation/tools.md#helm). Refer
to those documents for details.

- Install Kubectl via Homebrew:

  ```shell
  brew install kubernetes-cli
  ```

- Install minikube via Homebrew:

  ```shell
  brew cask install minikube
  ```

- Start minikube and configure it. If minikube cannot start, try running `minikube delete && minikube start`
  and repeat the steps:

  ```shell
  minikube start --cpus 3 --memory 8192 # minimum amount for GitLab to work
  minikube addons enable ingress
  ```

- Install Helm via Homebrew and initialize it:

  ```shell
  brew install helm
  ```

- Copy the [minikube minimum values YAML file](https://gitlab.com/gitlab-org/charts/gitlab/raw/master/examples/values-minikube-minimum.yaml)
  to your workstation:

  ```shell
  curl --output values.yaml "https://gitlab.com/gitlab-org/charts/gitlab/raw/master/examples/values-minikube-minimum.yaml"
  ```

- Find the IP address in the output of `minikube ip` and update the YAML file with
  this IP address.

- Install the GitLab Helm Chart:

  ```shell
  helm repo add gitlab https://charts.gitlab.io
  helm install gitlab -f <path-to-yaml-file> gitlab/gitlab
  ```

  If you want to modify some GitLab settings, you can use the above-mentioned configuration
  as a base and create your own YAML file.

- Monitor the installation progress via `helm status gitlab` and `minikube dashboard`.
  The installation could take up to 20-30 minutes depending on the amount of resources
  on your workstation.

- When all the pods show either a `Running` or `Completed` status, get the GitLab password as
  described in [Initial login](../installation/deployment.md#initial-login),
  and log in to GitLab via the UI. It will be accessible via `https://gitlab.domain`
  where `domain` is the value provided in the YAML file.

<!-- ## Troubleshooting

Include any troubleshooting steps that you can foresee. If you know beforehand what issues
one might have when setting this up, or when something is changed, or on upgrading, it's
important to describe those, too. Think of things that may go wrong and include them here.
This is important to minimize requests for support, and to avoid doc comments with
questions that you know someone might ask.

Each scenario can be a third-level heading, e.g. `### Getting error message X`.
If you have none to add when creating a doc, leave this section in place
but commented out to help encourage others to add to it in the future. -->
