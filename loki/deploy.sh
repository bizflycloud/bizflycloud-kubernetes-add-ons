#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="loki"
CHART="grafana/loki-stack"
CHART_VERSION="2.9.9"
NAMESPACE="loki-stack"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/loki/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/bizflycloud/bizflycloud-kubernetes-add-ons/master/grafana/loki-stack/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --timeout 10m0s\
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION"