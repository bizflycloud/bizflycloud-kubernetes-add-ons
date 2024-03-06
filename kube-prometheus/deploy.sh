#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="kube-prometheus"
CHART="prometheus-community/kube-prometheus-stack"
CHART_VERSION="55.7.0"
NAMESPACE="kube-prometheus-stack"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/kube-prometheus/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/bizflycloud/bizflycloud-kubernetes-add-ons/master/prometheus-community/kube-prometheus-stack/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --timeout 10m0s\
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION"