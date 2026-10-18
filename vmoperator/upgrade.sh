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

guard_script="${script_dir}/../scripts/upgrade_guard.sh"
if [ ! -f "$guard_script" ]; then
  guard_script="${script_dir}/scripts/upgrade_guard.sh"
fi

if [ -f "$guard_script" ]; then
  . "$guard_script"
  run_guarded_helm_upgrade "$@"
  if [ -f "${script_dir}/manifests/vmcluster.yaml" ]; then
  kubectl apply -n "$NAMESPACE" -f "${script_dir}/manifests/vmcluster.yaml"
fi
else
  helm upgrade "$STACK" "$CHART" \
    --atomic \
    --create-namespace \
    --install \
    --timeout 5m0s \
    --namespace "$NAMESPACE" \
    --values "$values" \
    --version "$CHART_VERSION" \
    "$@"

  if [ -f "${script_dir}/manifests/vmcluster.yaml" ]; then
  kubectl apply -n "$NAMESPACE" -f "${script_dir}/manifests/vmcluster.yaml"
fi
fi
