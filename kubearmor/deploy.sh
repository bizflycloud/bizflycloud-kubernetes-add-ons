#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add kubearmor https://kubearmor.github.io/charts
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="kubearmor"
CHART="kubearmor/kubearmor-operator"
CHART_VERSION="v1.0.1"
NAMESPACE="kubearmor"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/kubearmor/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/bizflycloud/bizflycloud-kubernetes-add-ons/master/kubearmor/kubearmor-operator/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --timeout 10m0s\
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION"
