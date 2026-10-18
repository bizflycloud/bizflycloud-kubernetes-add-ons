#!/bin/sh
set -e

################################################################################
# repo
################################################################################
helm repo add {{HELM_REPO_NAME}} {{HELM_REPO_URL}}
helm repo update >/dev/null 2>&1

################################################################################
# chart
################################################################################
STACK="{{STACK_NAME}}"
CHART="{{CHART_NAME}}"
CHART_VERSION="{{CHART_VERSION}}"
NAMESPACE="{{NAMESPACE}}"

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
