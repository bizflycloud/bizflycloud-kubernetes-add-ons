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
STACK="kube-state-metrics"
CHART="prometheus-community/kube-state-metrics"
CHART_VERSION="5.28.0"
NAMESPACE="kube-state-metrics"

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
values="${script_dir}/values.yml"

guard_script="${script_dir}/../scripts/upgrade_guard.sh"
if [ ! -f "$guard_script" ]; then
  guard_script="${script_dir}/scripts/upgrade_guard.sh"
fi

if [ -f "$guard_script" ]; then
  . "$guard_script"
  run_guarded_helm_upgrade "$@"
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

fi
