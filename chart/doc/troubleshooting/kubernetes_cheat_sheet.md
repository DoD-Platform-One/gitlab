---
stage: GitLab Delivery
group: Self Managed
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: Kubernetes cheat sheet
---

{{< details >}}

- Tier: Free, Premium, Ultimate
- Offering: GitLab Self-Managed

{{< /details >}}

This is a list of useful information regarding Kubernetes that the GitLab Support
Team sometimes uses while troubleshooting. GitLab is making this public, so that anyone
can make use of the Support team's collected knowledge

{{< alert type="warning" >}}

These commands **can alter or break** your Kubernetes components so use these at your own risk.

{{< /alert >}}

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

- One can stream logs from all containers at once, similar to the command `gitlab-ctl tail` in a Linux package installation:

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

  ```shell
  # find the pod
  kubectl --namespace gitlab get pods -lapp=toolbox

  # open the Rails console
  kubectl --namespace gitlab exec -it -c toolbox <toolbox-pod-name> -- gitlab-rails console

  # run GitLab check. The output can be confusing and invalid because of the specific structure of GitLab installed via helm chart
  gitlab-rake gitlab:check

  # open console without entering pod
  kubectl exec -it <toolbox-pod-name> -- gitlab-rails console

  # check the status of DB migrations
  kubectl exec -it <toolbox-pod-name> -- gitlab-rake db:migrate:status
  ```

- Troubleshooting **Infrastructure > Kubernetes clusters** integration:

  - Check the output of `kubectl get events -w --all-namespaces`.
  - Check the logs of pods within `gitlab-managed-apps` namespace.

- How to get your [initial administrator password](../installation/deployment.md#initial-login):

  ```shell
  # find the name of the secret containing the password
  kubectl get secrets | grep initial-root
  # decode it
  kubectl get secret <secret-name> -ojsonpath={.data.password} | base64 --decode ; echo
  ```

- How to connect to a GitLab PostgreSQL database.

  ```shell
  kubectl exec -it <toolbox-pod-name> -- gitlab-rails dbconsole --include-password --database main
  ```

- How to get information about Helm installation status:

  ```shell
  helm status <release name>
  ```

- How to update GitLab installed using Helm chart:

  ```shell
  helm repo update

  # get current values and redirect them to yaml file (analogue of gitlab.rb values)
  helm get values <release name> > gitlab.yaml

  # run upgrade itself
  helm upgrade <release name> <chart path> -f gitlab.yaml
  ```

  See also [Updating GitLab by using the Helm chart](../installation/upgrade.md).

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

## Fast-Stats for KubeSOS reports

[KubeSOS](https://gitlab.com/gitlab-com/support/toolbox/kubesos) is a tool that gathers the GitLab cluster configuration and logs from GitLab Cloud Native chart deployments. You can use [fast-stats](https://gitlab.com/gitlab-com/support/toolbox/fast-stats), a tool with minimal memory use, to quickly create and compare performance statistics from and between GitLab logs.

- Run `fast-stats`:

  ```shell
  cut -d  ' ' -f2- <file-name> | grep ^{ | fast-stats
  ```

- List errors:

  ```shell
  cut -d  ' ' -f2- <file-name> | grep ^{ | fast-stats errors
  ```

- Run `fast-stats` top:

  ```shell
  cut -d  ' ' -f2- <file-name> | grep ^{ | fast-stats top
  ```

- Change the number of rows printed. By default, 10 rows are printed.

  ```shell
  cut -d  ' ' -f2- <file-name> | grep ^{ | fast-stats -l <number of rows>
  ```

## Installation of minimal GitLab configuration via minikube on macOS

This section is based on [Developing for Kubernetes with minikube](../development/minikube/_index.md)
and [Helm](../installation/tools.md). Refer
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

- Install the GitLab Helm chart:

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

## Patching the Rails code in the `toolbox` pod

{{< alert type="warning" >}}

This task is not something that should be regularly performed. Use it at your own risk.

{{< /alert >}}

Patching operational GitLab service pods requires building new images, with the modified source code inside. These can _not_ be directly patched.
The [`toolbox` / `task-runner` pod](../charts/gitlab/toolbox/_index.md) has everything needed to operate as a Rails-based pod, without interfering with other normal service operations. You can use it to run independent tasks, and to modify the source code temporarily to perform some tasks.

{{< alert type="note" >}}

If you make any changes using the `toolbox` pod, those will not be persisted if the pod is restarted. They're only present for the life of the container's operation.

{{< /alert >}}

To patch the source code in the `toolbox` pod:

1. Fetch the desired `.patch` file to be applied:

   - Either download the diff of a merge request directly as a [patch file](https://docs.gitlab.com/user/project/merge_requests/reviews/#download-merge-request-changes-as-a-patch-file).
   - Or, fetch the diff directly using `curl`. Replace `<mr_iid>` below with the IID of the merge request, or change the URL to point to a raw snippet:

     ```shell
     curl --output ~/<mr_iid>.patch "https://gitlab.com/gitlab-org/gitlab/-/merge_requests/<mr_iid>.patch"
     ```

1. Patch the local files on the `toolbox` pod:

   ```shell
   cd /srv/gitlab
   busybox patch -p1 -f < ~/<mr_iid>.patch
   ```
