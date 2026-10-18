#!/bin/sh
set -e

################################################################################
# repo
################################################################################
helm repo add vm https://victoriametrics.github.io/helm-charts/
helm repo update >/dev/null 2>&1

################################################################################
# chart
################################################################################
STACK="vmoperator"
CHART="vm/victoria-metrics-operator"
CHART_VERSION="0.38.0"
NAMESPACE="vmoperator"

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

# Install VictoriaMetrics Cluster Custom Resources
if [ -f "${script_dir}/manifests/vmcluster.yaml" ]; then
  kubectl apply -n "$NAMESPACE" -f "${script_dir}/manifests/vmcluster.yaml"
fi
