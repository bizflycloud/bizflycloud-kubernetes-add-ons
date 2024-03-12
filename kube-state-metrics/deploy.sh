#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update > /dev/null


################################################################################
# chart
################################################################################
STACK="kube-state-metrics"
CHART="bitnami/kube-state-metrics"
CHART_VERSION="3.8.6"
NAMESPACE="kube-state-metrics"
REPO_ENV=$APPLICATION_ENV

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/kube-state-metrics/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/bizflycloud/bizflycloud-kubernetes-add-ons/$REPO_ENV/kube-state-metrics/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --timeout 10m0s\
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION"
