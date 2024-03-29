#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add {{HELM_REPO_NAME}} {{HELM_REPO_URL}}
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="{{STACK_NAME}}"
CHART="{{CHART_NAME}}"
CHART_VERSION="{{CHART_VERSION}}"
NAMESPACE="{{NAMESPACE}}"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/{{STACK_NAME}}/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/bizflycloud/bizflycloud-kubernetes-add-ons/master/{{CHART_NAME}}/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --timeout 10m0s\
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION"
