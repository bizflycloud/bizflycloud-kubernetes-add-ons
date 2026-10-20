#!/bin/sh
set -e

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

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --timeout 10m0s \
  --namespace "$NAMESPACE" \
  --values "$values" \
  "$@"
