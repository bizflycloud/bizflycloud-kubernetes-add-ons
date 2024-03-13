#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update > /dev/null
REPO_ENV=$APPLICATION_ENV
################################################################################
# chart
################################################################################
STACK="loki"
CHART="grafana/loki-stack"
CHART_VERSION="2.9.9"
NAMESPACE="loki"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
  values="${script_dir}/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/bizflycloud/bizflycloud-kubernetes-add-ons/$REPO_ENV/loki/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --timeout 10m0s\
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION"
