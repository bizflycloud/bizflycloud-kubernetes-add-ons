#!/bin/sh
set -e

################################################################################
# repo
################################################################################
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update >/dev/null 2>&1

################################################################################
# chart
################################################################################
STACK="loki"
CHART="grafana/loki-stack"
CHART_VERSION="2.9.9"
NAMESPACE="loki"

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
