#!/bin/sh
set -e

################################################################################
# repo
################################################################################
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update >/dev/null 2>&1

################################################################################
# chart
################################################################################
STACK="kube-prometheus"
CHART="prometheus-community/kube-prometheus-stack"
CHART_VERSION="69.8.2"
NAMESPACE="kube-prometheus"

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
values="${script_dir}/values.yml"

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --timeout 10m0s \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION" \
  "$@"
