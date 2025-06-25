#!/bin/bash
#
# Add all Helm repos this chart depends on.

helm repo add jetstack https://charts.jetstack.io/
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add gitlab https://charts.gitlab.io/
helm repo add traefik https://helm.traefik.io/traefik
helm repo add haproxy https://haproxytech.github.io/helm-charts
