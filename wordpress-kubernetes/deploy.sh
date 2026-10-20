#!/bin/sh
set -e

################################################################################
# repo
################################################################################
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update >/dev/null 2>&1

################################################################################
# chart
################################################################################
STACK="wordpress-kubernetes"
CHART="bitnami/wordpress"
CHART_VERSION="19.0.4"
NAMESPACE="wordpress-kubernetes"

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
