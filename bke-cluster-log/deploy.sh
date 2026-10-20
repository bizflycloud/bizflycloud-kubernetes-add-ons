#!/bin/sh
set -e

################################################################################
# repo
################################################################################
helm repo add sample-charts https://lmq1999.github.io/sample-chart/
helm repo update >/dev/null 2>&1

################################################################################
# chart
################################################################################
STACK="bke-cluster-log"
CHART="sample-charts/bke-cluster-log"
CHART_VERSION="1.0.1"
NAMESPACE="bke-cluster-log"

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
