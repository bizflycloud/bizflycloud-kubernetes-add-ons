#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add sample-charts https://lmq1999.github.io/sample-chart/
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="kube-vmagent"
CHART="sample-charts/kube-vmagent"
CHART_VERSION="0.1.1"
NAMESPACE="bke-obs-stack"
REPO_ENV=$APPLICATION_ENV

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/bizflycloud/bizflycloud-kubernetes-add-ons/$REPO_ENV/kube-vmagent/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --timeout 10m0s\
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION"
