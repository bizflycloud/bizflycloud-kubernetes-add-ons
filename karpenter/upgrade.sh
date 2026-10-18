#!/bin/sh
set -e

################################################################################
# repo
################################################################################
################################################################################
# chart
################################################################################
STACK="karpenter"
NAMESPACE="karpenter"

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
CHART="${script_dir}/helm"
values="${script_dir}/values.yml"

if [ -d "${script_dir}/crds" ]; then
  kubectl apply -f "${script_dir}/crds"
elif [ -d "${CHART}/crds" ]; then
  kubectl apply -f "${CHART}/crds"
fi

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
    "$@"

fi
