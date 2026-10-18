#!/bin/sh
set -e

################################################################################
# repo
################################################################################
helm repo add kubearmor https://kubearmor.github.io/charts
helm repo update >/dev/null 2>&1

################################################################################
# chart
################################################################################
STACK="kubearmor"
CHART="kubearmor/kubearmor-operator"
CHART_VERSION="v1.5.0"
NAMESPACE="kubearmor"

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
