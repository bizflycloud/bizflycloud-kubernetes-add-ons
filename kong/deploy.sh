#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add kong https://charts.konghq.com
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="kong"
CHART="kong/kong"
CHART_VERSION="2.38.0"
NAMESPACE="kong"
REPO_ENV=$APPLICATION_ENV

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/kong/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/bizflycloud/bizflycloud-kubernetes-add-ons/$REPO_ENV/kong/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --timeout 10m0s\
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION"