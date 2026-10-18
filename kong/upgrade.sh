#!/bin/sh
set -e

################################################################################
# repo
################################################################################
helm repo add kong https://charts.konghq.com
helm repo update >/dev/null 2>&1

################################################################################
# chart
################################################################################
STACK="kong"
CHART="kong/kong"
CHART_VERSION="2.46.0"
NAMESPACE="kong"

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
