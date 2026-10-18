#!/bin/sh
set -e

################################################################################
# repo
################################################################################
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server
helm repo update >/dev/null 2>&1

################################################################################
# chart
################################################################################
STACK="metrics-server"
CHART="metrics-server/metrics-server"
CHART_VERSION="3.12.2"
NAMESPACE="metrics-server"

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
