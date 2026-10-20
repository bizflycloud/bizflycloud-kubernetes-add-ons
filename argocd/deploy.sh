#!/bin/sh
set -e

################################################################################
# repo
################################################################################
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update >/dev/null 2>&1

################################################################################
# chart
################################################################################
STACK="argocd"
CHART="argo/argo-cd"
CHART_VERSION="7.8.2"
NAMESPACE="argocd"

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
